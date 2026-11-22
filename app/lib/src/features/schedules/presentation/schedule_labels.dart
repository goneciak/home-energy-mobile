import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/schedules/domain/api_weekday.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_window.dart';
import 'package:intl/intl.dart';

/// Short name of GI Core day [coreDay] in the app language ("pon.", "Mon").
String weekdayShort(AppLocalizations l10n, int coreDay) {
  // 2026-11-22 is a Sunday, so the 22nd + Dart weekday has that weekday.
  final date = DateTime.utc(2026, 11, 22 + ApiWeekday.toDart(coreDay));
  return DateFormat.E(l10n.localeName).format(date);
}

/// The days of a schedule, Monday first.
String daysLabel(AppLocalizations l10n, Set<int> days) => [
  for (final day in ApiWeekday.displayOrder)
    if (days.contains(day)) weekdayShort(l10n, day),
].join(', ');

/// "06:00–08:00", "22:00–06:00 (następnego dnia)" or "Cała doba".
String windowLabel(AppLocalizations l10n, ScheduleTimes times) {
  if (times.isWholeDay) return l10n.scheduleWholeDay;
  return times.wrapsMidnight
      ? l10n.scheduleTimeRangeNextDay(times.startTime, times.endTime)
      : l10n.scheduleTimeRange(times.startTime, times.endTime);
}

/// The label of the clock the schedule times are in (plan §13.4): the GI
/// Core clock with the wall time of a second zone today, or the home zone
/// when edits are converted.
String clockLabel(
  AppLocalizations l10n,
  ScheduleClock clock, {
  required DateTime now,
  int exampleMinutes = 6 * 60,
}) {
  final zone = clock.zone;
  if (clock.convertsEdits && zone?.name != null) {
    return l10n.scheduleClockConverting(zone!.name!);
  }
  final local = clock.zoneMinutesOf(exampleMinutes, now: now);
  if (zone == null || local == null) return l10n.scheduleClockCoreOnly;
  String hhmm(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:'
      '${(m % 60).toString().padLeft(2, '0')}';
  return zone is IanaScheduleZone
      ? l10n.scheduleClockDualHome(hhmm(exampleMinutes), hhmm(local))
      : l10n.scheduleClockDualPhone(hhmm(exampleMinutes), hhmm(local));
}
