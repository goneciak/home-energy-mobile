import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostic_report_sharer.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_session_notifier.g.dart';

/// The session state of the saved appliance, mirrored from
/// [AuthSessionManager.states].
///
/// * `AsyncLoading`: the stored session is being restored (cold start, or
///   after [retryRestore]).
/// * `AsyncError`: restoring failed without ending the session (appliance
///   unreachable, secure storage unavailable, different appliance); the
///   cookie is kept and the user can retry. An appliance that was reset
///   is not an error: its cookie is wiped and the profile marked as not set
///   up, so routing shows "Finish setup" (plan §9.3).
/// * `AsyncData`: [AuthUnauthenticated], [AuthSessionLost] (also when the
///   server rejected the stored session during restore) or
///   [AuthAuthenticated]. Later changes (a refresh that ends the session,
///   `/auth/me` updates) arrive through the session stream.
///
/// On every return to the foreground while signed in, the user is reloaded
/// with `GET /auth/me` and `GET /users/me/profile` (plan §7.6, §11), so a
/// role, `mustChangePassword` or language changed on the server reaches
/// routing and settings without a cold start. A restore that failed because
/// secure storage could not be read is retried on the next return to the
/// foreground (plan §7.1: e.g. the Keychain is locked until the first unlock
/// after boot).
///
/// Every signed-in user is recorded in the profile (`lastUserId`, plan
/// §7.1).
@Riverpod(keepAlive: true)
class AuthSessionNotifier extends _$AuthSessionNotifier {
  @override
  Future<AuthState> build() async {
    final client = ref.watch(giCoreClientProvider);
    if (client == null) return const AuthState.unauthenticated();
    final initialized = ref.read(applianceProfileProvider)?.isInitialized;
    if (initialized != true) return const AuthState.unauthenticated();
    try {
      final restored = await client.restoreSession();
      if (restored case AuthAuthenticated(:final user)) _rememberUser(user);
      return restored;
    } on ApplianceResetFailure {
      await forgetResetAppliance(ref);
      return const AuthState.unauthenticated();
    } on ApiFailure catch (failure) {
      // A new address rebuilds the client, and this provider with it, so
      // the restore runs again there; this error is then discarded.
      if (_mayHaveMoved(failure)) await _rebindMovedAppliance();
      rethrow;
    } finally {
      // Subscribing after restore() avoids setting state during build; no
      // event can be missed because nothing awaits in between.
      if (ref.mounted) {
        final subscription = client.session.states.listen(_onSessionState);
        ref.onDispose(subscription.cancel);
        _reloadUserOnResume(client);
      }
    }
  }

  /// The saved address did not lead to the saved appliance: it may have a
  /// new IP address (plan §9.3).
  static bool _mayHaveMoved(ApiFailure failure) => switch (failure) {
    UnreachableFailure() ||
    TimeoutFailure() ||
    DifferentApplianceFailure() => true,
    _ => false,
  };

  /// Looks for the saved appliance under its `.local` names; one with the
  /// same fingerprint becomes the profile's address, silently and with the
  /// session kept (plan §9.3). Best effort: on any failure the original
  /// restore error stands.
  Future<void> _rebindMovedAppliance() async {
    final profile = ref.read(applianceProfileProvider);
    if (profile == null) return;
    try {
      final moved = await ref.read(connectionLadderProvider).findMoved(profile);
      if (moved == null || !ref.mounted) return;
      await ref.read(applianceProfileProvider.notifier).rebind(moved.host);
    } on Object {
      // Nothing found; the restore error is shown with "Try again".
    }
  }

  void _reloadUserOnResume(GiCoreClient client) {
    final foreground = ref.read(appForegroundProvider);
    var wasForeground = foreground.value;
    void onChange() {
      final resumed = foreground.value && !wasForeground;
      wasForeground = foreground.value;
      if (!resumed) return;
      if (state case AsyncError(error: VaultUnavailableFailure())
          when !state.isLoading) {
        retryRestore();
      } else if (client.session.state is AuthAuthenticated) {
        // Best effort: a failure keeps the cached user, and a lost session
        // already arrives through the session stream. The profile reloads
        // itself (`userProfileProvider`).
        unawaited(client.me().then<void>((_) {}, onError: (Object _) {}));
      }
    }

    foreground.addListener(onChange);
    ref.onDispose(() => foreground.removeListener(onChange));
  }

  void _onSessionState(AuthState next) {
    // `unknown` only precedes restore(); it never replaces a resolved state.
    if (next is AuthUnknown) return;
    if (next case AuthAuthenticated(:final user)) _rememberUser(user);
    state = AsyncData(next);
  }

  void _rememberUser(CurrentUser user) {
    if (!ref.mounted) return;
    unawaited(
      ref.read(applianceProfileProvider.notifier).rememberUserId(user.id),
    );
  }

  GiCoreClient get _client {
    final client = ref.read(giCoreClientProvider);
    if (client == null) throw StateError('No appliance profile');
    return client;
  }

  /// Retries a failed restore (the "Try again" button).
  void retryRestore() => ref.invalidateSelf();

  /// Throws [ApiFailure]; on success the state becomes authenticated.
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _client.login(email: email, password: password);
    await ref
        .read(applianceProfileProvider.notifier)
        .rememberUser(email: email, userId: user.id);
    return user;
  }

  /// Ends the session; local credentials (refresh cookie and access token)
  /// are always wiped, and so are the per-session preferences (the profile
  /// language) and the local diagnostics, including a report file left for
  /// the share sheet (plan §8.3: logout clears secure storage, prefs and
  /// files). The app returns to the phone language.
  ///
  /// In demo mode it only ends the demo: nothing real is wiped.
  Future<LogoutResult> logout() async {
    if (_exitDemo()) return const LogoutResult(serverSessionEnded: true);
    final diagnostics = ref.read(diagnosticsServiceProvider);
    final reports = ref.read(reportDirectoryProvider);
    final locales = ref.read(sessionLocaleStoreProvider);
    final result = await _client.logout();
    await locales.clear();
    await diagnostics.clear();
    await DiagnosticReportSharer.deleteReports(reports);
    return result;
  }

  /// After `POST /users/me/change-password` the server clears
  /// `mustChangePassword`; mirror that locally without another request.
  void markPasswordChanged() {
    final current = state.value;
    if (current is AuthAuthenticated) {
      _client.session.updateUser(
        current.user.copyWith(mustChangePassword: false),
      );
    }
  }

  /// Logs out (best effort) and removes the appliance and its stored
  /// session from this phone. Without an authenticated session (restore
  /// failed, appliance not set up) the cookie is only wiped locally.
  ///
  /// In demo mode it only ends the demo.
  Future<void> forgetAppliance() async {
    if (_exitDemo()) return;
    await _endApplianceSession();
    await ref.read(applianceProfileProvider.notifier).forget();
  }

  /// D1 = A (plan §9.2): the confirmed appliance [probe] replaces the saved
  /// one, after the user agreed. Like [forgetAppliance] the old session is
  /// ended (best effort) and its cookie, access token, preferences and
  /// diagnostics are wiped; the new profile then takes the old one's place
  /// directly, so routing never passes through "no appliance". The caches
  /// belong to the old client and go with it.
  Future<void> replaceAppliance(
    ProbeResult probe, {
    bool cleartextNoticeShown = false,
  }) async {
    // A real appliance confirmed during the demo: the demo ends first, so
    // the saved profile and its session are the ones replaced.
    _exitDemo();
    final profiles = ref.read(applianceProfileProvider.notifier);
    await _endApplianceSession();
    await profiles.replaceWith(
      ApplianceProfile.fromProbe(
        probe,
        cleartextNoticeShown: cleartextNoticeShown,
      ),
    );
  }

  /// Ends demo mode; `false` when it was not on.
  bool _exitDemo() {
    if (ref.read(demoModeProvider) == null) return false;
    ref.read(demoModeProvider.notifier).exit();
    return true;
  }

  Future<void> _endApplianceSession() async {
    final diagnostics = ref.read(diagnosticsServiceProvider);
    final reports = ref.read(reportDirectoryProvider);
    final locales = ref.read(sessionLocaleStoreProvider);
    final client = ref.read(giCoreClientProvider);
    if (client != null && client.session.state is AuthAuthenticated) {
      await client.logout();
    }
    try {
      await ref.read(tokenVaultProvider)?.clear();
    } on Object {
      // A cookie left behind is scoped to the old profile id and never read
      // again.
    }
    await locales.clear();
    await diagnostics.clear();
    await DiagnosticReportSharer.deleteReports(reports);
  }
}

/// When the current 30-day session ends, or `null` when signed out. It only
/// changes with the session state (login, restore, logout, loss): rotation
/// keeps the absolute expiry.
@riverpod
DateTime? sessionExpiresAt(Ref ref) => switch (ref.watch(authSessionProvider)) {
  AsyncData(value: AuthAuthenticated()) =>
    ref.watch(giCoreClientProvider)?.session.sessionExpiresAt,
  _ => null,
};

/// The logged-in user, or `null`. Kept alive like the session it derives
/// from, since the router guard and the shared caches listen to it.
@Riverpod(keepAlive: true)
CurrentUser? currentUser(Ref ref) => switch (ref.watch(authSessionProvider)) {
  AsyncData(value: AuthAuthenticated(:final user)) => user,
  _ => null,
};
