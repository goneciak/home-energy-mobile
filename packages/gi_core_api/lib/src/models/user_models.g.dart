// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_UserProfile', json, ($checkedConvert) {
  final val = _UserProfile(
    id: $checkedConvert('id', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    firstName: $checkedConvert('firstName', (v) => v as String),
    enabled: $checkedConvert('enabled', (v) => v as bool),
    mustChangePassword: $checkedConvert('mustChangePassword', (v) => v as bool),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    lastName: $checkedConvert('lastName', (v) => v as String?),
    locale: $checkedConvert('locale', (v) => v as String?),
    role: $checkedConvert(
      'role',
      (v) =>
          $enumDecodeNullable(
            _$UserRoleEnumMap,
            v,
            unknownValue: UserRole.unknown,
          ) ??
          UserRole.unknown,
    ),
    lastLoginAt: $checkedConvert(
      'lastLoginAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'enabled': instance.enabled,
      'mustChangePassword': instance.mustChangePassword,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastName': instance.lastName,
      'locale': instance.locale,
      'role': _$UserRoleEnumMap[instance.role]!,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'OWNER',
  UserRole.admin: 'ADMIN',
  UserRole.user: 'USER',
  UserRole.service: 'SERVICE',
  UserRole.unknown: 'UNKNOWN',
};

_ChangePasswordResult _$ChangePasswordResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ChangePasswordResult', json, ($checkedConvert) {
  final val = _ChangePasswordResult(
    revokedSessions: $checkedConvert(
      'revokedSessions',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChangePasswordResultToJson(
  _ChangePasswordResult instance,
) => <String, dynamic>{'revokedSessions': instance.revokedSessions};
