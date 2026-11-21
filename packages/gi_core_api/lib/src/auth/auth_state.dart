import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/models/auth_models.dart';

part 'auth_state.freezed.dart';

/// Session state published by `AuthSessionManager.states`.
@freezed
sealed class AuthState with _$AuthState {
  /// Not resolved yet: before `restore()` or while it could not reach the
  /// appliance. A stored session may still exist.
  const factory unknown() = AuthUnknown;

  /// No session; show the login screen.
  const factory unauthenticated() = AuthUnauthenticated;

  const factory authenticated(CurrentUser user) = AuthAuthenticated;

  /// The session ended without the user's action; show the login screen
  /// with an explanation.
  const factory sessionLost(SessionLostReason reason) = AuthSessionLost;
}

/// Result of `AuthSessionManager.logout()`. Local data is always wiped.
final class LogoutResult {
  const new({required this.serverSessionEnded});

  /// `false` when the server could not be told; the session then stays on
  /// the appliance until it expires or is removed in the web panel
  /// (Profile → Sessions).
  final bool serverSessionEnded;
}
