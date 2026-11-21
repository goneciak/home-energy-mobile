// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CurrentUser', json, ($checkedConvert) {
      final val = _CurrentUser(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        firstName: $checkedConvert('firstName', (v) => v as String),
        mustChangePassword: $checkedConvert(
          'mustChangePassword',
          (v) => v as bool,
        ),
        lastName: $checkedConvert('lastName', (v) => v as String?),
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
      );
      return val;
    });

Map<String, dynamic> _$CurrentUserToJson(_CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'mustChangePassword': instance.mustChangePassword,
      'lastName': instance.lastName,
      'role': _$UserRoleEnumMap[instance.role]!,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'OWNER',
  UserRole.admin: 'ADMIN',
  UserRole.user: 'USER',
  UserRole.service: 'SERVICE',
  UserRole.unknown: 'UNKNOWN',
};

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_LoginResponse', json, ($checkedConvert) {
      final val = _LoginResponse(
        accessToken: $checkedConvert('accessToken', (v) => v as String),
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num).toInt()),
        user: $checkedConvert(
          'user',
          (v) => CurrentUser.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expiresIn': instance.expiresIn,
      'user': instance.user.toJson(),
    };

_RefreshResponse _$RefreshResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_RefreshResponse', json, ($checkedConvert) {
      final val = _RefreshResponse(
        accessToken: $checkedConvert('accessToken', (v) => v as String),
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$RefreshResponseToJson(_RefreshResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expiresIn': instance.expiresIn,
    };
