// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntityHistory _$EntityHistoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_EntityHistory', json, ($checkedConvert) {
      final val = _EntityHistory(
        entityId: $checkedConvert('entityId', (v) => v as String),
        from: $checkedConvert('from', (v) => DateTime.parse(v as String)),
        to: $checkedConvert('to', (v) => DateTime.parse(v as String)),
        samples: $checkedConvert(
          'samples',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) => HistorySample.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const <HistorySample>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$EntityHistoryToJson(_EntityHistory instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'samples': instance.samples.map((e) => e.toJson()).toList(),
    };

_HistorySample _$HistorySampleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HistorySample', json, ($checkedConvert) {
      final val = _HistorySample(
        at: $checkedConvert('at', (v) => DateTime.parse(v as String)),
        kind: $checkedConvert(
          'kind',
          (v) =>
              $enumDecodeNullable(
                _$HistorySampleKindEnumMap,
                v,
                unknownValue: HistorySampleKind.unknown,
              ) ??
              HistorySampleKind.unknown,
        ),
        value: $checkedConvert('value', (v) => v),
        unit: $checkedConvert('unit', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$HistorySampleToJson(_HistorySample instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'kind': _$HistorySampleKindEnumMap[instance.kind]!,
      'value': instance.value,
      'unit': instance.unit,
    };

const _$HistorySampleKindEnumMap = {
  HistorySampleKind.temperature: 'temperature',
  HistorySampleKind.energy: 'energy',
  HistorySampleKind.numeric: 'numeric',
  HistorySampleKind.switch_: 'switch',
  HistorySampleKind.text: 'text',
  HistorySampleKind.unknown: 'unknown',
};
