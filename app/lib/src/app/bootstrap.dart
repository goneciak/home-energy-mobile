import 'dart:async';
import 'dart:io' show Directory;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/app/preference_keys.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/backup_exclusion.dart';
import 'package:gi_home/src/core/platform/device_identity.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/font_licenses.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/auth/data/reinstall_marker.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/application/error_handlers.dart';
import 'package:gi_home/src/features/diagnostics/data/diagnostics_store.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The body of every flavor's `main` (`lib/main_dev.dart`,
/// `lib/main_beta.dart`, `lib/main.dart`).
///
/// The build must be configured for [flavor]: a `--dart-define-from-file`
/// of another flavor stops the start here, before anything runs (plan
/// §19.2).
void bootstrap(AppFlavor flavor) {
  final coldStart = Stopwatch()..start();
  final config = AppConfig.fromEnvironment(flavor);
  // Created before anything else so errors during start-up are kept too.
  final diagnostics = DiagnosticsService();

  // Uncaught Dart errors do not crash the process, so they would never reach
  // the native crash reports; they go to the redacted ring buffer instead
  // (plan §8.4). The binding is initialised inside the same zone as runApp.
  final started = runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    installErrorHandlers(diagnostics);
    await runGiHome(
      config: config,
      diagnostics: diagnostics,
      coldStart: coldStart,
    );
  }, zoneErrorHandler(diagnostics));
  if (started != null) unawaited(started);
}

/// Loads what the first frame needs and runs the app with [config].
/// [bootstrap] calls it inside its error zone; integration tests call it
/// directly, under their own binding and error handlers.
Future<void> runGiHome({
  required AppConfig config,
  DiagnosticsService? diagnostics,
  Stopwatch? coldStart,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = diagnostics ?? DiagnosticsService();
  registerFontLicenses();
  final (prefs, packageInfo, deviceIdentity, _) = await (
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: appPreferenceKeys,
      ),
    ),
    PackageInfo.fromPlatform(),
    readDeviceIdentity(),
    _attachDiagnosticsStore(service),
  ).wait;
  // Before anything reads secure storage (plan §7.1).
  await ReinstallMarker(
    prefs,
    appSecureStorage,
  ).check(hasProfile: ApplianceProfileStore(prefs).read() != null);

  runApp(
    ProviderScope(
      // The API client has its own retry policy; failed providers surface
      // their error instead of being retried behind the user's back.
      retry: (retryCount, error) => null,
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(prefs),
        appInfoProvider.overrideWithValue(
          AppInfo(
            version: packageInfo.version,
            buildNumber: packageInfo.buildNumber,
          ),
        ),
        deviceIdentityProvider.overrideWithValue(deviceIdentity),
        diagnosticsServiceProvider.overrideWithValue(service),
        coldStartStopwatchProvider.overrideWithValue(coldStart),
      ],
      child: const GiHomeApp(),
    ),
  );
}

/// Diagnostics live in Application Support, excluded from backups (§8.3).
/// Without it they stay in memory for this run.
Future<void> _attachDiagnosticsStore(DiagnosticsService diagnostics) async {
  try {
    final directory = await getApplicationSupportDirectory();
    await excludeFromBackup(directory, diagnostics);
    await diagnostics.attach(FileDiagnosticsStore(directory));
  } on Object catch (error, stack) {
    diagnostics.recordError(ErrorKind.zone, error, stack);
  }
}

/// Excludes [applicationSupport] (diagnostics now; snapshot and ETag cache
/// from M3) from iOS backups. A failure is recorded in [diagnostics] and
/// never stops the start.
Future<void> excludeFromBackup(
  Directory applicationSupport,
  DiagnosticsService diagnostics, {
  TargetPlatform? platform,
}) => BackupExclusion.exclude(
  applicationSupport,
  platform: platform,
  onError: (error, stack) => diagnostics.recordError(
    ErrorKind.platform,
    error,
    stack,
    'backup exclusion',
  ),
);
