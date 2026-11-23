import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:gi_core_api/gi_core_api.dart';

/// Why a poll could not reach the appliance, as far as backing off is
/// concerned.
final class ReachabilityProblem {
  const new({this.retryAfter});

  /// The pause GI Core asked for with `Retry-After` (429, 503).
  final Duration? retryAfter;

  /// The problem behind [error], or `null` when the failure says nothing about
  /// reaching the appliance (a 403, a missing resource, a parse error): such
  /// an error backs off only the poller that met it.
  static ReachabilityProblem? of(Object error) => switch (error) {
    UnreachableFailure() ||
    TimeoutFailure() ||
    LocalNetworkDeniedFailure() => const ReachabilityProblem(),
    RateLimitedFailure(:final retryAfter) => ReachabilityProblem(
      retryAfter: retryAfter,
    ),
    ServerFailure(:final retryAfter) => ReachabilityProblem(
      retryAfter: retryAfter,
    ),
    _ => null,
  };
}

/// What one appliance's pollers know about reaching it together.
///
/// A failing appliance is probed by ONE request at a time on one schedule
/// (5 → 10 → 30 → 60 s, or the `Retry-After` it asked for), however many
/// pollers watch it: the others wait for the probe's outcome instead of each
/// hammering an unreachable host. A success, or [reset] after a network
/// change, lets them all run again.
///
/// Listeners are told when the appliance became reachable (or [reset]).
class ReachabilityTracker extends ChangeNotifier {
  new({
    this.backoff = defaultBackoff,
    this.maxRetryAfter = const Duration(seconds: 120),
    this.maxRetryAfterJitter = const Duration(seconds: 1),
    this.probeLease = const Duration(seconds: 15),
    DateTime Function()? now,
    Random? random,
  }) : assert(backoff.isNotEmpty, 'backoff must not be empty'),
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  static const defaultBackoff = [
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  final List<Duration> backoff;

  /// Longest pause honoured from a `Retry-After`.
  final Duration maxRetryAfter;

  /// Up to this much is added to a `Retry-After` pause, so phones do not
  /// return in step.
  final Duration maxRetryAfterJitter;

  /// How long a claimed probe may stay unanswered before another poller may
  /// take over (a request has timed out by then).
  final Duration probeLease;

  final DateTime Function() _now;
  final Random _random;

  int _failures = 0;
  Object? _lastError;
  DateTime? _nextProbeAt;
  bool _probeClaimed = false;
  final _failureNotifier = _FailureNotifier();

  /// Told after every failed probe (not on recovery), e.g. to look for an
  /// appliance that moved.
  Listenable get onFailure => _failureNotifier;

  /// Consecutive failed probes; `0` while the appliance is reachable.
  int get failures => _failures;

  bool get isReachable => _failures == 0;

  /// The error of the latest failed probe; `null` while reachable.
  Object? get lastError => _failures == 0 ? null : _lastError;

  /// When the next probe may be sent; `null` while reachable.
  DateTime? get nextProbeAt => _nextProbeAt;

  /// How long until a probe may go out (zero when reachable or due).
  Duration waitUntilProbe() {
    final at = _nextProbeAt;
    if (_failures == 0 || at == null) return Duration.zero;
    final wait = at.difference(_now());
    return wait.isNegative ? Duration.zero : wait;
  }

  /// Whether the caller may send a request now. While reachable always; while
  /// failing only the one caller that finds the probe due, which then holds
  /// the probe until it reports back or [probeLease] runs out.
  bool tryClaimProbe() {
    if (_failures == 0) return true;
    if (waitUntilProbe() > Duration.zero) return false;
    _nextProbeAt = _now().add(probeLease);
    _probeClaimed = true;
    return true;
  }

  /// A request got through.
  void reportSuccess() {
    if (_failures == 0) return;
    _failures = 0;
    _nextProbeAt = null;
    _probeClaimed = false;
    notifyListeners();
  }

  /// A request did not reach the appliance. Reports that arrive while a probe
  /// is already scheduled (requests that were in flight together) count once.
  void reportFailure({Duration? retryAfter, Object? error}) {
    final scheduled = _nextProbeAt;
    final fresh =
        _failures == 0 || _probeClaimed || !_now().isBefore(scheduled!);
    _probeClaimed = false;
    if (error != null) _lastError = error;
    if (!fresh && retryAfter == null) return;
    if (fresh) _failures++;
    final Duration delay;
    if (retryAfter != null) {
      final capped = retryAfter > maxRetryAfter ? maxRetryAfter : retryAfter;
      final jitterMs = maxRetryAfterJitter.inMilliseconds;
      delay =
          capped +
          Duration(milliseconds: jitterMs <= 0 ? 0 : _random.nextInt(jitterMs));
    } else {
      delay = backoff[min(_failures, backoff.length) - 1];
    }
    final next = _now().add(delay);
    if (fresh || next.isAfter(scheduled)) {
      _nextProbeAt = next;
    }
    if (fresh) _failureNotifier.fire();
  }

  @override
  void dispose() {
    _failureNotifier.dispose();
    super.dispose();
  }

  /// The network changed: forget the failures (the address may well be
  /// reachable now) and let every waiting poller run.
  void reset() {
    _failures = 0;
    _nextProbeAt = null;
    _probeClaimed = false;
    notifyListeners();
  }
}

class _FailureNotifier extends ChangeNotifier {
  void fire() => notifyListeners();
}
