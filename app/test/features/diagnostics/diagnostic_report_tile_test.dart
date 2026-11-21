import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostic_report_sharer.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:gi_home/src/features/diagnostics/presentation/diagnostic_report_tile.dart';
import 'package:gi_home/src/features/settings/presentation/settings_screen.dart';
import 'package:share_plus/share_plus.dart';

import '../../support/test_app.dart';

void main() {
  late Directory tempRoot;
  late List<ShareParams> shared;
  late DiagnosticsService diagnostics;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('gi-report-');
    shared = [];
    diagnostics = DiagnosticsService()
      ..recordError(
        ErrorKind.zone,
        'GET http://192.168.1.10:3000/api/v1/auth/me for owner@example.com '
        'with Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ4In0.c2ln',
      )
      ..recordSessionLost(SessionLostReason.refreshTokenReused);
  });

  tearDown(() async {
    diagnostics.dispose();
    if (tempRoot.existsSync()) await tempRoot.delete(recursive: true);
  });

  Future<List<Override>> overrides({
    Future<Directory> Function()? directory,
  }) async => [
    sharedPreferencesProvider.overrideWithValue(await inMemoryPreferences()),
    appInfoProvider.overrideWithValue(testAppInfo),
    currentUserProvider.overrideWithValue(null),
    sessionExpiresAtProvider.overrideWithValue(null),
    diagnosticsServiceProvider.overrideWithValue(diagnostics),
    shareLauncherProvider.overrideWithValue((params) async {
      shared.add(params);
    }),
    reportDirectoryProvider.overrideWithValue(
      directory ?? () async => tempRoot,
    ),
  ];

  String sharedReport() {
    final file = File(shared.single.files!.single.path);
    return file.readAsStringSync();
  }

  test('the sharer writes one redacted JSON file and shares it', () async {
    final container = ProviderContainer(overrides: await overrides());
    addTearDown(container.dispose);
    final sharer = container.read(diagnosticReportSharerProvider);

    final first = await sharer.writeReport();
    await sharer.share(subject: 'Raport');

    // Older reports are removed: one file waits in the folder.
    expect(first.parent.listSync(), hasLength(1));
    final params = shared.single;
    expect(params.subject, 'Raport');
    expect(params.files!.single.mimeType, 'application/json');
    expect(params.files!.single.path, endsWith('.json'));
    final report = sharedReport();
    final json = jsonDecode(report) as Map<String, Object?>;
    expect(json['app'], {'version': '0.1.0', 'build': '1'});
    expect((json['counters']! as Map<String, Object?>)['sessionLost'], {
      'refreshTokenReused': 1,
    });
    expect(report, isNot(contains('192.168.1.10')));
    expect(report, isNot(contains('owner@example.com')));
    expect(report, isNot(contains('eyJ')));
  });

  testWidgets('Settings offer the diagnostic report with an explanation', (
    tester,
  ) async {
    final scope = await tester.runAsync(overrides);
    await tester.pumpWidget(
      testScreen(const SettingsScreen(), overrides: scope!),
    );
    await tester.pumpAndSettle();

    final tile = find.byKey(DiagnosticReportTile.tileKey);
    await tester.scrollUntilVisible(tile, 100);
    expect(find.text('Wyślij raport diagnostyczny'), findsOneWidget);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Raport diagnostyczny'), findsOneWidget);
    expect(
      find.textContaining('Nic nie jest wysyłane automatycznie'),
      findsOneWidget,
    );
    expect(find.textContaining('adresy IP są usuwane'), findsOneWidget);

    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();
    expect(shared, isEmpty);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DiagnosticReportTile.shareKey));
    // The report is written with real file I/O.
    for (var i = 0; i < 50 && shared.isEmpty; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();

    expect(shared, hasLength(1));
    expect(shared.single.subject, 'Raport diagnostyczny GI Home');
    expect(sharedReport(), isNot(contains('owner@example.com')));
  });

  testWidgets('a report that cannot be written shows a message', (
    tester,
  ) async {
    final scope = await tester.runAsync(
      () => overrides(
        directory: () async => throw const FileSystemException('no temp'),
      ),
    );
    await tester.pumpWidget(
      testScreen(const SettingsScreen(), overrides: scope!),
    );
    await tester.pumpAndSettle();

    final tile = find.byKey(DiagnosticReportTile.tileKey);
    await tester.scrollUntilVisible(tile, 100);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DiagnosticReportTile.shareKey));
    await tester.pumpAndSettle();

    expect(
      find.text('Nie udało się przygotować raportu. Spróbuj ponownie.'),
      findsOneWidget,
    );
    expect(shared, isEmpty);
  });
}
