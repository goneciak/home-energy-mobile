/// Why a new password breaks the GI Core rules.
enum PasswordProblem {
  empty,
  tooShort,
  tooLong,
  noLowercase,
  noUppercase,
  noDigit,
}

/// Client-side copy of the server rule for new passwords
/// (`ChangePasswordDto`, `ResetPasswordWithRecoveryDto`): 8-256 characters
/// with a lowercase letter, an uppercase letter and a digit. Shared by the
/// client (checks before sending) and the app's forms. The server stays the
/// authority.
abstract final class PasswordPolicy {
  static const minLength = 8;
  static const maxLength = 256;

  static final _lowercase = RegExp('[a-z]');
  static final _uppercase = RegExp('[A-Z]');
  static final _digit = RegExp(r'\d');

  /// The first broken rule, or `null` when [password] is acceptable.
  static PasswordProblem? check(String password) {
    if (password.isEmpty) return PasswordProblem.empty;
    if (password.length < minLength) return PasswordProblem.tooShort;
    if (password.length > maxLength) return PasswordProblem.tooLong;
    if (!_lowercase.hasMatch(password)) return PasswordProblem.noLowercase;
    if (!_uppercase.hasMatch(password)) return PasswordProblem.noUppercase;
    if (!_digit.hasMatch(password)) return PasswordProblem.noDigit;
    return null;
  }
}
