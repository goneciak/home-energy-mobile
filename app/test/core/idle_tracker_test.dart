import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/polling/idle_tracker.dart';

void main() {
  IdleTracker tracker(FakeAsync async) => IdleTracker(
    idleAfter: const Duration(minutes: 2),
    now: () => DateTime.utc(2026, 11, 18).add(async.elapsed),
  );

  test('turns idle 2 min after the start without interaction', () {
    fakeAsync((async) {
      final idle = tracker(async);
      final changes = <bool>[];
      idle.addListener(() => changes.add(idle.isIdle));

      async.elapse(const Duration(seconds: 119));
      expect(idle.isIdle, isFalse);
      async.elapse(const Duration(seconds: 1));
      expect(idle.isIdle, isTrue);
      expect(changes, [true]);
      idle.dispose();
    });
  });

  test('every touch starts the 2 min again', () {
    fakeAsync((async) {
      final idle = tracker(async);

      async.elapse(const Duration(seconds: 90));
      idle.touch();
      async.elapse(const Duration(seconds: 90));
      idle.touch();
      async.elapse(const Duration(seconds: 119));
      expect(idle.isIdle, isFalse);
      async.elapse(const Duration(seconds: 1));
      expect(idle.isIdle, isTrue);
      idle.dispose();
    });
  });

  test('a touch ends the idle period, once', () {
    fakeAsync((async) {
      final idle = tracker(async);
      async.elapse(const Duration(minutes: 3));
      expect(idle.isIdle, isTrue);
      var notified = 0;
      idle.addListener(() => notified++);

      idle
        ..touch()
        ..touch()
        ..touch();
      expect(idle.isIdle, isFalse);
      expect(notified, 1);

      async.elapse(const Duration(minutes: 2));
      expect(idle.isIdle, isTrue);
      idle.dispose();
    });
  });

  test('many touches keep a single timer', () {
    fakeAsync((async) {
      final idle = tracker(async);
      for (var i = 0; i < 100; i++) {
        idle.touch();
        async.elapse(const Duration(milliseconds: 16));
      }
      expect(async.pendingTimers, hasLength(1));
      idle.dispose();
      expect(async.pendingTimers, isEmpty);
    });
  });
}
