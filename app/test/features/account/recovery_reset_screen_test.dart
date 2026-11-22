import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/platform/secure_display.dart';
import 'package:gi_home/src/features/account/presentation/recovery_reset_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/account_fixtures.dart';

void main() {
  late AccountScript script;
  late List<MethodCall> calls;

  setUp(() {
    script = AccountScript();
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureDisplay.channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureDisplay.channel, null);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      accountTestApp(
        RecoveryResetScreen.new,
        overrides: fakeAccountControllers(script),
      ),
    );
    await tester.pumpAndSettle();
  }

  final email = find.byKey(const ValueKey('recovery-reset-email'));
  final code = find.byKey(const ValueKey('recovery-reset-code'));
  Finder password(int index) => find.byType(TextFormField).at(2 + index);
  final submit = find.byKey(const ValueKey('recovery-reset-submit'));

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fill(
    WidgetTester tester, {
    String mail = 'owner@gihome.test',
    String recovery = 'abcd-ef01-2345-6789-abcd-ef01-2345-6789',
    String newPassword = 'NewSecret1',
    String? repeat,
  }) async {
    await tester.enterText(email, mail);
    await tester.enterText(code, recovery);
    await tester.enterText(password(0), newPassword);
    await tester.enterText(password(1), repeat ?? newPassword);
  }

  testWidgets('the form is screen-protected and hidden in the background', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.enterText(code, 'ab12-cd');

    expect(
      [
        for (final c in calls)
          if (c.method == SecureDisplay.setSecureMethod)
            (c.arguments as Map)['secure'],
      ],
      [true],
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(code, findsNothing);
    expect(find.byKey(const ValueKey('recovery-reset-hidden')), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(code, findsOneWidget);
    // The typed code survives hiding.
    expect(find.text('AB12-CD'), findsOneWidget);
  });

  testWidgets('the code is uppercased as typed and keeps its dashes', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(code, 'ab12-cd');

    expect(
      tester.widget<TextFormField>(code).controller?.text ??
          tester
              .widget<EditableText>(
                find.descendant(of: code, matching: find.byType(EditableText)),
              )
              .controller
              .text,
      'AB12-CD',
    );
  });

  testWidgets('a valid form sends the dashed code and shows success', (
    tester,
  ) async {
    await pumpScreen(tester);

    await fill(tester);
    await tapVisible(tester, submit);

    expect(script.resets, [
      {
        'email': 'owner@gihome.test',
        'recoveryCode': placeholderRecoveryCode,
        'newPassword': 'NewSecret1',
      },
    ]);
    expect(find.text('Hasło zostało zmienione'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recovery-reset-login')),
    );
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  testWidgets('a code without dashes is accepted and sent with them', (
    tester,
  ) async {
    await pumpScreen(tester);

    await fill(tester, recovery: 'ABCDEF0123456789ABCDEF0123456789');
    await tapVisible(tester, submit);

    expect(script.resets.single['recoveryCode'], placeholderRecoveryCode);
  });

  testWidgets('a malformed code, a weak password and a mismatch are caught '
      'on the phone', (tester) async {
    await pumpScreen(tester);

    await fill(tester, recovery: 'ABCD-12', newPassword: 'short', repeat: 'x');
    await tapVisible(tester, submit);

    expect(
      find.text(
        'Kod ma postać 8 grup po 4 znaki (0–9, A–F) oddzielonych myślnikami.',
      ),
      findsOneWidget,
    );
    expect(find.text('Hasło musi mieć co najmniej 8 znaków.'), findsOneWidget);
    expect(script.resets, isEmpty);
  });

  testWidgets('an empty code and a bad e-mail are caught', (tester) async {
    await pumpScreen(tester);

    await fill(tester, mail: 'owner', recovery: '');
    await tapVisible(tester, submit);

    expect(find.text('Podaj kod odzyskiwania.'), findsOneWidget);
    expect(script.resets, isEmpty);
  });

  testWidgets('AUTH_RECOVERY_INVALID reads the same for e-mail and code', (
    tester,
  ) async {
    script.failure = const ApiFailure.domain(
      statusCode: 400,
      code: GiErrorCodes.authRecoveryInvalid,
    );
    await pumpScreen(tester);

    await fill(tester);
    await tapVisible(tester, submit);

    expect(
      find.text(
        'Nie udało się ustawić hasła. Sprawdź e-mail i kod odzyskiwania.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('429 asks to try again in a few minutes', (tester) async {
    script.failure = const ApiFailure.rateLimited();
    await pumpScreen(tester);

    await fill(tester);
    await tapVisible(tester, submit);

    expect(
      find.text('Zbyt wiele prób. Spróbuj za kilka minut.'),
      findsOneWidget,
    );
  });

  testWidgets('the back button returns to login', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Wróć do logowania'));
    await tester.pumpAndSettle();

    expect(find.text(AppRoutes.login), findsOneWidget);
  });
}
