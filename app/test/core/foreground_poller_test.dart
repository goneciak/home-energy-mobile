import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';

void main() {
  late AppForeground foreground;
  late int runs;
  late bool fail;
  Completer<void>? gate;

  ForegroundPoller poller() => ForegroundPoller(
    foreground: foreground,
    interval: const Duration(seconds: 30),
    maxJitter: Duration.zero,
    random: Random(1),
    task: () async {
      runs++;
      if (gate != null) await gate!.future;
      if (fail) throw Exception('boom');
    },
  );

  setUp(() {
    foreground = AppForeground();
    runs = 0;
    fail = false;
    gate = null;
  });

  test('runs at once and then every interval', () {
    fakeAsync((async) {
      final p = poller()..start();
      async.flushMicrotasks();
      expect(runs, 1);

      async.elapse(const Duration(seconds: 29));
      expect(runs, 1);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 2);
      async.elapse(const Duration(seconds: 60));
      expect(runs, 4);
      p.dispose();
    });
  });

  test('a phase delays the first regular run once, then the cadence holds', () {
    fakeAsync((async) {
      final p = poller()
        ..phase = const Duration(seconds: 10)
        ..start();
      async.flushMicrotasks();
      expect(runs, 1, reason: 'the first run is not delayed');

      async.elapse(const Duration(seconds: 39));
      expect(runs, 1);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 2, reason: 'interval plus phase');
      async.elapse(const Duration(seconds: 29));
      expect(runs, 2);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 3, reason: 'then the plain interval');
      p.dispose();
    });
  });

  test('the phase applies again after a return to the foreground', () {
    fakeAsync((async) {
      final p = poller()
        ..phase = const Duration(seconds: 10)
        ..start();
      async.elapse(const Duration(seconds: 40));
      expect(runs, 2);

      foreground.value = false;
      async.elapse(const Duration(minutes: 5));
      foreground.value = true;
      async
        ..elapse(Duration.zero)
        ..flushMicrotasks();
      expect(runs, 3, reason: 'the run on return is not delayed');

      async.elapse(const Duration(seconds: 39));
      expect(runs, 3);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 4);
      p.dispose();
    });
  });

  test('stops in the background and runs once on return', () {
    fakeAsync((async) {
      final p = poller()..start();
      async.flushMicrotasks();
      expect(runs, 1);

      foreground.value = false;
      async.elapse(const Duration(minutes: 10));
      expect(runs, 1);

      foreground.value = true;
      async.elapse(const Duration(milliseconds: 1));
      expect(runs, 2);
      p.dispose();
    });
  });

  test('does not start in the background', () {
    fakeAsync((async) {
      foreground.value = false;
      final p = poller()..start();
      async.elapse(const Duration(minutes: 5));
      expect(runs, 0);
      p.dispose();
    });
  });

  test('backs off 5 → 10 → 30 → 60 s after failures and recovers', () {
    fakeAsync((async) {
      fail = true;
      final p = poller()..start();
      async.flushMicrotasks();
      expect((runs, p.consecutiveFailures), (1, 1));

      async.elapse(const Duration(seconds: 5));
      expect((runs, p.consecutiveFailures), (2, 2));
      async.elapse(const Duration(seconds: 10));
      expect(runs, 3);
      async.elapse(const Duration(seconds: 30));
      expect(runs, 4);
      async.elapse(const Duration(seconds: 59));
      expect(runs, 4);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 5);
      async.elapse(const Duration(seconds: 60));
      expect(runs, 6);

      fail = false;
      async.elapse(const Duration(seconds: 60));
      expect((runs, p.consecutiveFailures), (7, 0));
      async.elapse(const Duration(seconds: 30));
      expect(runs, 8);
      p.dispose();
    });
  });

  test('a refresh joins the run in flight instead of starting another', () {
    fakeAsync((async) {
      gate = Completer<void>();
      final p = poller()..start();
      async.flushMicrotasks();
      expect((runs, p.isRunning), (1, true));

      unawaited(p.refresh());
      async.elapse(const Duration(minutes: 2));
      expect(runs, 1);

      gate!.complete();
      gate = null;
      async.flushMicrotasks();
      expect(p.isRunning, isFalse);

      unawaited(p.refresh());
      async.flushMicrotasks();
      expect(runs, 2);
      p.dispose();
    });
  });

  test('nothing runs after dispose', () {
    fakeAsync((async) {
      final p = poller()..start();
      async.flushMicrotasks();
      p.dispose();
      async.elapse(const Duration(minutes: 5));
      foreground.value = false;
      foreground.value = true;
      async.elapse(const Duration(minutes: 5));
      expect(runs, 1);
    });
  });

  group('changing the interval', () {
    ForegroundPoller timed(FakeAsync async) => ForegroundPoller(
      foreground: foreground,
      interval: const Duration(seconds: 30),
      maxJitter: Duration.zero,
      now: () => DateTime.utc(2026, 11, 18).add(async.elapsed),
      task: () async {
        runs++;
        if (fail) throw Exception('boom');
      },
    );

    test('re-times the waiting run from the end of the last one', () {
      fakeAsync((async) {
        final p = timed(async)..start();
        async.flushMicrotasks();
        expect(runs, 1);

        // Shorter: due 15 s after the run at 0 s.
        async.elapse(const Duration(seconds: 10));
        p.interval = const Duration(seconds: 15);
        expect(p.interval, const Duration(seconds: 15));
        async.elapse(const Duration(seconds: 4));
        expect(runs, 1);
        async.elapse(const Duration(seconds: 1));
        expect(runs, 2);
        async.elapse(const Duration(seconds: 15));
        expect(runs, 3);

        // Longer: the run at 30 s is followed by one at 90 s.
        p.interval = const Duration(seconds: 60);
        async.elapse(const Duration(seconds: 59));
        expect(runs, 3);
        async.elapse(const Duration(seconds: 1));
        expect(runs, 4);

        // Already overdue under the new interval: runs at once.
        async.elapse(const Duration(seconds: 10));
        p.interval = const Duration(seconds: 5);
        async.elapse(Duration.zero);
        expect(runs, 5);
        async.elapse(const Duration(seconds: 5));
        expect(runs, 6);
        p.dispose();
      });
    });

    test('leaves a backoff wait and a halted poller alone', () {
      fakeAsync((async) {
        fail = true;
        final p = timed(async)..start();
        async.flushMicrotasks();
        expect(runs, 1);

        // Backoff after the first failure is 5 s, whatever the interval.
        p.interval = const Duration(seconds: 1);
        async.elapse(const Duration(seconds: 4));
        expect(runs, 1);
        async.elapse(const Duration(seconds: 1));
        expect(runs, 2);

        p
          ..halt()
          ..interval = const Duration(seconds: 2);
        async.elapse(const Duration(minutes: 5));
        expect(runs, 2);
        p.dispose();
      });
    });
  });

  test('untilForeground waits for the return to the foreground', () {
    fakeAsync((async) {
      var done = false;
      foreground.value = false;
      unawaited(foreground.untilForeground().then((_) => done = true));
      async.flushMicrotasks();
      expect(done, isFalse);

      foreground.value = true;
      async.flushMicrotasks();
      expect(done, isTrue);
    });
  });
}
