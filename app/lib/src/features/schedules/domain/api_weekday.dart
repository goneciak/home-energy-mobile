/// Day-of-week numbering of GI Core's heating schedules: JavaScript
/// `Date.getDay()`, 0 = Sunday … 6 = Saturday (`daysOfWeek` in
/// `heating-schedule.dto.ts`). Dart's [DateTime.weekday] is 1 = Monday …
/// 7 = Sunday, so only Sunday differs.
abstract final class ApiWeekday {
  static const sunday = 0;
  static const monday = 1;
  static const saturday = 6;

  /// The days of a week in the order the app shows them (Monday first).
  static const displayOrder = [1, 2, 3, 4, 5, 6, 0];

  /// GI Core day of a Dart [DateTime.weekday] (Sunday 7 → 0).
  static int fromDart(int dartWeekday) {
    RangeError.checkValueInInterval(
      dartWeekday,
      DateTime.monday,
      DateTime.sunday,
      'dartWeekday',
    );
    return dartWeekday % 7;
  }

  /// Dart [DateTime.weekday] of a GI Core day (0 → Sunday 7).
  static int toDart(int coreDay) {
    RangeError.checkValueInInterval(coreDay, sunday, saturday, 'coreDay');
    return coreDay == sunday ? DateTime.sunday : coreDay;
  }

  /// GI Core day of the calendar day of [time] (in its own zone).
  static int of(DateTime time) => fromDart(time.weekday);

  /// [coreDay] moved by [days] (any sign), wrapping around the week.
  static int shift(int coreDay, int days) => (coreDay + days) % 7;
}
