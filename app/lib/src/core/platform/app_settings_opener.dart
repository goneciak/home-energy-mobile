import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:gi_home/src/core/platform/gi_platform_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_settings_opener.g.dart';

/// Opens this app's page in the system settings, where the user allows
/// local network access after denying it (plan §9.4, "Otwórz ustawienia").
abstract interface class AppSettingsOpener {
  /// Whether the settings page opened.
  Future<bool> open();
}

/// Android: `Settings.ACTION_APPLICATION_DETAILS_SETTINGS` through
/// [giPlatformChannel]. iOS: `UIApplication.openSettingsURLString`
/// (`app-settings:`), which opens the app's own page in Settings.
final class PlatformAppSettingsOpener implements AppSettingsOpener {
  const new();

  /// `UIApplication.openSettingsURLString`.
  static final Uri iosSettingsUrl = Uri.parse('app-settings:');

  @override
  Future<bool> open() async {
    try {
      if (Platform.isAndroid) {
        return await giPlatformChannel.invokeMethod<bool>('openAppSettings') ??
            false;
      }
      if (Platform.isIOS) return await launchUrl(iosSettingsUrl);
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
AppSettingsOpener appSettingsOpener(Ref ref) =>
    const PlatformAppSettingsOpener();
