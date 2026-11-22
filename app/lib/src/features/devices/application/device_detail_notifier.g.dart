// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `GET /devices/:id`, polled while the device details screen is visible
/// and the app is in the foreground (plan §11): every 5 s, and every 15 s
/// once the user has not touched or scrolled the screen for 2 min (the
/// screen reports interaction with [userActive]); the next interaction
/// brings the 5 s cadence back at once.
///
/// Polling stops once the device is gone (404) or the role may not read it
/// (403, plan §7.5: no request every few seconds that can only fail); only
/// an explicit [refresh] asks again.

@ProviderFor(DeviceDetailNotifier)
final deviceDetailProvider = DeviceDetailNotifierFamily._();

/// `GET /devices/:id`, polled while the device details screen is visible
/// and the app is in the foreground (plan §11): every 5 s, and every 15 s
/// once the user has not touched or scrolled the screen for 2 min (the
/// screen reports interaction with [userActive]); the next interaction
/// brings the 5 s cadence back at once.
///
/// Polling stops once the device is gone (404) or the role may not read it
/// (403, plan §7.5: no request every few seconds that can only fail); only
/// an explicit [refresh] asks again.
final class DeviceDetailNotifierProvider
    extends $NotifierProvider<DeviceDetailNotifier, PolledData<DeviceDetail>> {
  /// `GET /devices/:id`, polled while the device details screen is visible
  /// and the app is in the foreground (plan §11): every 5 s, and every 15 s
  /// once the user has not touched or scrolled the screen for 2 min (the
  /// screen reports interaction with [userActive]); the next interaction
  /// brings the 5 s cadence back at once.
  ///
  /// Polling stops once the device is gone (404) or the role may not read it
  /// (403, plan §7.5: no request every few seconds that can only fail); only
  /// an explicit [refresh] asks again.
  DeviceDetailNotifierProvider._({
    required DeviceDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deviceDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceDetailNotifierHash();

  @override
  String toString() {
    return r'deviceDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeviceDetailNotifier create() => DeviceDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolledData<DeviceDetail> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolledData<DeviceDetail>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceDetailNotifierHash() =>
    r'3ff177ac820c8c4d0bf311bac4d175aef81ba471';

/// `GET /devices/:id`, polled while the device details screen is visible
/// and the app is in the foreground (plan §11): every 5 s, and every 15 s
/// once the user has not touched or scrolled the screen for 2 min (the
/// screen reports interaction with [userActive]); the next interaction
/// brings the 5 s cadence back at once.
///
/// Polling stops once the device is gone (404) or the role may not read it
/// (403, plan §7.5: no request every few seconds that can only fail); only
/// an explicit [refresh] asks again.

final class DeviceDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          DeviceDetailNotifier,
          PolledData<DeviceDetail>,
          PolledData<DeviceDetail>,
          PolledData<DeviceDetail>,
          String
        > {
  DeviceDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'deviceDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `GET /devices/:id`, polled while the device details screen is visible
  /// and the app is in the foreground (plan §11): every 5 s, and every 15 s
  /// once the user has not touched or scrolled the screen for 2 min (the
  /// screen reports interaction with [userActive]); the next interaction
  /// brings the 5 s cadence back at once.
  ///
  /// Polling stops once the device is gone (404) or the role may not read it
  /// (403, plan §7.5: no request every few seconds that can only fail); only
  /// an explicit [refresh] asks again.

  DeviceDetailNotifierProvider call(String deviceId) =>
      DeviceDetailNotifierProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'deviceDetailProvider';
}

/// `GET /devices/:id`, polled while the device details screen is visible
/// and the app is in the foreground (plan §11): every 5 s, and every 15 s
/// once the user has not touched or scrolled the screen for 2 min (the
/// screen reports interaction with [userActive]); the next interaction
/// brings the 5 s cadence back at once.
///
/// Polling stops once the device is gone (404) or the role may not read it
/// (403, plan §7.5: no request every few seconds that can only fail); only
/// an explicit [refresh] asks again.

abstract class _$DeviceDetailNotifier
    extends $Notifier<PolledData<DeviceDetail>> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  PolledData<DeviceDetail> build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PolledData<DeviceDetail>, PolledData<DeviceDetail>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PolledData<DeviceDetail>, PolledData<DeviceDetail>>,
              PolledData<DeviceDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
