import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// A house-local wall-clock time without an offset, e.g. `2026-11-22T13:00`
/// from the PV forecast and the PV heating plan (Open-Meteo is asked for the
/// house timezone, so the value is NOT UTC).
///
/// Deliberately not a [DateTime]: converting it to an instant needs the
/// house timezone, which the API does not return with it. Compare and sort
/// values with [compareTo]; render [hour]/[minute] as they are.
@immutable
final class LocalWallTime implements Comparable<LocalWallTime> {
  const new(this.year, this.month, this.day, [this.hour = 0, this.minute = 0]);

  /// Parses `YYYY-MM-DD`, `YYYY-MM-DDTHH:mm` or `YYYY-MM-DDTHH:mm:ss`
  /// (seconds are dropped). An offset or `Z` is rejected: such a value is an
  /// instant, not a wall time.
  factory parse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) {
      throw FormatException('Expected a local date-time without offset', text);
    }
    final value = LocalWallTime(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
      int.parse(match[4] ?? '0'),
      int.parse(match[5] ?? '0'),
    );
    if (value.month < 1 ||
        value.month > 12 ||
        value.day < 1 ||
        value.day > 31 ||
        value.hour > 23 ||
        value.minute > 59) {
      throw FormatException('Local date-time out of range', text);
    }
    return value;
  }

  static final _pattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::\d{2}(?:\.\d+)?)?)?$',
  );

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;

  /// The calendar day of this wall time (time set to 00:00).
  LocalWallTime get date => LocalWallTime(year, month, day);

  int get _ordinal =>
      ((((year * 100 + month) * 100 + day) * 100) + hour) * 100 + minute;

  @override
  int compareTo(LocalWallTime other) => _ordinal.compareTo(other._ordinal);

  bool isBefore(LocalWallTime other) => compareTo(other) < 0;

  bool isAfter(LocalWallTime other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is LocalWallTime && other._ordinal == _ordinal;

  @override
  int get hashCode => _ordinal.hashCode;

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// `YYYY-MM-DDTHH:mm`, the format the API sends.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}'
      'T${_two(hour)}:${_two(minute)}';

  @override
  String toString() => toIso();
}

/// JSON converter for [LocalWallTime] (`YYYY-MM-DDTHH:mm`).
class LocalWallTimeConverter implements JsonConverter<LocalWallTime, String> {
  const new();

  @override
  LocalWallTime fromJson(String json) => LocalWallTime.parse(json);

  @override
  String toJson(LocalWallTime object) => object.toIso();
}

/// JSON converter for a calendar day `YYYY-MM-DD` held as a [LocalWallTime]
/// at 00:00 (weather daily rows are UTC days, PV daily rows house-local
/// days; neither is an instant).
class LocalDateConverter implements JsonConverter<LocalWallTime, String> {
  const new();

  @override
  LocalWallTime fromJson(String json) => LocalWallTime.parse(json).date;

  @override
  String toJson(LocalWallTime object) => object.toIso().substring(0, 10);
}
