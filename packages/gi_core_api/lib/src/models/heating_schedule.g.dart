// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heating_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HeatingSchedule _$HeatingScheduleFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_HeatingSchedule', json, ($checkedConvert) {
  final val = _HeatingSchedule(
    id: $checkedConvert('id', (v) => v as String),
    deviceId: $checkedConvert('deviceId', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    daysOfWeek: $checkedConvert(
      'daysOfWeek',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    startTime: $checkedConvert('startTime', (v) => v as String),
    endTime: $checkedConvert('endTime', (v) => v as String),
    targetTemperatureCelsius: $checkedConvert(
      'targetTemperatureCelsius',
      (v) => const NumOrStringConverter().fromJson(v),
    ),
    hysteresisCelsius: $checkedConvert(
      'hysteresisCelsius',
      (v) => const NumOrStringConverter().fromJson(v),
    ),
    enabled: $checkedConvert('enabled', (v) => v as bool),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$HeatingScheduleToJson(_HeatingSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'name': instance.name,
      'daysOfWeek': instance.daysOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'targetTemperatureCelsius': const NumOrStringConverter().toJson(
        instance.targetTemperatureCelsius,
      ),
      'hysteresisCelsius': const NumOrStringConverter().toJson(
        instance.hysteresisCelsius,
      ),
      'enabled': instance.enabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
