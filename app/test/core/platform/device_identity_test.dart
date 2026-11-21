import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/platform/device_identity.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';

import '../../support/test_app.dart';

void main() {
  group('DeviceIdentity.userAgentPlatform', () {
    test('Android: Linux, the release and the model', () {
      final identity = DeviceIdentity.android(
        release: '15',
        manufacturer: 'Google',
        model: 'Pixel 8',
      );

      expect(identity.userAgentPlatform, 'Linux; Android 15; Pixel 8');
    });

    test('Android: a bare model number gets its manufacturer', () {
      expect(
        DeviceIdentity.android(
          release: '14',
          manufacturer: 'samsung',
          model: 'SM-S921B',
        ).userAgentPlatform,
        'Linux; Android 14; samsung SM-S921B',
      );
      // Not repeated when the model already starts with it.
      expect(
        DeviceIdentity.android(
          release: '16',
          manufacturer: 'Xiaomi',
          model: 'Xiaomi 14T',
        ).userAgentPlatform,
        'Linux; Android 16; Xiaomi 14T',
      );
    });

    test('iOS: iPhone, the version and the marketing name', () {
      final identity = DeviceIdentity.ios(
        systemVersion: '18.1',
        modelName: 'iPhone 15 Pro',
        machine: 'iPhone16,1',
      );

      expect(identity.userAgentPlatform, 'iPhone; iOS 18.1; iPhone 15 Pro');
    });

    test('iOS: the hardware id when the marketing name is unknown', () {
      expect(
        DeviceIdentity.ios(
          systemVersion: '26.0',
          modelName: '',
          machine: 'iPhone99,9',
        ).userAgentPlatform,
        'iPhone; iOS 26.0; iPhone99,9',
      );
    });

    test('an unknown model is left out', () {
      expect(
        DeviceIdentity.android(
          release: '15',
          manufacturer: 'Google',
          model: ' ',
        ).userAgentPlatform,
        'Linux; Android 15',
      );
      expect(
        DeviceIdentity.ios(
          systemVersion: '18.1',
          modelName: '',
          machine: '',
        ).userAgentPlatform,
        'iPhone; iOS 18.1',
      );
    });
  });

  group('clientInfoProvider', () {
    test('names the phone model in the User-Agent', () {
      final container = ProviderContainer.test(
        overrides: [
          appInfoProvider.overrideWithValue(testAppInfo),
          deviceIdentityProvider.overrideWithValue(
            const DeviceIdentity(
              os: 'android',
              osVersion: '15',
              model: 'Pixel 8',
            ),
          ),
        ],
      );

      expect(
        container.read(clientInfoProvider).userAgent,
        'GIHome-Mobile/0.1.0 (Linux; Android 15; Pixel 8)',
      );
    });

    test('falls back to the OS version without device info', () {
      final container = ProviderContainer.test(
        overrides: [appInfoProvider.overrideWithValue(testAppInfo)],
      );

      final platform = container.read(clientInfoProvider).platform;

      expect(platform, endsWith('; ${Platform.operatingSystemVersion}'));
    });
  });

  test('readDeviceIdentity gives null off Android and iOS', () async {
    // The test host is a desktop: no plugin call is made.
    expect(await readDeviceIdentity(), isNull);
  });
}
