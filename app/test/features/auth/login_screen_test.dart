import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/presentation/login_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/test_app.dart';

/// What [FakeAuthSession.login] does: fails with [failure] (or succeeds),
/// recording each attempt in [logins]. Kept outside the notifier, whose
/// public API is its state alone.
class LoginScript {
  ApiFailure? failure;
  final logins = <(String, String)>[];
}

/// Session notifier whose login follows [script].
class FakeAuthSession extends AuthSessionNotifier {
  new(this.script, {this.initial = const AuthState.unauthenticated()});

  final LoginScript script;
  final AuthState initial;

  @override
  Future<AuthState> build() async => initial;

  @override
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) async {
    script.logins.add((email, password));
    final failure = script.failure;
    if (failure != null) throw failure;
    const user = CurrentUser(
      id: 'u1',
      email: 'owner@gihome.test',
      firstName: 'Dev',
      mustChangePassword: false,
    );
    state = const AsyncData(AuthState.authenticated(user));
    return user;
  }
}

void main() {
  late LoginScript script;
  late FakeAuthSession session;

  Future<void> pumpLogin(WidgetTester tester) async {
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(
        profile: testProfile.copyWith(lastUserEmail: 'owner@gihome.test'),
      ),
    );
    await tester.pumpWidget(
      testScreen(
        const LoginScreen(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs!),
          authSessionProvider.overrideWith(() => session),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(
    WidgetTester tester, {
    String password = 'Secret123',
  }) async {
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    script = LoginScript();
    session = FakeAuthSession(script);
  });

  testWidgets('shows the appliance and pre-fills the last email', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(find.text('do GI Home Dev'), findsOneWidget);
    expect(find.text('owner@gihome.test'), findsOneWidget);
    expect(find.byType(AutofillGroup), findsOneWidget);
  });

  testWidgets('validates the form before calling the server', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');

    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();

    expect(find.text('Wpisz poprawny adres e-mail.'), findsOneWidget);
    expect(find.text('Wpisz hasło.'), findsOneWidget);
    expect(script.logins, isEmpty);
  });

  testWidgets('submits trimmed email and password', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      ' owner@gihome.test ',
    );

    await submit(tester);

    expect(script.logins, [('owner@gihome.test', 'Secret123')]);
  });

  testWidgets('invalid credentials', (tester) async {
    script.failure = const ApiFailure.unauthorized(
      code: 'AUTH_INVALID_CREDENTIALS',
    );
    await pumpLogin(tester);

    await submit(tester);

    expect(find.text('Nieprawidłowy e-mail lub hasło.'), findsOneWidget);
  });

  testWidgets('disabled account', (tester) async {
    script.failure = const ApiFailure.forbidden(code: 'USER_DISABLED');
    await pumpLogin(tester);

    await submit(tester);

    expect(
      find.text(
        'To konto jest wyłączone. Skontaktuj się z właścicielem GI Home.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('rate limit counts down and blocks the button', (tester) async {
    script.failure = const ApiFailure.rateLimited(
      retryAfter: Duration(seconds: 3),
    );
    await pumpLogin(tester);

    await submit(tester);

    expect(find.text('Zbyt wiele prób logowania.'), findsOneWidget);
    expect(find.text('Spróbuj ponownie za 3 sekundy.'), findsOneWidget);
    // Only the static message is a live region, so the countdown is not
    // re-announced every second.
    final semantics = tester.ensureSemantics();
    await tester.pump();
    bool live(SemanticsNode node) =>
        node.getSemanticsData().flagsCollection.isLiveRegion;
    expect(
      find.semantics.byPredicate(
        (node) => live(node) && node.label.contains('Zbyt wiele prób'),
      ),
      findsOneWidget,
    );
    expect(
      find.semantics.byPredicate(
        (node) => live(node) && node.label.contains('Spróbuj ponownie za'),
      ),
      findsNothing,
    );
    semantics.dispose();
    final button = find.widgetWithText(FilledButton, 'Zaloguj');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Spróbuj ponownie za 1 sekundę.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Zbyt wiele prób'), findsNothing);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('meets the accessibility guidelines', (tester) async {
    await pumpLogin(tester);

    await expectAccessibilityGuidelines(tester);
  });

  testWidgets('rate limit without Retry-After waits 60 s', (tester) async {
    script.failure = const ApiFailure.rateLimited();
    await pumpLogin(tester);

    await submit(tester);

    expect(find.textContaining('za 60 sekund.'), findsOneWidget);
    await tester.pump(LoginScreen.defaultRateLimitWait);
  });

  testWidgets('unreachable appliance uses the generic message', (tester) async {
    script.failure = const ApiFailure.unreachable();
    await pumpLogin(tester);

    await submit(tester);

    expect(
      find.textContaining('Nie można połączyć się z GI Home.'),
      findsOneWidget,
    );
  });

  testWidgets('explains a session that ended elsewhere', (tester) async {
    session = FakeAuthSession(
      script,
      initial: const AuthState.sessionLost(SessionLostReason.sessionRevoked),
    );
    await pumpLogin(tester);

    expect(
      find.textContaining('Sesja wygasła lub została zakończona'),
      findsOneWidget,
    );
  });

  group('autofill (plan §4.1, §17.1)', () {
    List<String>? hintsOf(WidgetTester tester, Finder field) => tester
        .widget<TextField>(
          find.descendant(of: field, matching: find.byType(TextField)),
        )
        .autofillHints
        ?.toList();

    bool finishedAutofill(WidgetTester tester) => tester.testTextInput.log.any(
      (call) => call.method == 'TextInput.finishAutofillContext',
    );

    testWidgets('both fields are in one autofill group with their hints', (
      tester,
    ) async {
      await pumpLogin(tester);

      final fields = find.byType(TextFormField);
      expect(
        find.ancestor(of: fields.first, matching: find.byType(AutofillGroup)),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: fields.last, matching: find.byType(AutofillGroup)),
        findsOneWidget,
      );
      expect(hintsOf(tester, fields.first), [
        AutofillHints.username,
        AutofillHints.email,
      ]);
      expect(hintsOf(tester, fields.last), [AutofillHints.password]);
    });

    testWidgets('a successful login finishes the autofill context', (
      tester,
    ) async {
      await pumpLogin(tester);
      tester.testTextInput.log.clear();

      await submit(tester);

      expect(script.logins, hasLength(1));
      expect(finishedAutofill(tester), isTrue);
    });

    testWidgets('a failed login keeps the autofill context open', (
      tester,
    ) async {
      script.failure = const ApiFailure.unauthorized(
        code: 'AUTH_INVALID_CREDENTIALS',
      );
      await pumpLogin(tester);
      tester.testTextInput.log.clear();

      await submit(tester);

      expect(finishedAutofill(tester), isFalse);
    });
  });
}
