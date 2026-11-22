// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSessionInfo _$AuthSessionInfoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AuthSessionInfo', json, ($checkedConvert) {
  final val = _AuthSessionInfo(
    id: $checkedConvert('id', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    expiresAt: $checkedConvert('expiresAt', (v) => DateTime.parse(v as String)),
    current: $checkedConvert('current', (v) => v as bool? ?? false),
    lastUsedAt: $checkedConvert(
      'lastUsedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    userAgent: $checkedConvert('userAgent', (v) => v as String?),
    ipAddress: $checkedConvert('ipAddress', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AuthSessionInfoToJson(_AuthSessionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'current': instance.current,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'userAgent': instance.userAgent,
      'ipAddress': instance.ipAddress,
    };

_RecoveryCodeResult _$RecoveryCodeResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_RecoveryCodeResult', json, ($checkedConvert) {
      final val = _RecoveryCodeResult(
        recoveryCode: $checkedConvert('recoveryCode', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RecoveryCodeResultToJson(_RecoveryCodeResult instance) =>
    <String, dynamic>{'recoveryCode': instance.recoveryCode};
