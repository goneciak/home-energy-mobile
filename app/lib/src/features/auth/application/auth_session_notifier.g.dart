// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthSessionNotifier)
final authSessionProvider = AuthSessionNotifierProvider._();

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
final class AuthSessionNotifierProvider
    extends $AsyncNotifierProvider<AuthSessionNotifier, AuthState> {
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
  AuthSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionNotifierHash();

  @$internal
  @override
  AuthSessionNotifier create() => AuthSessionNotifier();
}

String _$authSessionNotifierHash() =>
    r'cd6a280fc837ec280b0e8f286818479c08a1a246';

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

abstract class _$AuthSessionNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// When the current 30-day session ends, or `null` when signed out. It only
/// changes with the session state (login, restore, logout, loss): rotation
/// keeps the absolute expiry.

@ProviderFor(sessionExpiresAt)
final sessionExpiresAtProvider = SessionExpiresAtProvider._();

/// When the current 30-day session ends, or `null` when signed out. It only
/// changes with the session state (login, restore, logout, loss): rotation
/// keeps the absolute expiry.

final class SessionExpiresAtProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// When the current 30-day session ends, or `null` when signed out. It only
  /// changes with the session state (login, restore, logout, loss): rotation
  /// keeps the absolute expiry.
  SessionExpiresAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionExpiresAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionExpiresAtHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return sessionExpiresAt(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$sessionExpiresAtHash() => r'20b958559ff0f3ead7ef6ea1cb29a09bec46000e';

/// The logged-in user, or `null`. Kept alive like the session it derives
/// from, since the router guard and the shared caches listen to it.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// The logged-in user, or `null`. Kept alive like the session it derives
/// from, since the router guard and the shared caches listen to it.

final class CurrentUserProvider
    extends $FunctionalProvider<CurrentUser?, CurrentUser?, CurrentUser?>
    with $Provider<CurrentUser?> {
  /// The logged-in user, or `null`. Kept alive like the session it derives
  /// from, since the router guard and the shared caches listen to it.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<CurrentUser?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CurrentUser? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrentUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrentUser?>(value),
    );
  }
}

String _$currentUserHash() => r'59675eb38711c30051f9d40f585f089a4806eb7e';
