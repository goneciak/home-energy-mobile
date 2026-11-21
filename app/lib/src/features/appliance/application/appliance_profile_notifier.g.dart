// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance_profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(applianceProfileStore)
final applianceProfileStoreProvider = ApplianceProfileStoreProvider._();

final class ApplianceProfileStoreProvider
    extends
        $FunctionalProvider<
          ApplianceProfileStore,
          ApplianceProfileStore,
          ApplianceProfileStore
        >
    with $Provider<ApplianceProfileStore> {
  ApplianceProfileStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceProfileStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceProfileStoreHash();

  @$internal
  @override
  $ProviderElement<ApplianceProfileStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApplianceProfileStore create(Ref ref) {
    return applianceProfileStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplianceProfileStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplianceProfileStore>(value),
    );
  }
}

String _$applianceProfileStoreHash() =>
    r'd06f50a0489329bc0241c9cb2e4ac5e02babc334';

/// The saved appliance profile; `null` until the user connects.
///
/// In demo mode it is the demo appliance's profile, held in memory: changes
/// are never stored, and the saved profile is left as it was.

@ProviderFor(ApplianceProfileNotifier)
final applianceProfileProvider = ApplianceProfileNotifierProvider._();

/// The saved appliance profile; `null` until the user connects.
///
/// In demo mode it is the demo appliance's profile, held in memory: changes
/// are never stored, and the saved profile is left as it was.
final class ApplianceProfileNotifierProvider
    extends $NotifierProvider<ApplianceProfileNotifier, ApplianceProfile?> {
  /// The saved appliance profile; `null` until the user connects.
  ///
  /// In demo mode it is the demo appliance's profile, held in memory: changes
  /// are never stored, and the saved profile is left as it was.
  ApplianceProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceProfileNotifierHash();

  @$internal
  @override
  ApplianceProfileNotifier create() => ApplianceProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplianceProfile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplianceProfile?>(value),
    );
  }
}

String _$applianceProfileNotifierHash() =>
    r'd690fbf2e456723e92a4aa77b2977cca4d9ca964';

/// The saved appliance profile; `null` until the user connects.
///
/// In demo mode it is the demo appliance's profile, held in memory: changes
/// are never stored, and the saved profile is left as it was.

abstract class _$ApplianceProfileNotifier extends $Notifier<ApplianceProfile?> {
  ApplianceProfile? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ApplianceProfile?, ApplianceProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApplianceProfile?, ApplianceProfile?>,
              ApplianceProfile?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
