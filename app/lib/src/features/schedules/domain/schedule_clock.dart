import 'package:gi_home/src/features/schedules/domain/api_weekday.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_window.dart';
import 'package:meta/meta.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const int _minutesPerDay = 24 * 60;

/// A time zone the schedule screens label or convert times in: its offset
/// from UTC at any instant.
abstract interface class ScheduleZone {
  /// IANA name (`Europe/Warsaw`), or `null` for the phone's own zone, whose
  /// name the platform does not give.
  String? get name;

  /// Offset from UTC in effect at [instant].
  Duration offsetAt(DateTime instant);
}

/// An IANA zone from the bundled rules (`package:timezone`).
final class IanaScheduleZone implements ScheduleZone {
  const new _(this._location);

  /// The zone [name], or `null` when the bundled rules do not know it.
  static IanaScheduleZone? tryParse(String name) {
    _ensureDatabase();
    try {
      return IanaScheduleZone._(tz.getLocation(name));
    } on Object {
      return null;
    }
  }

  static var _loaded = false;
  static void _ensureDatabase() {
    if (_loaded) return;
    tzdata.initializeTimeZones();
    _loaded = true;
  }

  final tz.Location _location;

  @override
  String get name => _location.name;

  @override
  Duration offsetAt(DateTime instant) => Duration(
    milliseconds: _location
        .lookupTimeZone(instant.millisecondsSinceEpoch)
        .timeZone
        .offset,
  );
}

/// The phone's zone (plan §13.4: what a USER, who cannot read
/// `/settings/system`, sees next to the GI Core clock). Only a label,
/// never a conversion target.
final class PhoneScheduleZone implements ScheduleZone {
  const new();

  @override
  String? get name => null;

  @override
  Duration offsetAt(DateTime instant) => instant.toLocal().timeZoneOffset;
}

/// How schedule times are shown and edited (plan §13.4, D8, spike S7).
///
/// GI Core evaluates schedule windows on its process clock, which is UTC
/// on the appliance, not in the `/settings/system` zone. By default the
/// app therefore shows and edits the GI Core clock as is and only labels
/// it with the [zone]'s wall time today ("06:00 UTC = 07:00"). With the
/// `scheduleClockConversion` flag and a known home zone, times are edited
/// in the home zone instead and converted with *today's* offset; a window
/// then keeps its length, and its days move with the start time when the
/// conversion crosses midnight (a window is anchored on its start day on
/// the GI Core side too). Saved windows are never rewritten silently: after
/// a DST change they stay at the same GI Core time.
@immutable
final class ScheduleClock {
  const new({this.zone, this.convert = false});

  /// Only the GI Core clock, without a second zone.
  static const coreOnly = ScheduleClock();

  /// The zone shown next to the GI Core clock, `null` when none is known.
  final ScheduleZone? zone;

  /// Whether times are edited in [zone] and converted (needs an IANA home
  /// zone; the phone's zone is never a conversion target).
  final bool convert;

  /// Whether the editor works in the home zone rather than the Core clock.
  bool get convertsEdits => convert && zone is IanaScheduleZone;

  /// GI Core times of [edited] (in the editing clock), using the offset of
  /// [zone] on today's date in that zone ([now] is any instant).
  ///
  /// A wall time that does not exist on that date (spring forward, e.g.
  /// 02:30 on 2026-03-29 in Europe/Warsaw) uses the offset before the
  /// change, i.e. it is read as the same instant as 03:30 summer time. One
  /// that occurs twice (fall back, 02:30 on 2026-10-25) is the first
  /// occurrence (summer time).
  ScheduleTimes toCore(ScheduleTimes edited, {required DateTime now}) {
    final zone = this.zone;
    if (!convertsEdits || zone == null) return edited;
    final local = _wallDate(zone, now);
    final wall = local.add(Duration(minutes: edited.startMinutes));
    final instant = resolveWallTime(zone, wall);
    return _shift(edited, instant.difference(wall).inMinutes);
  }

  /// Editing-clock times of [core] (GI Core times), using the offset of
  /// [zone] at the start of the window on today's UTC date.
  ScheduleTimes toEditing(ScheduleTimes core, {required DateTime now}) {
    final zone = this.zone;
    if (!convertsEdits || zone == null) return core;
    final utc = now.toUtc();
    final start = DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
    ).add(Duration(minutes: core.startMinutes));
    return _shift(core, zone.offsetAt(start).inMinutes);
  }

  /// Wall time in [zone] (minutes after midnight) of the GI Core time
  /// [coreMinutes] today, for the dual-time label; `null` without a zone.
  int? zoneMinutesOf(int coreMinutes, {required DateTime now}) {
    final zone = this.zone;
    if (zone == null) return null;
    final utc = now.toUtc();
    final instant = DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
    ).add(Duration(minutes: coreMinutes));
    return (coreMinutes + zone.offsetAt(instant).inMinutes) % _minutesPerDay;
  }

  /// Whether [zone]'s offset changes within [within] of [now] (a DST
  /// change ahead): converted windows then move by the difference.
  bool offsetChangesSoon(
    DateTime now, {
    Duration within = const Duration(days: 14),
  }) {
    final zone = this.zone;
    if (zone == null) return false;
    return zone.offsetAt(now) != zone.offsetAt(now.add(within));
  }

  /// The UTC instant of the wall time [wall] (its fields read as a wall
  /// clock in [zone]; pass a UTC [DateTime]). See [toCore] for times that
  /// do not exist or occur twice.
  static DateTime resolveWallTime(ScheduleZone zone, DateTime wall) {
    final asUtc = DateTime.utc(
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
    );
    const day = Duration(days: 1);
    final before = zone.offsetAt(asUtc.subtract(day));
    final after = zone.offsetAt(asUtc.add(day));
    final valid = [
      for (final offset in {before, after})
        if (zone.offsetAt(asUtc.subtract(offset)) == offset) offset,
    ];
    if (valid.isEmpty) return asUtc.subtract(before);
    final first = valid.reduce((a, b) => a > b ? a : b);
    return asUtc.subtract(first);
  }

  /// Today's date in [zone] at [now], as a UTC midnight.
  static DateTime _wallDate(ScheduleZone zone, DateTime now) {
    final wall = now.toUtc().add(zone.offsetAt(now));
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  static ScheduleTimes _shift(ScheduleTimes times, int minutes) {
    final start = times.startMinutes + minutes;
    final dayShift = (start / _minutesPerDay).floor();
    return ScheduleTimes(
      days: [for (final day in times.days) ApiWeekday.shift(day, dayShift)],
      startMinutes: start % _minutesPerDay,
      endMinutes: (times.endMinutes + minutes) % _minutesPerDay,
    );
  }
}
