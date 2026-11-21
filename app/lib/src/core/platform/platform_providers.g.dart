// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Preferences loaded before `runApp`; overridden in `main` and in tests.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Preferences loaded before `runApp`; overridden in `main` and in tests.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferencesWithCache,
          SharedPreferencesWithCache,
          SharedPreferencesWithCache
        >
    with $Provider<SharedPreferencesWithCache> {
  /// Preferences loaded before `runApp`; overridden in `main` and in tests.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferencesWithCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferencesWithCache create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferencesWithCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferencesWithCache>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'2b36a1d982bacdd47296b7337030022b269df9c2';

/// Overridden in `main` with `PackageInfo` and in tests.

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// Overridden in `main` with `PackageInfo` and in tests.

final class AppInfoProvider
    extends $FunctionalProvider<AppInfo, AppInfo, AppInfo>
    with $Provider<AppInfo> {
  /// Overridden in `main` with `PackageInfo` and in tests.
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $ProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppInfo create(Ref ref) {
    return appInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInfo>(value),
    );
  }
}

String _$appInfoHash() => r'7f150e263d4b0677112f5eaa8927814530e15904';

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'b9d7a386898dfd6d17ed7d315a68c5e898e156eb';

/// Transport used by every GI Core request; `null` means the real network.
/// This is the seam for the in-process demo adapter (plan §19.5) and tests.
///
/// In the dev flavor the `mockCore` feature flag swaps in [MockCoreAdapter];
/// the clients watch this provider, so switching the flag rebuilds them.
/// Beta and prod never get the mock, whatever the flags say.

@ProviderFor(coreHttpClientAdapter)
final coreHttpClientAdapterProvider = CoreHttpClientAdapterProvider._();

/// Transport used by every GI Core request; `null` means the real network.
/// This is the seam for the in-process demo adapter (plan §19.5) and tests.
///
/// In the dev flavor the `mockCore` feature flag swaps in [MockCoreAdapter];
/// the clients watch this provider, so switching the flag rebuilds them.
/// Beta and prod never get the mock, whatever the flags say.

final class CoreHttpClientAdapterProvider
    extends
        $FunctionalProvider<
          HttpClientAdapter?,
          HttpClientAdapter?,
          HttpClientAdapter?
        >
    with $Provider<HttpClientAdapter?> {
  /// Transport used by every GI Core request; `null` means the real network.
  /// This is the seam for the in-process demo adapter (plan §19.5) and tests.
  ///
  /// In the dev flavor the `mockCore` feature flag swaps in [MockCoreAdapter];
  /// the clients watch this provider, so switching the flag rebuilds them.
  /// Beta and prod never get the mock, whatever the flags say.
  CoreHttpClientAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreHttpClientAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coreHttpClientAdapterHash();

  @$internal
  @override
  $ProviderElement<HttpClientAdapter?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HttpClientAdapter? create(Ref ref) {
    return coreHttpClientAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HttpClientAdapter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HttpClientAdapter?>(value),
    );
  }
}

String _$coreHttpClientAdapterHash() =>
    r'753897635b8cca8949145a394cfeb30b7f254b1e';

/// The phone's OS and model, read once in `main` (`readDeviceIdentity`);
/// `null` when it could not be read (and in tests unless overridden).

@ProviderFor(deviceIdentity)
final deviceIdentityProvider = DeviceIdentityProvider._();

/// The phone's OS and model, read once in `main` (`readDeviceIdentity`);
/// `null` when it could not be read (and in tests unless overridden).

final class DeviceIdentityProvider
    extends
        $FunctionalProvider<DeviceIdentity?, DeviceIdentity?, DeviceIdentity?>
    with $Provider<DeviceIdentity?> {
  /// The phone's OS and model, read once in `main` (`readDeviceIdentity`);
  /// `null` when it could not be read (and in tests unless overridden).
  DeviceIdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdentityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdentityHash();

  @$internal
  @override
  $ProviderElement<DeviceIdentity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceIdentity? create(Ref ref) {
    return deviceIdentity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdentity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdentity?>(value),
    );
  }
}

String _$deviceIdentityHash() => r'7d4397db8a425a2c97a677e52356cee37b675b01';

/// `User-Agent` identity: the only label the user sees in GI Core sessions,
/// e.g. `GIHome-Mobile/0.1.0 (Linux; Android 15; Pixel 8)` (plan §6.5).
/// Without a [deviceIdentityProvider] value it falls back to the OS name
/// and `Platform.operatingSystemVersion`.

@ProviderFor(clientInfo)
final clientInfoProvider = ClientInfoProvider._();

/// `User-Agent` identity: the only label the user sees in GI Core sessions,
/// e.g. `GIHome-Mobile/0.1.0 (Linux; Android 15; Pixel 8)` (plan §6.5).
/// Without a [deviceIdentityProvider] value it falls back to the OS name
/// and `Platform.operatingSystemVersion`.

final class ClientInfoProvider
    extends $FunctionalProvider<ClientInfo, ClientInfo, ClientInfo>
    with $Provider<ClientInfo> {
  /// `User-Agent` identity: the only label the user sees in GI Core sessions,
  /// e.g. `GIHome-Mobile/0.1.0 (Linux; Android 15; Pixel 8)` (plan §6.5).
  /// Without a [deviceIdentityProvider] value it falls back to the OS name
  /// and `Platform.operatingSystemVersion`.
  ClientInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientInfoHash();

  @$internal
  @override
  $ProviderElement<ClientInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClientInfo create(Ref ref) {
    return clientInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientInfo>(value),
    );
  }
}

String _$clientInfoHash() => r'4a2d9a4b44591980a7b4f27949117b8c6fb7d9ab';

@ProviderFor(externalUrlOpener)
final externalUrlOpenerProvider = ExternalUrlOpenerProvider._();

final class ExternalUrlOpenerProvider
    extends $FunctionalProvider<UrlOpener, UrlOpener, UrlOpener>
    with $Provider<UrlOpener> {
  ExternalUrlOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalUrlOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalUrlOpenerHash();

  @$internal
  @override
  $ProviderElement<UrlOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UrlOpener create(Ref ref) {
    return externalUrlOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlOpener>(value),
    );
  }
}

String _$externalUrlOpenerHash() => r'8214c9647489818dc506f2fa94ff1ac4c02b898c';

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'ce4c8073e4878f6859ed9a59fae2c1819b4179af';
