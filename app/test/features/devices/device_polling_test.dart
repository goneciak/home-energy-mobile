import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/rooms_notifier.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';

import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';

void main() {
  late FakeDeviceSource source;
  late AppForeground foreground;

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

  int count(String call) => source.calls.where((c) => c == call).length;

  setUp(() {
    source = FakeDeviceSource(
      deviceList: fixtureDevices(),
      roomList: fixtureRooms(),
      details: {fixtureDetail().id: fixtureDetail()},
    );
    foreground = AppForeground();
    addTearDown(foreground.dispose);
  });

  group('device list', () {
    test('loads at once, then every 30 s while watched', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();

        final state = container.read(deviceListProvider);
        expect(state.data!.value, hasLength(3));
        expect(state.error, isNull);
        expect(state.isRefreshing, isFalse);
        expect(count('devices'), 1);

        async.elapse(const Duration(seconds: 29));
        expect(count('devices'), 1);
        async.elapse(const Duration(seconds: 1));
        expect(count('devices'), 2);
      });
    });

    test('a failed refresh keeps the last good list next to the error', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();
        final good = container.read(deviceListProvider).data;

        source.devicesFailure = const ApiFailure.unreachable();
        async.elapse(const Duration(seconds: 30));

        final failed = container.read(deviceListProvider);
        expect(failed.data, same(good));
        expect(failed.error, isA<UnreachableFailure>());

        // Backoff: the next attempt comes after 5 s and clears the error.
        source.devicesFailure = null;
        async.elapse(const Duration(seconds: 5));
        final recovered = container.read(deviceListProvider);
        expect(recovered.error, isNull);
        expect(recovered.data!.fetchedAt, isNot(good!.fetchedAt));
      });
    });

    test('stops in the background and refreshes once on return', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();

        foreground.value = false;
        async.elapse(const Duration(minutes: 5));
        expect(count('devices'), 1);

        foreground.value = true;
        async.elapse(const Duration(milliseconds: 300));
        expect(count('devices'), 2);
      });
    });

    test('stops while no listener is active (covered screen)', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final subscription = container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();

        subscription.pause();
        async.elapse(const Duration(minutes: 5));
        expect(count('devices'), 1);

        subscription.resume();
        async.elapse(const Duration(milliseconds: 300));
        expect(count('devices'), 2);
      });
    });

    test('pull-to-refresh joins a refresh already in flight', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();

        final notifier = container.read(deviceListProvider.notifier);
        unawaited(notifier.refresh());
        unawaited(notifier.refresh());
        async.flushMicrotasks();

        expect(count('devices'), 2);
      });
    });

    test('a new screen starts from the cached list', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final first = container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();
        final good = container.read(deviceListProvider).data;
        first.close();
        async.elapse(Duration.zero);

        container.listen(deviceListProvider, (_, _) {});
        expect(
          container.read(deviceListProvider),
          PolledData(data: good, isRefreshing: true),
        );
        async.flushMicrotasks();
      });
    });
  });

  group('device detail', () {
    final id = fixtureDetail().id;

    test('polls every 5 s and keeps the last good details on error', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        async.flushMicrotasks();
        final good = container.read(deviceDetailProvider(id)).data;
        expect(good!.value.id, id);

        async.elapse(const Duration(seconds: 5));
        expect(count('device:$id'), 2);

        source.detailFailure = const ApiFailure.timeout();
        async.elapse(const Duration(seconds: 5));
        final failed = container.read(deviceDetailProvider(id));
        expect(failed.error, isA<TimeoutFailure>());
        expect(failed.data!.value.id, id);
      });
    });

    test('a removed device drops the shown details', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        async.flushMicrotasks();

        source.details.clear();
        async.elapse(const Duration(seconds: 5));

        final state = container.read(deviceDetailProvider(id));
        expect(state.data, isNull);
        expect(state.error, isA<NotFoundFailure>());

        // No more requests for a deleted device, also not after a resume.
        async.elapse(const Duration(minutes: 5));
        foreground
          ..update(AppLifecycleState.paused)
          ..update(AppLifecycleState.resumed);
        async.elapse(const Duration(minutes: 1));
        expect(count('device:$id'), 2);

        // An explicit retry still asks.
        unawaited(container.read(deviceDetailProvider(id).notifier).refresh());
        async.flushMicrotasks();
        expect(count('device:$id'), 3);
      });
    });
  });

  group('device detail while the user is idle (plan §11)', () {
    final id = fixtureDetail().id;
    int runs() => count('device:$id');

    test('15 s after 2 min without interaction, 5 s again on the next', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        async.flushMicrotasks();
        final notifier = container.read(deviceDetailProvider(id).notifier);
        expect(runs(), 1);

        // A touch at 1:42 keeps the 5 s cadence until 3:42.
        async.elapse(const Duration(seconds: 102));
        notifier.userActive();
        expect(runs(), 21);
        async.elapse(const Duration(seconds: 118));
        expect(runs(), 45, reason: 'every 5 s up to 3:40');

        // Idle from 3:42: the run due at 3:45 moves to 3:55, then every 15 s.
        async.elapse(const Duration(seconds: 62));
        expect(runs(), 49, reason: 'at 3:55, 4:10, 4:25 and 4:40');
        final idleData = container.read(deviceDetailProvider(id)).data!;
        expect(
          notifier.freshnessOf(idleData.fetchedAt),
          same(FreshnessPolicy.deviceDetailIdle),
        );

        // A touch at 4:48 (5 s after 4:40 have passed) refreshes at once.
        async.elapse(const Duration(seconds: 6));
        expect(runs(), 49);
        notifier.userActive();
        async.elapse(Duration.zero);
        expect(runs(), 50);
        async.elapse(const Duration(seconds: 10));
        expect(runs(), 52, reason: 'every 5 s again');

        // Details from the idle cadence are judged by the idle policy; the
        // new ones by the 5 s one.
        expect(
          notifier.freshnessOf(idleData.fetchedAt),
          same(FreshnessPolicy.deviceDetailIdle),
        );
        final fresh = container.read(deviceDetailProvider(id)).data!;
        expect(
          notifier.freshnessOf(fresh.fetchedAt),
          same(FreshnessPolicy.deviceDetail),
        );
      });
    });

    test('a touch soon after an idle run waits for the 5 s mark', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        async.flushMicrotasks();
        final notifier = container.read(deviceDetailProvider(id).notifier);

        // A touch at 0:07 makes it idle from 2:07: the run due at 2:10
        // moves to 2:20, then 2:35.
        async.elapse(const Duration(seconds: 7));
        notifier.userActive();
        async.elapse(const Duration(seconds: 149));
        final before = runs();
        expect(before, 28);
        notifier.userActive();
        async.elapse(const Duration(seconds: 3));
        expect(runs(), before, reason: 'the run at 2:35 was 1 s ago');
        async.elapse(const Duration(seconds: 1));
        expect(runs(), before + 1, reason: 'due at 2:40');
      });
    });
  });

  group('HTTP 403 stops polling (plan §7.5)', () {
    test('device details', () {
      fakeAsync((async) {
        final id = fixtureDetail().id;
        final container = createContainer(async);
        container.listen(deviceDetailProvider(id), (_, _) {});
        async.flushMicrotasks();
        final good = container.read(deviceDetailProvider(id)).data;

        source.detailFailure = const ApiFailure.forbidden(code: 'HTTP_403');
        async.elapse(const Duration(seconds: 5));
        final state = container.read(deviceDetailProvider(id));
        expect(state.error, isA<ForbiddenFailure>());
        expect(state.data, same(good));

        async.elapse(const Duration(minutes: 5));
        expect(count('device:$id'), 2);

        // Pull-to-refresh asks again and resumes the cadence.
        source.detailFailure = null;
        unawaited(container.read(deviceDetailProvider(id).notifier).refresh());
        async.flushMicrotasks();
        expect(container.read(deviceDetailProvider(id)).error, isNull);
        // At the idle cadence: nobody touched the screen for 5 min.
        async.elapse(const Duration(seconds: 15));
        expect(count('device:$id'), 4);
      });
    });

    test('device list', () {
      fakeAsync((async) {
        source.devicesFailure = const ApiFailure.forbidden(code: 'HTTP_403');
        final container = createContainer(async);
        container.listen(deviceListProvider, (_, _) {});
        async.flushMicrotasks();

        expect(
          container.read(deviceListProvider).error,
          isA<ForbiddenFailure>(),
        );
        async.elapse(const Duration(minutes: 5));
        expect(count('devices'), 1);
      });
    });
  });

  group('rooms', () {
    test('load when watched and keep the last good rooms on error', () {
      fakeAsync((async) {
        final container = createContainer(async);
        container.listen(roomsProvider, (_, _) {});
        async.flushMicrotasks();
        final good = container.read(roomsProvider).data;
        expect(good!.value, hasLength(2));

        source.roomsFailure = const ApiFailure.unreachable();
        unawaited(container.read(roomsProvider.notifier).refresh());
        async.flushMicrotasks();

        expect(container.read(roomsProvider).data, same(good));
        expect(container.read(roomsProvider).error, isA<UnreachableFailure>());

        // Rooms are not polled.
        async.elapse(const Duration(minutes: 10));
        expect(count('rooms'), 2);
      });
    });

    test('a rebuild neither joins nor is overwritten by an older load', () {
      fakeAsync((async) {
        final container = createContainer(async);
        final pending = Completer<void>();
        source.roomsGate = pending.future;
        container.listen(roomsProvider, (_, _) {});
        async.flushMicrotasks();
        expect(count('rooms'), 1);

        // A new repository (e.g. another client) while the load is running.
        source.roomsGate = null;
        container
          ..invalidate(roomsRepositoryProvider)
          ..read(roomsProvider);
        async.flushMicrotasks();
        expect(count('rooms'), 2);
        expect(container.read(roomsProvider).data!.value, hasLength(2));

        // The first load ends with an error that belongs to the old build.
        source.roomsFailure = const ApiFailure.unreachable();
        pending.complete();
        async.flushMicrotasks();

        expect(container.read(roomsProvider).error, isNull);
        expect(container.read(roomsProvider).data!.value, hasLength(2));
      });
    });
  });
}
