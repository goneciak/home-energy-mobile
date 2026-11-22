import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/application/account_providers.dart';
import 'package:gi_home/src/features/account/data/session_locale_store.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/data/secure_token_vault.dart';
import 'package:gi_home/src/features/devices/data/device_snapshot_store.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/data/diagnostics_store.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_core_adapter.dart';
import '../support/fixtures.dart';
import '../support/test_app.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

/// Session and account (plan §7.1 D3, §7.8, §8.3, §13.2) through the real
/// providers, session manager and router, with GI Core replaced by
/// [FakeCoreAdapter].
void main() {
  late FakeCoreAdapter core;
  late InMemoryTokenVault vault;
  late Directory reportRoot;

  const regularUser = <String, Object>{
    'id': 'cmwl8s1se000780n2user0002',
    'email': 'user@gihome.test',
    'firstName': 'Jan',
    'lastName': 'Domownik',
    'role': 'USER',
    'mustChangePassword': false,
  };
  final ownerId = ownerUser['id']! as String;
  final storedCookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'B' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17),
    absoluteExpiry: DateTime.utc(2099),
  );

  /// Profile languages by user id; a missing entry means `locale: null`.
  late Map<String, String> profileLocales;

  String? bearer(RequestOptions request) =>
      request.headers['authorization'] as String?;

  Map<String, Object> userFor(RequestOptions request) =>
      bearer(request) == 'Bearer access-user' ? regularUser : ownerUser;

  Map<String, Object?> profileOf(Map<String, Object> user) => {
    ...user,
    'enabled': true,
    'locale': profileLocales[user['id']],
    'lastLoginAt': null,
    'createdAt': '2026-11-17T22:06:20.174Z',
    'updatedAt': '2026-11-17T22:06:20.174Z',
  };

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    ApplianceProfile? profile,
    FlutterSecureStorage? secureStorage,
    DiagnosticsService? diagnostics,
    AppForeground? foreground,
    Future<void> Function(SharedPreferencesWithCache prefs)? seed,
  }) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await tester.runAsync(() async {
      final prefs = await inMemoryPreferences(profile: profile);
      await seed?.call(prefs);
      return prefs;
    });
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(core),
          if (secureStorage != null)
            secureStorageProvider.overrideWithValue(secureStorage)
          else
            tokenVaultProvider.overrideWith(
              (ref) =>
                  ref.watch(applianceProfileProvider) == null ? null : vault,
            ),
          if (diagnostics != null)
            diagnosticsServiceProvider.overrideWithValue(diagnostics),
          if (foreground != null)
            appForegroundProvider.overrideWithValue(foreground),
          reportDirectoryProvider.overrideWithValue(() async => reportRoot),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(GiHomeApp)));
  }

  String emailFieldText(WidgetTester tester) => tester
      .widget<TextFormField>(find.byType(TextFormField).first)
      .controller!
      .text;

  Future<void> logIn(
    WidgetTester tester,
    String email, {
    String submit = 'Zaloguj',
  }) async {
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, 'Secret123');
    await tester.tap(find.widgetWithText(FilledButton, submit));
    await tester.pumpAndSettle();
  }

  setUp(() {
    reportRoot = Directory.systemTemp.createTempSync('gi-account-');
    addTearDown(() => reportRoot.deleteSync(recursive: true));
    vault = InMemoryTokenVault();
    profileLocales = {};
    core = FakeCoreAdapter({
      ...healthyApplianceRoutes(),
      'POST /api/v1/auth/login': (request) {
        final email = (request.data as Map)['email'];
        final isUser = email == regularUser['email'];
        return jsonReply(
          {
            'accessToken': isUser ? 'access-user' : 'access-owner',
            'expiresIn': 900,
            'user': isUser ? regularUser : ownerUser,
          },
          headers: {
            'set-cookie': [testSetCookie],
          },
        );
      },
      'POST /api/v1/auth/refresh': (_) => jsonReply(
        {'accessToken': 'access-owner', 'expiresIn': 900},
        headers: {
          'set-cookie': [testSetCookie],
        },
      ),
      'GET /api/v1/auth/me': (request) => jsonReply(userFor(request)),
      'GET /api/v1/users/me/profile': (request) =>
          jsonReply(profileOf(userFor(request))),
      'POST /api/v1/auth/logout': (_) => jsonReply(null, status: 204),
      'GET /api/v1/devices': (_) =>
          jsonReply(fixtureJson('DevicesController_list/seeded.json')),
      'GET /api/v1/rooms': (_) =>
          jsonReply(fixtureJson('RoomsController_list/seeded.json')),
    });
  });

  group('persisted access token (D3)', () {
    testWidgets('a cold start with a valid token makes no refresh request', (
      tester,
    ) async {
      vault = InMemoryTokenVault(
        storedCookie,
        PersistedAccessToken(
          token: 'access-stored',
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
        ),
      );

      await pumpApp(tester, profile: testProfile);

      expect(find.text('Kotłownia'), findsOneWidget);
      expect(
        core.requestedRoutes.where((r) => r == 'POST /api/v1/auth/refresh'),
        isEmpty,
      );
      final me = core.requests.firstWhere(
        (r) => r.uri.path == '/api/v1/auth/me',
      );
      expect(bearer(me), 'Bearer access-stored');
      expect(vault.cookie, storedCookie);
    });

    testWidgets('an expired token is refreshed on a cold start', (
      tester,
    ) async {
      vault = InMemoryTokenVault(
        storedCookie,
        PersistedAccessToken(
          token: 'access-stored',
          expiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );

      await pumpApp(tester, profile: testProfile);

      expect(
        core.requestedRoutes.where((r) => r == 'POST /api/v1/auth/refresh'),
        hasLength(1),
      );
      expect(vault.accessToken!.token, 'access-owner');
    });
  });

  group('"Zmień użytkownika" (plan §7.8)', () {
    testWidgets('OWNER → USER: empty email, nothing of the owner left', (
      tester,
    ) async {
      // The owner reads the app in English; the user's profile names no
      // language, so their session must not inherit it.
      profileLocales = {ownerId: 'en-US'};
      final container = await pumpApp(tester, profile: testProfile);
      await logIn(tester, 'owner@gihome.test');

      expect(find.text('Home'), findsWidgets);
      expect(container.read(applianceProfileProvider)!.lastUserId, ownerId);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Dev Owner'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('settings-switch-user')));
      await tester.pumpAndSettle();
      expect(find.text('Switch user?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('owner@gihome.test'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('switch-user-confirm')));
      await tester.pumpAndSettle();

      // Login, in the phone language, with an EMPTY email field.
      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(emailFieldText(tester), isEmpty);
      expect(core.requestedRoutes, contains('POST /api/v1/auth/logout'));
      final profile = container.read(applianceProfileProvider)!;
      expect(profile.lastUserEmail, isNull);
      expect(profile.lastUserId, isNull);
      expect(vault.cookie, isNull);
      expect(vault.accessToken, isNull);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(userProfileProvider).value, isNull);

      final ownerRequests = core.requests.length;
      await logIn(tester, 'user@gihome.test');

      // Back where the owner left: Settings, now in the phone language.
      expect(find.text('Ustawienia'), findsWidgets);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Domownik'), findsOneWidget);

      // Home is loaded again, for the user and with their token; no request
      // after the switch carries the owner's token.
      await tester.tap(find.text('Dom'));
      await tester.pumpAndSettle();
      expect(find.text('Kotłownia'), findsOneWidget);
      final userReads = core.requests.skip(ownerRequests).toList();
      for (final path in ['/api/v1/devices', '/api/v1/rooms']) {
        final read = userReads.lastWhere((r) => r.uri.path == path);
        expect(bearer(read), 'Bearer access-user', reason: path);
      }
      expect(
        userReads.where((r) => bearer(r) == 'Bearer access-owner'),
        isEmpty,
      );
      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();

      // The role-derived parts are recomputed for the user.
      expect(find.text('Jan Domownik'), findsOneWidget);
      expect(find.text('user@gihome.test'), findsOneWidget);
      expect(find.text('Domownik'), findsOneWidget);
      for (final ownerOnly in [
        'Dev Owner',
        'owner@gihome.test',
        'Właściciel',
        'Owner',
      ]) {
        expect(find.textContaining(ownerOnly), findsNothing, reason: ownerOnly);
      }
      expect(container.read(currentUserProvider)!.role, UserRole.user);
      expect(
        container.read(applianceProfileProvider)!.lastUserId,
        regularUser['id'],
      );
      expect(container.read(appLocaleProvider), isNull);
    });

    testWidgets('a plain logout keeps the email for the next login', (
      tester,
    ) async {
      final container = await pumpApp(tester, profile: testProfile);
      await logIn(tester, 'owner@gihome.test');
      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Wyloguj'));
      await tester.pumpAndSettle();

      expect(emailFieldText(tester), 'owner@gihome.test');
      expect(
        container.read(applianceProfileProvider)!.lastUserEmail,
        'owner@gihome.test',
      );
    });

    testWidgets('cancelling the confirmation keeps the session', (
      tester,
    ) async {
      await pumpApp(tester, profile: testProfile);
      await logIn(tester, 'owner@gihome.test');
      await tester.tap(find.text('Ustawienia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('settings-switch-user')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();

      expect(find.text('Dev Owner'), findsOneWidget);
      expect(core.requestedRoutes, isNot(contains('POST /api/v1/auth/logout')));
      expect(vault.cookie, isNotNull);
    });
  });

  group('profile language (plan §13.2)', () {
    testWidgets('an English profile switches the UI to English after login', (
      tester,
    ) async {
      profileLocales = {ownerId: 'en-US'};
      final container = await pumpApp(tester, profile: testProfile);
      expect(find.text('Zaloguj się'), findsOneWidget);

      await logIn(tester, 'owner@gihome.test');

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Dom'), findsNothing);
      expect(container.read(appLocaleProvider), const Locale('en'));
      expect(
        SessionLocaleStore(container.read(sharedPreferencesProvider))
            .read(profileId: testProfile.profileId, userId: ownerId),
        'en',
      );
    });

    testWidgets('requests ask GI Core for the language the app shows, '
        'not the phone language', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('pl');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      profileLocales = {ownerId: 'en-US'};
      final container = await pumpApp(tester, profile: testProfile);

      Future<void> meThroughClient() async {
        final me = container.read(giCoreClientProvider)!.me();
        await tester.pumpAndSettle();
        await me;
      }

      String? languageOf(String route) =>
          core.requests
                  .lastWhere((r) => '${r.method} ${r.uri.path}' == route)
                  .headers['accept-language']
              as String?;

      await logIn(tester, 'owner@gihome.test');
      expect(languageOf('POST /api/v1/auth/login'), 'pl');

      await meThroughClient();
      expect(languageOf('GET /api/v1/auth/me'), 'en');

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await logIn(tester, 'user@gihome.test');
      await meThroughClient();

      // A user without a profile language: the phone language again.
      expect(languageOf('GET /api/v1/auth/me'), 'pl');
    });

    testWidgets('a failed profile call keeps the phone language and does '
        'not break login', (tester) async {
      core.routes['GET /api/v1/users/me/profile'] = (_) =>
          jsonReply(errorEnvelope(500, 'HTTP_500'), status: 500);
      final container = await pumpApp(tester, profile: testProfile);

      await logIn(tester, 'owner@gihome.test');

      expect(find.text('Dom'), findsWidgets);
      expect(find.text('Kotłownia'), findsOneWidget);
      expect(container.read(currentUserProvider), isNotNull);
      expect(container.read(appLocaleProvider), isNull);
    });

    testWidgets('an unsupported language falls back to the phone one', (
      tester,
    ) async {
      profileLocales = {ownerId: 'de-DE'};
      await pumpApp(tester, profile: testProfile);

      await logIn(tester, 'owner@gihome.test');

      expect(find.text('Dom'), findsWidgets);
    });

    testWidgets('logout returns to the phone language', (tester) async {
      profileLocales = {ownerId: 'en-US'};
      final container = await pumpApp(tester, profile: testProfile);
      await logIn(tester, 'owner@gihome.test');
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(find.text('Zaloguj się'), findsOneWidget);
      expect(
        container
            .read(sharedPreferencesProvider)
            .containsKey(SessionLocaleStore.key),
        isFalse,
      );
    });

    testWidgets('a restored session starts in the language last applied, '
        'before the profile answers', (tester) async {
      vault = InMemoryTokenVault(storedCookie);
      final profileAnswer = Completer<void>();
      core.routes['GET /api/v1/users/me/profile'] = (_) async {
        await profileAnswer.future;
        return jsonReply(profileOf({...ownerUser}));
      };

      final container = await pumpApp(
        tester,
        profile: testProfile.copyWith(lastUserId: ownerId),
        seed: (prefs) => SessionLocaleStore(prefs).write(
          profileId: testProfile.profileId,
          userId: ownerId,
          languageCode: 'en',
        ),
      );

      expect(find.text('Home'), findsWidgets);

      // The profile now names Polish: it wins and is remembered.
      profileLocales = {ownerId: 'pl-PL'};
      profileAnswer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Dom'), findsWidgets);
      expect(
        SessionLocaleStore(container.read(sharedPreferencesProvider))
            .read(profileId: testProfile.profileId, userId: ownerId),
        'pl',
      );
    });

    testWidgets('another user never gets the language stored for the last '
        'one', (tester) async {
      await pumpApp(
        tester,
        profile: testProfile,
        seed: (prefs) => SessionLocaleStore(prefs).write(
          profileId: testProfile.profileId,
          userId: ownerId,
          languageCode: 'en',
        ),
      );

      expect(find.text('Zaloguj się'), findsOneWidget);
      await logIn(tester, 'user@gihome.test');

      expect(find.text('Dom'), findsWidgets);
    });

    testWidgets('returning to the app reloads the profile and its language', (
      tester,
    ) async {
      vault = InMemoryTokenVault(storedCookie);
      final foreground = AppForeground();
      addTearDown(foreground.dispose);
      await pumpApp(tester, profile: testProfile, foreground: foreground);
      expect(find.text('Dom'), findsWidgets);

      profileLocales = {ownerId: 'en-US'};
      foreground.update(AppLifecycleState.paused);
      await tester.pump();
      foreground.update(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      for (final path in [
        'GET /api/v1/auth/me',
        'GET /api/v1/users/me/profile',
      ]) {
        expect(
          core.requestedRoutes.where((r) => r == path),
          hasLength(2),
          reason: path,
        );
      }
      expect(find.text('Home'), findsWidgets);
    });
  });

  group('logout and user switch wipe the session from all three stores '
      '(plan §8.3)', () {
    late Map<String, String> secrets;
    late MockSecureStorage storage;
    late Directory support;
    late FileDiagnosticsStore files;
    late DiagnosticsService diagnostics;
    final profilePrefix = 'p/${testProfile.profileId}/';

    setUp(() {
      secrets = {};
      storage = MockSecureStorage();
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (invocation) async => secrets[invocation.namedArguments[#key]],
      );
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        final value = invocation.namedArguments[#value] as String?;
        if (value == null) {
          secrets.remove(key);
        } else {
          secrets[key] = value;
        }
      });
      when(() => storage.delete(key: any(named: 'key'))).thenAnswer(
        (invocation) async => secrets.remove(invocation.namedArguments[#key]),
      );
      when(storage.readAll).thenAnswer((_) async => {...secrets});
      support = Directory.systemTemp.createTempSync('gi-support-');
      addTearDown(() => support.deleteSync(recursive: true));
      files = FileDiagnosticsStore(support);
      diagnostics = DiagnosticsService(store: files);
      addTearDown(diagnostics.dispose);
    });

    for (final (name, action) in [
      ('logout', 'Wyloguj'),
      ('user switch', 'Zmień użytkownika'),
    ]) {
      testWidgets(name, (tester) async {
        profileLocales = {ownerId: 'pl-PL'};
        final container = await pumpApp(
          tester,
          profile: testProfile,
          secureStorage: storage,
          diagnostics: diagnostics,
        );
        await logIn(tester, 'owner@gihome.test');
        diagnostics.recordError(ErrorKind.zone, 'before $name');
        await tester.runAsync(diagnostics.flush);
        final prefs = container.read(sharedPreferencesProvider);

        // Everything a session leaves behind is there, the device list
        // snapshot included.
        expect(secrets.keys, {
          SecureTokenVault.keyFor(testProfile.profileId),
          SecureTokenVault.accessTokenKeyFor(testProfile.profileId),
          SecureDeviceSnapshotStore.keyFor(testProfile.profileId, ownerId),
        });
        expect(prefs.containsKey(SessionLocaleStore.key), isTrue);
        expect(files.errorsFile.existsSync(), isTrue);

        await tester.tap(find.text('Ustawienia'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        if (action == 'Zmień użytkownika') {
          await tester.tap(find.byKey(const ValueKey('switch-user-confirm')));
          await tester.pumpAndSettle();
        }
        // Let the file deletion finish outside the fake clock.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Zaloguj się'), findsOneWidget);
        expect(
          secrets.keys.where((key) => key.startsWith(profilePrefix)),
          isEmpty,
        );
        expect(prefs.containsKey(SessionLocaleStore.key), isFalse);
        expect(files.directory.existsSync(), isFalse);
        expect(diagnostics.errors, isEmpty);
      });
    }
  });
}
