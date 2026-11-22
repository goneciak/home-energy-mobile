import 'package:gi_home/src/features/history/domain/history_series.dart';

/// Largest-Triangle-Three-Buckets downsampling (Steinarsson 2013): keeps
/// the first and the last point and, from every bucket in between, the
/// point spanning the largest triangle with its neighbours, so peaks and
/// dips survive. Returns [data] unchanged when it already has at most
/// [threshold] points (or [threshold] is below 3).
List<ChartPoint> lttb(List<ChartPoint> data, int threshold) {
  final length = data.length;
  if (threshold < 3 || threshold >= length) return data;

  final sampled = <ChartPoint>[data.first];
  final every = (length - 2) / (threshold - 2);
  var a = 0;
  for (var i = 0; i < threshold - 2; i++) {
    // Average of the next bucket: the third corner of the triangle.
    var avgStart = ((i + 1) * every).floor() + 1;
    var avgEnd = ((i + 2) * every).floor() + 1;
    if (avgEnd > length) avgEnd = length;
    if (avgStart >= avgEnd) avgStart = avgEnd - 1;
    var avgX = 0.0;
    var avgY = 0.0;
    for (var j = avgStart; j < avgEnd; j++) {
      avgX += data[j].x;
      avgY += data[j].y;
    }
    final avgLength = avgEnd - avgStart;
    avgX /= avgLength;
    avgY /= avgLength;

    final rangeStart = (i * every).floor() + 1;
    final rangeEnd = ((i + 1) * every).floor() + 1;
    final pointA = data[a];
    var maxArea = -1.0;
    var next = rangeStart;
    for (var j = rangeStart; j < rangeEnd; j++) {
      final area =
          ((pointA.x - avgX) * (data[j].y - pointA.y) -
                  (pointA.x - data[j].x) * (avgY - pointA.y))
              .abs();
      if (area > maxArea) {
        maxArea = area;
        next = j;
      }
    }
    sampled.add(data[next]);
    a = next;
  }
  sampled.add(data.last);
  return sampled;
}

/// The chart line of a change log: [lttb] over the change points (at most
/// [threshold] of them) expanded into steps held until [endX], i.e. at most
/// `2 × threshold` points.
List<ChartPoint> stepChartPoints(
  List<ChartPoint> changes, {
  required int threshold,
  double? endX,
}) => expandSteps(lttb(changes, threshold), endX: endX);
