import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';

/// Route paths of the app.
abstract final class AppRoutes {
  static const connect = '/connect';
  static const setupRequired = '/setup-required';
  static const restore = '/restore';
  static const login = '/login';
  static const changePassword = '/change-password';
  static const home = '/home';
  static const settings = '/settings';

  /// "Znajdź GI Home" with a profile saved (plan §9.2): the connect screen,
  /// opened from a failed restore. It stays open in every session phase; a
  /// candidate the user confirms keeps or replaces the profile.
  static const findAppliance = '/find-appliance';

  /// The hidden experimental features screen (dev and beta), under
  /// Settings.
  static const experimental = '$settings/experimental';

  /// Read-only details of device [id], nested under Home.
  static String device(String id) => '$home/devices/${Uri.encodeComponent(id)}';

  /// Query parameter of a gate holding the shell location the user was
  /// headed to (a deep link, or a cold start into device details).
  static const fromParam = 'from';

  /// Whether [location] is a path inside the signed-in shell (never another
  /// host or scheme), so it is safe to return to after a gate.
  static bool isShellLocation(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return false;
    return uri.path == home ||
        uri.path.startsWith('$home/') ||
        uri.path == settings;
  }

  /// Routes that stand before the signed-in shell.
  static const Set<String> gates = {
    connect,
    setupRequired,
    restore,
    login,
    changePassword,
  };
}

/// Where the session is, as far as routing cares.
enum SessionPhase {
  /// The stored session is being restored.
  restoring,

  /// Restoring failed without ending the session (offline, vault, ...).
  restoreFailed,

  /// No session: never logged in, logged out or session lost.
  signedOut,

  signedIn;

  static SessionPhase of(AsyncValue<AuthState> auth) {
    if (auth.isLoading) return restoring;
    if (auth.hasError) return restoreFailed;
    return switch (auth.value) {
      AuthAuthenticated() => signedIn,
      AuthUnauthenticated() || AuthSessionLost() => signedOut,
      AuthUnknown() || null => restoring,
    };
  }
}

/// Everything the redirect depends on.
@immutable
final class RouteGuardState {
  const new({
    required this.hasProfile,
    required this.applianceInitialized,
    required this.session,
    required this.mustChangePassword,
  });

  final bool hasProfile;
  final bool applianceInitialized;
  final SessionPhase session;
  final bool mustChangePassword;

  @override
  bool operator ==(Object other) =>
      other is RouteGuardState &&
      other.hasProfile == hasProfile &&
      other.applianceInitialized == applianceInitialized &&
      other.session == session &&
      other.mustChangePassword == mustChangePassword;

  @override
  int get hashCode => Object.hash(
    hasProfile,
    applianceInitialized,
    session,
    mustChangePassword,
  );

  @override
  String toString() =>
      'RouteGuardState(profile: $hasProfile, initialized: '
      '$applianceInitialized, session: ${session.name}, '
      'mustChangePassword: $mustChangePassword)';
}

/// The redirect for [location] (path and query) under [state], or `null` to
/// stay.
///
/// Guards apply in order: no profile → connect; "Znajdź GI Home" stays
/// open while a profile exists; appliance not set up →
/// setup required; session restoring or failed → restore; signed out →
/// login; password change required → change password; otherwise the shell.
/// A shell location (other than Home) stopped by the session gates travels
/// along as `?from=` and is opened once signed in. Each target is a fixed
/// point for the same state, so redirects never loop.
String? resolveRedirect(RouteGuardState state, String location) {
  final uri = Uri.parse(location);
  final onGate = AppRoutes.gates.contains(uri.path);
  final requested = onGate
      ? uri.queryParameters[AppRoutes.fromParam]
      : location;
  final from =
      requested != null &&
          requested != AppRoutes.home &&
          AppRoutes.isShellLocation(requested)
      ? requested
      : null;

  String? goTo(String target, {bool keepFrom = false}) {
    if (uri.path == target) return null;
    if (!keepFrom || from == null) return target;
    return Uri(
      path: target,
      queryParameters: {AppRoutes.fromParam: from},
    ).toString();
  }

  if (!state.hasProfile) return goTo(AppRoutes.connect);
  if (uri.path == AppRoutes.findAppliance) return null;
  if (!state.applianceInitialized) return goTo(AppRoutes.setupRequired);
  switch (state.session) {
    case SessionPhase.restoring || SessionPhase.restoreFailed:
      return goTo(AppRoutes.restore, keepFrom: true);
    case SessionPhase.signedOut:
      return goTo(AppRoutes.login, keepFrom: true);
    case SessionPhase.signedIn:
      break;
  }
  if (state.mustChangePassword) {
    return goTo(AppRoutes.changePassword, keepFrom: true);
  }
  return onGate ? from ?? AppRoutes.home : null;
}
