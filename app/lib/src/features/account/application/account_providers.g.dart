// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionLocaleStore)
final sessionLocaleStoreProvider = SessionLocaleStoreProvider._();

final class SessionLocaleStoreProvider
    extends
        $FunctionalProvider<
          SessionLocaleStore,
          SessionLocaleStore,
          SessionLocaleStore
        >
    with $Provider<SessionLocaleStore> {
  SessionLocaleStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionLocaleStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionLocaleStoreHash();

  @$internal
  @override
  $ProviderElement<SessionLocaleStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionLocaleStore create(Ref ref) {
    return sessionLocaleStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionLocaleStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionLocaleStore>(value),
    );
  }
}

String _$sessionLocaleStoreHash() =>
    r'4927403eb9be5a59a54cb2de810b34ea7caa6912';

/// `GET /users/me/profile` of the signed-in user (plan §4.1, §13.2), or
/// `null` while signed out. Loaded after login and session restore (when
/// the user appears) and again on every return to the foreground (plan
/// §7.6, §11), next to the session notifier's `GET /auth/me`. Another
/// user, or none, drops it, so nothing of one user reaches the next.
///
/// On success the language it names is remembered for the next cold start
/// ([SessionLocaleStore]). A failure is only an error here: the app keeps
/// its language and the session goes on.

@ProviderFor(userProfile)
final userProfileProvider = UserProfileProvider._();

/// `GET /users/me/profile` of the signed-in user (plan §4.1, §13.2), or
/// `null` while signed out. Loaded after login and session restore (when
/// the user appears) and again on every return to the foreground (plan
/// §7.6, §11), next to the session notifier's `GET /auth/me`. Another
/// user, or none, drops it, so nothing of one user reaches the next.
///
/// On success the language it names is remembered for the next cold start
/// ([SessionLocaleStore]). A failure is only an error here: the app keeps
/// its language and the session goes on.

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          FutureOr<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $FutureProvider<UserProfile?> {
  /// `GET /users/me/profile` of the signed-in user (plan §4.1, §13.2), or
  /// `null` while signed out. Loaded after login and session restore (when
  /// the user appears) and again on every return to the foreground (plan
  /// §7.6, §11), next to the session notifier's `GET /auth/me`. Another
  /// user, or none, drops it, so nothing of one user reaches the next.
  ///
  /// On success the language it names is remembered for the next cold start
  /// ([SessionLocaleStore]). A failure is only an error here: the app keeps
  /// its language and the session goes on.
  UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfile?> create(Ref ref) {
    return userProfile(ref);
  }
}

String _$userProfileHash() => r'ff9c6c4f8baefec7e7ff1177681bdc23626b6e07';

/// The language the app shows (plan §13.2), fed to `MaterialApp.locale`;
/// `null` means the phone language.
///
/// * A language picked in Settings ([languagePreferenceProvider]) wins
///   over everything below, signed in or not.
/// * Signed out (before login, after logout or "Zmień użytkownika"): the
///   phone language.
/// * Signed in: the language of the user's GI Core profile, or the phone
///   language when the profile has none the app supports.
/// * Until the profile has answered (cold start, a failed profile call):
///   the language last applied for this user on this appliance, so a
///   restored session does not start in the phone language.

@ProviderFor(appLocale)
final appLocaleProvider = AppLocaleProvider._();

/// The language the app shows (plan §13.2), fed to `MaterialApp.locale`;
/// `null` means the phone language.
///
/// * A language picked in Settings ([languagePreferenceProvider]) wins
///   over everything below, signed in or not.
/// * Signed out (before login, after logout or "Zmień użytkownika"): the
///   phone language.
/// * Signed in: the language of the user's GI Core profile, or the phone
///   language when the profile has none the app supports.
/// * Until the profile has answered (cold start, a failed profile call):
///   the language last applied for this user on this appliance, so a
///   restored session does not start in the phone language.

final class AppLocaleProvider
    extends $FunctionalProvider<Locale?, Locale?, Locale?>
    with $Provider<Locale?> {
  /// The language the app shows (plan §13.2), fed to `MaterialApp.locale`;
  /// `null` means the phone language.
  ///
  /// * A language picked in Settings ([languagePreferenceProvider]) wins
  ///   over everything below, signed in or not.
  /// * Signed out (before login, after logout or "Zmień użytkownika"): the
  ///   phone language.
  /// * Signed in: the language of the user's GI Core profile, or the phone
  ///   language when the profile has none the app supports.
  /// * Until the profile has answered (cold start, a failed profile call):
  ///   the language last applied for this user on this appliance, so a
  ///   restored session does not start in the phone language.
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale? create(Ref ref) {
    return appLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$appLocaleHash() => r'fb445dd2801fb571184733f4f87c2be37f62c85b';

/// [requestLanguageProvider], kept on the language the app shows
/// ([appLocaleProvider]), so `Accept-Language` follows the signed-in user's
/// profile (plan §13.2). A listener instead of a watch from the client: the
/// app language depends on the session, and the session on the client.
/// `GiHomeApp` keeps it running from its first frame.

@ProviderFor(syncedRequestLanguage)
final syncedRequestLanguageProvider = SyncedRequestLanguageProvider._();

/// [requestLanguageProvider], kept on the language the app shows
/// ([appLocaleProvider]), so `Accept-Language` follows the signed-in user's
/// profile (plan §13.2). A listener instead of a watch from the client: the
/// app language depends on the session, and the session on the client.
/// `GiHomeApp` keeps it running from its first frame.

final class SyncedRequestLanguageProvider
    extends
        $FunctionalProvider<RequestLanguage, RequestLanguage, RequestLanguage>
    with $Provider<RequestLanguage> {
  /// [requestLanguageProvider], kept on the language the app shows
  /// ([appLocaleProvider]), so `Accept-Language` follows the signed-in user's
  /// profile (plan §13.2). A listener instead of a watch from the client: the
  /// app language depends on the session, and the session on the client.
  /// `GiHomeApp` keeps it running from its first frame.
  SyncedRequestLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncedRequestLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncedRequestLanguageHash();

  @$internal
  @override
  $ProviderElement<RequestLanguage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RequestLanguage create(Ref ref) {
    return syncedRequestLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestLanguage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestLanguage>(value),
    );
  }
}

String _$syncedRequestLanguageHash() =>
    r'5d2c74ae1645db10d3204ea23d52579289ab27b0';
