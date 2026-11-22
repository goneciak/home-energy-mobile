import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// M3 heating schedules end to end against the real GI Core of a contract
/// stack (plan §20 M3): connect → login → the fake device → schedules →
/// create a whole-day schedule for every day → it shows as active now →
/// edit its target → delete it.
///
/// Needs a contract stack seeded with `tools/seed_core.dart --init` (the
/// "Fake kotłownia" device with no schedules) and the owner's credentials
/// from `tools/backend/dev.env`, from `app/`:
/// `flutter drive --profile -d emulator-5554 --flavor dev`
/// `--driver=test_driver/integration_test.dart`
/// `--target=integration_test/schedule_flow_test.dart`
/// `--dart-define-from-file=config/dev.json`
/// `--dart-define-from-file=../tools/backend/dev.env`
/// `--dart-define=GI_CORE_ADDRESS=10.0.2.2:<port>`
///
/// A window whose start equals its end covers the whole day (GI Core's
/// `windowMatches`), so with every day selected the schedule is active
/// whatever the clocks of the emulator, the house and GI Core say.
/// The schedule is deleted at the end; a failed run leaves it behind, and
/// `packages/gi_core_api/test/contract/schedules_contract_test.dart` deletes
/// every schedule of the fake device before it runs.
/// Uses exactly one login (GI Core allows 5 per minute).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('GI_DEV_EMAIL');
  const password = String.fromEnvironment('GI_DEV_PASSWORD');
  const address = String.fromEnvironment(
    'GI_CORE_ADDRESS',
    defaultValue: '10.0.2.2:3000',
  );
  const fakeDevice = 'Fake kotłownia';
  const scheduleName = 'E2E cały dzień';

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    bool gone = false,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty != gone) {
      if (DateTime.now().isAfter(deadline)) {
        final visible = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data)
            .nonNulls
            .join(' | ');
        fail('Timed out after $timeout waiting for $finder. Visible: $visible');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Text in either app language: after login the UI follows the signed-in
  /// user's profile language.
  Finder anyLanguageText(String Function(AppLocalizations l10n) pick) {
    final texts = {
      for (final code in const ['pl', 'en'])
        pick(lookupAppLocalizations(Locale(code))),
    };
    return find.byWidgetPredicate(
      (widget) => widget is Text && texts.contains(widget.data),
    );
  }

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await waitFor(tester, finder);
    // A post-login snack bar (e.g. the sessions review offer) may cover a
    // floating action button; it is only an offer, so dismiss it.
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

  Finder scheduleTile() => find.text(scheduleName);

  /// Sets the end time to the start time through the time picker's text
  /// input, which makes the window cover the whole day.
  Future<void> endAtStart(WidgetTester tester) async {
    await tapWhenVisible(tester, find.byKey(const ValueKey('schedule-end')));
    await waitFor(tester, find.byType(Dialog));
    await tapWhenVisible(tester, find.byIcon(Icons.keyboard_outlined));
    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await waitFor(tester, fields);
    // The editor starts a new schedule at 06:00.
    await tester.enterText(fields.at(0), '06');
    await tester.enterText(fields.at(1), '00');
    await tester.pump();
    final ok = MaterialLocalizations.of(tester.element(find.byType(Dialog)))
        .okButtonLabel;
    await tapWhenVisible(
      tester,
      find.descendant(of: find.byType(Dialog), matching: find.text(ok)),
    );
    await waitFor(tester, find.byType(Dialog), gone: true);
  }

  testWidgets('schedules: create → active now → edit → delete', (tester) async {
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

    // Connect and log in as the owner (schedules are OWNER/ADMIN writes).
    await tester.enterText(find.byType(TextFormField), address);
    await tapWhenVisible(tester, find.text(l10n.connectSubmit));
    await tapWhenVisible(tester, find.text(l10n.connectConfirmYes));
    await waitFor(tester, find.text(l10n.loginTitle));
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, password);
    await tapWhenVisible(
      tester,
      find.widgetWithText(FilledButton, l10n.loginSubmit),
    );

    // The fake device → its schedules (none yet).
    await tapWhenVisible(tester, find.text(fakeDevice));
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('device-schedules')),
    );
    await waitFor(tester, find.byKey(const ValueKey('schedule-add')));
    expect(scheduleTile(), findsNothing);

    // Create: every day, 06:00–06:00 (the whole day), 52 °C.
    await tapWhenVisible(tester, find.byKey(const ValueKey('schedule-add')));
    await waitFor(tester, anyLanguageText((l) => l.scheduleEditorNewTitle));
    await tester.enterText(
      find.byKey(const ValueKey('schedule-name')),
      scheduleName,
    );
    for (final day in const [0, 6]) {
      await tapWhenVisible(tester, find.byKey(ValueKey('schedule-day-$day')));
    }
    await endAtStart(tester);
    await waitFor(tester, anyLanguageText((l) => l.scheduleWarnWholeDay));
    await tester.enterText(find.byKey(const ValueKey('schedule-target')), '52');
    await tapWhenVisible(tester, find.byKey(const ValueKey('schedule-save')));
    await waitFor(
      tester,
      find.byKey(const ValueKey('schedule-save')),
      gone: true,
    );

    // Back on the list: the new schedule is the one active now.
    await waitFor(tester, scheduleTile());
    await waitFor(tester, anyLanguageText((l) => l.scheduleActiveNow));
    expect(find.textContaining('52'), findsWidgets);

    // Edit the target.
    await tapWhenVisible(tester, scheduleTile());
    await waitFor(tester, anyLanguageText((l) => l.scheduleEditorEditTitle));
    await tester.enterText(find.byKey(const ValueKey('schedule-target')), '48');
    await tapWhenVisible(tester, find.byKey(const ValueKey('schedule-save')));
    // The editor's own fields hold the name and "48": wait until it closes.
    await waitFor(
      tester,
      find.byKey(const ValueKey('schedule-save')),
      gone: true,
    );
    await waitFor(tester, scheduleTile());
    await waitFor(tester, find.textContaining('48'));
    expect(anyLanguageText((l) => l.scheduleActiveNow), findsOneWidget);

    // Delete, confirming first.
    await tapWhenVisible(tester, scheduleTile());
    await waitFor(tester, anyLanguageText((l) => l.scheduleEditorEditTitle));
    // The editor is a lazy list: build the delete button by scrolling.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('schedule-delete')),
      200,
      scrollable: find
          .ancestor(
            of: find.byKey(const ValueKey('schedule-name')),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    await tapWhenVisible(tester, find.byKey(const ValueKey('schedule-delete')));
    await tapWhenVisible(
      tester,
      find.byKey(const ValueKey('schedule-delete-confirm')),
    );
    await waitFor(tester, find.byKey(const ValueKey('schedule-add')));
    await waitFor(tester, scheduleTile(), gone: true);
    expect(anyLanguageText((l) => l.scheduleActiveNow), findsNothing);
  });
}
