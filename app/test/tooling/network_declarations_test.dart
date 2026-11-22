import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What the app declares to the platforms for finding GI Home on the local
/// network: nothing beyond what the features that are shipped need.
void main() {
  // `flutter test` runs from app/; a Windows checkout may have CRLF.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  group('Android manifest', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');

    test('has the network permissions the app uses', () {
      for (final permission in [
        'INTERNET',
        'ACCESS_NETWORK_STATE',
        'NEARBY_WIFI_DEVICES',
      ]) {
        expect(manifest, contains('android.permission.$permission'));
      }
    });

    test('NEARBY_WIFI_DEVICES is never used to derive a location', () {
      expect(
        manifest,
        contains(
          'android:name="android.permission.NEARBY_WIFI_DEVICES"\n'
          '        android:usesPermissionFlags="neverForLocation"',
        ),
      );
    });

    test('the multicast permission is declared with the multicast DNS '
        'fallback behind its flag, and nothing broader', () {
      expect(
        manifest,
        contains('android.permission.CHANGE_WIFI_MULTICAST_STATE'),
      );
      expect(
        read('lib/src/core/config/feature_flags.dart'),
        contains("mdnsFallback('FF_MDNS_FALLBACK')"),
      );
      for (final broader in [
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
        'CHANGE_WIFI_STATE',
        'ACCESS_WIFI_STATE',
      ]) {
        expect(manifest, isNot(contains('android.permission.$broader')));
      }
    });
  });

  group('iOS Info.plist', () {
    final plist = read('ios/Runner/Info.plist');

    test('allows local networking and explains the prompt', () {
      expect(plist, contains('NSAllowsLocalNetworking'));
      expect(plist, contains('NSLocalNetworkUsageDescription'));
    });

    test('declares no Bonjour services: .local names resolve through the '
        'system, no browsing is needed', () {
      expect(plist, isNot(contains('NSBonjourServices')));
    });
  });

  group('feature flags', () {
    test('the multicast DNS fallback is off in every flavor', () {
      for (final flavor in ['dev', 'beta', 'prod']) {
        expect(
          read('config/$flavor.json'),
          contains('"FF_MDNS_FALLBACK": false'),
          reason: flavor,
        );
      }
    });
  });
}
