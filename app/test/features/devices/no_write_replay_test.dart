import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/network_change_source.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/application/network_recovery.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/heating_suspension_controller.dart';
import 'package:gi_home/src/features/devices/application/switch_command_controller.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_core_adapter.dart';
import '../../support/fake_device_source.dart';
import '../../support/fake_network_change_source.dart';
import '../../support/fixtures.dart';
import '../../support/heating_fixtures.dart';
import '../../support/switch_fixtures.dart';
import '../../support/test_app.dart';

const deviceId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';

/// Changing network, losing the connection and finding the appliance under
/// a new address must never send a write again. A command goes out once per
/// user action; what came of it is read from the device, never by sending
/// it again.
void main() {
  final start = DateTime.utc(2026, 11, 18, 7, 41);

  late SharedPreferencesWithCache prefs;
  late FakeDeviceSource devices;
  late FakeCommandSource commands;
  late FakeNetworkChangeSource network;
  late AppForeground foreground;

  /// What answers on the network: the saved address, and `gi-home.local`
  /// (the same appliance, found by its name).
  late MockCoreAdapter core;
  late Set<String> downHosts;

  setUp(() async {
    prefs = await inMemoryPreferences(profile: testProfile);
    devices = FakeDeviceSource(deviceList: fixtureDevices());
    commands = FakeCommandSource()
      ..suspendResult = (suspended) => patchedDevice(
        updatedAt: start.add(const Duration(seconds: 1)),
        suspended: suspended,
      );
    network = FakeNetworkChangeSource();
    foreground = AppForeground();
    downHosts = {};
    core = MockCoreAdapter({
      'GET /api/v1/health/live': (request) {
        if (downHosts.contains(request.uri.host)) refuseConnection(request);
        return jsonReply({'status': 'ok'});
      },
      'GET /api/v1/setup/status': (request) => jsonReply(initializedSetup),
    });
    addTearDown(foreground.dispose);
    addTearDown(network.close);
  });

  ProviderContainer createContainer(FakeAsync async) {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceReadSourceProvider.overrideWithValue(devices),
        deviceCommandSourceProvider.overrideWithValue(commands),
        currentUserProvider.overrideWithValue(
          const CurrentUser(
            id: 'u1',
            email: 'owner@example.com',
            firstName: 'Ola',
            mustChangePassword: false,
            role: UserRole.owner,
          ),
        ),
        appForegroundProvider.overrideWithValue(foreground),
        clockProvider.overrideWithValue(() => start.add(async.elapsed)),
        networkChangeSourceProvider.overrideWithValue(network),
        connectionLadderProvider.overrideWithValue(
          ConnectionLadder(
            probe: ApplianceProbe(
              clientInfo: const ClientInfo(
                appVersion: '0.1.0',
                platform: 'test',
              ),
              httpClientAdapter: core,
            ),
            resolver: const StaticHostResolver({'gi-home.local'}),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The app as the user has it: the recovery running, the details screen
  /// and the list polling.
  ProviderContainer openApp(FakeAsync async, DeviceDetail detail) {
    final container = createContainer(async);
    devices.details[deviceId] = detail;
    container
      ..listen(networkRecoveryProvider, (_, _) {})
      ..listen(deviceListProvider, (_, _) {})
      ..listen(deviceDetailProvider(deviceId), (_, _) {});
    async.flushMicrotasks();
    return container;
  }

  /// Lets the debounce pass and the search for the appliance finish.
  void settle(FakeAsync async) {
    async
      ..elapse(const Duration(seconds: 1))
      ..flushMicrotasks()
      ..elapse(const Duration(seconds: 5))
      ..flushMicrotasks();
  }

  void expectOnlyReadsOnTheNetwork() {
    expect(
      core.requests.map((r) => r.method).toSet(),
      everyElement('GET'),
      reason: 'the search for the appliance only reads',
    );
  }

  group('heating suspension', () {
    final provider = heatingSuspensionControllerProvider(deviceId);

    test('a request lost to a network change is not sent again, whatever the '
        'network does next', () {
      fakeAsync((async) {
        final container = openApp(async, heatingDetail());
        container.listen(provider, (_, _) {});
        final gate = Completer<void>();
        commands.gate = gate.future;

        unawaited(container.read(provider.notifier).submit(suspend: true));
        async.flushMicrotasks();
        expect(commands.suspendCalls, [(deviceId, true)]);
        expect(container.read(provider), isA<SuspensionSending>());

        // The phone leaves the Wi-Fi while the request is in flight, and
        // the request dies with a connection error.
        network.wifiToMobile();
        async.elapse(const Duration(milliseconds: 600));
        commands.failure = const ApiFailure.unreachable();
        gate.complete();
        async.flushMicrotasks();
        expect(container.read(provider), isA<SuspensionFailed>());

        // Back on Wi-Fi, then the appliance turns up under its name.
        commands.gate = null;
        downHosts.add('10.0.2.2');
        network.noneToWifi();
        settle(async);
        expect(
          container.read(applianceProfileProvider)!.baseUrl,
          'http://gi-home.local',
          reason: 'the appliance was rebound to its new address',
        );
        network.wifiToOtherWifi();
        settle(async);
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(
          commands.suspendCalls,
          hasLength(1),
          reason:
              'one request for one user action, before and after '
              'the rebind',
        );
        expect(commands.calls, isEmpty);
        expect(commands.strategyCalls, isEmpty);
        expectOnlyReadsOnTheNetwork();
      });
    });

    test('a request that went through is confirmed by polling, not by '
        'repeating it, while the network changes', () {
      fakeAsync((async) {
        final container = openApp(async, heatingDetail());
        container.listen(provider, (_, _) {});

        unawaited(container.read(provider.notifier).submit(suspend: true));
        async.flushMicrotasks();
        expect(container.read(provider), isA<SuspensionAwaiting>());

        network.wifiToMobile();
        async.elapse(const Duration(seconds: 1));
        downHosts.add('10.0.2.2');
        network.wifiToOtherWifi();
        settle(async);
        async.elapse(const Duration(minutes: 3));
        async.flushMicrotasks();

        expect(commands.suspendCalls, hasLength(1));
        expect(
          devices.calls.where((c) => c == 'device:$deviceId').length,
          greaterThan(2),
          reason: 'the outcome is read from the device',
        );
        expectOnlyReadsOnTheNetwork();
      });
    });

    test('each user action is one request: a second tap is a second '
        'action', () {
      fakeAsync((async) {
        final container = openApp(async, heatingDetail());
        container.listen(provider, (_, _) {});
        commands.failure = const ApiFailure.unreachable();

        unawaited(container.read(provider.notifier).submit(suspend: true));
        async.flushMicrotasks();
        network.wifiToMobile();
        settle(async);
        expect(commands.suspendCalls, hasLength(1));

        commands.failure = null;
        unawaited(container.read(provider.notifier).submit(suspend: true));
        async.flushMicrotasks();
        network.noneToWifi();
        settle(async);

        expect(commands.suspendCalls, hasLength(2));
      });
    });
  });

  group('switch command', () {
    final provider = switchCommandControllerProvider(deviceId, lightEntityId);

    test('a command lost to a network change is not sent again', () {
      fakeAsync((async) {
        final container = openApp(async, switchDeviceDetail());
        container.listen(provider, (_, _) {});
        final gate = Completer<void>();
        commands.gate = gate.future;

        unawaited(container.read(provider.notifier).submit(requestedOn: true));
        async.flushMicrotasks();
        expect(commands.calls, [(deviceId, lightEntityId, true)]);
        expect(container.read(provider), isA<SwitchSending>());

        network.wifiToMobile();
        async.elapse(const Duration(milliseconds: 600));
        commands.failure = const ApiFailure.timeout();
        gate.complete();
        async.flushMicrotasks();
        expect(container.read(provider), isA<SwitchFailed>());

        commands.gate = null;
        downHosts.add('10.0.2.2');
        network.wifiToOtherWifi();
        settle(async);
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(commands.calls, hasLength(1));
        expect(commands.suspendCalls, isEmpty);
        expect(commands.strategyCalls, isEmpty);
        expectOnlyReadsOnTheNetwork();
      });
    });

    test('a command waiting for its heartbeat is not repeated by a network '
        'change', () {
      fakeAsync((async) {
        final container = openApp(async, switchDeviceDetail());
        container.listen(provider, (_, _) {});
        commands.result = SwitchCommandResult(
          entityId: lightEntityId,
          confirmedAt: start.add(const Duration(seconds: 1)),
          state: true,
          availability: true,
        );

        unawaited(container.read(provider.notifier).submit(requestedOn: true));
        async.flushMicrotasks();
        network.wifiToMobile();
        async.elapse(const Duration(seconds: 1));
        network.noneToWifi();
        settle(async);
        async.elapse(const Duration(minutes: 3));
        async.flushMicrotasks();

        expect(commands.calls, hasLength(1));
        expectOnlyReadsOnTheNetwork();
      });
    });
  });
}
