import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/lttb.dart';

/// Host benchmark of the chart pipeline of a 7-day range (plan §20 M3:
/// render ≤ 3 s on a mid-range Android phone). ~20 000 change points (one
/// every 30 s) downsampled to a 1080 px wide chart. The budget is loose
/// for slow CI hosts; the measured time is printed for the record.
void main() {
  test('LTTB + steps of 20 160 points stays within budget', () {
    final random = math.Random(1);
    final start = DateTime.utc(2026, 11, 15).millisecondsSinceEpoch;
    final changes = <ChartPoint>[
      for (var i = 0; i < 7 * 24 * 120; i++)
        (
          x: (start + i * 30000).toDouble(),
          y: 45 + 6 * math.sin(i / 2880 * 2 * math.pi) + random.nextDouble(),
        ),
    ];
    // Warm-up (JIT), then the median of several runs.
    stepChartPoints(changes, threshold: 1080);
    final times = <int>[];
    late List<ChartPoint> points;
    for (var run = 0; run < 7; run++) {
      final stopwatch = Stopwatch()..start();
      points = stepChartPoints(
        changes,
        threshold: 1080,
        endX: changes.last.x + 30000,
      );
      times.add(stopwatch.elapsedMicroseconds);
    }
    times.sort();
    final medianMs = times[times.length ~/ 2] / 1000;
    // ignore: avoid_print, the benchmark result is the point of this test.
    print(
      'history LTTB: ${changes.length} → ${points.length} points, '
      'median ${medianMs.toStringAsFixed(2)} ms',
    );
    expect(points.length, lessThanOrEqualTo(2 * 1080 + 1));
    expect(medianMs, lessThan(250));
  });
}
