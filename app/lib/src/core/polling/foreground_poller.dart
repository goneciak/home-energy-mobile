import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Runs [task] periodically, but only while the app is in the foreground
/// (plan §11):
///
/// * everything stops when [foreground] turns `false`;
/// * on return to the foreground it runs once after a random 0–[maxJitter]
///   delay, then resumes the cadence;
/// * a tick is skipped while the previous run is still in flight;
/// * after failures the next run waits [backoff] (5 → 10 → 30 → 60 s by
///   default) instead of [interval];
/// * [halt] stops the cadence (e.g. the polled resource was deleted) until
///   the next explicit [refresh];
/// * [interval] may change while running (e.g. a slower cadence while the
///   user is idle): the pending regular run is re-timed to the new interval
///   after the previous run, measured on the clock passed as `now`.
///
/// [task] reports failure by throwing; the poller swallows the error, so the
/// task itself must publish it (e.g. into a provider state).
///
/// Typical use inside a provider:
/// ```dart
/// final poller = ForegroundPoller(
///   foreground: ref.watch(appForegroundProvider),
///   interval: const Duration(seconds: 30),
///   task: load,
/// )..start();
/// ref.onDispose(poller.dispose);
/// ```
class ForegroundPoller {
  new({
    required this.foreground,
    required this._interval,
    required this.task,
    this.backoff = defaultBackoff,
    this.maxJitter = const Duration(milliseconds: 300),
    Random? random,
    DateTime Function()? now,
  }) : assert(backoff.isNotEmpty, 'backoff must not be empty'),
       _random = random ?? Random(),
       _now = now ?? DateTime.now;

  static const defaultBackoff = [
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  final ValueListenable<bool> foreground;
  final Future<void> Function() task;
  final List<Duration> backoff;
  final Duration maxJitter;
  final Random _random;
  final DateTime Function() _now;
  Duration _interval;

  Timer? _timer;

  /// Whether [_timer] waits for the next regular run (not a backoff or
  /// jitter delay).
  bool _cadencePending = false;
  DateTime? _lastRunEnded;
  Future<void>? _inFlight;
  int _failures = 0;
  bool _started = false;
  bool _halted = false;
  bool _disposed = false;

  /// Number of consecutive failed runs.
  int get consecutiveFailures => _failures;

  bool get isRunning => _inFlight != null;

  /// Time between the end of a successful run and the next one.
  Duration get interval => _interval;

  /// Changes the cadence. A regular run already waiting is re-timed to
  /// [value] after the previous run ended, so a shorter interval brings it
  /// forward (at once when that time has passed) and a longer one pushes it
  /// back. Backoff after failures is not affected.
  set interval(Duration value) {
    if (value == _interval) return;
    _interval = value;
    final ended = _lastRunEnded;
    if (!_cadencePending || ended == null || _disposed || _halted) return;
    _timer?.cancel();
    final wait = ended.add(value).difference(_now());
    _timer = Timer(
      wait.isNegative ? Duration.zero : wait,
      () => unawaited(_run()),
    );
  }

  /// Runs immediately (if in the foreground) and starts the cadence.
  void start() {
    if (_started || _disposed) return;
    _started = true;
    foreground.addListener(_onForegroundChanged);
    if (foreground.value) unawaited(_run());
  }

  /// Runs now, e.g. for pull-to-refresh, and resumes a halted cadence.
  /// Joins a run already in flight.
  Future<void> refresh() {
    _halted = false;
    return _run();
  }

  /// Stops running until the next [refresh]; returning to the foreground
  /// does not restart it. May be called from within [task].
  void halt() {
    _halted = true;
    _cancelTimer();
  }

  void dispose() {
    _disposed = true;
    _cancelTimer();
    if (_started) foreground.removeListener(_onForegroundChanged);
  }

  void _onForegroundChanged() {
    _cancelTimer();
    if (!foreground.value || _disposed || _halted) return;
    final jitterMs = maxJitter.inMilliseconds;
    final delay = Duration(
      milliseconds: jitterMs <= 0 ? 0 : _random.nextInt(jitterMs + 1),
    );
    _timer = Timer(delay, () => unawaited(_run()));
  }

  Future<void> _run() {
    if (_disposed) return Future.value();
    return _inFlight ??= _execute().whenComplete(() => _inFlight = null);
  }

  Future<void> _execute() async {
    _cancelTimer();
    try {
      await task();
      _failures = 0;
    } on Object {
      _failures++;
    }
    _lastRunEnded = _now();
    _scheduleNext();
  }

  void _scheduleNext() {
    if (_disposed || _halted || !foreground.value) return;
    final regular = _failures == 0;
    final delay = regular
        ? _interval
        : backoff[min(_failures, backoff.length) - 1];
    _timer = Timer(delay, () => unawaited(_run()));
    _cadencePending = regular;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _cadencePending = false;
  }
}
