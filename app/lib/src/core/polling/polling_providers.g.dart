// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polling_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reachabilityRegistry)
final reachabilityRegistryProvider = ReachabilityRegistryProvider._();

final class ReachabilityRegistryProvider
    extends
        $FunctionalProvider<
          ReachabilityRegistry,
          ReachabilityRegistry,
          ReachabilityRegistry
        >
    with $Provider<ReachabilityRegistry> {
  ReachabilityRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reachabilityRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reachabilityRegistryHash();

  @$internal
  @override
  $ProviderElement<ReachabilityRegistry> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReachabilityRegistry create(Ref ref) {
    return reachabilityRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReachabilityRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReachabilityRegistry>(value),
    );
  }
}

String _$reachabilityRegistryHash() =>
    r'6526d775a0882c93be5c3b7a3a6a1efba3d4bd6a';

/// What the pollers of the saved appliance know about reaching it together
/// (see [ReachabilityTracker]). Without a readable profile (tests, before
/// connecting) everything shares one tracker.

@ProviderFor(applianceReachability)
final applianceReachabilityProvider = ApplianceReachabilityProvider._();

/// What the pollers of the saved appliance know about reaching it together
/// (see [ReachabilityTracker]). Without a readable profile (tests, before
/// connecting) everything shares one tracker.

final class ApplianceReachabilityProvider
    extends
        $FunctionalProvider<
          ReachabilityTracker,
          ReachabilityTracker,
          ReachabilityTracker
        >
    with $Provider<ReachabilityTracker> {
  /// What the pollers of the saved appliance know about reaching it together
  /// (see [ReachabilityTracker]). Without a readable profile (tests, before
  /// connecting) everything shares one tracker.
  ApplianceReachabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applianceReachabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applianceReachabilityHash();

  @$internal
  @override
  $ProviderElement<ReachabilityTracker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReachabilityTracker create(Ref ref) {
    return applianceReachability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReachabilityTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReachabilityTracker>(value),
    );
  }
}

String _$applianceReachabilityHash() =>
    r'366ce45e7eeddc1c7433c67518f383d528f299c0';

@ProviderFor(pollCoordinator)
final pollCoordinatorProvider = PollCoordinatorProvider._();

final class PollCoordinatorProvider
    extends
        $FunctionalProvider<PollCoordinator, PollCoordinator, PollCoordinator>
    with $Provider<PollCoordinator> {
  PollCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pollCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pollCoordinatorHash();

  @$internal
  @override
  $ProviderElement<PollCoordinator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PollCoordinator create(Ref ref) {
    return pollCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PollCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PollCoordinator>(value),
    );
  }
}

String _$pollCoordinatorHash() => r'49c2c2ce8c174e37f950966ab6287434f074c41d';
