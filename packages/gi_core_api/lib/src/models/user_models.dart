import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/enums.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

/// `GET /users/me/profile` (`users/dto/user-response.dto.ts`).
@freezed
abstract class UserProfile with _$UserProfile {
  const factory({
    required String id,
    required String email,
    required String firstName,
    required bool enabled,
    required bool mustChangePassword,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lastName,
    String? locale,
    @JsonKey(unknownEnumValue: UserRole.unknown)
    @Default(UserRole.unknown)
    UserRole role,
    DateTime? lastLoginAt,
  }) = _UserProfile;

  factory fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

/// `POST /users/me/change-password` body. Exactly these two keys.
///
/// Server rules: [newPassword] is 8-256 characters with a lowercase letter, an
/// uppercase letter and a digit; it must differ from the current password.
final class ChangePasswordRequest {
  const new({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;

  Map<String, Object?> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };

  @override
  String toString() => 'ChangePasswordRequest(<redacted>)';
}

/// `POST /users/me/change-password` 200 body. All other sessions of the user
/// are revoked; the current one stays valid.
@freezed
abstract class ChangePasswordResult with _$ChangePasswordResult {
  const factory({required int revokedSessions}) = _ChangePasswordResult;

  factory fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResultFromJson(json);
}
