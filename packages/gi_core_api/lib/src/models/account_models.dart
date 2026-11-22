import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/password_policy.dart';

part 'account_models.freezed.dart';
part 'account_models.g.dart';

/// One row of `GET /auth/sessions` (`auth/dto/auth-session.dto.ts`): only
/// sessions that are neither revoked nor expired, newest first. [current]
/// marks the session of this phone.
@freezed
abstract class AuthSessionInfo with _$AuthSessionInfo {
  const factory({
    required String id,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(false) bool current,
    DateTime? lastUsedAt,
    String? userAgent,
    String? ipAddress,
  }) = _AuthSessionInfo;

  factory fromJson(Map<String, dynamic> json) =>
      _$AuthSessionInfoFromJson(json);
}

/// `POST /auth/recovery/regenerate` 200 body. Shown once; the previous code
/// stops working. Never logged: [toString] hides the code.
@freezed
abstract class RecoveryCodeResult with _$RecoveryCodeResult {
  const factory({required String recoveryCode}) = _RecoveryCodeResult;

  const new _();

  factory fromJson(Map<String, dynamic> json) =>
      _$RecoveryCodeResultFromJson(json);

  @override
  String toString() => 'RecoveryCodeResult(<redacted>)';
}

/// Why a typed recovery code cannot be what the server issued.
enum RecoveryCodeProblem {
  empty,

  /// Longer than the server's 64-character limit.
  tooLong,

  /// 32 hex digits without the `-` separators (or separated by spaces). The
  /// server keeps dashes when it compares, so it would reject this;
  /// [RecoveryCodeFormat.canonical] restores them.
  missingDashes,

  /// Not 8 groups of 4 hex digits.
  malformed,
}

/// The recovery code format (`recovery-code.ts`): 32 uppercase hex digits in
/// 8 groups of 4 joined by `-`. The server normalises with trim, uppercase
/// and whitespace removal only; dashes are significant.
abstract final class RecoveryCodeFormat {
  static const groups = 8;
  static const groupLength = 4;
  static const maxLength = 64;

  static final _canonical = RegExp(r'^[0-9A-F]{4}(-[0-9A-F]{4}){7}$');
  static final _whitespace = RegExp(r'\s+');
  static final _digits = RegExp(r'^[0-9A-F]{32}$');

  /// What the server does to a code: trim, uppercase, drop whitespace.
  static String normalize(String input) =>
      input.trim().toUpperCase().replaceAll(_whitespace, '');

  /// The dashed form of [input] when it holds a recovery code with or
  /// without separators (dashes, spaces or none), otherwise `null`.
  static String? canonical(String input) {
    final upper = input.trim().toUpperCase();
    final dashed = upper.replaceAll(_whitespace, '');
    if (_canonical.hasMatch(dashed)) return dashed;
    final groupsOnly = upper.replaceAll(RegExp(r'[\s-]+'), '');
    if (!_digits.hasMatch(groupsOnly)) return null;
    return [
      for (var i = 0; i < groups; i++)
        groupsOnly.substring(i * groupLength, (i + 1) * groupLength),
    ].join('-');
  }

  /// `null` when [input], as the server normalises it, is a well-formed
  /// code; otherwise the first problem.
  static RecoveryCodeProblem? check(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) return RecoveryCodeProblem.empty;
    if (normalized.length > maxLength) return RecoveryCodeProblem.tooLong;
    if (_canonical.hasMatch(normalized)) return null;
    return canonical(input) == null
        ? RecoveryCodeProblem.malformed
        : RecoveryCodeProblem.missingDashes;
  }
}

/// Why a field of a recovery reset request breaks the server rules.
enum RecoveryResetProblem { email, recoveryCode, newPassword }

/// `POST /auth/recovery/reset` body (public; 5 requests per 15 min). Exactly
/// these three keys. The code is sent in its dashed [RecoveryCodeFormat]
/// form when it can be restored, otherwise as the server would normalise
/// it. Never logged: [toString] hides every field.
final class RecoveryResetRequest {
  const new({
    required this.email,
    required this.recoveryCode,
    required this.newPassword,
  });

  final String email;
  final String recoveryCode;
  final String newPassword;

  static const emailMaxLength = 254;
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// The code as it goes on the wire.
  String get wireRecoveryCode =>
      RecoveryCodeFormat.canonical(recoveryCode) ??
      RecoveryCodeFormat.normalize(recoveryCode);

  Set<RecoveryResetProblem> validate() {
    final mail = email.trim();
    final code = wireRecoveryCode;
    return {
      if (mail.isEmpty ||
          mail.length > emailMaxLength ||
          !_email.hasMatch(mail))
        RecoveryResetProblem.email,
      if (code.isEmpty || code.length > RecoveryCodeFormat.maxLength)
        RecoveryResetProblem.recoveryCode,
      if (PasswordPolicy.check(newPassword) != null)
        RecoveryResetProblem.newPassword,
    };
  }

  Map<String, Object?> toJson() => {
    'email': email.trim(),
    'recoveryCode': wireRecoveryCode,
    'newPassword': newPassword,
  };

  @override
  String toString() => 'RecoveryResetRequest(<redacted>)';
}

/// Why a field of a profile update breaks the server rules.
enum ProfileUpdateProblem { firstName, lastName, locale }

/// `PATCH /users/me/profile` body (`UpdateProfileDto`): only the fields set
/// are sent, each trimmed. An empty [lastName] clears it on the server.
@immutable
final class ProfileUpdate {
  const new({this.firstName, this.lastName, this.locale});

  final String? firstName;
  final String? lastName;

  /// BCP 47 tag, e.g. `pl-PL` or `en-US`.
  final String? locale;

  static const nameMaxLength = 100;
  static final _locale = RegExp(r'^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8})*$');

  bool get isEmpty => firstName == null && lastName == null && locale == null;

  Set<ProfileUpdateProblem> validate() {
    final first = firstName?.trim();
    final last = lastName?.trim();
    final tag = locale?.trim();
    return {
      if (first != null && (first.isEmpty || first.length > nameMaxLength))
        ProfileUpdateProblem.firstName,
      if (last != null && last.length > nameMaxLength)
        ProfileUpdateProblem.lastName,
      if (tag != null && !_locale.hasMatch(tag)) ProfileUpdateProblem.locale,
    };
  }

  Map<String, Object?> toJson() => {
    if (firstName != null) 'firstName': firstName!.trim(),
    if (lastName != null) 'lastName': lastName!.trim(),
    if (locale != null) 'locale': locale!.trim(),
  };

  @override
  bool operator ==(Object other) =>
      other is ProfileUpdate &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.locale == locale;

  @override
  int get hashCode => Object.hash(firstName, lastName, locale);
}
