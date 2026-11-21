import 'package:flutter/services.dart';

/// The app's own method channel, served by `MainActivity.kt` on Android
/// (plan §9.4). iOS does not implement it.
///
/// Methods:
/// * `sdkInt` → the Android API level (`Build.VERSION.SDK_INT`);
/// * `openAppSettings` → opens the app's page in the system settings
///   (`Settings.ACTION_APPLICATION_DETAILS_SETTINGS`), `true` if it opened;
/// * `requestNearbyWifiDevices` → asks for `NEARBY_WIFI_DEVICES` and answers
///   `granted`, `denied` or `permanentlyDenied`.
const giPlatformChannel = MethodChannel('pl.gihome.gi_home/platform');
