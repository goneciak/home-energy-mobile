import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/config/feature_flag_overrides_store.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../support/test_app.dart';

void main() {
  const key = FeatureFlagOverridesStore.overridesKey;

  /// Preferences as a fresh start of the app reads them.
  Future<SharedPreferencesWithCache> reopen() =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {key}),
      );

  /// A container for a [flavor] build with [defaults] whose preferences
  /// hold the overrides [stored].
  Future<ProviderContainer> containerFor(
    AppFlavor flavor, {
    Map<FeatureFlag, bool> defaults = const {},
    Map<String, Object?>? stored,
  }) async {
    final prefs = await inMemoryPreferences();
    if (stored != null) await prefs.setString(key, jsonEncode(stored));
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          testConfig(flavor, flagDefaults: defaults),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The overrides stored on the phone, as JSON.
  Future<Object?> persisted() async {
    final raw = (await reopen()).getString(key);
    return raw == null ? null : jsonDecode(raw);
  }

  test('defaults per flavor come from the config', () async {
    for (final flavor in AppFlavor.values) {
      final container = await containerFor(
        flavor,
        defaults: const {
          FeatureFlag.mockCore: true,
          FeatureFlag.scheduleClockConversion: true,
        },
      );
      final flags = container.read(featureFlagsProvider);

      expect(flags.mockCore, flavor == AppFlavor.dev, reason: flavor.name);
      expect(flags.scheduleClockConversion, isTrue, reason: flavor.name);
      expect(flags.switchControlByIntegration, isFalse);
      expect(flags.androidLocalNetworkPermissionRequest, isFalse);
    }
  });

  test('without an override the config is prod with every flag off', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appFlavorProvider), AppFlavor.prod);
    expect(container.read(featureFlagsProvider), FeatureFlags.allOff);
  });

  for (final flavor in [AppFlavor.dev, AppFlavor.beta]) {
    test(
      '${flavor.name}: overrides are stored and survive a restart',
      () async {
        final container = await containerFor(flavor);
        final notifier = container.read(featureFlagsProvider.notifier);

        await notifier.set(FeatureFlag.switchControlByIntegration, value: true);

        expect(
          container.read(featureFlagsProvider).switchControlByIntegration,
          isTrue,
        );
        expect(await persisted(), {'switchControlByIntegration': true});

        final restarted = ProviderContainer(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig(flavor)),
            sharedPreferencesProvider.overrideWithValue(await reopen()),
          ],
        );
        addTearDown(restarted.dispose);
        expect(
          restarted.read(featureFlagsProvider).switchControlByIntegration,
          isTrue,
        );

        // Back to the default drops the override; reset drops them all.
        await notifier.set(
          FeatureFlag.switchControlByIntegration,
          value: false,
        );
        expect(await persisted(), isNull);
        await notifier.set(FeatureFlag.scheduleClockConversion, value: true);
        expect(await persisted(), {'scheduleClockConversion': true});
        await notifier.resetToDefaults();
        expect(container.read(featureFlagsProvider), FeatureFlags.allOff);
        expect(await persisted(), isNull);
      },
    );
  }

  test('an override can switch a default off', () async {
    final container = await containerFor(
      AppFlavor.beta,
      defaults: const {FeatureFlag.scheduleClockConversion: true},
    );

    await container
        .read(featureFlagsProvider.notifier)
        .set(FeatureFlag.scheduleClockConversion, value: false);

    expect(
      container.read(featureFlagsProvider).scheduleClockConversion,
      isFalse,
    );
    expect(await persisted(), {'scheduleClockConversion': false});
  });

  test('beta cannot switch the mock Core on', () async {
    final container = await containerFor(
      AppFlavor.beta,
      stored: {'mockCore': true},
    );
    final notifier = container.read(featureFlagsProvider.notifier);

    expect(container.read(featureFlagsProvider).mockCore, isFalse);
    expect(notifier.canOverride(FeatureFlag.mockCore), isFalse);

    await notifier.set(FeatureFlag.mockCore, value: true);

    expect(container.read(featureFlagsProvider).mockCore, isFalse);
  });

  test('prod ignores stored overrides and never writes any', () async {
    const stored = {
      'scheduleClockConversion': false,
      'switchControlByIntegration': true,
    };
    final container = await containerFor(
      AppFlavor.prod,
      defaults: const {FeatureFlag.scheduleClockConversion: true},
      stored: stored,
    );
    final notifier = container.read(featureFlagsProvider.notifier);

    expect(
      container.read(featureFlagsProvider),
      FeatureFlags(const {FeatureFlag.scheduleClockConversion: true}),
    );
    for (final flag in FeatureFlag.values) {
      expect(notifier.canOverride(flag), isFalse, reason: flag.name);
    }

    await notifier.set(
      FeatureFlag.androidLocalNetworkPermissionRequest,
      value: true,
    );
    await notifier.resetToDefaults();

    expect(
      container.read(featureFlagsProvider),
      FeatureFlags(const {FeatureFlag.scheduleClockConversion: true}),
    );
    expect(await persisted(), stored);
  });

  test('unknown or malformed stored overrides are ignored', () async {
    final cases = <String, Map<FeatureFlag, bool>>{
      'not json': {},
      '[1, 2]': {},
      jsonEncode({
        'removedFlag': true,
        'mockCore': 'yes',
        'scheduleClockConversion': true,
      }): {
        FeatureFlag.scheduleClockConversion: true,
      },
    };
    for (final MapEntry(key: stored, value: expected) in cases.entries) {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({key: stored});

      expect(
        FeatureFlagOverridesStore(await reopen()).read(),
        expected,
        reason: stored,
      );
    }
  });
}
