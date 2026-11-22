import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// M3 account flows end to end against the real GI Core of a contract stack
/// (plan §13.2, §20 M3.5), as the seeded owner:
///
/// 1. the profile language: English, then back to Polish;
/// 2. sessions: a second session (signed in by this test over HTTP) is
///    revoked from the list;
/// 3. a new recovery code is generated and shown;
/// 4. the password is changed to a temporary one;
/// 5. after logging out, "Forgot password" resets it with that recovery
///    code back to the original, and the owner logs in again.
///
/// So the owner ends with the original password and locale. A run that
/// fails between steps 4 and 5 leaves the temporary password
/// (`<password>-E2e1`); re-seed the throwaway stack then.
///
/// Run like `schedule_flow_test.dart` (contract stack, owner credentials
/// from `tools/backend/dev.env`). Three logins (GI Core allows 5 per
/// minute) and one recovery reset (5 per 15 minutes). The recovery code is
/// read from the screen and never printed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('GI_DEV_EMAIL');
  const password = String.fromEnvironment('GI_DEV_PASSWORD');
  const address = String.fromEnvironment(
    'GI_CORE_ADDRESS',
    defaultValue: '10.0.2.2:3000',
  );
  const temporary = '$password-E2e1';

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    bool gone = false,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty != gone) {
      if (DateTime.now().isAfter(deadline)) {
        // The recovery code is a secret: only report what a failure needs.
        final visible = find
            .byType(Text)
            .evaluate()
            .where((e) => e.widget.key != const ValueKey('recovery-code-value'))
            .map((e) => (e.widget as Text).data)
            .nonNulls
            .join(' | ');
        fail('Timed out after $timeout waiting for $finder. Visible: $visible');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Text in either app language: the UI follows the profile language, which
  /// this test changes.
  Finder anyLanguageText(String Function(AppLocalizations l10n) pick) {
    final texts = {
      for (final code in const ['pl', 'en'])
        pick(lookupAppLocalizations(Locale(code))),
    };
    return find.byWidgetPredicate(
      (widget) => widget is Text && texts.contains(widget.data),
    );
  }

  Finder textIn(String code, String Function(AppLocalizations l10n) pick) =>
      find.text(pick(lookupAppLocalizations(Locale(code))));

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await waitFor(tester, finder);
    // A post-login snack bar (the sessions review offer) may cover the
    // target; it is only an offer, so dismiss it.
    ScaffoldMessenger.maybeOf(tester.element(finder.first))?.clearSnackBars();
    await tester.pump();
    // Centred, not scrolled to the edge: a pinned app bar would cover it.
    await Scrollable.ensureVisible(
      tester.element(finder.first),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(finder.first);
    await tester.pump();
  }

  /// The text field labelled with [pick] in either language.
  Finder field(String Function(AppLocalizations l10n) pick) => find.ancestor(
    of: anyLanguageText(pick),
    matching: find.byType(TextFormField),
  );

  Future<void> enterInto(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await waitFor(tester, finder);
    await Scrollable.ensureVisible(
      tester.element(finder.first),
      alignment: 0.5,
    );
    await tester.enterText(finder.first, text);
    await tester.pump();
  }

  Future<void> logIn(WidgetTester tester, String secret) async {
    await waitFor(tester, anyLanguageText((l) => l.loginTitle));
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, secret);
    await tapWhenVisible(
      tester,
      find.ancestor(
        of: anyLanguageText((l) => l.loginSubmit),
        matching: find.byType(FilledButton),
      ),
    );
    await waitFor(tester, find.byType(NavigationBar));
  }

  Future<void> openAccount(WidgetTester tester) async {
    await tapWhenVisible(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: anyLanguageText((l) => l.navSettings),
      ),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('settings-account')),
    );
    await waitFor(tester, find.byKey(const ValueKey('account-sessions')));
  }

  /// Lets route transitions finish: in a live test pump(duration) does not
  /// wait real time.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
    }
  }

  Future<void> back(WidgetTester tester) async {
    // A route still animating out keeps its (off-screen) BackButton in the
    // tree; wait for transitions so the tap hits the top route's button.
    await settle(tester);
    await tapWhenVisible(tester, find.byType(BackButton).last);
    await settle(tester);
  }

  /// Signs the owner in a second time over HTTP; returns that session's id
  /// and access token.
  Future<({String id, String token})> secondSession() async {
    final dio = Dio(BaseOptions(baseUrl: 'http://$address/api/v1'));
    try {
      final login = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = login.data!['accessToken'] as String;
      final sessions = await dio.get<List<dynamic>>(
        '/auth/sessions',
        options: Options(headers: {'authorization': 'Bearer $token'}),
      );
      final current = sessions.data!.cast<Map<String, dynamic>>().singleWhere(
        (s) => s['current'] == true,
      );
      return (id: current['id'] as String, token: token);
    } finally {
      dio.close();
    }
  }

  Future<int?> statusWith(String token) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://$address/api/v1',
        validateStatus: (_) => true,
      ),
    );
    try {
      final response = await dio.get<Object?>(
        '/auth/me',
        options: Options(headers: {'authorization': 'Bearer $token'}),
      );
      return response.statusCode;
    } finally {
      dio.close();
    }
  }

  testWidgets('account: language, sessions, recovery code, password change '
      'and reset from login', (tester) async {
    expect(
      email.isNotEmpty && password.isNotEmpty,
      isTrue,
      reason: 'Pass GI_DEV_EMAIL and GI_DEV_PASSWORD with --dart-define.',
    );
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    await SharedPreferencesAsync().clear();
    await const FlutterSecureStorage().deleteAll();

    await runGiHome(config: AppConfig.fromEnvironment(AppFlavor.dev));
    await waitFor(tester, find.byType(TextFormField));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    await tester.enterText(find.byType(TextFormField), address);
    await tapWhenVisible(tester, find.text(l10n.connectSubmit));
    await tapWhenVisible(tester, find.text(l10n.connectConfirmYes));
    await logIn(tester, password);

    // 1. Language from the server profile: English, then Polish again.
    await openAccount(tester);
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('account-locale-en-US')),
    );
    await waitFor(tester, textIn('en', (l) => l.accountTitle));
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('account-locale-pl-PL')),
    );
    await waitFor(tester, textIn('pl', (l) => l.accountTitle));

    // 2. Sessions: revoke the second one; its token stops working at once.
    final other = await tester.runAsync(secondSession);
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('account-sessions')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(ValueKey('session-revoke-${other!.id}')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('sessions-confirm')),
    );
    await waitFor(
      tester,
      find.byKey(ValueKey('session-${other.id}')),
      gone: true,
    );
    expect(await tester.runAsync(() => statusWith(other.token)), 401);
    await back(tester);

    // 3. A new recovery code, shown once; leaving needs the acknowledgement.
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('account-recovery-code')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-generate')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-confirm')),
    );
    final value = find.byKey(const ValueKey('recovery-code-value'));
    await waitFor(tester, value);
    final code = tester.widget<Text>(value).data!;
    expect(
      RegExp(r'^[0-9A-F]{4}(-[0-9A-F]{4}){7}$').hasMatch(code),
      isTrue,
      reason: 'the recovery code is not in the dashed format',
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-acknowledge')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-code-done')),
    );
    await waitFor(tester, find.byKey(const ValueKey('account-sessions')));

    // 4. Change the password to a temporary one.
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('account-change-password')),
    );
    await enterInto(
      tester,
      field((l) => l.changePasswordCurrentLabel),
      password,
    );
    await enterInto(tester, field((l) => l.changePasswordNewLabel), temporary);
    await enterInto(
      tester,
      field((l) => l.changePasswordRepeatLabel),
      temporary,
    );
    await tapWhenVisible(
      tester,
      anyLanguageText((l) => l.changePasswordVoluntarySubmit),
    );
    // The account screen stays in the tree below the change-password route,
    // so wait for that route to close.
    await waitFor(
      tester,
      field((l) => l.changePasswordCurrentLabel),
      gone: true,
    );
    await waitFor(tester, find.byKey(const ValueKey('account-sessions')));

    // 5. Log out; reset the password with the recovery code back to the
    // original from the login screen; log in with it.
    await back(tester);
    await tapWhenVisible(tester, anyLanguageText((l) => l.settingsLogout));
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('login-forgot-password')),
    );
    await enterInto(
      tester,
      find.byKey(const ValueKey('recovery-reset-email')),
      email,
    );
    await enterInto(
      tester,
      find.byKey(const ValueKey('recovery-reset-code')),
      code,
    );
    await enterInto(tester, field((l) => l.changePasswordNewLabel), password);
    await enterInto(
      tester,
      field((l) => l.changePasswordRepeatLabel),
      password,
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-reset-submit')),
    );
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('recovery-reset-login')),
    );
    await logIn(tester, password);

    // After a reset the app offers a new code (the used one stays valid).
    await waitFor(tester, find.byKey(const ValueKey('recovery-rotate-accept')));
    await tapWhenVisible(
      tester,
      anyLanguageText((l) => l.recoveryRotatePromptLater),
    );
    await waitFor(
      tester,
      find.byKey(const ValueKey('recovery-rotate-accept')),
      gone: true,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
