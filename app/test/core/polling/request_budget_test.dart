import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/polling_budget.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/heating_suspension_controller.dart';
import 'package:gi_home/src/features/home/application/heating_card_notifier.dart';
import 'package:gi_home/src/features/home/application/home_dashboard.dart';

import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';
import '../../support/heating_fixtures.dart';
import '../../support/switch_fixtures.dart';

/// The request budget of one phone (docs/load-budget.md): what each screen
/// sends to GI Core, counted on the fake device source with fake time. The
/// cadences are the production ones, so making a poller faster fails here.
void main() {
  final start = DateTime.utc(2026, 11, 18, 7, 41);
  const minute = Duration(minutes: 1);
  const homeBudget = PollingBudget.homeRequestsPerMinute;

  late FakeDeviceSource source;
  late AppForeground foreground;

  void useHeatingDevices(int count) {
    final ids = [for (var i = 1; i <= count; i++) 'heat-$i'];
    source = FakeDeviceSource(
      deviceList: [
        ...fixtureDevices(),
        for (final id in ids)
          listedDevice({
            'id': id,
            'name': id,
            'connectivityState': 'ONLINE',
            'heatingRelayEntityId': 'ent-relay-boiler',
          }),
      ],
      roomList: fixtureRooms(),
      details: {
        for (final id in ids)
          id: fixtureDetail({...entityRichDetailJson(), 'id': id}),
      },
    );
  }

  ProviderContainer createContainer(
    FakeAsync async, {
    FakeCommandSource? commands,
  }) {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        deviceReadSourceProvider.overrideWithValue(source),
        if (commands != null)
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
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Home with every heating card on screen.
  void showHome(ProviderContainer container, int cards) {
    container.listen(homeDashboardProvider, (_, _) {});
    for (var i = 1; i <= cards; i++) {
      container.listen(heatingCardProvider('heat-$i'), (_, _) {});
    }
  }

  void settle(FakeAsync async) {
    for (var i = 0; i < 3; i++) {
      async
        ..flushMicrotasks()
        ..elapse(Duration.zero);
    }
  }

  /// Requests sent in each of the next [minutes] minutes.
  List<int> perMinute(FakeAsync async, int minutes) {
    final counts = <int>[];
    for (var i = 0; i < minutes; i++) {
      final before = source.calls.length;
      async.elapse(minute);
      counts.add(source.calls.length - before);
    }
    return counts;
  }

  double average(List<int> counts) =>
      counts.reduce((a, b) => a + b) / counts.length;

  int peak(List<int> counts) => counts.reduce((a, b) => a > b ? a : b);

  setUp(() {
    useHeatingDevices(1);
    foreground = AppForeground();
    addTearDown(foreground.dispose);
  });

  group('Home', () {
    for (final cards in [1, 2, 3, 4, 5, 8]) {
      test('with $cards heating cards sends at most $homeBudget requests '
          'a minute', () {
        useHeatingDevices(cards);
        fakeAsync((async) {
          final container = createContainer(async);
          showHome(container, cards);
          settle(async);

          final counts = perMinute(async, 10);

          // The average is the budget; a single minute may be one request
          // over where the cadences fall on the minute marks.
          expect(average(counts), lessThanOrEqualTo(homeBudget));
          expect(peak(counts), lessThanOrEqualTo(homeBudget + 1));
          expect(
            average(counts),
            closeTo(PollingBudget.homeRequestsPerMinuteFor(cards), 1),
            reason: 'the documented rate is the real one',
          );
        });
      });
    }

    test('sends nothing in the background', () {
      useHeatingDevices(3);
      fakeAsync((async) {
        final container = createContainer(async);
        showHome(container, 3);
        settle(async);

        foreground.value = false;
        async.flushMicrotasks();
        final before = source.calls.length;
        async.elapse(const Duration(minutes: 10));

        expect(source.calls.length, before);
      });
    });

    test('an unreachable appliance is probed, not polled', () {
      useHeatingDevices(3);
      fakeAsync((async) {
        final container = createContainer(async);
        showHome(container, 3);
        settle(async);
        source
          ..devicesFailure = const ApiFailure.unreachable()
          ..roomsFailure = const ApiFailure.unreachable()
          ..detailFailure = const ApiFailure.unreachable();
        async.elapse(const Duration(seconds: 30));

        final counts = perMinute(async, 10);

        // Backoff 5, 10, 30, 60 s shared by every poller of the appliance:
        // far below the healthy rate.
        expect(average(counts), lessThan(3));
        expect(peak(counts), lessThanOrEqualTo(homeBudget));
      });
    });

    test('Retry-After lowers the rate and never raises it', () {
      useHeatingDevices(3);
      fakeAsync((async) {
        final container = createContainer(async);
        showHome(container, 3);
        settle(async);
        const limited = ApiFailure.rateLimited(
          retryAfter: Duration(seconds: 60),
        );
        source
          ..devicesFailure = limited
          ..detailFailure = limited;
        async.elapse(const Duration(seconds: 30));

        final counts = perMinute(async, 10);

        expect(average(counts), lessThanOrEqualTo(2));
      });
    });
  });

  group('device details', () {
    const id = 'heat-1';

    test('send 12 requests a minute while in use, 4 once idle', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        settle(async);

        final active = perMinute(async, 1);
        expect(active.single, closeTo(12, 1));

        // Two minutes without a touch is the idle threshold.
        async.elapse(PollingBudget.deviceDetailIdleAfter);
        final idle = perMinute(async, 5);
        expect(
          average(idle),
          closeTo(PollingBudget.perMinute(PollingBudget.deviceDetailIdle), 1),
        );
        expect(average(idle), lessThanOrEqualTo(5));
      });
    });

    test('send nothing in the background', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        settle(async);

        foreground.value = false;
        async.flushMicrotasks();
        final before = source.calls.length;
        async.elapse(const Duration(minutes: 10));

        expect(source.calls.length, before);
      });
    });
  });

  group('after a command', () {
    const id = 'heat-1';

    test('the confirmation poll is a short burst that ends with the '
        'command', () {
      fakeAsync((async) {
        final commands = FakeCommandSource()
          ..suspendResult = (suspended) => patchedDevice(
            updatedAt: start.add(const Duration(seconds: 1)),
            suspended: suspended,
          );
        // The device never reports the change: the command times out.
        source.details[id] = heatingDetail();
        final container = createContainer(async, commands: commands);
        final provider = heatingSuspensionControllerProvider(id);
        container.listen(provider, (_, _) {});
        settle(async);
        final before = source.calls.length;

        unawaited(container.read(provider.notifier).submit(suspend: true));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 3));
        final burst = source.calls.length - before;

        // One read every 2 s for at most the confirmation window.
        const window = HeatingSuspensionController.confirmTimeout;
        final allowance =
            window.inSeconds / PollingBudget.postCommandPoll.inSeconds + 2;
        expect(burst, greaterThan(0));
        expect(burst, lessThanOrEqualTo(allowance));
        expect(commands.suspendCalls, hasLength(1));

        // Settled: nothing more is sent.
        final settled = source.calls.length;
        async.elapse(const Duration(minutes: 5));
        expect(source.calls.length, settled);
      });
    });
  });
}
