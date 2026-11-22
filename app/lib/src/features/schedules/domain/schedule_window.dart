import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/schedules/domain/api_weekday.dart';
import 'package:meta/meta.dart';

const int _minutesPerDay = 24 * 60;

/// The days and the time window of a heating schedule, in one clock (the
/// GI Core clock or the clock the user edits in). Times are minutes after
/// midnight, 0..1439.
@immutable
final class ScheduleTimes {
  new({
    required Iterable<int> days,
    required this.startMinutes,
    required this.endMinutes,
  }) : days = Set.unmodifiable(days) {
    RangeError.checkValueInInterval(
      startMinutes,
      0,
      _minutesPerDay - 1,
      'startMinutes',
    );
    RangeError.checkValueInInterval(
      endMinutes,
      0,
      _minutesPerDay - 1,
      'endMinutes',
    );
  }

  /// The times of [schedule] as GI Core stores them; `null` when its
  /// `HH:mm` values are malformed.
  static ScheduleTimes? ofSchedule(HeatingSchedule schedule) {
    final start = schedule.startMinutes;
    final end = schedule.endMinutes;
    if (start == null || end == null) return null;
    return ScheduleTimes(
      days: schedule.daysOfWeek.where((d) => d >= 0 && d <= 6),
      startMinutes: start,
      endMinutes: end,
    );
  }

  /// GI Core days (0 = Sunday … 6 = Saturday) the window starts on.
  final Set<int> days;
  final int startMinutes;
  final int endMinutes;

  /// `start == end`: the whole of every day in [days] (GI Core accepts it;
  /// the editor warns about it).
  bool get isWholeDay => startMinutes == endMinutes;

  /// `start > end`: the window runs past midnight into the next day,
  /// anchored on the start day.
  bool get wrapsMidnight => startMinutes > endMinutes;

  String get startTime => HeatingScheduleRules.formatMinutes(startMinutes);
  String get endTime => HeatingScheduleRules.formatMinutes(endMinutes);

  /// [days] sorted 0..6, for the request body.
  List<int> get sortedDays => days.toList()..sort();

  /// GI Core's `windowMatches` (`heating-schedule-reconciliation.service
  /// .ts`) for the minute [minuteOfDay] of a day numbered [day], in the
  /// clock these times are in. Minute granularity; the start minute is
  /// inclusive, the end minute exclusive:
  ///
  /// * `start == end`: the whole day, when [day] is in [days];
  /// * `start < end`: [day] in [days] and start ≤ now < end;
  /// * `start > end`: ([day] in [days] and now ≥ start) or (the day before
  ///   is in [days] and now < end).
  bool matches(int day, int minuteOfDay) {
    final yesterday = (day + 6) % 7;
    if (isWholeDay) return days.contains(day);
    if (startMinutes < endMinutes) {
      return days.contains(day) &&
          minuteOfDay >= startMinutes &&
          minuteOfDay < endMinutes;
    }
    return (days.contains(day) && minuteOfDay >= startMinutes) ||
        (days.contains(yesterday) && minuteOfDay < endMinutes);
  }

  /// The minutes of the week this window covers, as half-open ranges of
  /// minutes since Sunday 00:00 (a wrap past Saturday continues on Sunday).
  List<({int from, int to})> weekRanges() {
    const week = 7 * _minutesPerDay;
    final length = isWholeDay
        ? _minutesPerDay
        : (endMinutes - startMinutes) % _minutesPerDay;
    final ranges = <({int from, int to})>[];
    for (final day in sortedDays) {
      final from = day * _minutesPerDay + (isWholeDay ? 0 : startMinutes);
      final to = from + length;
      if (to <= week) {
        ranges.add((from: from, to: to));
      } else {
        ranges
          ..add((from: from, to: week))
          ..add((from: 0, to: to - week));
      }
    }
    return ranges;
  }

  /// Whether this window and [other] (same clock) share at least one
  /// minute of the week. GI Core has no overlap rule: the first enabled
  /// schedule by creation wins, so this is only a client-side warning.
  bool overlaps(ScheduleTimes other) {
    for (final a in weekRanges()) {
      for (final b in other.weekRanges()) {
        if (a.from < b.to && b.from < a.to) return true;
      }
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is ScheduleTimes &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes &&
      other.days.length == days.length &&
      other.days.containsAll(days);

  @override
  int get hashCode =>
      Object.hash(startMinutes, endMinutes, Object.hashAllUnordered(days));

  @override
  String toString() => 'ScheduleTimes($sortedDays $startTime-$endTime)';
}

/// Which schedule GI Core applies, inferred on the phone: no endpoint
/// returns it (plan §4.2).
abstract final class ActiveSchedule {
  /// The first enabled schedule by `createdAt` whose window matches the GI
  /// Core clock at [coreNow] (its wall time and weekday are read as is:
  /// pass the time in the Core's zone, UTC on the appliance), or `null`.
  static HeatingSchedule? of(
    Iterable<HeatingSchedule> schedules,
    DateTime coreNow,
  ) {
    final ordered = schedules.where((s) => s.enabled).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final day = ApiWeekday.of(coreNow);
    final minute = coreNow.hour * 60 + coreNow.minute;
    for (final schedule in ordered) {
      if (ScheduleTimes.ofSchedule(schedule)?.matches(day, minute) ?? false) {
        return schedule;
      }
    }
    return null;
  }

  /// The schedules among [others] (same clock) whose windows share a
  /// minute with [times], ignoring the one with [exceptId] and disabled
  /// ones.
  static List<HeatingSchedule> overlapping(
    ScheduleTimes times,
    Iterable<HeatingSchedule> others, {
    String? exceptId,
  }) => [
    for (final other in others)
      if (other.id != exceptId && other.enabled)
        if (ScheduleTimes.ofSchedule(other) case final otherTimes?
            when otherTimes.overlaps(times))
          other,
  ];
}
