import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// One chart point: `x` in milliseconds since the epoch (UTC), `y` the
/// value (switches as 0/1).
typedef ChartPoint = ({double x, double y});

/// The numeric samples of a change log as points, in the order received
/// (ascending). Text and unknown values are left out.
List<ChartPoint> changePoints(Iterable<HistorySample> samples) => [
  for (final sample in samples)
    if (sample.numericValue case final y?)
      (x: sample.at.millisecondsSinceEpoch.toDouble(), y: y),
];

/// Expands change points into a step line: a value holds until the next
/// change, which is drawn as a vertical jump (two points at the same x),
/// and the last value is held until [endX] (the end of the range).
///
/// History samples are recorded only when a value changes, so joining them
/// with slanted lines would invent values the device never reported.
List<ChartPoint> expandSteps(List<ChartPoint> changes, {double? endX}) {
  if (changes.isEmpty) return const [];
  final out = <ChartPoint>[changes.first];
  for (var i = 1; i < changes.length; i++) {
    final previous = changes[i - 1];
    final next = changes[i];
    if (next.y != previous.y) out.add((x: next.x, y: previous.y));
    out.add(next);
  }
  final last = changes.last;
  if (endX != null && endX > last.x) out.add((x: endX, y: last.y));
  return out;
}

/// Min, max and the latest value of a history range, for the summary and
/// its screen reader label.
@immutable
final class HistorySummary {
  const new _({required this.count, this.min, this.max, this.last});

  /// Summary of ascending [samples]; [min]/[max] cover numeric values only.
  factory of(List<HistorySample> samples) {
    double? min;
    double? max;
    for (final sample in samples) {
      if (sample.kind == HistorySampleKind.switch_) continue;
      final value = sample.numericValue;
      if (value == null) continue;
      if (min == null || value < min) min = value;
      if (max == null || value > max) max = value;
    }
    return HistorySummary._(
      count: samples.length,
      min: min,
      max: max,
      last: samples.lastOrNull,
    );
  }

  /// Number of recorded changes.
  final int count;
  final double? min;
  final double? max;

  /// The latest sample of the range.
  final HistorySample? last;
}
