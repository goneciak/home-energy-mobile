import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:meta/meta.dart';

/// The phone as named in the `User-Agent` (plan §6.5 point 2): the only
/// label of this device the user sees in GI Core's session list.
@immutable
final class DeviceIdentity {
  const new({required this.os, required this.osVersion, this.model});

  /// The identity of an Android device: the model prefixed with its
  /// manufacturer unless the model already names it (`Pixel 8` stays,
  /// `SM-S921B` becomes `samsung SM-S921B`).
  factory android({
    required String release,
    required String manufacturer,
    required String model,
  }) {
    final maker = manufacturer.trim();
    final name = model.trim();
    final named =
        maker.isEmpty ||
        name.toLowerCase().startsWith(maker.toLowerCase()) ||
        _knownBrandModel.hasMatch(name);
    return DeviceIdentity(
      os: 'android',
      osVersion: release.trim(),
      model: name.isEmpty ? null : (named ? name : '$maker $name'),
    );
  }

  /// The identity of an iOS device: the marketing name (`iPhone 15 Pro`)
  /// when the plugin knows it, otherwise the hardware id (`iPhone16,1`).
  factory ios({
    required String systemVersion,
    required String modelName,
    required String machine,
  }) {
    final name = modelName.trim();
    final hardware = machine.trim();
    return DeviceIdentity(
      os: 'ios',
      osVersion: systemVersion.trim(),
      model: name.isNotEmpty ? name : (hardware.isEmpty ? null : hardware),
    );
  }

  /// `android`, `ios` or another `Platform.operatingSystem` value.
  final String os;

  /// Marketing version of the OS, e.g. `15` (Android) or `18.1` (iOS).
  final String osVersion;

  /// Device model, e.g. `Pixel 8` or `iPhone 15 Pro`; `null` when unknown.
  final String? model;

  /// The platform part of the `User-Agent`:
  ///
  /// * Android: `Linux; Android 15; Pixel 8`;
  /// * iOS: `iPhone; iOS 18.1; iPhone 15 Pro`;
  /// * anything else: `<os>; <version>`.
  ///
  /// The model is left out when unknown.
  String get userAgentPlatform {
    final model = this.model?.trim();
    final parts = switch (os) {
      'android' => ['Linux', 'Android $osVersion'],
      'ios' => ['iPhone', 'iOS $osVersion'],
      _ => [os, osVersion],
    };
    return [...parts, if (model != null && model.isNotEmpty) model].join('; ');
  }

  @override
  bool operator ==(Object other) =>
      other is DeviceIdentity &&
      other.os == os &&
      other.osVersion == osVersion &&
      other.model == model;

  @override
  int get hashCode => Object.hash(os, osVersion, model);

  @override
  String toString() => 'DeviceIdentity($userAgentPlatform)';

  /// Model names that are recognisable without the manufacturer
  /// (`Google Pixel 8` would only repeat the brand).
  static final _knownBrandModel = RegExp(r'^(Pixel|Nexus)\b');
}

/// Reads the [DeviceIdentity] of this phone; `null` on other platforms or
/// when the plugin fails, so the `User-Agent` falls back to
/// `Platform.operatingSystemVersion`. Never throws.
Future<DeviceIdentity?> readDeviceIdentity([DeviceInfoPlugin? plugin]) async {
  final info = plugin ?? DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return DeviceIdentity.android(
        release: android.version.release,
        manufacturer: android.manufacturer,
        model: android.model,
      );
    }
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return DeviceIdentity.ios(
        systemVersion: ios.systemVersion,
        modelName: ios.modelName,
        machine: ios.utsname.machine,
      );
    }
  } on Object {
    // The fallback label is good enough for a session list.
  }
  return null;
}
