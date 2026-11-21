import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Thrown by [ConcurrencyLimiter.acquire] when its `cancel` future completes
/// before a slot became free. No slot was taken.
final class ConcurrencyWaitCancelled implements Exception {
  const new();

  @override
  String toString() => 'ConcurrencyWaitCancelled';
}

/// An async semaphore: at most [maxConcurrent] holders at a time, the rest
/// wait in arrival order.
///
/// Used for the per-appliance cap on requests in flight (plan §11: at most
/// 4 concurrent requests per GI Home, see [ConcurrencyLimitedAdapter]) and
/// by the app for smaller groups of pollers (Home heating cards: 3).
final class ConcurrencyLimiter {
  new(this.maxConcurrent)
    : assert(maxConcurrent > 0, 'maxConcurrent must be positive');

  /// Plan §11: "Maksymalnie 4 współbieżne żądania na urządzenie GI Home".
  static const perApplianceRequests = 4;

  final int maxConcurrent;

  int _running = 0;
  final _waiting = Queue<Completer<void>>();

  /// Slots held right now.
  int get running => _running;

  /// Callers waiting for a free slot.
  int get waiting => _waiting.length;

  /// Runs [task] once a slot is free and completes with its result or error.
  Future<T> run<T>(Future<T> Function() task) async {
    final release = await acquire();
    try {
      return await task();
    } finally {
      release();
    }
  }

  /// Waits for a free slot and returns the function that frees it again.
  /// Calling that function more than once has no further effect.
  ///
  /// When [cancel] completes (with a value or an error) while the caller is
  /// still waiting, the wait ends with [ConcurrencyWaitCancelled] and no slot
  /// is taken.
  Future<void Function()> acquire({Future<void>? cancel}) async {
    if (_running < maxConcurrent) {
      _running++;
      return _releaser();
    }
    final turn = Completer<void>();
    _waiting.add(turn);
    if (cancel != null) {
      void giveUp() {
        if (!turn.isCompleted && _waiting.remove(turn)) {
          turn.completeError(const ConcurrencyWaitCancelled());
        }
      }

      unawaited(cancel.then((_) => giveUp(), onError: (Object _) => giveUp()));
    }
    // The slot is handed over by [_release], so [_running] stays counted.
    await turn.future;
    return _releaser();
  }

  void Function() _releaser() {
    var released = false;
    return () {
      if (released) return;
      released = true;
      _release();
    };
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
    } else {
      _running--;
    }
  }
}

/// Wraps the real [HttpClientAdapter] so that at most
/// [ConcurrencyLimiter.maxConcurrent] requests are on the wire at once.
///
/// The slot covers only the network exchange: from the moment the request
/// is handed to the adapter until its response body has been read (or the
/// request failed or was cancelled). Interceptors run outside it, so a
/// request waiting for a token refresh, or replayed after one, never holds
/// a slot while it waits; the refresh and `/setup/status` calls of the
/// session manager take a slot only for their own send. Nothing that holds
/// a slot ever waits for another slot, so the cap cannot deadlock.
///
/// A request cancelled while it waits leaves the queue without being sent.
final class ConcurrencyLimitedAdapter implements HttpClientAdapter {
  new(this._inner, this.limiter);

  final HttpClientAdapter _inner;
  final ConcurrencyLimiter limiter;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final void Function() release;
    try {
      release = await limiter.acquire(cancel: cancelFuture);
    } on ConcurrencyWaitCancelled {
      throw DioException.requestCancelled(
        requestOptions: options,
        reason: 'cancelled while waiting for a free request slot',
      );
    }
    // Dio stops reading a cancelled response, and an adapter may ignore the
    // cancellation altogether, so cancelling always frees the slot.
    unawaited(
      cancelFuture?.then((_) => release(), onError: (Object _) => release()),
    );
    final ResponseBody body;
    try {
      body = await _inner.fetch(options, requestStream, cancelFuture);
    } on Object {
      release();
      rethrow;
    }
    final bodyIsRead =
        options.responseType != ResponseType.stream &&
        (options.validateStatus(body.statusCode) ||
            options.receiveDataWhenStatusError);
    if (bodyIsRead) {
      body.stream = _releasingWhenDone(body.stream, release);
    } else {
      release();
    }
    return body;
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);

  /// [stream] that calls [release] once it is done, fails, or its listener
  /// cancels.
  static Stream<Uint8List> _releasingWhenDone(
    Stream<Uint8List> stream,
    void Function() release,
  ) async* {
    try {
      yield* stream;
    } finally {
      release();
    }
  }
}
