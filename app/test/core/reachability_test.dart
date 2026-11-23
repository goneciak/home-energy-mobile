import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/reachability_tracker.dart';

void main() {
  final epoch = DateTime.utc(2026, 11, 22, 8);

  group('ReachabilityTracker', () {
    late Duration elapsed;
    late ReachabilityTracker tracker;

    ReachabilityTracker create({Duration jitter = Duration.zero}) =>
        ReachabilityTracker(
          now: () => epoch.add(elapsed),
          maxRetryAfterJitter: jitter,
          random: Random(1),
        );

    setUp(() {
      elapsed = Duration.zero;
      tracker = create();
    });

    test('backs off 5 → 10 → 30 → 60 s and stays at 60 s', () {
      final steps = <Duration>[];
      for (var i = 0; i < 6; i++) {
        expect(tracker.tryClaimProbe(), isTrue);
        tracker.reportFailure();
        steps.add(tracker.waitUntilProbe());
        elapsed += tracker.waitUntilProbe();
      }
      expect(steps.map((d) => d.inSeconds), [5, 10, 30, 60, 60, 60]);
    });

    test('one probe at a time: others wait for its outcome', () {
      tracker.reportFailure();
      expect(tracker.tryClaimProbe(), isFalse, reason: 'not due yet');

      elapsed += const Duration(seconds: 5);
      expect(tracker.tryClaimProbe(), isTrue);
      expect(tracker.tryClaimProbe(), isFalse, reason: 'already claimed');
      expect(tracker.tryClaimProbe(), isFalse);
    });

    test('an unanswered probe is handed on after the lease', () {
      tracker.reportFailure();
      elapsed += const Duration(seconds: 5);
      expect(tracker.tryClaimProbe(), isTrue);

      elapsed += tracker.probeLease;
      expect(tracker.tryClaimProbe(), isTrue);
    });

    test('failures reported together count once', () {
      tracker
        ..reportFailure()
        ..reportFailure()
        ..reportFailure();

      expect(tracker.failures, 1);
      expect(tracker.waitUntilProbe(), const Duration(seconds: 5));
    });

    test('a success makes the appliance reachable and tells listeners', () {
      var told = 0;
      tracker
        ..addListener(() => told++)
        ..reportFailure()
        ..reportSuccess();

      expect(tracker.isReachable, isTrue);
      expect(tracker.waitUntilProbe(), Duration.zero);
      expect(told, 1);

      tracker.reportSuccess();
      expect(told, 1, reason: 'nothing changed');
    });

    test('reset forgets the failures and tells listeners', () {
      var told = 0;
      tracker
        ..addListener(() => told++)
        ..reportFailure()
        ..reportFailure()
        ..reset();

      expect(tracker.failures, 0);
      expect(tracker.tryClaimProbe(), isTrue);
      expect(told, 1);
    });

    test('Retry-After replaces the backoff step', () {
      tracker.reportFailure(retryAfter: const Duration(seconds: 42));

      expect(tracker.waitUntilProbe(), const Duration(seconds: 42));
    });

    test('Retry-After is capped at 120 s', () {
      tracker.reportFailure(retryAfter: const Duration(hours: 1));

      expect(tracker.waitUntilProbe(), const Duration(seconds: 120));
    });

    test('Retry-After gets up to a second of jitter, never less', () {
      final waits = <Duration>{};
      for (var seed = 0; seed < 20; seed++) {
        final t = ReachabilityTracker(now: () => epoch, random: Random(seed))
          ..reportFailure(retryAfter: const Duration(seconds: 10));
        waits.add(t.waitUntilProbe());
      }
      expect(
        waits.every(
          (w) =>
              w >= const Duration(seconds: 10) &&
              w < const Duration(seconds: 11),
        ),
        isTrue,
      );
      expect(waits.length, greaterThan(1), reason: 'it is random');
    });

    test('a zero Retry-After probes at once', () {
      tracker.reportFailure(retryAfter: Duration.zero);

      expect(tracker.waitUntilProbe(), Duration.zero);
    });
  });

  group('ReachabilityProblem', () {
    test('what says nothing about reaching the appliance is not one', () {
      expect(
        ReachabilityProblem.of(const ApiFailure.forbidden(code: 'X')),
        isNull,
      );
      expect(
        ReachabilityProblem.of(const ApiFailure.notFound(code: 'X')),
        isNull,
      );
      expect(ReachabilityProblem.of(StateError('bug')), isNull);
    });

    test('unreachable, timeout and local network denial are', () {
      expect(ReachabilityProblem.of(const ApiFailure.unreachable()), isNotNull);
      expect(ReachabilityProblem.of(const ApiFailure.timeout()), isNotNull);
      expect(
        ReachabilityProblem.of(const ApiFailure.localNetworkDenied()),
        isNotNull,
      );
    });

    test('429 and 503 carry their Retry-After', () {
      expect(
        ReachabilityProblem.of(
          const ApiFailure.rateLimited(retryAfter: Duration(seconds: 7)),
        )?.retryAfter,
        const Duration(seconds: 7),
      );
      expect(
        ReachabilityProblem.of(
          const ApiFailure.server(
            statusCode: 503,
            retryAfter: Duration(seconds: 9),
          ),
        )?.retryAfter,
        const Duration(seconds: 9),
      );
    });
  });

  group('pollers sharing a tracker', () {
    late AppForeground foreground;
    late FakeAsync fake;
    late ReachabilityTracker tracker;
    late Object? failure;
    late Map<String, int> runs;

    DateTime now() => epoch.add(fake.elapsed);

    ForegroundPoller poller(String name, {Duration? every}) => ForegroundPoller(
      foreground: foreground,
      interval: every ?? const Duration(seconds: 30),
      maxJitter: Duration.zero,
      reachability: tracker,
      now: now,
      task: () async {
        runs[name] = (runs[name] ?? 0) + 1;
        // A test double throws whatever the scenario sets.
        // ignore: only_throw_errors
        if (failure case final error?) throw error;
      },
    );

    /// Runs [body] with fake time that also drives [now].
    void run(void Function(FakeAsync async) body) {
      fakeAsync((async) {
        fake = async;
        tracker = ReachabilityTracker(
          now: now,
          maxRetryAfterJitter: Duration.zero,
        );
        body(async);
      });
    }

    void elapse(FakeAsync async, Duration d) => async.elapse(d);

    int total() => runs.values.fold(0, (a, b) => a + b);

    setUp(() {
      foreground = AppForeground();
      failure = null;
      runs = {};
    });

    test('three pollers, one unreachable host: one probe per schedule', () {
      run((async) {
        failure = const ApiFailure.unreachable();
        final pollers = [poller('list'), poller('card1'), poller('card2')];
        for (final p in pollers) {
          p.start();
        }
        async.flushMicrotasks();
        // All three started together and met the failure.
        expect(total(), 3);
        expect(tracker.failures, 1, reason: 'counted once');

        // Per probe slot exactly one request: 5 s, then 10 s, then 30 s.
        elapse(async, const Duration(seconds: 5));
        expect(total(), 4);
        elapse(async, const Duration(seconds: 10));
        expect(total(), 5);
        elapse(async, const Duration(seconds: 30));
        expect(total(), 6);
        // The slots between probes send nothing.
        elapse(async, const Duration(seconds: 29));
        expect(total(), 6);

        for (final p in pollers) {
          p.dispose();
        }
      });
    });

    test('a probe that gets through wakes the others', () {
      run((async) {
        failure = const ApiFailure.unreachable();
        final a = poller('a')..start();
        final b = poller('b')..start();
        async.flushMicrotasks();
        expect(total(), 2);

        failure = null;
        elapse(async, const Duration(seconds: 5));
        // One probe went out and succeeded; the waiting poller follows
        // within the jitter, not after its own backoff.
        elapse(async, const Duration(milliseconds: 400));
        expect(tracker.isReachable, isTrue);
        expect(runs['a']! + runs['b']!, 4);
        expect(runs['a'], 2);
        expect(runs['b'], 2);

        a.dispose();
        b.dispose();
      });
    });

    test('Retry-After of a 503 sets the pause for every poller', () {
      run((async) {
        failure = const ApiFailure.server(
          statusCode: 503,
          retryAfter: Duration(seconds: 45),
        );
        final a = poller('a')..start();
        final b = poller('b')..start();
        async.flushMicrotasks();
        expect(total(), 2);

        elapse(async, const Duration(seconds: 44));
        expect(total(), 2, reason: 'backoff alone would have probed at 5 s');
        elapse(async, const Duration(seconds: 1));
        expect(total(), 3);

        a.dispose();
        b.dispose();
      });
    });

    test('a failure that is not about reaching the appliance backs off only '
        'that poller', () {
      run((async) {
        failure = const ApiFailure.notFound(code: 'DEVICE_NOT_FOUND');
        final a = poller('a')..start();
        async.flushMicrotasks();

        expect(tracker.isReachable, isTrue);
        elapse(async, const Duration(seconds: 5));
        expect(runs['a'], 2, reason: 'its own 5 s backoff');

        a.dispose();
      });
    });

    test('a poller held back by another probe hands the shared '
        'error to its owner', () {
      run((async) {
        failure = const ApiFailure.unreachable();
        final shared = <Object>[];
        final a = poller('a')..start();
        async.flushMicrotasks();
        final b = ForegroundPoller(
          foreground: foreground,
          interval: const Duration(seconds: 30),
          maxJitter: Duration.zero,
          reachability: tracker,
          now: now,
          onSharedFailure: shared.add,
          task: () async {
            runs['b'] = (runs['b'] ?? 0) + 1;
          },
        )..start();
        async.flushMicrotasks();
        // b's own first run was held back: a had already failed.
        expect(runs['b'], isNull);
        expect(shared, [isA<UnreachableFailure>()]);

        a.dispose();
        b.dispose();
      });
    });

    test('pollNow forgets the backoff and runs at once', () {
      run((async) {
        failure = const ApiFailure.unreachable();
        final a = poller('a')..start();
        async.flushMicrotasks();
        elapse(async, const Duration(seconds: 5));
        expect(runs['a'], 2);
        expect(tracker.failures, 2);

        failure = null;
        tracker.reset();
        unawaited(a.pollNow());
        async.flushMicrotasks();

        expect(runs['a'], 3);
        expect(a.consecutiveFailures, 0);
        a.dispose();
      });
    });

    test('pollNow does nothing in the background or after halt', () {
      run((async) {
        final a = poller('a')..start();
        async.flushMicrotasks();
        expect(runs['a'], 1);

        foreground.value = false;
        unawaited(a.pollNow());
        async.flushMicrotasks();
        expect(runs['a'], 1);

        foreground.value = true;
        elapse(async, const Duration(milliseconds: 100));
        final afterResume = runs['a']!;
        a.halt();
        unawaited(a.pollNow());
        async.flushMicrotasks();
        expect(runs['a'], afterResume);

        a.dispose();
      });
    });

    test('pull-to-refresh probes even while another poller holds the '
        'slot', () {
      run((async) {
        failure = const ApiFailure.unreachable();
        final a = poller('a')..start();
        async.flushMicrotasks();
        expect(runs['a'], 1);

        unawaited(a.refresh());
        async.flushMicrotasks();
        expect(runs['a'], 2);
        a.dispose();
      });
    });
  });
}
