import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:gi_home/src/app/preference_keys.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const testAppInfo = AppInfo(version: '0.1.0', buildNumber: '1');

final testProfile = ApplianceProfile(
  profileId: '0123456789abcdef0123456789abcdef',
  label: 'GI Home Dev',
  baseUrl: 'http://10.0.2.2:3000',
  deviceName: 'GI Home Dev',
  initializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
);

/// The config of a [flavor] build with the given flag defaults.
AppConfig testConfig(
  AppFlavor flavor, {
  Map<FeatureFlag, bool> flagDefaults = const {},
}) => AppConfig(
  flavor: flavor,
  flagDefaults: FeatureFlags(flagDefaults).restrictTo(flavor),
  defines: {AppConfig.flavorDefine: flavor.name},
);

/// In-memory preferences, optionally holding [profile].
Future<SharedPreferencesWithCache> inMemoryPreferences({
  ApplianceProfile? profile,
}) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({
        if (profile != null)
          ApplianceProfileStore.profileKey: jsonEncode(profile.toJson()),
      });
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: appPreferenceKeys,
    ),
  );
}

/// [child] inside a Polish, themed [MaterialApp] and a [ProviderScope].
Widget testScreen(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('pl'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
