import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/history/domain/history_series.dart';
import 'package:gi_home/src/features/history/domain/history_window.dart';

/// "24 h" on the range selector.
String historyWindowLabel(AppLocalizations l10n, HistoryWindow window) =>
    switch (window) {
      HistoryWindow.hour => l10n.historyWindowHour,
      HistoryWindow.sixHours => l10n.historyWindowSixHours,
      HistoryWindow.day => l10n.historyWindowDay,
      HistoryWindow.week => l10n.historyWindowWeek,
    };

/// "ostatnia doba" inside a sentence.
String historyWindowLongLabel(AppLocalizations l10n, HistoryWindow window) =>
    switch (window) {
      HistoryWindow.hour => l10n.historyWindowHourLong,
      HistoryWindow.sixHours => l10n.historyWindowSixHoursLong,
      HistoryWindow.day => l10n.historyWindowDayLong,
      HistoryWindow.week => l10n.historyWindowWeekLong,
    };

/// A recorded value as the device details show it ("45,5 °C", "włączony").
String formatHistoryValue(
  AppLocalizations l10n,
  HistorySample sample, {
  String? deviceClass,
}) => formatEntityValue(
  l10n,
  EntityValue.parse(sample.value),
  unit: sample.unit,
  deviceClass: sample.kind == HistorySampleKind.temperature
      ? 'temperature'
      : deviceClass,
);

/// A chart value [y] in the unit of [sample] (the kind and unit of the
/// series).
String formatHistoryNumber(
  AppLocalizations l10n,
  double y,
  HistorySample sample, {
  String? deviceClass,
}) => formatHistoryValue(
  l10n,
  sample.copyWith(value: y),
  deviceClass: deviceClass,
);

/// The screen reader summary of a chart (plan §13.3): range, extremes and
/// the latest value, or for a switch the latest state and the toggles.
String historySemanticsLabel(
  AppLocalizations l10n, {
  required String name,
  required HistoryWindow window,
  required HistorySummary summary,
  String? deviceClass,
}) {
  final last = summary.last;
  if (last == null) return l10n.historyEmptyTitle;
  final range = historyWindowLongLabel(l10n, window);
  final lastValue = formatHistoryValue(l10n, last, deviceClass: deviceClass);
  final time = formatDateTime(l10n, last.at);
  final min = summary.min;
  final max = summary.max;
  if (min == null || max == null) {
    return l10n.historySwitchSemantics(
      name,
      range,
      // Inside a sentence: "ostatnio wł." rather than "ostatnio Wł.".
      lastValue.toLowerCase(),
      time,
      summary.count,
    );
  }
  return l10n.historyChartSemantics(
    name,
    range,
    formatHistoryNumber(l10n, min, last, deviceClass: deviceClass),
    formatHistoryNumber(l10n, max, last, deviceClass: deviceClass),
    lastValue,
    time,
    summary.count,
  );
}
