// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_cookie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RefreshCookie _$RefreshCookieFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_RefreshCookie', json, ($checkedConvert) {
      final val = _RefreshCookie(
        name: $checkedConvert('name', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        obtainedAt: $checkedConvert(
          'obtainedAt',
          (v) => DateTime.parse(v as String),
        ),
        absoluteExpiry: $checkedConvert(
          'absoluteExpiry',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        generation: $checkedConvert(
          'generation',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    });

Map<String, dynamic> _$RefreshCookieToJson(_RefreshCookie instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'path': instance.path,
      'obtainedAt': instance.obtainedAt.toIso8601String(),
      'absoluteExpiry': instance.absoluteExpiry?.toIso8601String(),
      'generation': instance.generation,
    };
