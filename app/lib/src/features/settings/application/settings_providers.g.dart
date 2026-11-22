// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(languagePreferenceStore)
final languagePreferenceStoreProvider = LanguagePreferenceStoreProvider._();

final class LanguagePreferenceStoreProvider
    extends
        $FunctionalProvider<
          LanguagePreferenceStore,
          LanguagePreferenceStore,
          LanguagePreferenceStore
        >
    with $Provider<LanguagePreferenceStore> {
  LanguagePreferenceStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePreferenceStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePreferenceStoreHash();

  @$internal
  @override
  $ProviderElement<LanguagePreferenceStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LanguagePreferenceStore create(Ref ref) {
    return languagePreferenceStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LanguagePreferenceStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LanguagePreferenceStore>(value),
    );
  }
}

String _$languagePreferenceStoreHash() =>
    r'8792b658ae472f79eb3ee39449607909f2e15b42';

/// The language picked in Settings, or `null` for "Automatycznie" (the
/// profile language, else the phone one; plan §13.2). It wins over both.

@ProviderFor(LanguagePreference)
final languagePreferenceProvider = LanguagePreferenceProvider._();

/// The language picked in Settings, or `null` for "Automatycznie" (the
/// profile language, else the phone one; plan §13.2). It wins over both.
final class LanguagePreferenceProvider
    extends $NotifierProvider<LanguagePreference, Locale?> {
  /// The language picked in Settings, or `null` for "Automatycznie" (the
  /// profile language, else the phone one; plan §13.2). It wins over both.
  LanguagePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePreferenceHash();

  @$internal
  @override
  LanguagePreference create() => LanguagePreference();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$languagePreferenceHash() =>
    r'687a219b85c405c4607ca9b052f316177ad91f49';

/// The language picked in Settings, or `null` for "Automatycznie" (the
/// profile language, else the phone one; plan §13.2). It wins over both.

abstract class _$LanguagePreference extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Best-effort running GI Core version from `GET /appliance/updates/status`
/// (plan §16), for OWNER/ADMIN only, so other roles never cause a 403.
/// `null` when unknown: another role, no check yet, or any failure. Nothing
/// is gated on it, but a change of version re-runs the capability probes
/// ([coreCapabilitiesProvider]). Read each time Settings opens.

@ProviderFor(applianceRunningVersion)
final applianceRunningVersionProvider = ApplianceRunningVersionProvider._();

/// Best-effort running GI Core version from `GET /appliance/updates/status`
/// (plan §16), for OWNER/ADMIN only, so other roles never cause a 403.
/// `null` when unknown: another role, no check yet, or any failure. Nothing
/// is gated on it, but a change of version re-runs the capability probes
/// ([coreCapabilitiesProvider]). Read each time Settings opens.

final class ApplianceRunningVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Best-effort running GI Core version from `GET /appliance/updates/status`
  /// (plan §16), for OWNER/ADMIN only, so other roles never cause a 403.
  /// `null` when unknown: another role, no check yet, or any failure. Nothing
  /// is gated on it, but a change of version re-runs the capability probes
  /// ([coreCapabilitiesProvider]). Read each time Settings opens.
  ApplianceRunningVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceRunningVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceRunningVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return applianceRunningVersion(ref);
  }
}

String _$applianceRunningVersionHash() =>
    r'74858327add0fe38401bd0772b2ff89bf78575be';

/// `GET /settings/system` (device name, time zone) for OWNER/ADMIN/SERVICE,
/// or `null` for other roles and on any failure: Settings then just leave
/// those rows out.

@ProviderFor(systemSettings)
final systemSettingsProvider = SystemSettingsProvider._();

/// `GET /settings/system` (device name, time zone) for OWNER/ADMIN/SERVICE,
/// or `null` for other roles and on any failure: Settings then just leave
/// those rows out.

final class SystemSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SystemSettings?>,
          SystemSettings?,
          FutureOr<SystemSettings?>
        >
    with $FutureModifier<SystemSettings?>, $FutureProvider<SystemSettings?> {
  /// `GET /settings/system` (device name, time zone) for OWNER/ADMIN/SERVICE,
  /// or `null` for other roles and on any failure: Settings then just leave
  /// those rows out.
  SystemSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemSettingsHash();

  @$internal
  @override
  $FutureProviderElement<SystemSettings?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SystemSettings?> create(Ref ref) {
    return systemSettings(ref);
  }
}

String _$systemSettingsHash() => r'd1807400878ebd9910ad318fe66397ffc123c381';

/// How the session's end is shown in Settings (plan §7.6), from the stored
/// refresh cookie's expiry; `null` while signed out or when unknown.

@ProviderFor(sessionExpiry)
final sessionExpiryProvider = SessionExpiryProvider._();

/// How the session's end is shown in Settings (plan §7.6), from the stored
/// refresh cookie's expiry; `null` while signed out or when unknown.

final class SessionExpiryProvider
    extends $FunctionalProvider<SessionExpiry?, SessionExpiry?, SessionExpiry?>
    with $Provider<SessionExpiry?> {
  /// How the session's end is shown in Settings (plan §7.6), from the stored
  /// refresh cookie's expiry; `null` while signed out or when unknown.
  SessionExpiryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionExpiryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionExpiryHash();

  @$internal
  @override
  $ProviderElement<SessionExpiry?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionExpiry? create(Ref ref) {
    return sessionExpiry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionExpiry? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionExpiry?>(value),
    );
  }
}

String _$sessionExpiryHash() => r'2261f980c92d08af60612a844c450fd613e8633a';
