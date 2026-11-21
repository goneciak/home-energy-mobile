import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/enums.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// `GET /auth/me` and the `user` part of the login response
/// (`auth/dto/auth-user.dto.ts`).
@freezed
abstract class CurrentUser with _$CurrentUser {
  const factory({
    required String id,
    required String email,
    required String firstName,
    required bool mustChangePassword,
    String? lastName,
    @JsonKey(unknownEnumValue: UserRole.unknown)
    @Default(UserRole.unknown)
    UserRole role,
  }) = _CurrentUser;

  factory fromJson(Map<String, dynamic> json) => _$CurrentUserFromJson(json);
}

/// `POST /auth/login` 200 body. The refresh token is never in the body; it
/// only arrives as `Set-Cookie`.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory({
    required String accessToken,
    required int expiresIn,
    required CurrentUser user,
  }) = _LoginResponse;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  @override
  String toString() => 'LoginResponse(expiresIn: $expiresIn, user: $user)';
}

/// `POST /auth/refresh` 200 body (`auth/dto/auth-token-response.dto.ts`).
@freezed
abstract class RefreshResponse with _$RefreshResponse {
  const factory({required String accessToken, required int expiresIn}) =
      _RefreshResponse;

  const new _();

  factory fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);

  @override
  String toString() => 'RefreshResponse(expiresIn: $expiresIn)';
}

/// `POST /auth/login` body. Exactly these two keys: the backend's
/// ValidationPipe rejects anything else.
final class LoginRequest {
  const new({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, Object?> toJson() => {'email': email, 'password': password};

  @override
  String toString() => 'LoginRequest(email: <redacted>, password: <redacted>)';
}
