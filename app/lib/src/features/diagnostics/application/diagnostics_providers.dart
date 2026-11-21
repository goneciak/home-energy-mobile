import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gi_home/src/core/l10n/request_language.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/diagnostics/application/cold_start_meter.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'diagnostics_providers.g.dart';

/// The app's diagnostics. `main` overrides it with the instance its error
/// handlers write to; the default keeps everything in memory (tests).
@Riverpod(keepAlive: true)
DiagnosticsService diagnosticsService(Ref ref) {
  final service = DiagnosticsService();
  ref.onDispose(service.dispose);
  return service;
}

/// Started on the first line of `main`; `null` when cold start is not
/// measured (tests).
@Riverpod(keepAlive: true)
Stopwatch? coldStartStopwatch(Ref ref) => null;

/// Measures this start up to the Home condition (plan §1.1 G1).
@Riverpod(keepAlive: true)
ColdStartMeter coldStartMeter(Ref ref) => ColdStartMeter(
  ref.watch(coldStartStopwatchProvider),
  ref.watch(diagnosticsServiceProvider),
);

/// Build, device and appliance facts for the diagnostic report.
@riverpod
ReportEnvironment reportEnvironment(Ref ref) {
  final appInfo = ref.watch(appInfoProvider);
  final profile = ref.watch(applianceProfileProvider);
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final language = ref.watch(requestLanguageProvider)();
  return ReportEnvironment(
    appVersion: appInfo.version,
    buildNumber: appInfo.buildNumber,
    platform: Platform.operatingSystem,
    osVersion: Platform.operatingSystemVersion,
    locale: '$language (system ${systemLocale.toLanguageTag()})',
    applianceConnected: profile != null,
    applianceCleartext: profile?.address.isCleartext,
  );
}

/// Opens the system share sheet; overridden in tests.
typedef ShareLauncher = Future<void> Function(ShareParams params);

@Riverpod(keepAlive: true)
ShareLauncher shareLauncher(Ref ref) => SharePlus.instance.share;

/// Where a report file is written before it is shared; overridden in tests.
@Riverpod(keepAlive: true)
Future<Directory> Function() reportDirectory(Ref ref) => getTemporaryDirectory;
