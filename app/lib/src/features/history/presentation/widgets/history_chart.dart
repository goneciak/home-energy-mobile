import 'package:fl_chart/fl_chart.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

const _msPerHour = 3600000;

/// A step chart of a change log (`fl_chart`). The picture is hidden from
/// screen readers, which read [semanticsLabel] instead (the summary; the
/// values themselves are in the table, plan §5.2).
///
/// A switch is drawn as an on/off band (0/1); any other series as a line
/// between its rounded extremes.
class HistoryChart extends StatelessWidget {
  const new({
    required this.points,
    required this.from,
    required this.to,
    required this.window,
    required this.semanticsLabel,
    required this.formatValue,
    this.isSwitch = false,
    super.key,
  });

  /// Step points from `stepChartPoints`, x in epoch milliseconds.
  final List<ChartPoint> points;
  final DateTime from;
  final DateTime to;
  final HistoryWindow window;
  final String semanticsLabel;

  /// Axis label of a value (without the unit for numbers).
  final String Function(double value) formatValue;
  final bool isSwitch;

  static const height = 220.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final l10n = context.l10n;
    final labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: tokens.textMuted);
    // Hours in the local wall clock, so ticks fall on full local hours and
    // midnights.
    final offset = to.toLocal().timeZoneOffset.inMilliseconds;
    double hours(num ms) => (ms + offset) / _msPerHour;
    DateTime wallTime(double x) => DateTime.fromMillisecondsSinceEpoch(
      (x * _msPerHour - offset).round(),
      isUtc: true,
    ).toLocal();

    final spots = [for (final p in points) FlSpot(hours(p.x), p.y)];
    final (minY, maxY) = isSwitch ? (0.0, 1.0) : _paddedRange(points);
    final bottomFormat = window == HistoryWindow.week
        ? DateFormat.Md(l10n.localeName)
        : DateFormat.Hm(l10n.localeName);
    final grid = tokens.textMuted.withValues(alpha: 0.25);

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: MediaQuery.withClampedTextScaling(
          // Axis labels are a visual aid; the table carries the values.
          maxScaleFactor: 1.3,
          child: SizedBox(
            height: height,
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: hours(from.millisecondsSinceEpoch),
                maxX: hours(to.millisecondsSinceEpoch),
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
                lineTouchData: const LineTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: isSwitch ? 1 : null,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: grid, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isSwitch ? 56 : 44,
                      interval: isSwitch ? 1 : null,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          isSwitch
                              ? (value >= 0.5
                                    ? l10n.entityValueOn
                                    : l10n.entityValueOff)
                              : formatValue(value),
                          style: labelStyle,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(window),
                      minIncluded: false,
                      maxIncluded: false,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          bottomFormat.format(wallTime(value)),
                          style: labelStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: isSwitch ? tokens.teal : tokens.ember,
                    barWidth: isSwitch ? 1.5 : 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: isSwitch,
                      color: tokens.teal.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _bottomInterval(HistoryWindow window) => switch (window) {
    HistoryWindow.hour => 0.25,
    HistoryWindow.sixHours => 2,
    HistoryWindow.day => 6,
    HistoryWindow.week => 48,
  };

  /// Min and max of [points] padded and rounded to whole units, so the line
  /// never touches the frame; a flat series gets ±1.
  static (double, double) _paddedRange(List<ChartPoint> points) {
    var min = double.infinity;
    var max = double.negativeInfinity;
    for (final p in points) {
      if (p.y < min) min = p.y;
      if (p.y > max) max = p.y;
    }
    if (!min.isFinite || !max.isFinite) return (0, 1);
    if (max - min < 1) {
      return ((min - 1).floorToDouble(), (max + 1).ceilToDouble());
    }
    final pad = (max - min) * 0.1;
    return ((min - pad).floorToDouble(), (max + pad).ceilToDouble());
  }
}
