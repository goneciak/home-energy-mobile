import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/network_change_source.dart';
import 'package:gi_home/src/core/polling/reachability_tracker.dart';
import 'package:gi_home/src/features/appliance/application/network_recovery.dart';

import '../../support/fake_network_change_source.dart';

void main() {
  late FakeNetworkChangeSource source;
  late AppForeground foreground;
  late bool active;
  late List<String> log;

  NetworkRecovery create({Listenable? unreachable, DateTime Function()? now}) =>
      NetworkRecovery(
        changes: source.changes,
        foreground: foreground,
        unreachable: unreachable,
        now: now,
        isActive: () => active,
        resetReachability: () => log.add('reset'),
        refreshPollers: () async => log.add('refresh'),
        rebind: () async {
          log.add('rebind');
          return false;
        },
      )..start();

  setUp(() {
    source = FakeNetworkChangeSource();
    foreground = AppForeground();
    active = true;
    log = [];
    addTearDown(foreground.dispose);
    addTearDown(source.close);
  });

  test('a network change resets the backoff, refreshes the pollers and looks '
      'for a moved appliance, once it settled', () {
    fakeAsync((async) {
      final recovery = create();

      source.wifiToMobile();
      async.elapse(const Duration(milliseconds: 499));
      expect(log, isEmpty);

      async.elapse(const Duration(milliseconds: 1));
      expect(log, ['reset', 'refresh', 'rebind']);
      recovery.dispose();
    });
  });

  test('every kind of change counts: Wi-Fi to Wi-Fi, none to Wi-Fi', () {
    fakeAsync((async) {
      final recovery = create();

      source.wifiToOtherWifi();
      async.elapse(const Duration(seconds: 1));
      source.noneToWifi();
      async.elapse(const Duration(seconds: 1));

      expect(log.where((e) => e == 'refresh'), hasLength(2));
      expect(log.where((e) => e == 'rebind'), hasLength(2));
      recovery.dispose();
    });
  });

  test('a burst of events is one recovery', () {
    fakeAsync((async) {
      final recovery = create();

      source.wifiToMobile();
      async.elapse(const Duration(milliseconds: 200));
      source.noneToWifi();
      async.elapse(const Duration(milliseconds: 200));
      source.wifiToOtherWifi();
      async.elapse(const Duration(seconds: 2));

      expect(log, ['reset', 'refresh', 'rebind']);
      recovery.dispose();
    });
  });

  test('going offline recovers nothing: there is no network to find it on', () {
    fakeAsync((async) {
      final recovery = create();

      source.goOffline();
      async.elapse(const Duration(seconds: 2));

      expect(log, isEmpty);
      recovery.dispose();
    });
  });

  test('offline for a moment and back is one recovery, for the last state', () {
    fakeAsync((async) {
      final recovery = create();

      source.goOffline();
      async.elapse(const Duration(milliseconds: 100));
      source.noneToWifi();
      async.elapse(const Duration(seconds: 1));

      expect(log, ['reset', 'refresh', 'rebind']);
      recovery.dispose();
    });
  });

  test('without an appliance (demo mode, not set up) nothing happens', () {
    fakeAsync((async) {
      active = false;
      final recovery = create();

      source.wifiToMobile();
      async.elapse(const Duration(seconds: 1));
      foreground
        ..value = false
        ..value = true;

      expect(log, isEmpty);
      recovery.dispose();
    });
  });

  test('returning to the foreground only resets the backoff: the pollers '
      'refresh themselves', () {
    fakeAsync((async) {
      final recovery = create();

      foreground.value = false;
      async.elapse(const Duration(minutes: 5));
      expect(log, isEmpty);

      foreground.value = true;
      async.flushMicrotasks();
      expect(log, ['reset']);
      recovery.dispose();
    });
  });

  group('an unreachable appliance', () {
    late ReachabilityTracker tracker;
    late DateTime clock;

    setUp(() {
      clock = DateTime.utc(2026, 11, 22, 9);
      tracker = ReachabilityTracker(now: () => clock);
    });

    test('is looked for, at most once a minute', () {
      fakeAsync((async) {
        final recovery = create(
          unreachable: tracker.onFailure,
          now: () => clock,
        );

        tracker.reportFailure();
        async.flushMicrotasks();
        expect(log, ['rebind']);

        clock = clock.add(const Duration(seconds: 30));
        tracker
          ..reset()
          ..reportFailure();
        expect(log, ['rebind'], reason: 'too soon');

        clock = clock.add(const Duration(seconds: 31));
        tracker
          ..reset()
          ..reportFailure();
        expect(log, ['rebind', 'rebind']);
        recovery.dispose();
      });
    });

    test('is not looked for in the background or without an appliance', () {
      fakeAsync((async) {
        final recovery = create(
          unreachable: tracker.onFailure,
          now: () => clock,
        );

        foreground.value = false;
        tracker.reportFailure();
        foreground.value = true;
        log.clear();
        active = false;
        tracker
          ..reset()
          ..reportFailure();

        expect(log.where((e) => e == 'rebind'), isEmpty);
        recovery.dispose();
      });
    });
  });

  test('a failing source does not break the app', () {
    fakeAsync((async) {
      final controller = StreamController<NetworkState>();
      final recovery = NetworkRecovery(
        changes: controller.stream,
        foreground: foreground,
        isActive: () => true,
        resetReachability: () => log.add('reset'),
        refreshPollers: () async => log.add('refresh'),
        rebind: () async => false,
      )..start();

      controller.addError(StateError('no connectivity plug-in'));
      async.elapse(const Duration(seconds: 1));

      expect(log, isEmpty);
      recovery.dispose();
      unawaited(controller.close());
    });
  });

  test('a failing refresh or rebind is swallowed', () {
    fakeAsync((async) {
      final recovery = NetworkRecovery(
        changes: source.changes,
        foreground: foreground,
        isActive: () => true,
        resetReachability: () {},
        refreshPollers: () async => throw StateError('boom'),
        rebind: () async => throw StateError('boom'),
      )..start();

      source.wifiToMobile();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      recovery.dispose();
    });
  });

  test('after dispose nothing runs', () {
    fakeAsync((async) {
      create().dispose();
      source.wifiToMobile();
      async.elapse(const Duration(seconds: 1));
      expect(log, isEmpty);
    });
  });

  group('NetworkState', () {
    test('compares by value', () {
      expect(
        const NetworkState({NetworkKind.wifi, NetworkKind.vpn}),
        const NetworkState({NetworkKind.vpn, NetworkKind.wifi}),
      );
      expect(
        const NetworkState({NetworkKind.wifi}),
        isNot(const NetworkState({NetworkKind.mobile})),
      );
      expect(
        const NetworkState({NetworkKind.wifi}, identity: 'a'),
        isNot(const NetworkState({NetworkKind.wifi}, identity: 'b')),
      );
    });

    test('none is not connected', () {
      expect(NetworkState.none.isConnected, isFalse);
      expect(const NetworkState({NetworkKind.wifi}).isConnected, isTrue);
    });
  });
}
