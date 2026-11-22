// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `GET /auth/sessions`: the user's live sessions, this phone's first,
/// then newest first (plan §4.2, §20 M3.5).

@ProviderFor(authSessions)
final authSessionsProvider = AuthSessionsProvider._();

/// `GET /auth/sessions`: the user's live sessions, this phone's first,
/// then newest first (plan §4.2, §20 M3.5).

final class AuthSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuthSessionInfo>>,
          List<AuthSessionInfo>,
          FutureOr<List<AuthSessionInfo>>
        >
    with
        $FutureModifier<List<AuthSessionInfo>>,
        $FutureProvider<List<AuthSessionInfo>> {
  /// `GET /auth/sessions`: the user's live sessions, this phone's first,
  /// then newest first (plan §4.2, §20 M3.5).
  AuthSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<AuthSessionInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuthSessionInfo>> create(Ref ref) {
    return authSessions(ref);
  }
}

String _$authSessionsHash() => r'7855c3a641f1c2149fc37ca3b756d28aa7360493';

/// Saving the profile (`PATCH /users/me/profile`): names and the account
/// language (plan §13.2). On success the profile is fetched again, so the
/// app language follows the server.

@ProviderFor(ProfileEditController)
final profileEditControllerProvider = ProfileEditControllerProvider._();

/// Saving the profile (`PATCH /users/me/profile`): names and the account
/// language (plan §13.2). On success the profile is fetched again, so the
/// app language follows the server.
final class ProfileEditControllerProvider
    extends $NotifierProvider<ProfileEditController, AsyncValue<UserProfile?>> {
  /// Saving the profile (`PATCH /users/me/profile`): names and the account
  /// language (plan §13.2). On success the profile is fetched again, so the
  /// app language follows the server.
  ProfileEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEditControllerHash();

  @$internal
  @override
  ProfileEditController create() => ProfileEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UserProfile?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UserProfile?>>(value),
    );
  }
}

String _$profileEditControllerHash() =>
    r'74bd29bf433fe8ab1c3897e058e1389dc9a70e28';

/// Saving the profile (`PATCH /users/me/profile`): names and the account
/// language (plan §13.2). On success the profile is fetched again, so the
/// app language follows the server.

abstract class _$ProfileEditController
    extends $Notifier<AsyncValue<UserProfile?>> {
  AsyncValue<UserProfile?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserProfile?>, AsyncValue<UserProfile?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile?>, AsyncValue<UserProfile?>>,
              AsyncValue<UserProfile?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ending sessions from the session list: one of them, or all of them
/// (`POST /auth/logout-all`). Ending this phone's session signs out here.

@ProviderFor(SessionActionsController)
final sessionActionsControllerProvider = SessionActionsControllerProvider._();

/// Ending sessions from the session list: one of them, or all of them
/// (`POST /auth/logout-all`). Ending this phone's session signs out here.
final class SessionActionsControllerProvider
    extends $NotifierProvider<SessionActionsController, AsyncValue<void>> {
  /// Ending sessions from the session list: one of them, or all of them
  /// (`POST /auth/logout-all`). Ending this phone's session signs out here.
  SessionActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionActionsControllerHash();

  @$internal
  @override
  SessionActionsController create() => SessionActionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$sessionActionsControllerHash() =>
    r'1afc5416c15e23b69a148c80504603e320f376a2';

/// Ending sessions from the session list: one of them, or all of them
/// (`POST /auth/logout-all`). Ending this phone's session signs out here.

abstract class _$SessionActionsController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A new recovery code (`POST /auth/recovery/regenerate`). The code lives
/// only in this state, for as long as the screen showing it: it is never
/// stored, logged or sent anywhere else.

@ProviderFor(RecoveryCodeController)
final recoveryCodeControllerProvider = RecoveryCodeControllerProvider._();

/// A new recovery code (`POST /auth/recovery/regenerate`). The code lives
/// only in this state, for as long as the screen showing it: it is never
/// stored, logged or sent anywhere else.
final class RecoveryCodeControllerProvider
    extends
        $NotifierProvider<
          RecoveryCodeController,
          AsyncValue<RecoveryCodeResult?>
        > {
  /// A new recovery code (`POST /auth/recovery/regenerate`). The code lives
  /// only in this state, for as long as the screen showing it: it is never
  /// stored, logged or sent anywhere else.
  RecoveryCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoveryCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recoveryCodeControllerHash();

  @$internal
  @override
  RecoveryCodeController create() => RecoveryCodeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RecoveryCodeResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RecoveryCodeResult?>>(
        value,
      ),
    );
  }
}

String _$recoveryCodeControllerHash() =>
    r'929306fe03d47850993c8a1227235d4b99404c0a';

/// A new recovery code (`POST /auth/recovery/regenerate`). The code lives
/// only in this state, for as long as the screen showing it: it is never
/// stored, logged or sent anywhere else.

abstract class _$RecoveryCodeController
    extends $Notifier<AsyncValue<RecoveryCodeResult?>> {
  AsyncValue<RecoveryCodeResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecoveryCodeResult?>,
              AsyncValue<RecoveryCodeResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecoveryCodeResult?>,
                AsyncValue<RecoveryCodeResult?>
              >,
              AsyncValue<RecoveryCodeResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `POST /auth/recovery/reset` from the login screen (public). On success
/// every session of the user is gone and the code is still valid, so a
/// new one is offered after the next login ([AccountPrompts]).

@ProviderFor(RecoveryResetController)
final recoveryResetControllerProvider = RecoveryResetControllerProvider._();

/// `POST /auth/recovery/reset` from the login screen (public). On success
/// every session of the user is gone and the code is still valid, so a
/// new one is offered after the next login ([AccountPrompts]).
final class RecoveryResetControllerProvider
    extends $NotifierProvider<RecoveryResetController, AsyncValue<bool>> {
  /// `POST /auth/recovery/reset` from the login screen (public). On success
  /// every session of the user is gone and the code is still valid, so a
  /// new one is offered after the next login ([AccountPrompts]).
  RecoveryResetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoveryResetControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recoveryResetControllerHash();

  @$internal
  @override
  RecoveryResetController create() => RecoveryResetController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }
}

String _$recoveryResetControllerHash() =>
    r'380dee1c1b837a14cda572d3b0e19092263f0842';

/// `POST /auth/recovery/reset` from the login screen (public). On success
/// every session of the user is gone and the code is still valid, so a
/// new one is offered after the next login ([AccountPrompts]).

abstract class _$RecoveryResetController extends $Notifier<AsyncValue<bool>> {
  AsyncValue<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, AsyncValue<bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, AsyncValue<bool>>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Prompts waiting for the signed-in shell, in memory only.

@ProviderFor(AccountPrompts)
final accountPromptsProvider = AccountPromptsProvider._();

/// Prompts waiting for the signed-in shell, in memory only.
final class AccountPromptsProvider
    extends $NotifierProvider<AccountPrompts, PendingAccountPrompts> {
  /// Prompts waiting for the signed-in shell, in memory only.
  AccountPromptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountPromptsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountPromptsHash();

  @$internal
  @override
  AccountPrompts create() => AccountPrompts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingAccountPrompts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingAccountPrompts>(value),
    );
  }
}

String _$accountPromptsHash() => r'5996411adc38bb479fadeb624b9ca327348b4ede';

/// Prompts waiting for the signed-in shell, in memory only.

abstract class _$AccountPrompts extends $Notifier<PendingAccountPrompts> {
  PendingAccountPrompts build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PendingAccountPrompts, PendingAccountPrompts>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PendingAccountPrompts, PendingAccountPrompts>,
              PendingAccountPrompts,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
