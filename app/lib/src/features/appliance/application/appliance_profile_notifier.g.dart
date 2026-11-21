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

@ProviderFor(ApplianceProfileNotifier)
final applianceProfileProvider = ApplianceProfileNotifierProvider._();

/// The saved appliance profile; `null` until the user connects.
final class ApplianceProfileNotifierProvider
    extends $NotifierProvider<ApplianceProfileNotifier, ApplianceProfile?> {
  /// The saved appliance profile; `null` until the user connects.
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
    r'25cf01762a0a9efb6d6e1a999efb47f78e576216';

/// The saved appliance profile; `null` until the user connects.

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
