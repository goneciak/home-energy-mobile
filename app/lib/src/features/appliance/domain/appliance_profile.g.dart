// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApplianceProfile _$ApplianceProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ApplianceProfile', json, ($checkedConvert) {
      final val = _ApplianceProfile(
        profileId: $checkedConvert('profileId', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        baseUrl: $checkedConvert('baseUrl', (v) => v as String),
        hosts: $checkedConvert(
          'hosts',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
        deviceName: $checkedConvert('deviceName', (v) => v as String?),
        initializedAt: $checkedConvert(
          'initializedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        lastUserEmail: $checkedConvert('lastUserEmail', (v) => v as String?),
        lastUserId: $checkedConvert('lastUserId', (v) => v as String?),
        cleartextNoticeShown: $checkedConvert(
          'cleartextNoticeShown',
          (v) => v as bool? ?? false,
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApplianceProfileToJson(_ApplianceProfile instance) =>
    <String, dynamic>{
      'profileId': instance.profileId,
      'label': instance.label,
      'baseUrl': instance.baseUrl,
      'hosts': instance.hosts,
      'deviceName': instance.deviceName,
      'initializedAt': instance.initializedAt?.toIso8601String(),
      'lastUserEmail': instance.lastUserEmail,
      'lastUserId': instance.lastUserId,
      'cleartextNoticeShown': instance.cleartextNoticeShown,
    };
