import 'dart:isolate';

import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/lttb.dart';
import 'package:meta/meta.dart';

/// The points the chart draws.
@immutable
final class HistoryChartSeries {
  const new({required this.points, required this.sourceCount, this.worker});

  final List<ChartPoint> points;

  /// Number of change points before downsampling.
  final int sourceCount;

  /// Debug name of the isolate that downsampled, `null` when the series was
  /// built on the calling isolate.
  final String? worker;
}

/// Builds the chart line of `changes` with at most `threshold` change
/// points, held until `endX`.
typedef HistoryDownsampler = Future<HistoryChartSeries> Function(
  List<ChartPoint> changes, {
  required int threshold,
  double? endX,
});

/// Debug name of the downsampling isolate.
const historyWorkerName = 'history-lttb';

/// [HistoryDownsampler] that runs LTTB in a short-lived isolate
/// ([Isolate.run]) so a 7-day range (tens of thousands of samples) never
/// blocks the UI thread. A series that needs no downsampling is only
/// expanded into steps, without an isolate.
Future<HistoryChartSeries> downsampleInIsolate(
  List<ChartPoint> changes, {
  required int threshold,
  double? endX,
}) async {
  if (changes.length <= threshold) {
    return HistoryChartSeries(
      points: expandSteps(changes, endX: endX),
      sourceCount: changes.length,
    );
  }
  return await Isolate.run(
    () => HistoryChartSeries(
      points: stepChartPoints(changes, threshold: threshold, endX: endX),
      sourceCount: changes.length,
      worker: Isolate.current.debugName,
    ),
    debugName: historyWorkerName,
  );
}

/// [HistoryDownsampler] on the calling isolate (widget tests and goldens,
/// where a real isolate does not finish inside the fake-async zone).
Future<HistoryChartSeries> downsampleSynchronously(
  List<ChartPoint> changes, {
  required int threshold,
  double? endX,
}) async => HistoryChartSeries(
  points: stepChartPoints(changes, threshold: threshold, endX: endX),
  sourceCount: changes.length,
);
