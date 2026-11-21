import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/app_settings_opener.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/auth/data/secure_token_vault.dart';
import 'package:gi_home/src/features/auth/data/vault_read_failures.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostic_report_sharer.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/data/diagnostics_store.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../support/accessibility.dart';
import '../support/fake_core_adapter.dart';
import '../support/fake_platform.dart';
import '../support/fixtures.dart';
import '../support/test_app.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

/// End-to-end routing through the real providers, session manager and
/// router, with GI Core replaced by [FakeCoreAdapter].
void main() {
  late FakeCoreAdapter core;
  late InMemoryTokenVault vault;
  late Directory reportRoot;
  late FakeSettingsOpener settings;

  const seededDeviceId = '341584fe-d238-44e5-b97b-191ff594bb09';
  final storedCookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'B' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17),
    absoluteExpiry: DateTime.utc(2099),
  );

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    ApplianceProfile? profile,
    AppForeground? foreground,
    Stopwatch? coldStart,
    DiagnosticsService? diagnostics,
    FlutterSecureStorage? secureStorage,
    HostResolver resolver = const StaticHostResolver({}),
    Size physicalSize = const Size(1200, 3600),
  }) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = physicalSize
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(profile: profile),
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(core),
          // With [secureStorage] the real vault chain is used.
          if (secureStorage != null)
            secureStorageProvider.overrideWithValue(secureStorage)
          else
            tokenVaultProvider.overrideWith(
              (ref) =>
                  ref.watch(applianceProfileProvider) == null ? null : vault,
            ),
          if (foreground != null)
            appForegroundProvider.overrideWithValue(foreground),
          if (coldStart != null)
            coldStartStopwatchProvider.overrideWithValue(coldStart),
          if (diagnostics != null)
            diagnosticsServiceProvider.overrideWithValue(diagnostics),
          reportDirectoryProvider.overrideWithValue(() async => reportRoot),
          hostResolverProvider.overrideWithValue(resolver),
          appSettingsOpenerProvider.overrideWithValue(settings),
        ],
        child: const GiHomeApp(),
      ),
    );
    // A restore held in the background shows a spinner that never settles.
    if (foreground?.value ?? true) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return ProviderScope.containerOf(tester.element(find.byType(GiHomeApp)));
  }

  setUp(() {
    settings = FakeSettingsOpener();
    reportRoot = Directory.systemTemp.createTempSync('gi-flow-');
    addTearDown(() => reportRoot.deleteSync(recursive: true));
    vault = InMemoryTokenVault();
    core = FakeCoreAdapter({
      ...healthyApplianceRoutes(),
      'POST /api/v1/auth/login': (_) => jsonReply(
        {'accessToken': 'access-1', 'expiresIn': 900, 'user': ownerUser},
        headers: {
          'set-cookie': [testSetCookie],
        },
      ),
      'POST /api/v1/auth/refresh': (_) => jsonReply(
        {'accessToken': 'access-2', 'expiresIn': 900},
        headers: {
          'set-cookie': [testSetCookie],
        },
      ),
      'GET /api/v1/auth/me': (_) => jsonReply(ownerUser),
      'POST /api/v1/auth/logout': (_) => jsonReply(null, status: 204),
      'GET /api/v1/devices': (_) =>
          jsonReply(fixtureJson('DevicesController_list/seeded.json')),
      'GET /api/v1/rooms': (_) =>
          jsonReply(fixtureJson('RoomsController_list/seeded.json')),
      'GET /api/v1/devices/$seededDeviceId': (_) => jsonReply(
        fixtureJson('DevicesController_get/no_room_no_entities.json'),
      ),
    });
  });

  /// A report written for the share sheet, and share_plus's copy of it, as
  /// they are left in the temporary directory after sharing.
  List<Directory> leaveSharedReport() {
    final separator = Platform.pathSeparator;
    final folders = [
      for (final name in [
        DiagnosticReportSharer.folderName,
        DiagnosticReportSharer.sharePlusFolderName,
      ])
        Directory('${reportRoot.path}$separator$name')..createSync(),
    ];
    for (final folder in folders) {
      File('${folder.path}${separator}report.json').writeAsStringSync('{}');
    }
    return folders;
  }

  void expectHome() {
    expect(find.text('Dom'), findsWidgets);
    expect(find.text('Kotłownia'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('device-$seededDeviceId')),
      findsOneWidget,
    );
  }

  testWidgets('without a profile the app opens the connect screen', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Połącz z GI Home'), findsOneWidget);
  });

  testWidgets('an appliance that is not set up leads to setup required', (
    tester,
  ) async {
    await pumpApp(tester, profile: testProfile.copyWith(initializedAt: null));

    expect(find.text('Dokończ konfigurację'), findsOneWidget);
    expect(find.textContaining('10.0.2.2:3000'), findsWidgets);
  });

  testWidgets('connect → login → home → settings → logout', (tester) async {
    final container = await pumpApp(tester);

    await tester.enterText(find.byType(TextFormField), '10.0.2.2:3000');
    await tester.tap(find.text('Sprawdź'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tak, połącz'));
    await tester.pumpAndSettle();

    expect(find.text('Zaloguj się'), findsOneWidget);
    expect(vault.cookie, isNull);

    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@gihome.test',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();

    expectHome();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(vault.cookie, isNotNull);
    expect(
      container.read(applianceProfileProvider)!.lastUserEmail,
      'owner@gihome.test',
    );

    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();

    expect(find.text('Dev Owner'), findsOneWidget);
    expect(find.text('Właściciel'), findsOneWidget);
    expect(
      find.text('HTTP – połączenie nieszyfrowane w sieci lokalnej'),
      findsOneWidget,
    );
    expect(find.text('0.1.0 (1)'), findsOneWidget);

    await tester.tap(find.text('Wyloguj'));
    await tester.pumpAndSettle();

    expect(find.text('Zaloguj się'), findsOneWidget);
    expect(vault.cookie, isNull);
    expect(core.requestedRoutes, contains('POST /api/v1/auth/logout'));
  });

  testWidgets('settings open the licences page with the bundled fonts', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    await pumpApp(tester, profile: testProfile);

    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licencje open source'));
    // The licence list loads in the background; the page itself is enough.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('a stored session is restored straight into the shell', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);

    await pumpApp(tester, profile: testProfile);

    expectHome();
    // Fingerprint check before the cookie leaves the phone.
    expect(core.requestedRoutes.take(3), [
      'GET /api/v1/setup/status',
      'POST /api/v1/auth/refresh',
      'GET /api/v1/auth/me',
    ]);
    // Home reads the list and the rooms, never details of non-heating
    // devices; the profile (language, plan §13.2) is loaded alongside.
    expect(core.requestedRoutes.skip(3).toSet(), {
      'GET /api/v1/users/me/profile',
      'GET /api/v1/devices',
      'GET /api/v1/rooms',
    });
    expect(vault.cookie!.generation, 1);
  });

  testWidgets('mustChangePassword holds the user on change password', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    core.routes['GET /api/v1/auth/me'] = (_) =>
        jsonReply({...ownerUser, 'mustChangePassword': true});
    core.routes['POST /api/v1/users/me/change-password'] = (_) =>
        jsonReply({'revokedSessions': 2});

    await pumpApp(tester, profile: testProfile);
    expect(find.text('Zmień hasło'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'OldSecret1');
    await tester.enterText(fields.at(1), 'short');
    await tester.enterText(fields.at(2), 'short');
    await tester.tap(find.text('Zmień hasło i kontynuuj'));
    await tester.pumpAndSettle();
    expect(find.text('Hasło musi mieć co najmniej 8 znaków.'), findsOneWidget);
    expect(
      core.requestedRoutes,
      isNot(contains('POST /api/v1/users/me/change-password')),
    );

    await tester.enterText(fields.at(1), 'NewSecret1');
    await tester.enterText(fields.at(2), 'NewSecret1');
    await tester.tap(find.text('Zmień hasło i kontynuuj'));
    await tester.pumpAndSettle();

    final request = core.requests.lastWhere(
      (r) => r.uri.path == '/api/v1/users/me/change-password',
    );
    expect(request.data, {
      'currentPassword': 'OldSecret1',
      'newPassword': 'NewSecret1',
    });
    expectHome();
    expect(
      find.text('Hasło zostało zmienione. Wylogowano 2 inne urządzenia.'),
      findsOneWidget,
    );
  });

  testWidgets('an unreachable appliance keeps the session and offers retry', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    core.routes['GET /api/v1/setup/status'] = refuseConnection;

    await pumpApp(tester, profile: testProfile);

    expect(find.text('Nie udało się połączyć z GI Home'), findsOneWidget);
    expect(vault.cookie, storedCookie);

    core.routes.addAll(healthyApplianceRoutes());
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();

    expectHome();
  });

  group('a moved appliance (plan §9.3)', () {
    void unreachableAt(String host) {
      for (final route in [
        'GET /api/v1/health/live',
        'GET /api/v1/setup/status',
        'POST /api/v1/auth/refresh',
      ]) {
        final handler = core.routes[route]!;
        core.routes[route] = (request) => request.uri.host == host
            ? refuseConnection(request)
            : handler(request);
      }
    }

    testWidgets('is found under gi-home.local and keeps its session', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      unreachableAt('10.0.2.2');

      final container = await pumpApp(
        tester,
        profile: testProfile,
        resolver: const StaticHostResolver({'gi-home.local'}),
      );

      expectHome();
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.profileId, testProfile.profileId);
      expect(profile.baseUrl, 'http://gi-home.local');
      expect(profile.hosts, ['http://gi-home.local', 'http://10.0.2.2:3000']);
      expect(vault.cookie, isNotNull);
      expect(
        core.requests
            .where((r) => r.uri.path.endsWith('/auth/refresh'))
            .last
            .uri
            .host,
        'gi-home.local',
      );
    });

    testWidgets('another appliance under gi-home.local is never used', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      unreachableAt('10.0.2.2');
      core.routes['GET /api/v1/setup/status'] = (request) =>
          request.uri.host == '10.0.2.2'
          ? refuseConnection(request)
          : jsonReply({
              ...initializedSetup,
              'initializedAt': '2025-05-05T05:05:05.000Z',
            });

      final container = await pumpApp(
        tester,
        profile: testProfile,
        resolver: const StaticHostResolver({'gi-home.local'}),
      );

      expect(find.text('Nie udało się połączyć z GI Home'), findsOneWidget);
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.profileId, testProfile.profileId);
      expect(profile.baseUrl, testProfile.baseUrl);
      expect(vault.cookie, storedCookie);
      expect(
        core.requests.where(
          (r) =>
              r.uri.host == 'gi-home.local' &&
              r.uri.path.endsWith('/auth/refresh'),
        ),
        isEmpty,
      );
    });

    testWidgets('"Znajdź GI Home" on a failed restore lists the appliances '
        'and replaces the profile after confirming', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      unreachableAt('10.0.2.2');
      core.routes['GET /api/v1/setup/status'] = (request) =>
          switch (request.uri.host) {
            '10.0.2.2' => refuseConnection(request),
            _ => jsonReply({
              ...initializedSetup,
              'deviceName': 'Kotłownia',
              'initializedAt': '2026-03-01T08:00:00.000Z',
            }),
          };
      final container = await pumpApp(
        tester,
        profile: testProfile,
        resolver: const StaticHostResolver({'gi-home-2.local'}),
      );
      expect(find.text('Nie udało się połączyć z GI Home'), findsOneWidget);

      await tester.tap(find.text('Znajdź GI Home'));
      await tester.pumpAndSettle();
      expect(find.text('Połącz z GI Home'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('connect-candidate-http://gi-home-2.local')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tak, połącz'));
      await tester.pumpAndSettle();
      // Not signed in: the session cannot be ended on the old appliance.
      expect(find.textContaining('sesja pozostanie tam aktywna'), findsOne);
      await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
      await tester.pumpAndSettle();

      final profile = container.read(applianceProfileProvider)!;
      expect(profile.profileId, isNot(testProfile.profileId));
      expect(profile.baseUrl, 'http://gi-home-2.local');
      expect(vault.cookie, isNull);
      expect(find.text('Zaloguj się'), findsWidgets);
    });
  });

  group('secure storage failures (plan §7.1)', () {
    late MockSecureStorage storage;
    final key = SecureTokenVault.keyFor(testProfile.profileId);
    const vaultTitle = 'Dane logowania są chwilowo niedostępne';
    const vaultMessage =
        'Nie można odczytać danych logowania – spróbuj ponownie.';

    setUp(() {
      storage = MockSecureStorage();
      when(() => storage.delete(key: key)).thenAnswer((_) async {});
      when(() => storage.read(key: key))
          .thenThrow(PlatformException(code: 'errSecInteractionNotAllowed'));
    });

    testWidgets('keeps the profile twice, then wipes and asks to log in', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        profile: testProfile,
        secureStorage: storage,
      );

      expect(find.text(vaultTitle), findsOneWidget);
      expect(find.text(vaultMessage), findsOneWidget);
      verifyNever(() => storage.delete(key: key));

      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pumpAndSettle();
      expect(find.text(vaultTitle), findsOneWidget);
      verifyNever(() => storage.delete(key: key));
      expect(
        VaultReadFailures(
          container.read(sharedPreferencesProvider),
          profileId: testProfile.profileId,
        ).count,
        2,
      );

      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pumpAndSettle();

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(
        find.text(
          'Nie udało się odczytać zapisanych danych logowania, więc zostały '
          'usunięte. Zaloguj się ponownie.',
        ),
        findsOneWidget,
      );
      verify(() => storage.delete(key: key)).called(greaterThan(0));
      expect(container.read(applianceProfileProvider), isNotNull);
      expect(
        core.requestedRoutes,
        isNot(contains('POST /api/v1/auth/refresh')),
      );
      final counters = container.read(diagnosticsServiceProvider).counters;
      expect(counters.vaultUnavailable, 3);
      expect(counters.sessionLost, {SessionLostReason.vaultWiped: 1});
    });

    testWidgets('the next return to the app retries by itself', (tester) async {
      final foreground = AppForeground();
      addTearDown(foreground.dispose);
      await pumpApp(
        tester,
        profile: testProfile,
        foreground: foreground,
        secureStorage: storage,
      );
      expect(find.text(vaultTitle), findsOneWidget);

      // The phone is unlocked meanwhile.
      when(() => storage.read(key: key))
          .thenAnswer((_) async => jsonEncode(storedCookie.toJson()));
      when(
        () => storage.write(
          key: key,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      foreground.update(AppLifecycleState.paused);
      await tester.pump();
      foreground.update(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expectHome();
    });
  });

  testWidgets('a stored session the server rejects leads to login with the '
      'reason', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    core.routes['POST /api/v1/auth/refresh'] = (_) =>
        jsonReply(errorEnvelope(401, 'AUTH_SESSION_REVOKED'), status: 401);

    await pumpApp(tester, profile: testProfile);

    expect(find.text('Zaloguj się'), findsOneWidget);
    expect(
      find.text(
        'Sesja wygasła lub została zakończona na innym urządzeniu '
        '(np. limit 10 zalogowanych urządzeń).',
      ),
      findsOneWidget,
    );
    expect(find.text('Nie udało się połączyć z GI Home'), findsNothing);
    expect(vault.cookie, isNull);
  });

  group('appliance fingerprint (plan §9.3)', () {
    testWidgets('a reset appliance leads to finishing the setup, not an '
        'error, and its cookie is wiped', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/setup/status'] = (_) =>
          jsonReply(uninitializedSetup);

      final container = await pumpApp(tester, profile: testProfile);

      expect(find.text('Dokończ konfigurację'), findsOneWidget);
      expect(find.text('Nie udało się połączyć z GI Home'), findsNothing);
      expect(
        core.requestedRoutes,
        isNot(contains('POST /api/v1/auth/refresh')),
      );
      expect(vault.cookie, isNull);
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.isInitialized, isFalse);
      expect(profile.label, testProfile.label);

      // Set up again: the new fingerprint is stored and the user logs in.
      core.routes['GET /api/v1/setup/status'] = (_) => jsonReply({
        ...initializedSetup,
        'initializedAt': '2026-11-18T08:00:00.000Z',
      });
      await tester.tap(find.text('Sprawdź ponownie'));
      await tester.pumpAndSettle();

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(
        container.read(applianceProfileProvider)!.initializedAt,
        DateTime.utc(2026, 11, 18, 8),
      );
    });

    testWidgets('a renamed appliance keeps the session and renames the '
        'profile', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/setup/status'] = (_) =>
          jsonReply({...initializedSetup, 'deviceName': 'Dom nad jeziorem'});

      final container = await pumpApp(tester, profile: testProfile);

      expectHome();
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.deviceName, 'Dom nad jeziorem');
      expect(profile.label, 'Dom nad jeziorem');
      expect(profile.initializedAt, testProfile.initializedAt);
      // Persisted, not only in memory.
      expect(
        container.read(applianceProfileStoreProvider).read()!.label,
        'Dom nad jeziorem',
      );
    });
  });

  testWidgets('changing the appliance while unreachable asks first', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    core.routes['GET /api/v1/setup/status'] = refuseConnection;
    final container = await pumpApp(tester, profile: testProfile);
    expect(find.text('Nie udało się połączyć z GI Home'), findsOneWidget);

    await tester.tap(find.text('Zmień urządzenie'));
    await tester.pumpAndSettle();
    expect(find.text('Zmienić urządzenie?'), findsOneWidget);
    expect(find.textContaining('sesja pozostanie tam aktywna'), findsOneWidget);
    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(container.read(applianceProfileProvider), isNotNull);
    expect(vault.cookie, storedCookie);

    await tester.tap(find.text('Zmień urządzenie'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
    await tester.pumpAndSettle();

    expect(find.text('Połącz z GI Home'), findsOneWidget);
    expect(container.read(applianceProfileProvider), isNull);
    expect(vault.cookie, isNull);
  });

  testWidgets('a cold start in the background refreshes only once in the '
      'foreground', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    final foreground = AppForeground(initiallyForeground: false);
    addTearDown(foreground.dispose);

    await pumpApp(tester, profile: testProfile, foreground: foreground);
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Łączenie z GI Home…'), findsOneWidget);
    expect(core.requestedRoutes, isNot(contains('POST /api/v1/auth/refresh')));

    foreground.update(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(core.requestedRoutes, contains('POST /api/v1/auth/refresh'));
    expectHome();
  });

  testWidgets('returning to the app reloads the user', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    final foreground = AppForeground();
    addTearDown(foreground.dispose);
    await pumpApp(tester, profile: testProfile, foreground: foreground);
    expectHome();

    // Meanwhile an admin required a password change.
    core.routes['GET /api/v1/auth/me'] = (_) =>
        jsonReply({...ownerUser, 'mustChangePassword': true});
    foreground.update(AppLifecycleState.paused);
    await tester.pump();
    foreground.update(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(
      core.requestedRoutes.where((r) => r == 'GET /api/v1/auth/me'),
      hasLength(2),
    );
    expect(find.text('Zmień hasło'), findsOneWidget);
  });

  testWidgets('the device list is polled only while Home is visible', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    await pumpApp(tester, profile: testProfile);
    int listRequests() =>
        core.requestedRoutes.where((r) => r == 'GET /api/v1/devices').length;
    expect(listRequests(), 1);

    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(listRequests(), 2);

    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 2));
    await tester.pumpAndSettle();
    expect(listRequests(), 2);

    await tester.tap(find.text('Dom'));
    await tester.pumpAndSettle();
    expect(listRequests(), 3);
    expectHome();
  });

  testWidgets('Home asks for heating details only, at most 3 at a time', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    // The recorded list with its boiler controller wired up for heating,
    // plus four more heating controllers; the sensor and the lamp stay
    // non-heating.
    const boilerId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';
    final recorded = fixtureObject('DevicesController_list/seeded.json');
    final items = (recorded['items']! as List).cast<Map<String, dynamic>>();
    final boiler = items.firstWhere((d) => d['id'] == boilerId);
    final heatingIds = [boilerId, for (var i = 1; i <= 4; i++) 'heat-$i'];
    final nonHeatingIds = [
      for (final item in items)
        if (item['id'] != boilerId) item['id']! as String,
    ];
    core.routes['GET /api/v1/devices'] = (_) => jsonReply({
      ...recorded,
      'items': [
        for (final item in items)
          if (item['id'] != boilerId) item,
        for (final id in heatingIds)
          {
            ...boiler,
            'id': id,
            'name': id == boilerId ? boiler['name'] : 'Kocioł $id',
            'heatingRelayEntityId': 'ent-relay-boiler',
            'pumpRelayEntityId': 'ent-relay-pump',
            'controlTemperatureEntityId': 'ent-supply',
          },
      ],
    });
    var inFlight = 0;
    var maxInFlight = 0;
    var gate = Completer<void>();
    for (final id in heatingIds) {
      core.routes['GET /api/v1/devices/$id'] = (_) async {
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        try {
          await gate.future;
          return jsonReply({...entityRichDetailJson(), 'id': id});
        } finally {
          inFlight--;
        }
      };
    }
    int detailRequests(String id) => core.requestedRoutes
        .where((r) => r == 'GET /api/v1/devices/$id')
        .length;

    // Tall enough for every heating card to be on screen.
    await pumpApp(
      tester,
      profile: testProfile,
      physicalSize: const Size(1200, 9000),
    );

    // Five heating cards: three requests out, two waiting for a slot.
    expect(inFlight, 3);
    gate.complete();
    await tester.pumpAndSettle();

    expect(maxInFlight, 3);
    for (final id in heatingIds) {
      expect(detailRequests(id), 1, reason: id);
    }
    for (final id in nonHeatingIds) {
      expect(detailRequests(id), 0, reason: id);
    }
    expect(find.text('Grzeje'), findsWidgets);

    // The 15 s cadence; non-heating devices are still never asked for.
    gate = Completer<void>()..complete();
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    for (final id in heatingIds) {
      expect(detailRequests(id), 2, reason: id);
    }
    for (final id in nonHeatingIds) {
      expect(detailRequests(id), 0, reason: id);
    }
    expect(maxInFlight, 3);

    // Another tab covers Home: no more card requests.
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    for (final id in heatingIds) {
      expect(detailRequests(id), 2, reason: id);
    }
  });

  testWidgets('a device tile opens its details under Home and back', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    await pumpApp(tester, profile: testProfile);

    await tester.tap(find.byKey(const ValueKey('device-$seededDeviceId')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Czujnik bez pokoju'), findsOneWidget);
    expect(
      find.text('To urządzenie nie ma jeszcze elementów.'),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      core.requestedRoutes,
      contains('GET /api/v1/devices/$seededDeviceId'),
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expectHome();
  });

  testWidgets('changing the appliance forgets the profile after confirming', (
    tester,
  ) async {
    vault = InMemoryTokenVault(storedCookie);
    final container = await pumpApp(tester, profile: testProfile);

    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zmień urządzenie'));
    await tester.pumpAndSettle();

    expect(find.text('Zmienić urządzenie?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
    await tester.pumpAndSettle();

    expect(find.text('Połącz z GI Home'), findsOneWidget);
    expect(container.read(applianceProfileProvider), isNull);
    expect(vault.cookie, isNull);
    expect(core.requestedRoutes, contains('POST /api/v1/auth/logout'));
  });
  group('diagnostics', () {
    testWidgets('going to the background writes pending diagnostics now', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      final foreground = AppForeground();
      addTearDown(foreground.dispose);
      final store = MemoryDiagnosticsStore();
      final diagnostics = DiagnosticsService(store: store);
      addTearDown(diagnostics.dispose);
      await pumpApp(
        tester,
        profile: testProfile,
        foreground: foreground,
        diagnostics: diagnostics,
      );
      final saves = store.saves;

      diagnostics.recordError(ErrorKind.zone, 'just before');
      foreground.value = false;
      await tester.pump();

      expect(store.saves, saves + 1, reason: 'not after the write delay');
      expect('${store.errors}', contains('just before'));
    });

    testWidgets('a forced logout is counted by its reason', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['POST /api/v1/auth/refresh'] = (_) => jsonReply(
        errorEnvelope(401, 'AUTH_REFRESH_TOKEN_REUSED'),
        status: 401,
      );

      final container = await pumpApp(tester, profile: testProfile);

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(container.read(diagnosticsServiceProvider).counters.sessionLost, {
        SessionLostReason.refreshTokenReused: 1,
      });
    });

    testWidgets('a malformed response is counted per endpoint', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/devices'] = (_) => jsonReply({'items': 'x'});

      final container = await pumpApp(tester, profile: testProfile);

      final counters = container.read(diagnosticsServiceProvider).counters;
      expect(counters.unexpectedShape[GiEndpoints.devicesList.id], 1);
      expect(counters.sessionLost, isEmpty);
    });

    testWidgets('the cold start is measured up to the Home condition', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      final coldStart = Stopwatch()..start();
      bool? measuringWhenListArrived;
      core.routes['GET /api/v1/devices'] = (_) async {
        // A slow Pi: the first list arrives long after the restore.
        if (measuringWhenListArrived == null) {
          await Future<void>.delayed(const Duration(seconds: 3));
          measuringWhenListArrived = coldStart.isRunning;
        }
        return jsonReply(fixtureJson('DevicesController_list/seeded.json'));
      };

      final container = await pumpApp(
        tester,
        profile: testProfile,
        coldStart: coldStart,
      );

      expectHome();
      expect(measuringWhenListArrived, isTrue);
      final counters = container.read(diagnosticsServiceProvider).counters;
      expect(counters.coldStarts, 1);
      expect(coldStart.isRunning, isFalse);
      expect(counters.coldStartMs.single, coldStart.elapsedMilliseconds);

      // Later visits to Home are no cold starts.
      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dom'));
      await tester.pumpAndSettle();
      expect(counters.coldStarts, 1);
    });

    testWidgets('a start that ends on the login screen is no sample', (
      tester,
    ) async {
      final coldStart = Stopwatch()..start();

      final container = await pumpApp(
        tester,
        profile: testProfile,
        coldStart: coldStart,
      );

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(coldStart.isRunning, isFalse);
      expect(container.read(diagnosticsServiceProvider).counters.coldStarts, 0);
    });

    testWidgets('changing the appliance clears the diagnostics', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/setup/status'] = refuseConnection;
      final container = await pumpApp(tester, profile: testProfile);
      final diagnostics = container.read(diagnosticsServiceProvider)
        ..recordError(ErrorKind.zone, 'before change');
      final reports = leaveSharedReport();

      await tester.tap(find.text('Zmień urządzenie'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Zmień urządzenie'));
      await tester.pumpAndSettle();

      expect(find.text('Połącz z GI Home'), findsOneWidget);
      expect(diagnostics.errors, isEmpty);
      for (final folder in reports) {
        expect(folder.existsSync(), isFalse, reason: folder.path);
      }
    });

    testWidgets('a denied local network is counted and explained', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/setup/status'] = (request) =>
          throw DioException.connectionError(
            requestOptions: request,
            reason: 'denied',
            error: const SocketException(
              'Connection failed',
              osError: OSError('Operation not permitted', 1),
            ),
          );

      final container = await pumpApp(tester, profile: testProfile);

      expect(
        find.text(
          'GI Home nie ma dostępu do sieci lokalnej. Zezwól na dostęp w '
          'Ustawieniach telefonu.',
        ),
        findsOneWidget,
      );
      expect(
        container.read(diagnosticsServiceProvider).counters.localNetworkDenied,
        1,
      );
      expect(vault.cookie, storedCookie);

      await tester.tap(find.text('Otwórz ustawienia'));
      await tester.pumpAndSettle();
      expect(settings.opened, 1);
    });

    testWidgets('the request log is kept without password or cookie', (
      tester,
    ) async {
      const password = 'Secret-Pa55word';
      final container = await pumpApp(tester, profile: testProfile);
      expect(find.text('Zaloguj się'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'owner@gihome.test',
      );
      await tester.enterText(find.byType(TextFormField).last, password);
      await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
      await tester.pumpAndSettle();
      expectHome();
      // A refresh puts the cookie into a request header.
      await tester.runAsync(
        () => container
            .read(giCoreClientProvider)!
            .session
            .ensureFresh(force: true),
      );

      final diagnostics = container.read(diagnosticsServiceProvider);
      final lines = diagnostics.httpLog.map((e) => e.message).toList();
      expect(lines, contains(startsWith('-> POST /api/v1/auth/login')));
      expect(lines, contains(startsWith('<- 200 POST /api/v1/auth/login')));
      expect(lines, contains(startsWith('-> POST /api/v1/auth/refresh')));
      final text = lines.join(' | ');
      for (final secret in [
        password,
        'owner@gihome.test',
        'access-1',
        'access-2',
        '11111111-1111-4111-8111-111111111111',
        'A' * 43,
      ]) {
        expect(text, isNot(contains(secret)), reason: secret);
      }
      expect(text, contains('set-cookie: <redacted>'));
      expect(text, contains('cookie: <redacted>'));
      // Request lines are no errors.
      expect(diagnostics.errors, isEmpty);
    });

    testWidgets('logging out clears the diagnostics', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      final container = await pumpApp(tester, profile: testProfile);
      final diagnostics = container.read(diagnosticsServiceProvider)
        ..recordError(ErrorKind.zone, 'before logout')
        ..recordSessionLost(SessionLostReason.sessionRevoked);
      final reports = leaveSharedReport();

      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wyloguj'));
      await tester.pumpAndSettle();

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(diagnostics.errors, isEmpty);
      expect(diagnostics.counters.sessionLost, isEmpty);
      for (final folder in reports) {
        expect(folder.existsSync(), isFalse, reason: folder.path);
      }
    });
  });

  group('accessibility of the M1 screens (plan §12.9, §17.2)', () {
    testWidgets('session restore while connecting', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      final foreground = AppForeground(initiallyForeground: false);
      addTearDown(foreground.dispose);
      await pumpApp(tester, profile: testProfile, foreground: foreground);
      expect(find.text('Łączenie z GI Home…'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);

      foreground.update(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    });

    testWidgets('session restore after a failure', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/setup/status'] = refuseConnection;
      await pumpApp(tester, profile: testProfile);
      expect(find.text('Nie udało się połączyć z GI Home'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('change password required at sign-in', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      core.routes['GET /api/v1/auth/me'] = (_) =>
          jsonReply({...ownerUser, 'mustChangePassword': true});
      await pumpApp(tester, profile: testProfile);
      expect(find.text('Zmień hasło'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('Home in the shell, and Settings', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      await pumpApp(tester, profile: testProfile);
      expectHome();
      await expectAccessibilityGuidelines(tester);

      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();
      expect(find.text('Dev Owner'), findsOneWidget);
      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('the update banner over Home', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      final diagnostics = DiagnosticsService();
      await pumpApp(tester, profile: testProfile, diagnostics: diagnostics);
      for (var i = 0; i < 3; i++) {
        diagnostics.recordFailure(
          const ApiFailure.unexpectedShape(endpointId: 'DevicesController_get'),
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('Zaktualizuj aplikację'), findsOneWidget);
      // Non-blocking: Home stays below the banner.
      expect(find.text('Kotłownia'), findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });
  });
}
