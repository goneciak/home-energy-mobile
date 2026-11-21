import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/home/application/heating_card_notifier.dart';
import 'package:gi_home/src/features/home/application/home_dashboard.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';

import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';

/// Records how many detail requests run at the same time.
class _ConcurrencySource extends FakeDeviceSource {
  new({super.deviceList, super.roomList, super.details});

  int inFlight = 0;
  int maxInFlight = 0;

  @override
  Future<DeviceDetail> device(String id) async {
    inFlight++;
    if (inFlight > maxInFlight) maxInFlight = inFlight;
    try {
      return await super.device(id);
    } finally {
      inFlight--;
    }
  }
}

void main() {
  late _ConcurrencySource source;
  late AppForeground foreground;

  const heatingIds = ['heat-1', 'heat-2', 'heat-3', 'heat-4', 'heat-5'];

  ProviderContainer createContainer(FakeAsync async) {
    final start = DateTime.utc(2026, 11, 18, 7, 41);
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        deviceReadSourceProvider.overrideWithValue(source),
        currentUserProvider.overrideWithValue(null),
        appForegroundProvider.overrideWithValue(foreground),
        clockProvider.overrideWithValue(() => start.add(async.elapsed)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Home with the cards of [ids] on screen: each card widget watches its
  /// own provider (the dashboard never does).
  Map<String, ProviderSubscription<PolledData<DeviceDetail>>> showHome(
    ProviderContainer container, {
    List<String> ids = heatingIds,
  }) {
    container.listen(homeDashboardProvider, (_, _) {});
    return {
      for (final id in ids)
        id: container.listen(heatingCardProvider(id), (_, _) {}),
    };
  }

  /// Lets the list load and the cards start.
  void settle(FakeAsync async) {
    for (var i = 0; i < 3; i++) {
      async
        ..flushMicrotasks()
        ..elapse(Duration.zero);
    }
  }

  int detailCalls([String? id]) => source.calls
      .where((c) => id == null ? c.startsWith('device:') : c == 'device:$id')
      .length;

  setUp(() {
    source = _ConcurrencySource(
      deviceList: [
        // The recorded devices: none of them heats.
        ...fixtureDevices(),
        for (final id in heatingIds)
          listedDevice({
            'id': id,
            'name': id,
            'connectivityState': 'ONLINE',
            'heatingRelayEntityId': 'ent-relay-boiler',
          }),
        // A disabled heating device is listed, but gets no card.
        listedDevice({
          'id': 'heat-off',
          'name': 'heat-off',
          'enabled': false,
          'heatingRelayEntityId': 'ent-relay-boiler',
        }),
      ],
      roomList: fixtureRooms(),
      details: {
        for (final id in heatingIds)
          id: fixtureDetail({...entityRichDetailJson(), 'id': id}),
      },
    );
    foreground = AppForeground();
    addTearDown(foreground.dispose);
  });

  test('the dashboard alone fetches no details', () {
    fakeAsync((async) {
      final container = createContainer(async);
      container.listen(homeDashboardProvider, (_, _) {});
      settle(async);
      async.elapse(const Duration(minutes: 1));

      expect(detailCalls(), 0);
      expect(source.calls, contains('devices'));
      final dashboard = container.read(homeDashboardProvider);
      expect(dashboard.heatingCards, isEmpty);
      expect(
        dashboard.condition!.limitedReasons,
        isNot(contains(LimitedDataReason.heatingDetailsFailed)),
      );
    });
  });

  test('only cards on screen are fetched, at most 3 at a time', () {
    fakeAsync((async) {
      final pending = Completer<void>();
      source.detailGate = pending.future;
      final container = createContainer(async);
      showHome(container);
      settle(async);

      // Five cards, three requests running, two waiting for a slot.
      expect(source.inFlight, 3);
      expect(detailCalls(), 3);

      pending.complete();
      async.flushMicrotasks();
      expect(source.maxInFlight, 3);
      expect(source.calls.where((c) => c.startsWith('device:')).toSet(), {
        for (final id in heatingIds) 'device:$id',
      });
      final dashboard = container.read(homeDashboardProvider);
      expect(dashboard.heatingCards.keys, unorderedEquals(heatingIds));
      for (final card in dashboard.heatingCards.values) {
        expect(card.data, isNotNull);
        expect(card.error, isNull);
      }
      expect(
        dashboard.condition!.limitedReasons,
        isNot(contains(LimitedDataReason.heatingDetailsFailed)),
      );
    });
  });

  test('one card on screen: list 2/min plus that card 4/min', () {
    fakeAsync((async) {
      final container = createContainer(async);
      showHome(container, ids: ['heat-1']);
      settle(async);
      final listBefore = source.calls.where((c) => c == 'devices').length;
      final cardBefore = detailCalls();

      async.elapse(const Duration(minutes: 1));

      expect(source.calls.where((c) => c == 'devices').length - listBefore, 2);
      expect(detailCalls() - cardBefore, 4);
      expect(detailCalls(), detailCalls('heat-1'));
    });
  });

  test('polls every 15 s; a tick is skipped while a request runs', () {
    fakeAsync((async) {
      final container = createContainer(async);
      showHome(container);
      settle(async);
      expect(detailCalls('heat-1'), 1);

      async.elapse(const Duration(seconds: 14));
      expect(detailCalls('heat-1'), 1);
      async.elapse(const Duration(seconds: 1));
      expect(detailCalls('heat-1'), 2);
      expect(source.maxInFlight, lessThanOrEqualTo(3));

      // A request that hangs: no new one is sent while it runs.
      final pending = Completer<void>();
      source.detailGate = pending.future;
      async.elapse(const Duration(seconds: 15));
      final hanging = detailCalls();
      async.elapse(const Duration(minutes: 1));
      expect(detailCalls(), hanging);

      source.detailGate = null;
      pending.complete();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 15));
      expect(detailCalls(), greaterThan(hanging));
      expect(source.maxInFlight, lessThanOrEqualTo(3));
    });
  });

  test('a failed card limits the condition and backs off', () {
    fakeAsync((async) {
      final container = createContainer(async);
      showHome(container);
      settle(async);

      source.detailFailure = const ApiFailure.timeout();
      async.elapse(const Duration(seconds: 15));

      final dashboard = container.read(homeDashboardProvider);
      final card = dashboard.heatingCards['heat-1']!;
      expect(card.error, isA<TimeoutFailure>());
      expect(card.data, isNotNull, reason: 'the last good details are kept');
      expect(dashboard.condition!.level, ConditionLevel.limitedData);
      expect(
        dashboard.condition!.limitedReasons,
        contains(LimitedDataReason.heatingDetailsFailed),
      );

      // Backoff: the next attempt comes after 5 s, not 15 s.
      final failedAt = detailCalls('heat-1');
      source.detailFailure = null;
      async.elapse(const Duration(seconds: 5));
      expect(detailCalls('heat-1'), failedAt + 1);
      expect(
        container.read(homeDashboardProvider).condition!.limitedReasons,
        isNot(contains(LimitedDataReason.heatingDetailsFailed)),
      );
    });
  });

  test('a card out of view stops polling; its last result still counts', () {
    fakeAsync((async) {
      final container = createContainer(async);
      final cards = showHome(container, ids: ['heat-1', 'heat-2']);
      settle(async);
      source.detailFailure = const ApiFailure.timeout();
      async.elapse(const Duration(seconds: 15));
      source.detailFailure = null;

      // heat-1 is scrolled away right after its failed request.
      cards['heat-1']!.close();
      async.flushMicrotasks();
      final away = detailCalls('heat-1');
      async.elapse(const Duration(minutes: 2));

      expect(detailCalls('heat-1'), away);
      expect(detailCalls('heat-2'), greaterThan(away));
      final dashboard = container.read(homeDashboardProvider);
      expect(dashboard.heatingCards['heat-1']!.error, isA<TimeoutFailure>());
      expect(
        dashboard.condition!.limitedReasons,
        contains(LimitedDataReason.heatingDetailsFailed),
      );

      // Back in view: fetched again, and the condition recovers.
      showHome(container, ids: ['heat-1']);
      settle(async);
      expect(detailCalls('heat-1'), away + 1);
      expect(
        container.read(homeDashboardProvider).condition!.limitedReasons,
        isNot(contains(LimitedDataReason.heatingDetailsFailed)),
      );
    });
  });

  test('a card back in view with fresh details waits for the next tick', () {
    fakeAsync((async) {
      final container = createContainer(async);
      final cards = showHome(container, ids: ['heat-1']);
      settle(async);
      expect(detailCalls('heat-1'), 1);

      cards['heat-1']!.close();
      async.elapse(const Duration(seconds: 5));
      final back = showHome(container, ids: ['heat-1']);
      settle(async);
      expect(detailCalls('heat-1'), 1, reason: 'details are 5 s old');
      expect(back['heat-1']!.read().data, isNotNull);
      expect(back['heat-1']!.read().isRefreshing, isFalse);

      async.elapse(const Duration(seconds: 15));
      expect(detailCalls('heat-1'), 2);

      back['heat-1']!.close();
      async.elapse(const Duration(seconds: 20));
      showHome(container, ids: ['heat-1']);
      settle(async);
      expect(detailCalls('heat-1'), 3, reason: 'details are 20 s old');
    });
  });

  test('stops in the background and refreshes once on return', () {
    fakeAsync((async) {
      final container = createContainer(async);
      showHome(container);
      settle(async);
      final before = detailCalls();

      foreground.value = false;
      async.elapse(const Duration(minutes: 5));
      expect(detailCalls(), before);

      foreground.value = true;
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(detailCalls(), before + heatingIds.length);
    });
  });

  test('stops while Home is not visible', () {
    fakeAsync((async) {
      final container = createContainer(async);
      final cards = showHome(container);
      settle(async);
      final before = detailCalls();

      // A covering route or another tab pauses the cards' subscriptions.
      for (final card in cards.values) {
        card.pause();
      }
      async.elapse(const Duration(minutes: 5));
      expect(detailCalls(), before);

      for (final card in cards.values) {
        card.resume();
      }
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(detailCalls(), before + heatingIds.length);
    });
  });

  test('a device that stops heating loses its card', () {
    fakeAsync((async) {
      final container = createContainer(async);
      showHome(container);
      settle(async);
      expect(container.read(homeDashboardProvider).heatingCards, hasLength(5));

      source.deviceList = [
        for (final device in source.deviceList)
          if (device.id == 'heat-1')
            device.copyWith(heatingRelayEntityId: null)
          else
            device,
      ];
      async.elapse(const Duration(seconds: 30));

      final dashboard = container.read(homeDashboardProvider);
      expect(dashboard.heatingCards.keys, isNot(contains('heat-1')));
      expect(
        hasHeatingCard(
          dashboard.devices.data!.value.firstWhere((d) => d.id == 'heat-1'),
        ),
        isFalse,
      );
    });
  });
}
