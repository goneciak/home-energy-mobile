import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/polling/concurrency_limiter.dart';

void main() {
  test('runs at most maxConcurrent tasks, the rest in arrival order', () {
    fakeAsync((async) {
      final limiter = ConcurrencyLimiter(2);
      final gates = List.generate(4, (_) => Completer<void>());
      final started = <int>[];
      final results = <int>[];
      for (var i = 0; i < 4; i++) {
        unawaited(
          limiter
              .run(() async {
                started.add(i);
                await gates[i].future;
                return i;
              })
              .then(results.add),
        );
      }
      async.flushMicrotasks();
      expect(started, [0, 1]);
      expect(limiter.running, 2);
      expect(limiter.waiting, 2);

      gates[1].complete();
      async.flushMicrotasks();
      expect(started, [0, 1, 2]);
      expect(limiter.running, 2);

      gates[0].complete();
      gates[2].complete();
      gates[3].complete();
      async.flushMicrotasks();
      expect(started, [0, 1, 2, 3]);
      expect(results, unorderedEquals([0, 1, 2, 3]));
      expect(limiter.running, 0);
      expect(limiter.waiting, 0);
    });
  });

  test('a failing task passes its error on and frees its slot', () {
    fakeAsync((async) {
      final limiter = ConcurrencyLimiter(1);
      Object? error;
      unawaited(
        limiter
            .run<void>(() async => throw StateError('boom'))
            .catchError((Object e) => error = e),
      );
      var ran = false;
      unawaited(limiter.run(() async => ran = true));
      async.flushMicrotasks();

      expect(error, isA<StateError>());
      expect(ran, isTrue);
      expect(limiter.running, 0);
    });
  });
}
