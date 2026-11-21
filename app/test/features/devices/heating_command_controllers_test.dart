import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/heating_suspension_controller.dart';
import 'package:gi_home/src/features/devices/application/strategy_edit_controller.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';

import '../../support/fake_device_source.dart';
import '../../support/heating_fixtures.dart';
import '../../support/switch_fixtures.dart';

const deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

final start = DateTime.utc(2026, 11, 18, 7, 41);

/// Server time of the `PATCH` (its `updatedAt`).
final DateTime patchedAt = start.add(const Duration(seconds: 1));

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
    commands = FakeCommandSource()
      ..suspendResult = (suspended) =>
          patchedDevice(updatedAt: patchedAt, suspended: suspended);
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

  void load(FakeAsync async, ProviderContainer container, DeviceDetail d) {
    devices.details[deviceId] = d;
    unawaited(container.read(devicesRepositoryProvider).fetchDevice(deviceId));
    async.flushMicrotasks();
  }

  int deviceReads() =>
      devices.calls.where((call) => call == 'device:$deviceId').length;

  group('HeatingSuspensionController', () {
    final provider = heatingSuspensionControllerProvider(deviceId);

    List<SuspensionState> prepare(
      FakeAsync async,
      ProviderContainer container,
      DeviceDetail device,
    ) {
      load(async, container, device);
      final states = <SuspensionState>[];
      container.listen(provider, (_, next) => states.add(next));
      return states;
    }

    void submit(ProviderContainer container, {required bool suspend}) =>
        unawaited(container.read(provider.notifier).submit(suspend: suspend));

    test('suspend sends ONLY the flag, is never optimistic and polls until '
        'GI Core reports it (async side effects)', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final states = prepare(async, container, heatingDetail());

        submit(container, suspend: true);
        async.flushMicrotasks();
        expect(commands.suspendCalls, [(deviceId, true)]);
        expect(states, [
          const SuspensionSending(suspend: true),
          SuspensionAwaiting(suspend: true, requestedAt: patchedAt),
        ]);

        // The first re-read still shows the old flag: keep waiting.
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(deviceReads(), 2);
        expect(container.read(provider), isA<SuspensionAwaiting>());

        // The flag is set, the heartbeat is older than the PATCH.
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: start,
          relays: [true, false, false],
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          const SuspendApplied(relays: RelayReport.awaitingHeartbeat),
        );

        // A heartbeat after the PATCH reports the outputs off.
        final heartbeat = patchedAt.add(const Duration(seconds: 5));
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: heartbeat,
          relays: [false, false, false],
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          SuspendApplied(
            relays: RelayReport.outputsOff,
            heartbeatAt: heartbeat,
          ),
        );

        // Polling stopped.
        final reads = deviceReads();
        async.elapse(const Duration(minutes: 1));
        expect(deviceReads(), reads);
      });
    });

    test('GI Edge: a heartbeat with every relay commanded off but an '
        'output still on is reported', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        final heartbeat = patchedAt.add(const Duration(seconds: 1));
        submit(container, suspend: true);
        async.flushMicrotasks();
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: heartbeat,
          relays: [true],
          commanded: [false],
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          SuspendApplied(relays: RelayReport.outputOn, heartbeatAt: heartbeat),
        );
      });
    });

    test('GI Edge: a heartbeat sent before the OFF commands were applied '
        '(commanded still on) is not the report', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        submit(container, suspend: true);
        async.flushMicrotasks();
        final early = patchedAt.add(const Duration(seconds: 1));
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: early,
          relays: [true, false],
        );
        async.elapse(HeatingSuspensionController.pollInterval * 3);
        expect(
          container.read(provider),
          const SuspendApplied(relays: RelayReport.awaitingHeartbeat),
        );

        final later = patchedAt.add(const Duration(seconds: 9));
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: later,
          relays: [false, false],
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          SuspendApplied(relays: RelayReport.outputsOff, heartbeatAt: later),
        );
      });
    });

    test('GI Edge: at the deadline a heartbeat still commanding on is '
        'reported as it is', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        submit(container, suspend: true);
        async.flushMicrotasks();
        final heartbeat = patchedAt.add(const Duration(seconds: 1));
        devices.details[deviceId] = heatingDetail(
          heatingSuspended: true,
          lastSeenAt: heartbeat,
          relays: [true],
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        async.elapse(HeatingSuspensionController.heartbeatTimeout);
        expect(
          container.read(provider),
          SuspendApplied(relays: RelayReport.outputOn, heartbeatAt: heartbeat),
        );
      });
    });

    test('GI Edge: no heartbeat within the TTL', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        submit(container, suspend: true);
        async.flushMicrotasks();
        devices.details[deviceId] = heatingDetail(heatingSuspended: true);
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(container.read(provider).isBusy, isTrue);
        async.elapse(HeatingSuspensionController.heartbeatTimeout);
        expect(
          container.read(provider),
          const SuspendApplied(relays: RelayReport.noHeartbeat),
        );
      });
    });

    test('LEGACY_ESPHOME: no relay claim once the flag is set', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail(mode: 'LEGACY_ESPHOME'));
        submit(container, suspend: true);
        async.flushMicrotasks();
        devices.details[deviceId] = heatingDetail(
          mode: 'LEGACY_ESPHOME',
          heatingSuspended: true,
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          const SuspendApplied(relays: RelayReport.notApplicable),
        );
      });
    });

    test('the flag never shows: timed out, not assumed', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        submit(container, suspend: true);
        async.elapse(HeatingSuspensionController.confirmTimeout);
        expect(
          container.read(provider),
          const SuspensionTimedOut(suspend: true),
        );
        final reads = deviceReads();
        async.elapse(const Duration(minutes: 1));
        expect(deviceReads(), reads);
      });
    });

    test('suspend is allowed on stale data (safe direction)', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail(connectivity: 'STALE'));
        submit(container, suspend: true);
        async.flushMicrotasks();
        expect(commands.suspendCalls, [(deviceId, true)]);
        async.elapse(const Duration(minutes: 1));
      });
    });

    test('resume waits for the flag AND the restored base mode (async '
        'reconcile)', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final states = prepare(
          async,
          container,
          heatingDetail(heatingSuspended: true),
        );
        submit(container, suspend: false);
        async.flushMicrotasks();
        expect(commands.suspendCalls, [(deviceId, false)]);

        // Flag cleared, the reconcile has not restored the mode yet.
        devices.details[deviceId] = heatingDetail(
          effective: strategyJson(55, 4, 'OFF'),
        );
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(container.read(provider), isA<SuspensionAwaiting>());

        devices.details[deviceId] = heatingDetail();
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(states.last, const ResumeApplied(strategyRestored: true));
      });
    });

    test('resume: the mode not restored within the window is said so', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail(heatingSuspended: true));
        submit(container, suspend: false);
        async.flushMicrotasks();
        devices.details[deviceId] = heatingDetail(
          effective: strategyJson(55, 4, 'OFF'),
        );
        async.elapse(HeatingSuspensionController.confirmTimeout);
        expect(
          container.read(provider),
          const ResumeApplied(strategyRestored: false),
        );
      });
    });

    test('resume without a base strategy needs only the flag', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(
          async,
          container,
          heatingDetail(heatingSuspended: true, base: null),
        );
        submit(container, suspend: false);
        async.flushMicrotasks();
        devices.details[deviceId] = heatingDetail(base: null);
        async.elapse(HeatingSuspensionController.pollInterval);
        expect(
          container.read(provider),
          const ResumeApplied(strategyRestored: true),
        );
      });
    });

    test('resume is locked on stale or missing data; nothing is sent', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(provider, (_, _) {});
        submit(container, suspend: false);
        async.flushMicrotasks();
        expect(
          container.read(provider),
          SuspensionLocked(Locked(const [LockReason.staleData])),
        );
        load(
          async,
          container,
          heatingDetail(heatingSuspended: true, connectivity: 'OFFLINE'),
        );
        submit(container, suspend: false);
        async.flushMicrotasks();
        expect(container.read(provider), isA<SuspensionLocked>());
        expect(commands.suspendCalls, isEmpty);
      });
    });

    test('USER and SERVICE are locked out of both directions', () {
      for (final r in [UserRole.user, UserRole.service]) {
        fakeAsync((async) {
          role = r;
          final container = createContainer(async);
          prepare(async, container, heatingDetail(heatingSuspended: true));
          submit(container, suspend: true);
          async.flushMicrotasks();
          expect(
            (container.read(provider) as SuspensionLocked).reason,
            LockReason.notOwnerAdmin,
          );
          submit(container, suspend: false);
          async.flushMicrotasks();
          expect(container.read(provider), isA<SuspensionLocked>());
          expect(commands.suspendCalls, isEmpty);
        });
      }
    });

    test('a failure is shown, the device re-read, nothing retried; a '
        'submit while busy is ignored', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        final gate = Completer<void>();
        commands.gate = gate.future;
        submit(container, suspend: true);
        submit(container, suspend: true);
        async.flushMicrotasks();
        expect(commands.suspendCalls, hasLength(1));

        const failure = ApiFailure.forbidden(code: 'HTTP_403');
        commands.failure = failure;
        gate.complete();
        async.flushMicrotasks();
        expect(
          container.read(provider),
          const SuspensionFailed(suspend: true, failure: failure),
        );
        expect(deviceReads(), 2);
        async.elapse(const Duration(minutes: 1));
        expect(commands.suspendCalls, hasLength(1));
      });
    });

    test('refresh and dismiss forget a finished outcome', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        commands.failure = const ApiFailure.timeout();
        submit(container, suspend: true);
        async.flushMicrotasks();
        unawaited(container.read(provider.notifier).refresh());
        async.flushMicrotasks();
        expect(container.read(provider), const SuspensionIdle());

        submit(container, suspend: true);
        async.flushMicrotasks();
        container.read(provider.notifier).dismiss();
        expect(container.read(provider), const SuspensionIdle());
      });
    });
  });

  group('StrategyEditController', () {
    final provider = strategyEditControllerProvider(deviceId);
    const draft = ControlStrategy(
      targetTemperatureCelsius: 60,
      hysteresisCelsius: 3,
      mode: ControlStrategyMode.manual,
    );
    const saved = ControlStrategyUpdateResult(
      configurationVersion: 8,
      controlStrategy: draft,
      baseControlStrategy: draft,
    );

    List<StrategyEditState> prepare(
      FakeAsync async,
      ProviderContainer container,
      DeviceDetail device,
    ) {
      load(async, container, device);
      final states = <StrategyEditState>[];
      container.listen(provider, (_, next) => states.add(next));
      return states;
    }

    void submit(ProviderContainer container, StrategyBaseline from) =>
        unawaited(
          container
              .read(provider.notifier)
              .submit(startedFrom: from, draft: draft),
        );

    test('re-reads, then PATCHes all three fields and reports base and '
        'effective', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final states = prepare(async, container, heatingDetail());
        commands.strategyResult = saved;

        submit(container, StrategyBaseline.of(heatingDetail()));
        async.flushMicrotasks();

        expect(commands.strategyCalls, [(deviceId, draft)]);
        expect(states, [
          const StrategyEditChecking(),
          const StrategyEditSaving(),
          const StrategyEditSaved(result: saved, suspended: false),
        ]);
        // The re-read before, and one after.
        expect(deviceReads(), 3);
      });
    });

    test('a schedule bumping configurationVersion is not a conflict', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        commands.strategyResult = saved;
        final from = StrategyBaseline.of(heatingDetail());
        devices.details[deviceId] = heatingDetail(
          effective: strategyJson(21, 1, 'AUTO'),
          transform: (json) => {...json, 'configurationVersion': 1234},
        );
        submit(container, from);
        async.flushMicrotasks();
        expect(container.read(provider), isA<StrategyEditSaved>());
      });
    });

    test('base changed elsewhere: conflict, nothing sent; reapplying '
        'against the current values saves', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        commands.strategyResult = saved;
        final from = StrategyBaseline.of(heatingDetail());
        devices.details[deviceId] = heatingDetail(
          base: strategyJson(50, 4, 'AUTO'),
        );

        submit(container, from);
        async.flushMicrotasks();
        final state = container.read(provider) as StrategyEditConflict;
        expect(state.conflict.fields, [StrategyConflictField.target]);
        expect(commands.strategyCalls, isEmpty);

        submit(container, state.conflict.current);
        async.flushMicrotasks();
        expect(commands.strategyCalls, [(deviceId, draft)]);
        expect(container.read(provider), isA<StrategyEditSaved>());
      });
    });

    test('suspended elsewhere: conflict on the suspension alone', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        devices.details[deviceId] = heatingDetail(heatingSuspended: true);
        submit(container, StrategyBaseline.of(heatingDetail()));
        async.flushMicrotasks();
        final state = container.read(provider) as StrategyEditConflict;
        expect(state.conflict.fields, [StrategyConflictField.suspended]);
        expect(commands.strategyCalls, isEmpty);
      });
    });

    test('saving while suspended says the effective mode stays OFF', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final suspended = heatingDetail(heatingSuspended: true);
        prepare(async, container, suspended);
        commands.strategyResult = saved;
        submit(container, StrategyBaseline.of(suspended));
        async.flushMicrotasks();
        expect(
          container.read(provider),
          const StrategyEditSaved(result: saved, suspended: true),
        );
      });
    });

    test('stale data after the re-read locks the edit', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        devices.details[deviceId] = heatingDetail(connectivity: 'STALE');
        submit(container, StrategyBaseline.of(heatingDetail()));
        async.flushMicrotasks();
        expect(container.read(provider), isA<StrategyEditLocked>());
        expect(commands.strategyCalls, isEmpty);
      });
    });

    test('a failed re-read or PATCH is shown (400, 404); reset clears', () {
      fakeAsync((async) {
        final container = createContainer(async);
        prepare(async, container, heatingDetail());
        const notFound = ApiFailure.notFound(code: 'DEVICE_NOT_FOUND');
        devices.detailFailure = notFound;
        submit(container, StrategyBaseline.of(heatingDetail()));
        async.flushMicrotasks();
        expect(container.read(provider), const StrategyEditFailed(notFound));

        devices.detailFailure = null;
        const invalid = ApiFailure.validation(
          details: {
            'hysteresisCelsius': ['must not be less than 1'],
          },
        );
        commands.failure = invalid;
        submit(container, StrategyBaseline.of(heatingDetail()));
        async.flushMicrotasks();
        expect(container.read(provider), const StrategyEditFailed(invalid));

        container.read(provider.notifier).reset();
        expect(container.read(provider), const StrategyEditIdle());
      });
    });
  });
}
