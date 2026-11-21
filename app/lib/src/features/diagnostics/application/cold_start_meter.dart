import 'package:flutter/widgets.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';

/// Measures the cold start as plan §1.1 G1 defines it: from the first line
/// of `main` to the first frame that shows the Home condition, i.e. after
/// the session restore and the first `GET /devices`. That time goes to the
/// local counter (plan §8.4).
///
/// A start that leads somewhere else first (connect, login, a failed
/// restore, a required password change) or goes to the background before
/// Home is ready is no G1 sample and is [abandon]ed, so the counter never
/// mixes in the time a user spends typing.
final class ColdStartMeter {
  new(this._stopwatch, this._diagnostics);

  Stopwatch? _stopwatch;
  final DiagnosticsService _diagnostics;

  /// Whether a cold start is still waiting for the Home condition.
  bool get isMeasuring => _stopwatch != null;

  /// This start is not measured.
  void abandon() {
    _stopwatch?.stop();
    _stopwatch = null;
  }

  /// The Home condition is being built: the time is taken at the end of
  /// this frame. Only the first call of a start counts.
  void homeConditionShown() {
    final stopwatch = _stopwatch;
    if (stopwatch == null) return;
    _stopwatch = null;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        stopwatch.stop();
        _diagnostics.recordColdStart(stopwatch.elapsed);
      })
      ..ensureVisualUpdate();
  }
}
