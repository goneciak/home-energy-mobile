import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/data/language_preference_store.dart';
import 'package:gi_home/src/features/settings/presentation/language_tile.dart';
import 'package:gi_home/src/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_core_adapter.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// Settings (plan §20 M2 item 6, §7.6, §13.2, §16) through the real
/// providers, session manager and router, with GI Core replaced by
/// [FakeCoreAdapter].
void main() {
  const updatesStatus = 'GET /api/v1/appliance/updates/status';
  const systemSettings = 'GET /api/v1/settings/system';
  const logoutRoute = 'POST /api/v1/auth/logout';
  const versionKey = ValueKey('settings-core-version');
  const timezoneKey = ValueKey('settings-timezone');
  const cleartext = 'HTTP – połączenie nieszyfrowane w sieci lokalnej';

  late FakeCoreAdapter core;
  late InMemoryTokenVault vault;
  late String role;

  Map<String, Object> user() => {...ownerUser, 'role': role};

  setUp(() {
    vault = InMemoryTokenVault();
    role = 'OWNER';
    core = FakeCoreAdapter({
      ...healthyApplianceRoutes(),
      'POST /api/v1/auth/login': (_) => jsonReply(
        {'accessToken': 'access', 'expiresIn': 900, 'user': user()},
        headers: {
          'set-cookie': [testSetCookie],
        },
      ),
      'GET /api/v1/auth/me': (_) => jsonReply(user()),
      'GET /api/v1/users/me/profile': (_) => jsonReply({
        ...user(),
        'enabled': true,
        'locale': 'pl-PL',
        'lastLoginAt': null,
        'createdAt': '2026-11-17T22:06:20.174Z',
        'updatedAt': '2026-11-17T22:06:20.174Z',
      }),
      logoutRoute: (_) => jsonReply(null, status: 204),
      'GET /api/v1/devices': (_) =>
          jsonReply(fixtureJson('DevicesController_list/seeded.json')),
      'GET /api/v1/rooms': (_) =>
          jsonReply(fixtureJson('RoomsController_list/seeded.json')),
      updatesStatus: (_) => jsonReply(
        fixtureJson(
          'ApplianceUpdateController_getStatus/checked_handwritten.json',
        ),
      ),
      systemSettings: (_) =>
          jsonReply(fixtureJson('SettingsController_getSystem/ok.json')),
    });
  });

  void tallView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(1200, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// The app, logged in as [role], on the Settings tab.
  Future<ProviderContainer> openSettings(WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tallView(tester);
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(profile: testProfile),
    );
    final reports = Directory.systemTemp.createTempSync('gi-settings-');
    addTearDown(() => reports.deleteSync(recursive: true));
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(core),
          tokenVaultProvider.overrideWith(
            (ref) => ref.watch(applianceProfileProvider) == null ? null : vault,
          ),
          reportDirectoryProvider.overrideWithValue(() async => reports),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'a@gihome.test');
    await tester.enterText(find.byType(TextFormField).last, 'Secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    return ProviderScope.containerOf(tester.element(find.byType(GiHomeApp)));
  }

  group('device information per role', () {
    for (final allowed in ['OWNER', 'ADMIN']) {
      testWidgets('$allowed sees the running version and the time zone', (
        tester,
      ) async {
        role = allowed;
        await openSettings(tester);

        expect(find.byKey(versionKey), findsOneWidget);
        expect(
          find.text('1.4.2 (według ostatniego sprawdzenia aktualizacji)'),
          findsOneWidget,
        );
        expect(find.byKey(timezoneKey), findsOneWidget);
        expect(find.text('Europe/Warsaw'), findsOneWidget);
        expect(find.text(cleartext), findsOneWidget);
      });
    }

    testWidgets('USER sees neither and causes no 403', (tester) async {
      role = 'USER';
      await openSettings(tester);

      expect(find.byKey(versionKey), findsNothing);
      expect(find.byKey(timezoneKey), findsNothing);
      expect(core.requestedRoutes, isNot(contains(updatesStatus)));
      expect(core.requestedRoutes, isNot(contains(systemSettings)));
      // The rest of the screen is there.
      expect(find.text('Domownik'), findsOneWidget);
      expect(find.text(cleartext), findsOneWidget);
    });

    testWidgets('SERVICE sees the time zone but no update status', (
      tester,
    ) async {
      role = 'SERVICE';
      await openSettings(tester);

      expect(find.byKey(versionKey), findsNothing);
      expect(find.byKey(timezoneKey), findsOneWidget);
      expect(core.requestedRoutes, isNot(contains(updatesStatus)));
    });

    testWidgets('an unconfigured appliance shows no version', (tester) async {
      core.routes[updatesStatus] = (_) => jsonReply(
        fixtureJson(
          'ApplianceUpdateController_getStatus/unconfigured_handwritten.json',
        ),
      );
      await openSettings(tester);

      expect(core.requestedRoutes, contains(updatesStatus));
      expect(find.byKey(versionKey), findsNothing);
      expect(find.byKey(timezoneKey), findsOneWidget);
    });

    for (final (name, reply) in <(String, FakeHandler)>[
      (
        '403',
        (request) => jsonReply(
          errorEnvelope(403, 'HTTP_403', path: request.uri.path),
          status: 403,
        ),
      ),
      ('offline', refuseConnection),
    ]) {
      testWidgets('a failed read ($name) only hides the rows', (tester) async {
        core.routes[updatesStatus] = reply;
        core.routes[systemSettings] = reply;
        await openSettings(tester);
        // Let the read retries (and their back-off) run out.
        await tester.pump(const Duration(minutes: 1));
        await tester.pumpAndSettle();

        expect(find.byKey(versionKey), findsNothing);
        expect(find.byKey(timezoneKey), findsNothing);
        expect(find.text('Dev Owner'), findsOneWidget);
        expect(find.text('Wyloguj'), findsOneWidget);
      });
    }
  });

  group('logout', () {
    testWidgets('ends the session on GI Core and returns to login', (
      tester,
    ) async {
      final container = await openSettings(tester);

      await tester.tap(find.text('Wyloguj'));
      await tester.pumpAndSettle();

      expect(core.requestedRoutes, contains(logoutRoute));
      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(find.textContaining('Wylogowano z telefonu'), findsNothing);
      expect(vault.cookie, isNull);
      expect(container.read(currentUserProvider), isNull);
    });

    testWidgets('offline, it still clears the phone and returns to login', (
      tester,
    ) async {
      core.routes[logoutRoute] = refuseConnection;
      final container = await openSettings(tester);

      await tester.tap(find.text('Wyloguj'));
      await tester.pumpAndSettle();

      expect(core.requestedRoutes, contains(logoutRoute));
      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(find.textContaining('Wylogowano z telefonu'), findsOneWidget);
      expect(vault.cookie, isNull);
      expect(container.read(currentUserProvider), isNull);
    });
  });

  group('language', () {
    Future<void> pick(WidgetTester tester, String? code) async {
      await tester.tap(find.byKey(LanguageTile.tileKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(LanguageTile.optionKey(code)));
      await tester.pumpAndSettle();
    }

    testWidgets('English rebuilds the app at once and is remembered', (
      tester,
    ) async {
      final container = await openSettings(tester);
      expect(find.text('Automatycznie'), findsOneWidget);

      await pick(tester, 'en');

      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(container.read(appLocaleProvider), const Locale('en'));
      expect(
        container
            .read(sharedPreferencesProvider)
            .getString(LanguagePreferenceStore.key),
        'en',
      );

      // The pick is a phone preference: it outlives logout.
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(appLocaleProvider), const Locale('en'));
    });

    testWidgets('Automatycznie returns to the profile language', (
      tester,
    ) async {
      final container = await openSettings(tester);
      await pick(tester, 'en');
      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

      await pick(tester, null);

      expect(find.widgetWithText(AppBar, 'Ustawienia'), findsOneWidget);
      expect(container.read(languagePreferenceProvider), isNull);
      expect(container.read(appLocaleProvider), const Locale('pl'));
      expect(
        container
            .read(sharedPreferencesProvider)
            .containsKey(LanguagePreferenceStore.key),
        isFalse,
      );
    });
  });

  group('session expiry (plan §7.6)', () {
    final end = DateTime.utc(2026, 12, 20, 12);

    Future<void> pumpAt(WidgetTester tester, DateTime now) async {
      tallView(tester);
      final prefs = await tester.runAsync(inMemoryPreferences);
      await tester.pumpWidget(
        testScreen(
          const SettingsScreen(),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs!),
            appInfoProvider.overrideWithValue(testAppInfo),
            currentUserProvider.overrideWithValue(
              CurrentUser.fromJson(ownerUser),
            ),
            sessionExpiresAtProvider.overrideWithValue(end),
            clockProvider.overrideWithValue(() => now),
            applianceRunningVersionProvider.overrideWith((ref) async => null),
            systemSettingsProvider.overrideWith((ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('long before the end only the date is shown', (tester) async {
      await pumpAt(tester, end.subtract(const Duration(days: 10)));

      expect(
        find.byKey(const ValueKey('settings-session-expiry')),
        findsOneWidget,
      );
      expect(find.textContaining('Sesja ważna do'), findsOneWidget);
      expect(find.textContaining('zalogować się ponownie'), findsNothing);
    });

    for (final (days, text) in [
      (3, 'Za 3 dni trzeba będzie zalogować się ponownie'),
      (1, 'Za 1 dzień trzeba będzie zalogować się ponownie'),
    ]) {
      testWidgets('$days days before the end it warns', (tester) async {
        await pumpAt(tester, end.subtract(Duration(days: days)));

        expect(find.text(text), findsOneWidget);
      });
    }
  });
}
