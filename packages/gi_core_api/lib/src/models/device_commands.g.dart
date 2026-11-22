// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_commands.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwitchCommandResult _$SwitchCommandResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SwitchCommandResult', json, ($checkedConvert) {
      final val = _SwitchCommandResult(
        entityId: $checkedConvert('entityId', (v) => v as String),
        confirmedAt: $checkedConvert(
          'confirmedAt',
          (v) => DateTime.parse(v as String),
        ),
        state: $checkedConvert('state', (v) => v),
        availability: $checkedConvert('availability', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$SwitchCommandResultToJson(
  _SwitchCommandResult instance,
) => <String, dynamic>{
  'entityId': instance.entityId,
  'confirmedAt': instance.confirmedAt.toIso8601String(),
  'state': instance.state,
  'availability': instance.availability,
};

_ControlStrategyUpdateResult _$ControlStrategyUpdateResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ControlStrategyUpdateResult', json, ($checkedConvert) {
  final val = _ControlStrategyUpdateResult(
    configurationVersion: $checkedConvert(
      'configurationVersion',
      (v) => (v as num).toInt(),
    ),
    controlStrategy: $checkedConvert(
      'controlStrategy',
      (v) => const ControlStrategyConverter().fromJson(v),
    ),
    baseControlStrategy: $checkedConvert(
      'baseControlStrategy',
      (v) => const ControlStrategyConverter().fromJson(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ControlStrategyUpdateResultToJson(
  _ControlStrategyUpdateResult instance,
) => <String, dynamic>{
  'configurationVersion': instance.configurationVersion,
  'controlStrategy': const ControlStrategyConverter().toJson(
    instance.controlStrategy,
  ),
  'baseControlStrategy': const ControlStrategyConverter().toJson(
    instance.baseControlStrategy,
  ),
};
