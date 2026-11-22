// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `GET /devices`, polled every 30 s while Home or device details are
/// visible and the app is in the foreground (plan §11). It is the shared
/// source of status, faults, heating and dry-run flags.
///
/// Every good list is published to [lastDeviceListProvider] and saved as
/// the persistent snapshot (plan §8.3). Before the first list of a cold
/// start, that snapshot (of the same profile and user) is shown, with its
/// age; it is never written back as fresh.
///
/// A 403 stops the cadence (plan §7.5: the role may not read the list, so
/// asking again every 30 s could only fail); pull-to-refresh asks again.

@ProviderFor(DeviceListNotifier)
final deviceListProvider = DeviceListNotifierProvider._();

/// `GET /devices`, polled every 30 s while Home or device details are
/// visible and the app is in the foreground (plan §11). It is the shared
/// source of status, faults, heating and dry-run flags.
///
/// Every good list is published to [lastDeviceListProvider] and saved as
/// the persistent snapshot (plan §8.3). Before the first list of a cold
/// start, that snapshot (of the same profile and user) is shown, with its
/// age; it is never written back as fresh.
///
/// A 403 stops the cadence (plan §7.5: the role may not read the list, so
/// asking again every 30 s could only fail); pull-to-refresh asks again.
final class DeviceListNotifierProvider
    extends
        $NotifierProvider<
          DeviceListNotifier,
          PolledData<List<DeviceListItem>>
        > {
  /// `GET /devices`, polled every 30 s while Home or device details are
  /// visible and the app is in the foreground (plan §11). It is the shared
  /// source of status, faults, heating and dry-run flags.
  ///
  /// Every good list is published to [lastDeviceListProvider] and saved as
  /// the persistent snapshot (plan §8.3). Before the first list of a cold
  /// start, that snapshot (of the same profile and user) is shown, with its
  /// age; it is never written back as fresh.
  ///
  /// A 403 stops the cadence (plan §7.5: the role may not read the list, so
  /// asking again every 30 s could only fail); pull-to-refresh asks again.
  DeviceListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceListNotifierHash();

  @$internal
  @override
  DeviceListNotifier create() => DeviceListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolledData<List<DeviceListItem>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolledData<List<DeviceListItem>>>(
        value,
      ),
    );
  }
}

String _$deviceListNotifierHash() =>
    r'7f9c9d8a3a8416d928e0c1c616d4fef7a032dde9';

/// `GET /devices`, polled every 30 s while Home or device details are
/// visible and the app is in the foreground (plan §11). It is the shared
/// source of status, faults, heating and dry-run flags.
///
/// Every good list is published to [lastDeviceListProvider] and saved as
/// the persistent snapshot (plan §8.3). Before the first list of a cold
/// start, that snapshot (of the same profile and user) is shown, with its
/// age; it is never written back as fresh.
///
/// A 403 stops the cadence (plan §7.5: the role may not read the list, so
/// asking again every 30 s could only fail); pull-to-refresh asks again.

abstract class _$DeviceListNotifier
    extends $Notifier<PolledData<List<DeviceListItem>>> {
  PolledData<List<DeviceListItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              PolledData<List<DeviceListItem>>,
              PolledData<List<DeviceListItem>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PolledData<List<DeviceListItem>>,
                PolledData<List<DeviceListItem>>
              >,
              PolledData<List<DeviceListItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
