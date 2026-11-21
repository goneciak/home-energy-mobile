import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/gi_platform_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_network_permission.g.dart';

/// The answer to the runtime permission request.
enum LocalNetworkPermissionStatus {
  granted,
  denied,

  /// Denied with "Don't ask again" (or twice): only the system settings can
  /// grant it now.
  permanentlyDenied;

  static LocalNetworkPermissionStatus? tryParse(String? name) {
    for (final status in values) {
      if (status.name == name) return status;
    }
    return null;
  }
}

/// What [LocalNetworkPermission] needs from the platform; faked in tests.
abstract interface class LocalNetworkPermissionBackend {
  /// The Android API level, or `null` on any other platform.
  Future<int?> androidSdkInt();

  /// Asks for `NEARBY_WIFI_DEVICES` (Android 13+); answers at once when it
  /// is granted already.
  Future<LocalNetworkPermissionStatus> requestNearbyWifiDevices();
}

/// Android's local network protection (plan §9.4, §22): before the
/// connection ladder looks around the LAN, ask for `NEARBY_WIFI_DEVICES`
/// (declared with `neverForLocation`). Nothing to do on iOS (the system
/// asks by itself on the first local request) and below Android 13 (API
/// 33), where the permission does not exist.
///
/// Only used while `FeatureFlags.androidLocalNetworkPermissionRequest` is
/// on: until an API level enforces the protection, the request is ready but
/// not shown.
final class LocalNetworkPermission {
  const new(this._backend);

  /// Android 13, the first API level with `NEARBY_WIFI_DEVICES`.
  static const firstApiLevel = 33;

  final LocalNetworkPermissionBackend _backend;

  /// Completes when the app may use the local network, and throws
  /// [LocalNetworkDeniedFailure] when the user denied it (also for good),
  /// which the screens explain with a way to the settings. A platform
  /// error does not block: the requests themselves then tell.
  Future<void> ensureGranted() async {
    final LocalNetworkPermissionStatus status;
    try {
      final sdk = await _backend.androidSdkInt();
      if (sdk == null || sdk < firstApiLevel) return;
      status = await _backend.requestNearbyWifiDevices();
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
    if (status == LocalNetworkPermissionStatus.granted) return;
    throw ApiFailure.localNetworkDenied(
      reason: 'NEARBY_WIFI_DEVICES ${status.name}',
    );
  }
}

/// [LocalNetworkPermissionBackend] over [giPlatformChannel] (Android only).
final class ChannelLocalNetworkPermissionBackend
    implements LocalNetworkPermissionBackend {
  const new();

  @override
  Future<int?> androidSdkInt() async {
    if (!Platform.isAndroid) return null;
    return await giPlatformChannel.invokeMethod<int>('sdkInt');
  }

  @override
  Future<LocalNetworkPermissionStatus> requestNearbyWifiDevices() async {
    final answer = await giPlatformChannel.invokeMethod<String>(
      'requestNearbyWifiDevices',
    );
    return LocalNetworkPermissionStatus.tryParse(answer) ??
        LocalNetworkPermissionStatus.denied;
  }
}

@Riverpod(keepAlive: true)
LocalNetworkPermission localNetworkPermission(Ref ref) =>
    const LocalNetworkPermission(ChannelLocalNetworkPermissionBackend());
