import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/account/application/account_controllers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:material_ui/material_ui.dart';

import '../support/account_fixtures.dart';
import '../support/fake_core_adapter.dart';
import '../support/fixtures.dart';
import '../support/test_app.dart';

/// Account flows (plan §4.2, §13.2, §20 M3.5) through the real providers,
/// session manager and router, with GI Core replaced by [FakeCoreAdapter].
void main() {
  late FakeCoreAdapter core;
  late InMemoryTokenVault vault;
  late Directory reportRoot;
  late String? profileLocale;
  late List<Map<String, Object?>> sessions;

  final storedCookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'B' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17),
    absoluteExpiry: DateTime.utc(2099),
  );

  Map<String, Object?> profile() => {
    ...ownerUser,
    'enabled': true,
    'locale': profileLocale,
    'lastLoginAt': null,
    'createdAt': '2026-11-17T22:06:20.174Z',
    'updatedAt': '2026-11-17T22:06:20.174Z',
  };

  Object? bodyOf(RequestOptions request) => switch (request.data) {
    final String text => jsonDecode(text),
    final Object? other => other,
  };

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(profile: testProfile),
    );
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
          reportDirectoryProvider.overrideWithValue(() async => reportRoot),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(GiHomeApp)));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> logIn(
    WidgetTester tester, {
    String password = 'Secret123',
  }) async {
    await tester.enterText(
      find.byType(TextFormField).first,
      'owner@gihome.test',
    );
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();
  }

  Future<void> openAccount(WidgetTester tester) async {
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('settings-account')));
  }

  setUp(() {
    reportRoot = Directory.systemTemp.createTempSync('gi-account-flow-');
    addTearDown(() => reportRoot.deleteSync(recursive: true));
    vault = InMemoryTokenVault();
    profileLocale = 'pl-PL';
    sessions = [for (final s in testSessions) s.toJson()];
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
      'GET /api/v1/users/me/profile': (_) => jsonReply(profile()),
      'PATCH /api/v1/users/me/profile': (request) {
        final body = bodyOf(request)! as Map<String, Object?>;
        profileLocale = (body['locale'] as String?) ?? profileLocale;
        return jsonReply(profile());
      },
      'GET /api/v1/auth/sessions': (_) => jsonReply(sessions),
      'POST /api/v1/auth/logout-all': (_) => jsonReply(null, status: 204),
      'POST /api/v1/auth/recovery/reset': (_) => jsonReply(null, status: 204),
      'GET /api/v1/devices': (_) =>
          jsonReply(fixtureJson('DevicesController_list/seeded.json')),
      'GET /api/v1/rooms': (_) =>
          jsonReply(fixtureJson('RoomsController_list/seeded.json')),
    });
    for (final s in testSessions) {
      core.routes['DELETE /api/v1/auth/sessions/${s.id}'] = (_) {
        sessions.removeWhere((row) => row['id'] == s.id);
        return jsonReply(null, status: 204);
      };
    }
  });

  testWidgets('after a login the other sessions are offered for review', (
    tester,
  ) async {
    await pumpApp(tester);
    await logIn(tester);

    expect(
      find.text('Na Twoim koncie są jeszcze 2 aktywne sesje.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Przejrzyj'));
    await tester.pumpAndSettle();

    expect(find.text('Ten telefon'), findsOneWidget);
  });

  testWidgets('no other session, no offer', (tester) async {
    sessions = [testSessions.first.toJson()];
    await pumpApp(tester);
    await logIn(tester);

    expect(find.textContaining('aktywn'), findsNothing);
  });

  testWidgets('revoking another session keeps this one', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    final container = await pumpApp(tester);
    await openAccount(tester);
    await tapVisible(tester, find.byKey(const ValueKey('account-sessions')));

    await tapVisible(
      tester,
      find.byKey(ValueKey('session-revoke-${testSessions[1].id}')),
    );
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(
      core.requestedRoutes,
      contains('DELETE /api/v1/auth/sessions/${testSessions[1].id}'),
    );
    expect(container.read(currentUserProvider), isNotNull);
    expect(find.text('Chrome · Windows'), findsNothing);
  });

  testWidgets('revoking this phone signs out here', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    final container = await pumpApp(tester);
    await openAccount(tester);
    await tapVisible(tester, find.byKey(const ValueKey('account-sessions')));

    await tapVisible(
      tester,
      find.byKey(ValueKey('session-revoke-${testSessions[0].id}')),
    );
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(container.read(currentUserProvider), isNull);
    expect(vault.cookie, isNull);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });

  testWidgets('logout-all signs out here as well', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    final container = await pumpApp(tester);
    await openAccount(tester);
    await tapVisible(tester, find.byKey(const ValueKey('account-sessions')));

    await tapVisible(tester, find.byKey(const ValueKey('sessions-logout-all')));
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    expect(core.requestedRoutes, contains('POST /api/v1/auth/logout-all'));
    expect(container.read(currentUserProvider), isNull);
    expect(vault.cookie, isNull);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });

  testWidgets('the account language is written to the server and the app '
      'follows it (plan §13.2)', (tester) async {
    vault = InMemoryTokenVault(storedCookie);
    await pumpApp(tester);
    await openAccount(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('account-locale-en-US')),
    );

    final patch = core.requests.lastWhere((r) => r.method == 'PATCH');
    expect(bodyOf(patch), {'locale': 'en-US'});
    expect(find.text('Profile and security'), findsOneWidget);
  });

  testWidgets('a password reset with the recovery code leads to login and '
      'then to a new code', (tester) async {
    final container = await pumpApp(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('login-forgot-password')),
    );
    expect(find.text('Odzyskiwanie hasła'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('recovery-reset-email')),
      'owner@gihome.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('recovery-reset-code')),
      placeholderRecoveryCode.toLowerCase(),
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'NewSecret1');
    await tester.enterText(find.byType(TextFormField).at(3), 'NewSecret1');
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-reset-submit')),
    );

    final reset = core.requests.singleWhere(
      (r) => r.uri.path == '/api/v1/auth/recovery/reset',
    );
    expect(bodyOf(reset), {
      'email': 'owner@gihome.test',
      'recoveryCode': placeholderRecoveryCode,
      'newPassword': 'NewSecret1',
    });
    expect(container.read(accountPromptsProvider).rotateRecoveryCode, isTrue);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-reset-login')),
    );
    await logIn(tester, password: 'NewSecret1');

    expect(find.text('Wygeneruj nowy kod odzyskiwania'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('recovery-rotate-accept')));
    await tester.pumpAndSettle();

    expect(find.text('Wygeneruj nowy kod'), findsOneWidget);
  });
}
