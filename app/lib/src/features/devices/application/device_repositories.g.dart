// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device endpoints of the saved appliance. Only read once signed in, i.e.
/// when a client exists.

@ProviderFor(deviceReadSource)
final deviceReadSourceProvider = DeviceReadSourceProvider._();

/// Device endpoints of the saved appliance. Only read once signed in, i.e.
/// when a client exists.

final class DeviceReadSourceProvider
    extends
        $FunctionalProvider<
          DeviceReadSource,
          DeviceReadSource,
          DeviceReadSource
        >
    with $Provider<DeviceReadSource> {
  /// Device endpoints of the saved appliance. Only read once signed in, i.e.
  /// when a client exists.
  DeviceReadSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceReadSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceReadSourceHash();

  @$internal
  @override
  $ProviderElement<DeviceReadSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceReadSource create(Ref ref) {
    return deviceReadSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceReadSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceReadSource>(value),
    );
  }
}

String _$deviceReadSourceHash() => r'647ae1c81d59d1c5545b1494944fba3a0dc3a9b1';

/// Shared device cache. A new appliance gets a new repository; a different
/// (or no) user clears it, so nothing outlives the session (plan §8.3).

@ProviderFor(devicesRepository)
final devicesRepositoryProvider = DevicesRepositoryProvider._();

/// Shared device cache. A new appliance gets a new repository; a different
/// (or no) user clears it, so nothing outlives the session (plan §8.3).

final class DevicesRepositoryProvider
    extends
        $FunctionalProvider<
          DevicesRepository,
          DevicesRepository,
          DevicesRepository
        >
    with $Provider<DevicesRepository> {
  /// Shared device cache. A new appliance gets a new repository; a different
  /// (or no) user clears it, so nothing outlives the session (plan §8.3).
  DevicesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicesRepositoryHash();

  @$internal
  @override
  $ProviderElement<DevicesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DevicesRepository create(Ref ref) {
    return devicesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevicesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevicesRepository>(value),
    );
  }
}

String _$devicesRepositoryHash() => r'9b7fa5a02e3bddd0c94eb843e18efb5447a1762e';

/// Shared room cache, cleared like [devicesRepository].

@ProviderFor(roomsRepository)
final roomsRepositoryProvider = RoomsRepositoryProvider._();

/// Shared room cache, cleared like [devicesRepository].

final class RoomsRepositoryProvider
    extends
        $FunctionalProvider<RoomsRepository, RoomsRepository, RoomsRepository>
    with $Provider<RoomsRepository> {
  /// Shared room cache, cleared like [devicesRepository].
  RoomsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoomsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoomsRepository create(Ref ref) {
    return roomsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomsRepository>(value),
    );
  }
}

String _$roomsRepositoryHash() => r'9cfe603c6a230f6880cbeb2705ec8e7f5c419b15';
