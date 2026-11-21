import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/switch_command_controller.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';

import '../../support/fake_device_source.dart';
import '../../support/switch_fixtures.dart';

const deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

final start = DateTime.utc(2026, 11, 18, 7, 41);

/// Server time of the `PUT` (its `confirmedAt`).
final DateTime requestedAt = start.add(const Duration(seconds: 1));

CurrentUser user(UserRole role) => CurrentUser(
  id: 'u1',
  email: 'owner@example.com',
  firstName: 'Ola',
  mustChangePassword: false,
  role: role,
);

void main() {
  late FakeDeviceSource devices;
  late FakeCommandSource commands;
  late AppForeground foreground;
  late UserRole role;

  setUp(() {
    devices = FakeDeviceSource();
    commands = FakeCommandSource();
    foreground = AppForeground();
    addTearDown(foreground.dispose);
    role = UserRole.owner;
  });

  ProviderContainer createContainer(FakeAsync async) {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        deviceReadSourceProvider.overrideWithValue(devices),
        deviceCommandSourceProvider.overrideWithValue(commands),
        currentUserProvider.overrideWithValue(user(role)),
        appForegroundProvider.overrideWithValue(foreground),
        clockProvider.overrideWithValue(() => start.add(async.elapsed)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final provider = switchCommandControllerProvider(deviceId, lightEntityId);

  /// Loads [device] into the repository, then keeps the controller alive
  /// and records every state it goes through.
  List<SwitchCommandState> prepare(
    FakeAsync async,
    ProviderContainer container,
    DeviceDetail device,
  ) {
    devices.details[deviceId] = device;
    unawaited(container.read(devicesRepositoryProvider).fetchDevice(deviceId));
    async.flushMicrotasks();
    final states = <SwitchCommandState>[];
    container.listen(provider, (_, next) => states.add(next));
    return states;
  }

  void submit(ProviderContainer container, {required bool on}) =>
      unawaited(container.read(provider.notifier).submit(requestedOn: on));

  int deviceReads() =>
      devices.calls.where((call) => call == 'device:$deviceId').length;

  SwitchCommandResult result(Object? state) => SwitchCommandResult(
    entityId: lightEntityId,
    confirmedAt: requestedAt,
    state: state,
    availability: true,
  );

  group('LEGACY_ESPHOME', () {
    test('a 200 is "the device confirmed the command", then re-read', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final states = prepare(
          async,
          container,
          switchDeviceDetail(mode: 'LEGACY_ESPHOME'),
        );
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();

        expect(commands.calls, [(deviceId, lightEntityId, true)]);
        expect(states, [
          const SwitchSending(requested: true),
          SwitchLegacyConfirmed(state: true, confirmedAt: requestedAt),
        ]);
        expect(deviceReads(), 2);
      });
    });

    test('a body without a boolean state is a failure, not a success', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(mode: 'LEGACY_ESPHOME'));
        commands.result = result(null);

        submit(container, on: true);
        async.flushMicrotasks();

        expect(container.read(provider), isA<SwitchFailed>());
      });
    });

    test('OFF needs no special handling and is confirmed the same way', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(
          async,
          container,
          switchDeviceDetail(mode: 'LEGACY_ESPHOME', lightOn: true),
        );
        commands.result = result(false);

        submit(container, on: false);
        async.flushMicrotasks();

        expect(
          container.read(provider),
          SwitchLegacyConfirmed(state: false, confirmedAt: requestedAt),
        );
      });
    });
  });

  group('GI_EDGE_V1', () {
    test('the optimistic entity write is not a confirmation; a heartbeat '
        'after confirmedAt is', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final states = prepare(async, container, switchDeviceDetail());
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        expect(
          container.read(provider),
          SwitchAwaitingHeartbeat(
            requested: true,
            confirmedAt: requestedAt,
            dryRun: false,
          ),
        );

        // GI Core already wrote the entity optimistically (value true), but
        // the device-level lastSeenAt is still before the command.
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: start,
          relay3: {'output': false, 'commanded': false},
        );
        async.elapse(const Duration(seconds: 5));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());

        // An equal timestamp is not "after" either.
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: requestedAt,
          relay3: {'output': true, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 2));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());

        final heartbeatAt = requestedAt.add(const Duration(seconds: 4));
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: heartbeatAt,
          relay3: {'output': true, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 2));

        expect(
          container.read(provider),
          SwitchHeartbeatObserved(
            requested: true,
            commanded: true,
            output: true,
            seenAt: heartbeatAt,
          ),
        );
        expect(states.whereType<SwitchLegacyConfirmed>(), isEmpty);
        expect(commands.calls, hasLength(1));

        // Polling stops once observed.
        final reads = deviceReads();
        async.elapse(const Duration(seconds: 30));
        expect(deviceReads(), reads);
        expect(container.read(provider), isA<SwitchHeartbeatObserved>());
      });
    });

    test('dry-run: the response carries the OLD state and is never used; '
        'the heartbeat shows commanded on, output off', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(dryRun: true));
        // GI Core returns the entity's old value in dry-run.
        commands.result = result(false);

        submit(container, on: true);
        async.flushMicrotasks();
        expect(
          container.read(provider),
          SwitchAwaitingHeartbeat(
            requested: true,
            confirmedAt: requestedAt,
            dryRun: true,
          ),
        );

        final heartbeatAt = requestedAt.add(const Duration(seconds: 3));
        devices.details[deviceId] = switchDeviceDetail(
          dryRun: true,
          lastSeenAt: heartbeatAt,
          relay3: {'output': false, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 2));

        expect(
          container.read(provider),
          SwitchDryRunRecorded(
            requested: true,
            commanded: true,
            output: false,
            seenAt: heartbeatAt,
          ),
        );
      });
    });

    test('a heartbeat sent before the command was applied (old commanded) '
        'is not the report; waiting goes on', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        // Heartbeat after confirmedAt, before the command poll applied it.
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: requestedAt.add(const Duration(seconds: 1)),
          relay3: {'output': false, 'commanded': false},
        );
        async.elapse(const Duration(seconds: 10));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());

        final heartbeatAt = requestedAt.add(const Duration(seconds: 12));
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: heartbeatAt,
          relay3: {'output': true, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 2));
        expect(
          container.read(provider),
          SwitchHeartbeatObserved(
            requested: true,
            commanded: true,
            output: true,
            seenAt: heartbeatAt,
          ),
        );
      });
    });

    test('at the deadline a heartbeat that never matched is reported as it '
        'is, not as a timeout', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(dryRun: true));
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        final heartbeatAt = requestedAt.add(const Duration(seconds: 3));
        devices.details[deviceId] = switchDeviceDetail(
          dryRun: true,
          lastSeenAt: heartbeatAt,
          relay3: {'output': false, 'commanded': false},
        );
        async.elapse(const Duration(seconds: 44));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());
        async.elapse(const Duration(seconds: 1));
        expect(
          container.read(provider),
          SwitchDryRunRecorded(
            requested: true,
            commanded: false,
            output: false,
            seenAt: heartbeatAt,
          ),
        );
      });
    });

    test('the wait outlasts a 30 s heartbeat interval plus two polls', () {
      expect(
        SwitchCommandController.heartbeatTimeout,
        greaterThan(
          const Duration(seconds: 30) +
              SwitchCommandController.heartbeatPollInterval * 2,
        ),
      );
    });

    test('a heartbeat without relay diagnostics reports them as unknown', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(reportLight: false));
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        final heartbeatAt = requestedAt.add(const Duration(seconds: 1));
        devices.details[deviceId] = switchDeviceDetail(
          lastSeenAt: heartbeatAt,
          reportLight: false,
        );
        async.elapse(const Duration(seconds: 2));

        expect(
          container.read(provider),
          SwitchHeartbeatObserved(
            requested: true,
            commanded: null,
            output: null,
            seenAt: heartbeatAt,
          ),
        );
      });
    });

    test('without a newer heartbeat it times out after 45 s', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        // Re-reads keep answering with a heartbeat from before the command.
        devices.details[deviceId] = switchDeviceDetail(
          lightOn: true,
          lastSeenAt: start,
        );
        async.elapse(const Duration(seconds: 44));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());
        expect(deviceReads(), greaterThan(5));

        async.elapse(const Duration(seconds: 1));
        expect(
          container.read(provider),
          SwitchTimedOut(requested: true, confirmedAt: requestedAt),
        );

        // Nothing more is read or sent until the user asks.
        final reads = deviceReads();
        async.elapse(const Duration(minutes: 1));
        expect(deviceReads(), reads);
        expect(commands.calls, hasLength(1));

        unawaited(container.read(provider.notifier).refresh());
        async.flushMicrotasks();
        expect(deviceReads(), reads + 1);
        expect(container.read(provider), const SwitchIdle());
      });
    });

    test('failed re-reads keep waiting', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        devices.detailFailure = const ApiFailure.timeout();
        async.elapse(const Duration(seconds: 10));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());

        devices.detailFailure = null;
        devices.details[deviceId] = switchDeviceDetail(
          lastSeenAt: requestedAt.add(const Duration(seconds: 9)),
          relay3: {'output': true, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 10));
        expect(container.read(provider), isA<SwitchHeartbeatObserved>());
      });
    });

    test('re-reads go through the open details screen', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        container.listen(deviceDetailProvider(deviceId), (_, _) {});
        async.flushMicrotasks();
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        final heartbeatAt = requestedAt.add(const Duration(seconds: 1));
        devices.details[deviceId] = switchDeviceDetail(
          lastSeenAt: heartbeatAt,
          lightOn: true,
          relay3: {'output': true, 'commanded': true},
        );
        async.elapse(const Duration(seconds: 2));

        expect(container.read(provider), isA<SwitchHeartbeatObserved>());
        expect(
          container.read(deviceDetailProvider(deviceId)).data?.value.lastSeenAt,
          heartbeatAt,
        );
      });
    });
  });

  group('failures', () {
    final failures = <String, ApiFailure>{
      'HEATING_SUSPENDED': const ApiFailure.domain(
        statusCode: 409,
        code: 'HEATING_SUSPENDED',
      ),
      'ENTITY_DISABLED': const ApiFailure.domain(
        statusCode: 409,
        code: 'ENTITY_DISABLED',
      ),
      'ENTITY_NOT_WRITABLE': const ApiFailure.domain(
        statusCode: 422,
        code: 'ENTITY_NOT_WRITABLE',
      ),
      'DEVICE_ENTITY_NOT_FOUND': const ApiFailure.notFound(
        code: 'DEVICE_ENTITY_NOT_FOUND',
      ),
      'DEVICE_OFFLINE': const ApiFailure.server(
        statusCode: 503,
        errorCode: 'DEVICE_OFFLINE',
      ),
      'ESPHOME_DEVICE_UNREACHABLE': const ApiFailure.server(
        statusCode: 503,
        errorCode: 'ESPHOME_DEVICE_UNREACHABLE',
      ),
      'ESPHOME_COMMAND_REJECTED': const ApiFailure.server(
        statusCode: 502,
        errorCode: 'ESPHOME_COMMAND_REJECTED',
      ),
      'ESPHOME_COMMAND_UNCONFIRMED': const ApiFailure.server(
        statusCode: 502,
        errorCode: 'ESPHOME_COMMAND_UNCONFIRMED',
      ),
      'ESPHOME_COMMAND_TIMEOUT': const ApiFailure.server(
        statusCode: 504,
        errorCode: 'ESPHOME_COMMAND_TIMEOUT',
      ),
      'HTTP_403': const ApiFailure.forbidden(code: 'HTTP_403'),
      'no answer': const ApiFailure.timeout(),
    };
    const unknownOutcome = {
      'ESPHOME_COMMAND_REJECTED',
      'ESPHOME_COMMAND_UNCONFIRMED',
      'ESPHOME_COMMAND_TIMEOUT',
      'no answer',
    };

    for (final MapEntry(key: name, value: failure) in failures.entries) {
      for (final mode in ['LEGACY_ESPHOME', 'GI_EDGE_V1']) {
        test('$name ($mode): failed, device re-read, no retry', () {
          fakeAsync((async) {
            final container = createContainer(async);
            prepare(async, container, switchDeviceDetail(mode: mode));
            commands.failure = failure;

            submit(container, on: true);
            async.flushMicrotasks();

            final state = container.read(provider);
            expect(state, SwitchFailed(requested: true, failure: failure));
            expect(
              (state as SwitchFailed).outcomeUnknown,
              unknownOutcome.contains(name),
            );
            expect(deviceReads(), 2);
            async.elapse(const Duration(minutes: 2));
            expect(commands.calls, hasLength(1));
            expect(container.read(provider), state);
          });
        });
      }
    }

    test('a re-read failing after the command failure keeps the failure', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        commands.failure = const ApiFailure.server(
          statusCode: 503,
          errorCode: 'DEVICE_OFFLINE',
        );
        devices.detailFailure = const ApiFailure.unreachable();

        submit(container, on: true);
        async.flushMicrotasks();

        expect(container.read(provider), isA<SwitchFailed>());
      });
    });
  });

  group('guards', () {
    test('a second submit while one is in flight is ignored', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(mode: 'LEGACY_ESPHOME'));
        final gate = Completer<void>();
        commands
          ..gate = gate.future
          ..result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        submit(container, on: true);
        submit(container, on: false);
        container.read(provider.notifier).dismiss();
        unawaited(container.read(provider.notifier).refresh());
        async.flushMicrotasks();
        expect(commands.calls, hasLength(1));
        expect(container.read(provider), const SwitchSending(requested: true));

        gate.complete();
        async.flushMicrotasks();
        expect(container.read(provider), isA<SwitchLegacyConfirmed>());
      });
    });

    test('while awaiting a heartbeat a submit is ignored', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        submit(container, on: false);
        async.flushMicrotasks();

        expect(commands.calls, hasLength(1));
        expect(container.read(provider), isA<SwitchAwaitingHeartbeat>());
      });
    });

    test('without device data nothing is sent', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(provider, (_, _) {});

        submit(container, on: true);
        async.flushMicrotasks();

        expect(commands.calls, isEmpty);
        expect(
          container.read(provider),
          SwitchLocked(Locked(const [LockReason.staleData])),
        );
      });
    });

    test('stale data locks the switch before anything is sent', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());
        async.elapse(const Duration(seconds: 11));

        submit(container, on: true);
        async.flushMicrotasks();

        expect(commands.calls, isEmpty);
        expect(
          (container.read(provider) as SwitchLocked).reason,
          LockReason.staleData,
        );
      });
    });

    test('ON while suspended is locked; OFF is sent', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(
          async,
          container,
          switchDeviceDetail(
            mode: 'LEGACY_ESPHOME',
            heatingSuspended: true,
            lightOn: true,
          ),
        );
        commands.result = result(false);

        submit(container, on: true);
        async.flushMicrotasks();
        expect(
          (container.read(provider) as SwitchLocked).reason,
          LockReason.suspendedOnRequest,
        );

        submit(container, on: false);
        async.flushMicrotasks();
        expect(container.read(provider), isA<SwitchLegacyConfirmed>());
        expect(commands.calls, [(deviceId, lightEntityId, false)]);
      });
    });

    test('a view-only role sends nothing', () {
      role = UserRole.user;
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail());

        submit(container, on: true);
        async.flushMicrotasks();

        expect(commands.calls, isEmpty);
        expect(
          (container.read(provider) as SwitchLocked).reason,
          LockReason.notOwnerAdmin,
        );
      });
    });

    test('the heating relay is never switched from the app', () {
      fakeAsync((async) {
        final container = createContainer(async);
        devices.details[deviceId] = switchDeviceDetail();
        unawaited(
          container.read(devicesRepositoryProvider).fetchDevice(deviceId),
        );
        async.flushMicrotasks();
        final relay = switchCommandControllerProvider(
          deviceId,
          'ent-relay-boiler',
        );
        container.listen(relay, (_, _) {});

        unawaited(container.read(relay.notifier).submit(requestedOn: false));
        async.flushMicrotasks();

        expect(commands.calls, isEmpty);
        expect(
          (container.read(relay) as SwitchLocked).reason,
          LockReason.heatingOrPumpRelay,
        );
      });
    });

    test('dismiss clears a finished outcome', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, switchDeviceDetail(mode: 'LEGACY_ESPHOME'));
        commands.result = result(true);

        submit(container, on: true);
        async.flushMicrotasks();
        container.read(provider.notifier).dismiss();

        expect(container.read(provider), const SwitchIdle());
      });
    });

    test('disposing while waiting stops polling', () {
      fakeAsync((async) {
        final container = createContainer(async);
        devices.details[deviceId] = switchDeviceDetail();
        unawaited(
          container.read(devicesRepositoryProvider).fetchDevice(deviceId),
        );
        async.flushMicrotasks();
        commands.result = result(true);
        final subscription = container.listen(provider, (_, _) {});

        submit(container, on: true);
        async.flushMicrotasks();
        subscription.close();
        async.flushMicrotasks();
        final reads = deviceReads();
        async.elapse(const Duration(minutes: 1));

        expect(deviceReads(), reads);
      });
    });
  });

  group('relayIndexOf', () {
    DeviceEntity entity(String sourceName) => DeviceEntity(
      id: 'e',
      displayName: 'e',
      sourceName: sourceName,
      readable: true,
      writable: true,
      availability: true,
      enabled: true,
    );

    test('reads relay_N and relayN', () {
      expect(relayIndexOf(entity('relay_1')), 1);
      expect(relayIndexOf(entity('relay2')), 2);
      expect(relayIndexOf(entity(' RELAY_12 ')), 12);
    });

    test('anything else is not a relay', () {
      expect(relayIndexOf(entity('heating_relay')), isNull);
      expect(relayIndexOf(entity('relay')), isNull);
      expect(relayIndexOf(entity('diagnostics.relay1Commanded')), isNull);
    });
  });

  group('reportedSwitchState', () {
    DeviceEntity light(DeviceDetail device) =>
        device.entities.firstWhere((e) => e.id == lightEntityId);

    DeviceDetail withLightSeenAt(DeviceDetail device, DateTime at) =>
        device.copyWith(
          entities: [
            for (final e in device.entities)
              if (e.id == lightEntityId) e.copyWith(lastSeenAt: at) else e,
          ],
        );

    test('GI Edge relay: the reported output, never the optimistic entity '
        'value (after a timeout and refresh the toggle must not read ON)', () {
      final device = switchDeviceDetail(
        lightOn: true,
        relay3: {'output': false, 'commanded': false},
      );
      expect(reportedSwitchState(device, light(device)), isFalse);
    });

    test('GI Edge dry-run: the commanded state (output stays off)', () {
      final device = switchDeviceDetail(
        dryRun: true,
        relay3: {'output': false, 'commanded': true},
      );
      expect(reportedSwitchState(device, light(device)), isTrue);
    });

    test('GI Edge without relay diagnostics: the entity value only when no '
        'write followed the last heartbeat', () {
      final heartbeat = DateTime.utc(2026, 11, 18, 7, 40, 30);
      final base = switchDeviceDetail(lightOn: true, reportLight: false);
      final sameHeartbeat = withLightSeenAt(
        base,
        heartbeat.add(const Duration(milliseconds: 40)),
      );
      expect(reportedSwitchState(sameHeartbeat, light(sameHeartbeat)), isTrue);
      expect(
        switchValueUnconfirmed(sameHeartbeat, light(sameHeartbeat)),
        isFalse,
      );

      final queued = withLightSeenAt(
        base,
        heartbeat.add(const Duration(seconds: 10)),
      );
      expect(switchValueUnconfirmed(queued, light(queued)), isTrue);
      expect(reportedSwitchState(queued, light(queued)), isNull);

      final neverSeen = base.copyWith(lastSeenAt: null);
      expect(switchValueUnconfirmed(neverSeen, light(neverSeen)), isTrue);
    });

    test('LEGACY_ESPHOME: the entity value as it is', () {
      final device = switchDeviceDetail(
        mode: 'LEGACY_ESPHOME',
        lightOn: true,
        relay3: {'output': false, 'commanded': false},
      );
      expect(reportedSwitchState(device, light(device)), isTrue);
      expect(switchValueUnconfirmed(device, light(device)), isFalse);
    });
  });

  group('states', () {
    test('only sending and awaiting are busy', () {
      final at = DateTime.utc(2026);
      expect(const SwitchSending(requested: true).isBusy, isTrue);
      expect(
        SwitchAwaitingHeartbeat(
          requested: true,
          confirmedAt: at,
          dryRun: false,
        ).isBusy,
        isTrue,
      );
      for (final state in <SwitchCommandState>[
        const SwitchIdle(),
        SwitchLocked(Locked(const [LockReason.staleData])),
        SwitchLegacyConfirmed(state: true, confirmedAt: at),
        SwitchHeartbeatObserved(
          requested: true,
          commanded: true,
          output: true,
          seenAt: at,
        ),
        SwitchDryRunRecorded(
          requested: true,
          commanded: true,
          output: false,
          seenAt: at,
        ),
        SwitchTimedOut(requested: true, confirmedAt: at),
        const SwitchFailed(requested: true, failure: ApiFailure.timeout()),
      ]) {
        expect(state.isBusy, isFalse, reason: '$state');
        expect(state, isNot(equals(const SwitchSending(requested: true))));
        expect(state.toString(), isNotEmpty);
        expect(state.hashCode, isA<int>());
      }
    });
  });
}
