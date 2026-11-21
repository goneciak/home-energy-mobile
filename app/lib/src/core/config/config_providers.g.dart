// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The build configuration. The bootstrap overrides it with the config of
/// the entrypoint's flavor; without that (tests) it is prod with every flag
/// off, so nothing meant for developers shows up by accident.

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// The build configuration. The bootstrap overrides it with the config of
/// the entrypoint's flavor; without that (tests) it is prod with every flag
/// off, so nothing meant for developers shows up by accident.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// The build configuration. The bootstrap overrides it with the config of
  /// the entrypoint's flavor; without that (tests) it is prod with every flag
  /// off, so nothing meant for developers shows up by accident.
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'f1ee47b5cc63b697157cfb42301f20df562c1f6e';

@ProviderFor(appFlavor)
final appFlavorProvider = AppFlavorProvider._();

final class AppFlavorProvider
    extends $FunctionalProvider<AppFlavor, AppFlavor, AppFlavor>
    with $Provider<AppFlavor> {
  AppFlavorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appFlavorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appFlavorHash();

  @$internal
  @override
  $ProviderElement<AppFlavor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppFlavor create(Ref ref) {
    return appFlavor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppFlavor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppFlavor>(value),
    );
  }
}

String _$appFlavorHash() => r'ba4f3238b54e9d571cfea66d01d82908e9e35c7c';

@ProviderFor(featureFlagOverridesStore)
final featureFlagOverridesStoreProvider = FeatureFlagOverridesStoreProvider._();

final class FeatureFlagOverridesStoreProvider
    extends
        $FunctionalProvider<
          FeatureFlagOverridesStore,
          FeatureFlagOverridesStore,
          FeatureFlagOverridesStore
        >
    with $Provider<FeatureFlagOverridesStore> {
  FeatureFlagOverridesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureFlagOverridesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureFlagOverridesStoreHash();

  @$internal
  @override
  $ProviderElement<FeatureFlagOverridesStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeatureFlagOverridesStore create(Ref ref) {
    return featureFlagOverridesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureFlagOverridesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureFlagOverridesStore>(value),
    );
  }
}

String _$featureFlagOverridesStoreHash() =>
    r'c234abdd50562792c6325ace57569c0011030f19';

/// The feature flags in effect (plan §19.6): the flavor defaults from the
/// config, with the overrides stored on the phone in dev and beta. Prod
/// never reads or writes overrides, and a flag that does not exist in the
/// flavor stays off.
///
/// The merge with the capability probe results (plan §16) comes with the
/// probes in M3; until then the flags alone decide.

@ProviderFor(FeatureFlagsNotifier)
final featureFlagsProvider = FeatureFlagsNotifierProvider._();

/// The feature flags in effect (plan §19.6): the flavor defaults from the
/// config, with the overrides stored on the phone in dev and beta. Prod
/// never reads or writes overrides, and a flag that does not exist in the
/// flavor stays off.
///
/// The merge with the capability probe results (plan §16) comes with the
/// probes in M3; until then the flags alone decide.
final class FeatureFlagsNotifierProvider
    extends $NotifierProvider<FeatureFlagsNotifier, FeatureFlags> {
  /// The feature flags in effect (plan §19.6): the flavor defaults from the
  /// config, with the overrides stored on the phone in dev and beta. Prod
  /// never reads or writes overrides, and a flag that does not exist in the
  /// flavor stays off.
  ///
  /// The merge with the capability probe results (plan §16) comes with the
  /// probes in M3; until then the flags alone decide.
  FeatureFlagsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureFlagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureFlagsNotifierHash();

  @$internal
  @override
  FeatureFlagsNotifier create() => FeatureFlagsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureFlags value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureFlags>(value),
    );
  }
}

String _$featureFlagsNotifierHash() =>
    r'86ad8050d12c78dfcd4da3e4e161f869730ef3a9';

/// The feature flags in effect (plan §19.6): the flavor defaults from the
/// config, with the overrides stored on the phone in dev and beta. Prod
/// never reads or writes overrides, and a flag that does not exist in the
/// flavor stays off.
///
/// The merge with the capability probe results (plan §16) comes with the
/// probes in M3; until then the flags alone decide.

abstract class _$FeatureFlagsNotifier extends $Notifier<FeatureFlags> {
  FeatureFlags build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FeatureFlags, FeatureFlags>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeatureFlags, FeatureFlags>,
              FeatureFlags,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
