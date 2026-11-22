import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/polling/reachability_tracker.dart';

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
/// * with a [reachability] tracker (one per appliance, shared by all of its
///   pollers) a failure to reach the appliance backs off on the tracker's
///   schedule instead, which also honours `Retry-After`; only one poller at
///   a time probes an unreachable appliance and the others wait for the
///   outcome;
/// * a run held back because another poller is probing reports the shared
///   failure to [onSharedFailure], so the screen still shows it;
/// * [phase] spreads pollers that share a cadence over that cadence (see
///   below);
/// * [pollNow] runs at once and forgets the backoff (the network changed);
/// * [interval] may change while running (e.g. a slower cadence while the
///   user is idle): the pending regular run is re-timed to the new interval
///   after the previous run, measured on the clock passed as `now`.
///
/// With a [phase] the first regular run after the start, and the one after
/// returning to the foreground, wait that much longer, so several pollers of
/// the same cadence (the heating cards on Home) do not all fire together:
/// they send the same number of requests, evenly instead of in bursts.
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
    this.phase = Duration.zero,
    this.reachability,
    this.onSharedFailure,
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

  /// Offset of this poller within its cadence, see the class comment. May
  /// change while running.
  Duration phase;

  /// Shared view of reaching the appliance; `null` backs off on its own.
  final ReachabilityTracker? reachability;

  /// Told the shared error when a run is held back because the appliance is
  /// known to be unreachable: the poller's owner publishes it like a failure
  /// of its own task, so every screen shows what the one probe found.
  final void Function(Object error)? onSharedFailure;
  final Random _random;
  final DateTime Function() _now;
  Duration _interval;

  Timer? _timer;

  /// Whether [_timer] waits for the next regular run (not a backoff or
  /// jitter delay).
  bool _cadencePending = false;

  /// Whether [_timer] waits out a backoff or another poller's probe.
  bool _backoffPending = false;
  DateTime? _lastRunEnded;
  Future<void>? _inFlight;
  int _failures = 0;
  bool _started = false;
  bool _halted = false;
  bool _disposed = false;

  /// Whether the next regular run is the first of a start or resume and
  /// still has to wait for [phase].
  bool _phasePending = true;

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
    reachability?.addListener(_onReachabilityChanged);
    if (foreground.value) unawaited(_run());
  }

  /// Runs now, e.g. for pull-to-refresh, and resumes a halted cadence.
  /// Joins a run already in flight.
  Future<void> refresh() {
    _halted = false;
    return _run(force: true);
  }

  /// Forgets the failures so far and runs now, e.g. because the phone changed
  /// network. Does nothing while stopped, halted or in the background.
  Future<void> pollNow() {
    if (_disposed || _halted || !foreground.value) return Future.value();
    resetBackoff();
    return _run(force: true);
  }

  /// Forgets the failures so far: the next failure backs off from the first
  /// step again.
  void resetBackoff() => _failures = 0;

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
    reachability?.removeListener(_onReachabilityChanged);
  }

  /// The appliance became reachable (or the tracker was reset): a poller
  /// waiting out a backoff runs again at once, as it would have on its own
  /// schedule. Requests to one appliance are bounded by the callers' own
  /// limiters, so there is no herd to spread out.
  void _onReachabilityChanged() {
    if (_disposed || _halted || !foreground.value) return;
    if (!_backoffPending || _inFlight != null) return;
    _cancelTimer();
    _timer = Timer(Duration.zero, () => unawaited(_run()));
  }

  Duration _jitter() {
    final jitterMs = maxJitter.inMilliseconds;
    return Duration(
      milliseconds: jitterMs <= 0 ? 0 : _random.nextInt(jitterMs + 1),
    );
  }

  void _onForegroundChanged() {
    _cancelTimer();
    if (!foreground.value || _disposed || _halted) return;
    _phasePending = true;
    _timer = Timer(_jitter(), () => unawaited(_run()));
  }

  /// [force] skips the wait for an unreachable appliance's probe slot
  /// (pull-to-refresh, [pollNow]).
  Future<void> _run({bool force = false}) {
    if (_disposed) return Future.value();
    return _inFlight ??= _execute(force: force)
        .whenComplete(() => _inFlight = null);
  }

  Future<void> _execute({required bool force}) async {
    _cancelTimer();
    final tracker = reachability;
    if (tracker != null && !force && !tracker.tryClaimProbe()) {
      // Another poller is probing the unreachable appliance.
      if (tracker.lastError case final error?) {
        try {
          onSharedFailure?.call(error);
        } on Object {
          // The owner's publishing must not stop the cadence.
        }
      }
      _waitFor(tracker.waitUntilProbe());
      return;
    }
    try {
      await task();
      _failures = 0;
      tracker?.reportSuccess();
    } on Object catch (error) {
      _failures++;
      final problem = tracker == null ? null : ReachabilityProblem.of(error);
      if (problem != null) {
        tracker!.reportFailure(retryAfter: problem.retryAfter, error: error);
      }
    }
    _lastRunEnded = _now();
    _scheduleNext();
  }

  void _scheduleNext() {
    if (_disposed || _halted || !foreground.value) return;
    final tracker = reachability;
    if (tracker != null && !tracker.isReachable) {
      _waitFor(tracker.waitUntilProbe());
      return;
    }
    final regular = _failures == 0;
    var delay = regular
        ? _interval
        : backoff[min(_failures, backoff.length) - 1];
    if (regular && _phasePending) {
      delay += phase;
      _phasePending = false;
    }
    _timer = Timer(delay, () => unawaited(_run()));
    _cadencePending = regular;
    _backoffPending = !regular;
  }

  void _waitFor(Duration delay) {
    if (_disposed || _halted || !foreground.value) return;
    _timer = Timer(delay, () => unawaited(_run()));
    _backoffPending = true;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _cadencePending = false;
    _backoffPending = false;
  }
}
