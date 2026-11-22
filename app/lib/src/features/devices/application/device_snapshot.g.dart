// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_snapshot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the device list snapshot is kept: secure storage, or memory in demo
/// mode (the demo never writes anything real).

@ProviderFor(deviceSnapshotStore)
final deviceSnapshotStoreProvider = DeviceSnapshotStoreProvider._();

/// Where the device list snapshot is kept: secure storage, or memory in demo
/// mode (the demo never writes anything real).

final class DeviceSnapshotStoreProvider
    extends
        $FunctionalProvider<
          DeviceSnapshotStore,
          DeviceSnapshotStore,
          DeviceSnapshotStore
        >
    with $Provider<DeviceSnapshotStore> {
  /// Where the device list snapshot is kept: secure storage, or memory in demo
  /// mode (the demo never writes anything real).
  DeviceSnapshotStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceSnapshotStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceSnapshotStoreHash();

  @$internal
  @override
  $ProviderElement<DeviceSnapshotStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceSnapshotStore create(Ref ref) {
    return deviceSnapshotStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceSnapshotStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceSnapshotStore>(value),
    );
  }
}

String _$deviceSnapshotStoreHash() =>
    r'705fef1688c046c97decc812a013bc048dd2b491';

/// Keeps the persistent snapshot of the device list in step with the
/// session (plan §8.3): saved after each good list, restored for a cold
/// start, wiped on logout, on a user change and when the session ends or
/// is lost (`AuthSessionNotifier`).

@ProviderFor(deviceSnapshotKeeper)
final deviceSnapshotKeeperProvider = DeviceSnapshotKeeperProvider._();

/// Keeps the persistent snapshot of the device list in step with the
/// session (plan §8.3): saved after each good list, restored for a cold
/// start, wiped on logout, on a user change and when the session ends or
/// is lost (`AuthSessionNotifier`).

final class DeviceSnapshotKeeperProvider
    extends
        $FunctionalProvider<
          DeviceSnapshotKeeper,
          DeviceSnapshotKeeper,
          DeviceSnapshotKeeper
        >
    with $Provider<DeviceSnapshotKeeper> {
  /// Keeps the persistent snapshot of the device list in step with the
  /// session (plan §8.3): saved after each good list, restored for a cold
  /// start, wiped on logout, on a user change and when the session ends or
  /// is lost (`AuthSessionNotifier`).
  DeviceSnapshotKeeperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceSnapshotKeeperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceSnapshotKeeperHash();

  @$internal
  @override
  $ProviderElement<DeviceSnapshotKeeper> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceSnapshotKeeper create(Ref ref) {
    return deviceSnapshotKeeper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceSnapshotKeeper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceSnapshotKeeper>(value),
    );
  }
}

String _$deviceSnapshotKeeperHash() =>
    r'cce82b7da216d537f74094fcfbe711fbb5a7799e';

/// The snapshot a cold start without a connection can show: the one of the
/// profile's last signed-in user (plan §8.3), or `null`.

@ProviderFor(offlineSnapshot)
final offlineSnapshotProvider = OfflineSnapshotProvider._();

/// The snapshot a cold start without a connection can show: the one of the
/// profile's last signed-in user (plan §8.3), or `null`.

final class OfflineSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceSnapshot?>,
          DeviceSnapshot?,
          FutureOr<DeviceSnapshot?>
        >
    with $FutureModifier<DeviceSnapshot?>, $FutureProvider<DeviceSnapshot?> {
  /// The snapshot a cold start without a connection can show: the one of the
  /// profile's last signed-in user (plan §8.3), or `null`.
  OfflineSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineSnapshotHash();

  @$internal
  @override
  $FutureProviderElement<DeviceSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceSnapshot?> create(Ref ref) {
    return offlineSnapshot(ref);
  }
}

String _$offlineSnapshotHash() => r'953407250c061dc3703f6ead0eb007696015f68f';

/// The latest device list known to the app, without polling for it: set by
/// the device list poll (and its snapshot seed), cleared with the session.
/// The "Uwaga" badge reads it so that the tab bar alone never keeps the
/// list polling (plan §11 load budget).

@ProviderFor(LastDeviceList)
final lastDeviceListProvider = LastDeviceListProvider._();

/// The latest device list known to the app, without polling for it: set by
/// the device list poll (and its snapshot seed), cleared with the session.
/// The "Uwaga" badge reads it so that the tab bar alone never keeps the
/// list polling (plan §11 load budget).
final class LastDeviceListProvider
    extends $NotifierProvider<LastDeviceList, Fetched<List<DeviceListItem>>?> {
  /// The latest device list known to the app, without polling for it: set by
  /// the device list poll (and its snapshot seed), cleared with the session.
  /// The "Uwaga" badge reads it so that the tab bar alone never keeps the
  /// list polling (plan §11 load budget).
  LastDeviceListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastDeviceListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastDeviceListHash();

  @$internal
  @override
  LastDeviceList create() => LastDeviceList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Fetched<List<DeviceListItem>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Fetched<List<DeviceListItem>>?>(
        value,
      ),
    );
  }
}

String _$lastDeviceListHash() => r'0ca19b9479948d34ba0b1ae2d8aac9d9f5fc8701';

/// The latest device list known to the app, without polling for it: set by
/// the device list poll (and its snapshot seed), cleared with the session.
/// The "Uwaga" badge reads it so that the tab bar alone never keeps the
/// list polling (plan §11 load budget).

abstract class _$LastDeviceList
    extends $Notifier<Fetched<List<DeviceListItem>>?> {
  Fetched<List<DeviceListItem>>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Fetched<List<DeviceListItem>>?,
              Fetched<List<DeviceListItem>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Fetched<List<DeviceListItem>>?,
                Fetched<List<DeviceListItem>>?
              >,
              Fetched<List<DeviceListItem>>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
