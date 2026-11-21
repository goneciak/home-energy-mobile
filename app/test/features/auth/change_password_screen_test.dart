import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/auth/application/change_password_controller.dart';
import 'package:gi_home/src/features/auth/presentation/change_password_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/test_app.dart';

/// What [FakeChangePasswordController] does: fails with [failure] (or
/// succeeds), recording each attempt in [submissions] and each [finished]
/// screen. Kept outside the notifier, whose public API is its state alone.
class ChangePasswordScript {
  ApiFailure? failure;
  final submissions = <(String, String)>[];
  int finished = 0;
}

/// Controller following [ChangePasswordScript], without a GI Core client.
class FakeChangePasswordController extends ChangePasswordController {
  new(this._script);

  final ChangePasswordScript _script;

  @override
  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    _script.submissions.add((currentPassword, newPassword));
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    final failure = _script.failure;
    state = failure == null
        ? const AsyncData(ChangePasswordResult(revokedSessions: 2))
        : AsyncError(failure, StackTrace.empty);
  }

  @override
  void finish() => _script.finished++;
}

void main() {
  late ChangePasswordScript script;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      testScreen(
        const ChangePasswordScreen(),
        overrides: [
          changePasswordControllerProvider.overrideWith(
            () => FakeChangePasswordController(script),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextFormField).at(index);

  List<String>? hintsOf(WidgetTester tester, Finder field) => tester
      .widget<TextField>(
        find.descendant(of: field, matching: find.byType(TextField)),
      )
      .autofillHints
      ?.toList();

  bool finishedAutofill(WidgetTester tester) => tester.testTextInput.log.any(
    (call) => call.method == 'TextInput.finishAutofillContext',
  );

  Future<void> fillAndSubmit(WidgetTester tester) async {
    await tester.enterText(field(0), 'OldSecret1');
    await tester.enterText(field(1), 'NewSecret1');
    await tester.enterText(field(2), 'NewSecret1');
    tester.testTextInput.log.clear();
    await tester.tap(find.text('Zmień hasło i kontynuuj'));
    await tester.pumpAndSettle();
  }

  setUp(() => script = ChangePasswordScript());

  testWidgets('the current password is filled in and the new one generated '
      'by the password manager (plan §4.1)', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(AutofillGroup), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      expect(
        find.ancestor(of: field(i), matching: find.byType(AutofillGroup)),
        findsOneWidget,
      );
    }
    expect(hintsOf(tester, field(0)), [AutofillHints.password]);
    expect(hintsOf(tester, field(1)), [AutofillHints.newPassword]);
    expect(hintsOf(tester, field(2)), [AutofillHints.newPassword]);
  });

  testWidgets('a successful change finishes the autofill context', (
    tester,
  ) async {
    await pumpScreen(tester);

    await fillAndSubmit(tester);

    expect(script.submissions, [('OldSecret1', 'NewSecret1')]);
    expect(finishedAutofill(tester), isTrue);
    expect(script.finished, 1);
    expect(
      find.text('Hasło zostało zmienione. Wylogowano 2 inne urządzenia.'),
      findsOneWidget,
    );
  });

  testWidgets('a rejected change keeps the autofill context open', (
    tester,
  ) async {
    script.failure = const ApiFailure.domain(
      statusCode: 400,
      code: 'USER_CURRENT_PASSWORD_INVALID',
    );
    await pumpScreen(tester);

    await fillAndSubmit(tester);

    expect(finishedAutofill(tester), isFalse);
    expect(script.finished, 0);
  });

  testWidgets('a weak or mismatched new password is not sent', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field(0), 'OldSecret1');
    await tester.enterText(field(1), 'NewSecret1');
    await tester.enterText(field(2), 'NewSecret2');
    await tester.tap(find.text('Zmień hasło i kontynuuj'));
    await tester.pumpAndSettle();

    expect(script.submissions, isEmpty);
  });

  testWidgets('meets the accessibility guidelines', (tester) async {
    await pumpScreen(tester);
    await expectAccessibilityGuidelines(tester);

    // Also with the validation messages shown.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await expectAccessibilityGuidelines(tester);
  });
}
