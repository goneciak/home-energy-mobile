import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/converters/json_converters.dart';

part 'heating_schedule.freezed.dart';
part 'heating_schedule.g.dart';

/// One row of `GET /devices/:deviceId/schedules` (raw Prisma
/// `HeatingSchedule`); also the body of the POST (201) and PATCH (200).
///
/// [daysOfWeek] uses the JavaScript `getDay()` numbering: 0 = Sunday …
/// 6 = Saturday. [startTime]/[endTime] are `HH:mm`, evaluated on the GI Core
/// process clock (UTC on the appliance, spike S7). `start == end` is a
/// whole-day window; `start > end` wraps past midnight, anchored on the start
/// day.
@freezed
abstract class HeatingSchedule with _$HeatingSchedule {
  const factory({
    required String id,
    required String deviceId,
    required String name,
    required List<int> daysOfWeek,
    required String startTime,
    required String endTime,
    @NumOrStringConverter() required double targetTemperatureCelsius,
    @NumOrStringConverter() required double hysteresisCelsius,
    required bool enabled,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HeatingSchedule;

  const new _();

  factory fromJson(Map<String, dynamic> json) =>
      _$HeatingScheduleFromJson(json);

  /// [startTime] as minutes after midnight; `null` when malformed.
  int? get startMinutes => HeatingScheduleRules.minutesOf(startTime);

  /// [endTime] as minutes after midnight; `null` when malformed.
  int? get endMinutes => HeatingScheduleRules.minutesOf(endTime);
}

/// A rule of the server's create/update DTO that an input breaks.
enum ScheduleInputProblem {
  /// Name empty or longer than 120 characters.
  name,

  /// No day, more than 7, a duplicate or a value outside 0..6.
  daysOfWeek,

  /// Not zero-padded 24h `HH:mm` (`24:00` and `6:00` are rejected).
  startTime,
  endTime,

  /// Outside 0..100 °C or not finite.
  targetTemperature,

  /// Outside 1..20 °C or not finite.
  hysteresis,
}

/// Client-side mirror of `heating-schedule.dto.ts`. The server has NO
/// cross-field rules: overlapping schedules, `start == end`, duplicate names
/// and any number of schedules are accepted.
abstract final class HeatingScheduleRules {
  static const nameMaxLength = 120;
  static const minTarget = 0.0;
  static const maxTarget = 100.0;
  static const minHysteresis = 1.0;
  static const maxHysteresis = 20.0;

  static final timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  /// `HH:mm` as minutes after midnight; `null` when it breaks [timePattern].
  static int? minutesOf(String time) {
    if (!timePattern.hasMatch(time)) return null;
    return int.parse(time.substring(0, 2)) * 60 + int.parse(time.substring(3));
  }

  /// Minutes after midnight as zero-padded `HH:mm`.
  static String formatMinutes(int minutes) {
    if (minutes < 0 || minutes >= 24 * 60) {
      throw RangeError.range(minutes, 0, 24 * 60 - 1, 'minutes');
    }
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
  }

  static bool validName(String name) =>
      name.isNotEmpty && name.length <= nameMaxLength;

  static bool validDays(List<int> days) =>
      days.isNotEmpty &&
      days.length <= 7 &&
      days.toSet().length == days.length &&
      days.every((d) => d >= 0 && d <= 6);

  static bool validTime(String time) => timePattern.hasMatch(time);

  static bool validTarget(double value) =>
      value.isFinite && value >= minTarget && value <= maxTarget;

  static bool validHysteresis(double value) =>
      value.isFinite && value >= minHysteresis && value <= maxHysteresis;
}

/// `POST /devices/:deviceId/schedules` body. Serializes exactly the DTO keys
/// (unknown keys fail with `VALIDATION_FAILED`).
@immutable
final class HeatingScheduleInput {
  const new({
    required this.name,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.targetTemperatureCelsius,
    required this.hysteresisCelsius,
    this.enabled = true,
  });

  final String name;

  /// 0 = Sunday … 6 = Saturday.
  final List<int> daysOfWeek;
  final String startTime;
  final String endTime;
  final double targetTemperatureCelsius;
  final double hysteresisCelsius;
  final bool enabled;

  /// Rules of the server DTO this input breaks; empty when it is valid.
  Set<ScheduleInputProblem> validate() => {
    if (!HeatingScheduleRules.validName(name)) ScheduleInputProblem.name,
    if (!HeatingScheduleRules.validDays(daysOfWeek))
      ScheduleInputProblem.daysOfWeek,
    if (!HeatingScheduleRules.validTime(startTime))
      ScheduleInputProblem.startTime,
    if (!HeatingScheduleRules.validTime(endTime)) ScheduleInputProblem.endTime,
    if (!HeatingScheduleRules.validTarget(targetTemperatureCelsius))
      ScheduleInputProblem.targetTemperature,
    if (!HeatingScheduleRules.validHysteresis(hysteresisCelsius))
      ScheduleInputProblem.hysteresis,
  };

  Map<String, Object?> toJson() => {
    'name': name,
    'daysOfWeek': [...daysOfWeek],
    'startTime': startTime,
    'endTime': endTime,
    'targetTemperatureCelsius': targetTemperatureCelsius,
    'hysteresisCelsius': hysteresisCelsius,
    'enabled': enabled,
  };
}

/// `PATCH /devices/:deviceId/schedules/:scheduleId` body: only the fields
/// that are set are sent; an empty patch (`{}`) is valid.
@immutable
final class HeatingSchedulePatch {
  const new({
    this.name,
    this.daysOfWeek,
    this.startTime,
    this.endTime,
    this.targetTemperatureCelsius,
    this.hysteresisCelsius,
    this.enabled,
  });

  final String? name;
  final List<int>? daysOfWeek;
  final String? startTime;
  final String? endTime;
  final double? targetTemperatureCelsius;
  final double? hysteresisCelsius;
  final bool? enabled;

  Set<ScheduleInputProblem> validate() => {
    if (name case final v? when !HeatingScheduleRules.validName(v))
      ScheduleInputProblem.name,
    if (daysOfWeek case final v? when !HeatingScheduleRules.validDays(v))
      ScheduleInputProblem.daysOfWeek,
    if (startTime case final v? when !HeatingScheduleRules.validTime(v))
      ScheduleInputProblem.startTime,
    if (endTime case final v? when !HeatingScheduleRules.validTime(v))
      ScheduleInputProblem.endTime,
    if (targetTemperatureCelsius case final v?
        when !HeatingScheduleRules.validTarget(v))
      ScheduleInputProblem.targetTemperature,
    if (hysteresisCelsius case final v?
        when !HeatingScheduleRules.validHysteresis(v))
      ScheduleInputProblem.hysteresis,
  };

  Map<String, Object?> toJson() => {
    'name': ?name,
    if (daysOfWeek case final days?) 'daysOfWeek': [...days],
    'startTime': ?startTime,
    'endTime': ?endTime,
    'targetTemperatureCelsius': ?targetTemperatureCelsius,
    'hysteresisCelsius': ?hysteresisCelsius,
    'enabled': ?enabled,
  };
}
