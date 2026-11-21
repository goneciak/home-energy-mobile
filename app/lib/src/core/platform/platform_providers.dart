import 'dart:io' show Platform;

import 'package:dio/dio.dart' show HttpClientAdapter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/dev/mock_core_adapter.dart';
import 'package:gi_home/src/core/platform/device_identity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

part 'platform_providers.g.dart';

/// App build identity, read once from the platform in `main`.
final class AppInfo {
  const new({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;
}

/// Preferences loaded before `runApp`; overridden in `main` and in tests.
@Riverpod(keepAlive: true)
SharedPreferencesWithCache sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferencesProvider must be overridden');

/// Overridden in `main` with `PackageInfo` and in tests.
@Riverpod(keepAlive: true)
AppInfo appInfo(Ref ref) =>
    throw UnimplementedError('appInfoProvider must be overridden');

/// Keychain items are readable after the first unlock, never synced to
/// iCloud or restored on another device (plan §7.1). Android uses the
/// package's current default cipher. `main` uses it directly for the
/// reinstall check, before the provider scope exists.
const appSecureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => appSecureStorage;

/// Transport used by every GI Core request; `null` means the real network.
/// This is the seam for the in-process demo adapter (plan §19.5) and tests.
///
/// In the dev flavor the `mockCore` feature flag swaps in [MockCoreAdapter];
/// the clients watch this provider, so switching the flag rebuilds them.
/// Beta and prod never get the mock, whatever the flags say.
@Riverpod(keepAlive: true)
HttpClientAdapter? coreHttpClientAdapter(Ref ref) {
  if (ref.watch(appFlavorProvider) != AppFlavor.dev) return null;
  final mock = ref.watch(featureFlagsProvider.select((f) => f.mockCore));
  return mock ? MockCoreAdapter(mockCoreRoutes()) : null;
}

/// The phone's OS and model, read once in `main` (`readDeviceIdentity`);
/// `null` when it could not be read (and in tests unless overridden).
@Riverpod(keepAlive: true)
DeviceIdentity? deviceIdentity(Ref ref) => null;

/// `User-Agent` identity: the only label the user sees in GI Core sessions,
/// e.g. `GIHome-Mobile/0.1.0 (Linux; Android 15; Pixel 8)` (plan §6.5).
/// Without a [deviceIdentityProvider] value it falls back to the OS name
/// and `Platform.operatingSystemVersion`.
@Riverpod(keepAlive: true)
ClientInfo clientInfo(Ref ref) => ClientInfo(
  appVersion: ref.watch(appInfoProvider).version,
  platform:
      ref.watch(deviceIdentityProvider)?.userAgentPlatform ??
      '${_platformName()}; ${Platform.operatingSystemVersion}',
);

/// Opens a web page outside the app (e.g. a store listing); `false` when
/// nothing could open it. Overridden in tests.
typedef UrlOpener = Future<bool> Function(Uri url);

@Riverpod(keepAlive: true)
UrlOpener externalUrlOpener(Ref ref) =>
    (url) => launchUrl(url, mode: LaunchMode.externalApplication);

/// Wall clock of the phone; overridden in tests.
typedef Clock = DateTime Function();

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => DateTime.now;

String _platformName() => switch (Platform.operatingSystem) {
  'ios' => 'iOS',
  'android' => 'Android',
  final other => other,
};
