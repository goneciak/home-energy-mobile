import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/config/config_providers.dart';

void main() {
  group('AppConfig.parse', () {
    test('reads the flavor and the flag defaults', () {
      final config = AppConfig.parse(AppFlavor.dev, const {
        'FLAVOR': 'dev',
        'FF_MOCK_CORE': 'true',
        'FF_SCHEDULE_CLOCK_CONVERSION': 'false',
        'FF_SWITCH_CONTROL_BY_INTEGRATION': 'true',
        'FF_ANDROID_LOCAL_NETWORK_PERMISSION_REQUEST': '',
      });

      expect(config.flavor, AppFlavor.dev);
      expect(config.flagDefaults.mockCore, isTrue);
      expect(config.flagDefaults.scheduleClockConversion, isFalse);
      expect(config.flagDefaults.switchControlByIntegration, isTrue);
      expect(config.flagDefaults.androidLocalNetworkPermissionRequest, isFalse);
      // Unset defines are left out of what the screen shows.
      expect(config.defines.keys, [
        'FLAVOR',
        'FF_MOCK_CORE',
        'FF_SCHEDULE_CLOCK_CONVERSION',
        'FF_SWITCH_CONTROL_BY_INTEGRATION',
      ]);
    });

    test('without defines every flag is off', () {
      for (final flavor in AppFlavor.values) {
        final config = AppConfig.parse(flavor, const {});

        expect(config.flavor, flavor);
        expect(config.flagDefaults, FeatureFlags.allOff);
        expect(config.defines, isEmpty);
      }
    });

    test('a FLAVOR of another flavor is rejected', () {
      expect(
        () => AppConfig.parse(AppFlavor.prod, const {'FLAVOR': 'dev'}),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('config/prod.json'),
          ),
        ),
      );
      expect(
        () => AppConfig.parse(AppFlavor.dev, const {'FLAVOR': 'beta'}),
        throwsStateError,
      );
    });

    test('an unknown flavor or a non-boolean flag is a format error', () {
      expect(
        () => AppConfig.parse(AppFlavor.dev, const {'FLAVOR': 'staging'}),
        throwsFormatException,
      );
      expect(
        () => AppConfig.parse(AppFlavor.dev, const {'FF_MOCK_CORE': 'yes'}),
        throwsFormatException,
      );
    });

    test('the mock Core cannot be switched on outside dev', () {
      for (final flavor in [AppFlavor.beta, AppFlavor.prod]) {
        final config = AppConfig.parse(flavor, const {
          'FF_MOCK_CORE': 'true',
          'FF_SCHEDULE_CLOCK_CONVERSION': 'true',
        });

        expect(config.flagDefaults.mockCore, isFalse, reason: flavor.name);
        expect(config.flagDefaults.scheduleClockConversion, isTrue);
      }
    });

    test('reads the store links; empty means none', () {
      final config = AppConfig.parse(AppFlavor.prod, const {
        'STORE_URL_ANDROID':
            'https://play.google.com/store/apps/details?id=pl.gi.home',
        'STORE_URL_IOS': '',
      });

      expect(
        config.storeUrlFor(TargetPlatform.android),
        Uri.parse('https://play.google.com/store/apps/details?id=pl.gi.home'),
      );
      expect(config.iosStoreUrl, isNull);
      expect(config.storeUrlFor(TargetPlatform.iOS), isNull);
      expect(config.storeUrlFor(TargetPlatform.linux), isNull);
      expect(AppConfig.parse(AppFlavor.prod, const {}).androidStoreUrl, isNull);
    });

    test('a store link must be an https URL', () {
      for (final value in ['http://example.com/app', 'not a url', 'https:']) {
        expect(
          () => AppConfig.parse(AppFlavor.prod, {'STORE_URL_IOS': value}),
          throwsFormatException,
          reason: value,
        );
      }
    });

    test('a test run without defines builds the prod config', () {
      expect(
        AppConfig.fromEnvironment(AppFlavor.prod),
        AppConfig.parse(AppFlavor.prod, const {}),
      );
    });
  });

  test('every define the app reads is compiled in', () {
    expect(AppConfig.compiledDefines.keys.toSet(), {
      AppConfig.flavorDefine,
      for (final flag in FeatureFlag.values) flag.define,
      AppConfig.androidStoreUrlDefine,
      AppConfig.iosStoreUrlDefine,
    });
  });

  group('config/<flavor>.json', () {
    String read(AppFlavor flavor) =>
        File('config/${flavor.name}.json').readAsStringSync();

    // `--dart-define-from-file` passes every value as its text.
    Map<String, String> defines(AppFlavor flavor) => {
      for (final MapEntry(:key, :value)
          in (jsonDecode(read(flavor)) as Map<String, Object?>).entries)
        key: '$value',
    };

    for (final flavor in AppFlavor.values) {
      test('${flavor.name}.json configures its flavor', () {
        final values = defines(flavor);
        final config = AppConfig.parse(flavor, values);

        expect(values['FLAVOR'], flavor.name);
        expect(values.keys.toSet(), AppConfig.compiledDefines.keys.toSet());
        // Beta looks for the appliance by multicast DNS too: testers on
        // phones that cannot resolve gi-home.local (the IP always works).
        expect(
          config.flagDefaults,
          flavor == AppFlavor.beta
              ? FeatureFlags(const {FeatureFlag.mdnsFallback: true})
              : FeatureFlags.allOff,
        );
        // No store listing yet: the update banner shows its text only.
        expect(config.androidStoreUrl, isNull);
        expect(config.iosStoreUrl, isNull);
      });
    }

    test('hold no secrets', () {
      final secret = RegExp('password|secret|token|key', caseSensitive: false);
      for (final flavor in AppFlavor.values) {
        expect(read(flavor), isNot(contains(secret)), reason: flavor.name);
      }
    });
  });

  group('FeatureFlags', () {
    test('is a value with typed getters', () {
      final flags = FeatureFlags(const {
        FeatureFlag.switchControlByIntegration: true,
      });

      expect(flags.switchControlByIntegration, isTrue);
      expect(flags.mockCore, isFalse);
      expect(flags.scheduleClockConversion, isFalse);
      expect(flags.androidLocalNetworkPermissionRequest, isFalse);
      expect(flags, FeatureFlags(flags.asMap()));
      expect(flags.hashCode, FeatureFlags(flags.asMap()).hashCode);
      expect(flags, isNot(FeatureFlags.allOff));
      expect(flags.asMap().keys, FeatureFlag.values);
      expect(
        () => flags.asMap()[FeatureFlag.mockCore] = true,
        throwsUnsupportedError,
      );
      expect(flags.toString(), 'FeatureFlags(switchControlByIntegration)');
    });

    test('merge and restrictTo', () {
      final flags = FeatureFlags.allOff.merge({
        FeatureFlag.mockCore: true,
        FeatureFlag.scheduleClockConversion: true,
      });

      expect(flags.mockCore, isTrue);
      expect(flags.restrictTo(AppFlavor.dev), flags);
      expect(flags.restrictTo(AppFlavor.beta).mockCore, isFalse);
      expect(flags.restrictTo(AppFlavor.beta).scheduleClockConversion, isTrue);
    });

    test('only the mock Core is dev-only', () {
      expect(
        [
          for (final flag in FeatureFlag.values)
            if (flag.devOnly) flag,
        ],
        [FeatureFlag.mockCore],
      );
    });
  });
}
