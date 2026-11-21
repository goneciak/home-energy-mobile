import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// M2 control paths end to end against the real GI Core of a contract stack
/// (plan §20 M2 item 8): connect → login → the fake device → edit the
/// strategy → suspend → resume → strategy back to the seeded 55 °C.
///
/// Needs a contract stack seeded with `tools/seed_core.dart --init` (the
/// "Fake kotłownia" device, LEGACY_ESPHOME, strategy 55 °C / 4 K / MANUAL)
/// and the owner's credentials from `tools/backend/dev.env`, from `app/`:
/// `flutter drive --profile -d emulator-5554 --flavor dev`
/// `--driver=test_driver/integration_test.dart`
/// `--target=integration_test/control_flow_test.dart`
/// `--dart-define-from-file=config/dev.json`
/// `--dart-define-from-file=../tools/backend/dev.env`
/// `--dart-define=GI_CORE_ADDRESS=10.0.2.2:<port>`
///
/// The heating relay is read-only in the UI (plan §12.4), so switching is
/// covered by `packages/gi_core_api/test/contract/control_contract_test.dart`
/// at the API level, and by `demo_flow_test.dart` in the UI.
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

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await waitFor(tester, finder);
    // Centred, not scrolled to the edge: a pinned app bar would cover it.
    await Scrollable.ensureVisible(
      tester.element(finder.first),
      alignment: 0.5,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder.first);
    await tester.pump();
  }

  /// Opens the strategy editor, sets [target] and saves; confirms when the
  /// confirmation policy asks, then closes the sheet.
  Future<void> saveStrategy(WidgetTester tester, String target) async {
    await tapWhenVisible(tester, find.byKey(const ValueKey('strategy-edit')));
    final field = find.byKey(const ValueKey('strategy-target'));
    await waitFor(tester, field);
    await tester.enterText(field, target);
    await tapWhenVisible(tester, find.byKey(const ValueKey('strategy-save')));
    final confirm = find.byKey(const ValueKey('strategy-confirm'));
    final saved = find.byKey(const ValueKey('strategy-saved'));
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (confirm.evaluate().isEmpty && saved.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) fail('strategy save hung');
      await tester.pump(const Duration(milliseconds: 200));
    }
    if (confirm.evaluate().isNotEmpty) await tapWhenVisible(tester, confirm);
    await waitFor(tester, saved);
    await tapWhenVisible(tester, find.byKey(const ValueKey('strategy-close')));
    await waitFor(tester, saved, gone: true);
  }

  testWidgets('login → fake device → strategy → suspend → resume', (
    tester,
  ) async {
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
    await waitFor(tester, find.text(l10n.loginTitle));
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, password);
    await tapWhenVisible(
      tester,
      find.widgetWithText(FilledButton, l10n.loginSubmit),
    );

    final device = find.descendant(
      of: find.byWidgetPredicate(
        // A DeviceTile or, for heating devices, the heating card slot.
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('device-'),
      ),
      matching: find.text(fakeDevice),
    );
    await tapWhenVisible(tester, device);
    await waitFor(tester, find.byKey(const ValueKey('heating-control-panel')));

    // Strategy: 50 °C, saved and confirmed by the server's answer.
    await saveStrategy(tester, '50');

    // Hold to suspend; the outcome comes from re-reading the device.
    final hold = find.byKey(const ValueKey('heating-suspend-hold'));
    await waitFor(tester, hold);
    await Scrollable.ensureVisible(tester.element(hold), alignment: 0.5);
    await tester.pump(const Duration(milliseconds: 300));
    final gesture = await tester.startGesture(tester.getCenter(hold));
    // Real time: in a live test pump(duration) does not wait, and the hold
    // animation runs on the wall clock.
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    await gesture.up();
    final resume = find.byKey(const ValueKey('heating-resume'));
    await waitFor(tester, resume);

    // Resume through the consequence sheet, which names the strategy that
    // will apply again.
    await tapWhenVisible(tester, resume);
    await waitFor(tester, find.byKey(const ValueKey('resume-will-apply')));
    await tapWhenVisible(tester, find.byKey(const ValueKey('resume-confirm')));
    await waitFor(tester, hold);

    // Back to the seeded strategy for the next run.
    await saveStrategy(tester, '55');
  });
}
