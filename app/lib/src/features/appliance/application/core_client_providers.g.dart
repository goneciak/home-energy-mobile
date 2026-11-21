// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Probes addresses typed on the connect screen and the candidates of the
/// connection ladder. Kept alive like the session that rebinds with it.

@ProviderFor(applianceProbe)
final applianceProbeProvider = ApplianceProbeProvider._();

/// Probes addresses typed on the connect screen and the candidates of the
/// connection ladder. Kept alive like the session that rebinds with it.

final class ApplianceProbeProvider
    extends $FunctionalProvider<ApplianceProbe, ApplianceProbe, ApplianceProbe>
    with $Provider<ApplianceProbe> {
  /// Probes addresses typed on the connect screen and the candidates of the
  /// connection ladder. Kept alive like the session that rebinds with it.
  ApplianceProbeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceProbeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceProbeHash();

  @$internal
  @override
  $ProviderElement<ApplianceProbe> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApplianceProbe create(Ref ref) {
    return applianceProbe(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplianceProbe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplianceProbe>(value),
    );
  }
}

String _$applianceProbeHash() => r'fbf567e1262bf86488333b44c40fba53b31ae5be';

/// Secure storage of the current profile's refresh cookie. Failed reads are
/// counted across restarts; the third in a row wipes the entry (plan §7.1),
/// and each one feeds the local diagnostic counters. Demo mode keeps its
/// session in memory and never touches secure storage.

@ProviderFor(tokenVault)
final tokenVaultProvider = TokenVaultProvider._();

/// Secure storage of the current profile's refresh cookie. Failed reads are
/// counted across restarts; the third in a row wipes the entry (plan §7.1),
/// and each one feeds the local diagnostic counters. Demo mode keeps its
/// session in memory and never touches secure storage.

final class TokenVaultProvider
    extends $FunctionalProvider<TokenVault?, TokenVault?, TokenVault?>
    with $Provider<TokenVault?> {
  /// Secure storage of the current profile's refresh cookie. Failed reads are
  /// counted across restarts; the third in a row wipes the entry (plan §7.1),
  /// and each one feeds the local diagnostic counters. Demo mode keeps its
  /// session in memory and never touches secure storage.
  TokenVaultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenVaultProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenVaultHash();

  @$internal
  @override
  $ProviderElement<TokenVault?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenVault? create(Ref ref) {
    return tokenVault(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenVault? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenVault?>(value),
    );
  }
}

String _$tokenVaultHash() => r'ea5e59d7d4f07af804a690a11f467b01d4f1c8a3';

/// The GI Core client (and its single [AuthSessionManager]) for the saved
/// appliance; `null` without a profile.
///
/// It is rebuilt only when the appliance, its address or its fingerprint
/// change — never while a session is in use, so two session managers never
/// hold the same refresh cookie.
///
/// Its failures and every forced logout feed the local diagnostic counters
/// (plan §8.4); the subscription starts before `restore()` can run, so no
/// session loss is missed. Its redacted request log goes to the diagnostics
/// ring buffer in every build, and to the console in debug builds.
///
/// The fingerprint check (plan §9.3) may report that the appliance was
/// renamed (the profile follows the new name) or reset (see
/// [forgetResetAppliance]).

@ProviderFor(giCoreClient)
final giCoreClientProvider = GiCoreClientProvider._();

/// The GI Core client (and its single [AuthSessionManager]) for the saved
/// appliance; `null` without a profile.
///
/// It is rebuilt only when the appliance, its address or its fingerprint
/// change — never while a session is in use, so two session managers never
/// hold the same refresh cookie.
///
/// Its failures and every forced logout feed the local diagnostic counters
/// (plan §8.4); the subscription starts before `restore()` can run, so no
/// session loss is missed. Its redacted request log goes to the diagnostics
/// ring buffer in every build, and to the console in debug builds.
///
/// The fingerprint check (plan §9.3) may report that the appliance was
/// renamed (the profile follows the new name) or reset (see
/// [forgetResetAppliance]).

final class GiCoreClientProvider
    extends $FunctionalProvider<GiCoreClient?, GiCoreClient?, GiCoreClient?>
    with $Provider<GiCoreClient?> {
  /// The GI Core client (and its single [AuthSessionManager]) for the saved
  /// appliance; `null` without a profile.
  ///
  /// It is rebuilt only when the appliance, its address or its fingerprint
  /// change — never while a session is in use, so two session managers never
  /// hold the same refresh cookie.
  ///
  /// Its failures and every forced logout feed the local diagnostic counters
  /// (plan §8.4); the subscription starts before `restore()` can run, so no
  /// session loss is missed. Its redacted request log goes to the diagnostics
  /// ring buffer in every build, and to the console in debug builds.
  ///
  /// The fingerprint check (plan §9.3) may report that the appliance was
  /// renamed (the profile follows the new name) or reset (see
  /// [forgetResetAppliance]).
  GiCoreClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giCoreClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giCoreClientHash();

  @$internal
  @override
  $ProviderElement<GiCoreClient?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GiCoreClient? create(Ref ref) {
    return giCoreClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiCoreClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiCoreClient?>(value),
    );
  }
}

String _$giCoreClientHash() => r'053992c9257c6b5e6068bef0cea543ccdd45dae6';
