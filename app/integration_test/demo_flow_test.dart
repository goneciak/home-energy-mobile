import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Demo mode end to end on a real target (plan §19.5), in real time and
/// without any GI Core: connect → demo → home → device → switch → suspend
/// → resume → exit.
///
/// Needs no backend or credentials, from `app/`:
/// `flutter test integration_test/demo_flow_test.dart -d <device>`
/// `--flavor dev --dart-define-from-file=config/dev.json`
/// on an Android or iOS target. The project has no `windows/` or `web/`
/// platform folders yet; once one is added the same command runs there
/// (`-d windows` / `-d chrome`).
///
/// The same flow runs under `flutter test` in
/// `test/features/demo/demo_flow_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    bool gone = false,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty != gone) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out after $timeout waiting for $finder (gone: $gone)');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // The demo profile may switch the UI language.
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
    // Centred, not scrolled to the edge: a pinned app bar would cover it.
    await Scrollable.ensureVisible(
      tester.element(finder.first),
      alignment: 0.5,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder.first);
    await tester.pump();
  }

  testWidgets('connect → demo → home → switch → suspend → resume → exit', (
    tester,
  ) async {
    // Clean state: no appliance profile, so the app opens on "Connect".
    await SharedPreferencesAsync().clear();
    await const FlutterSecureStorage().deleteAll();

    await runGiHome(config: AppConfig.fromEnvironment(AppFlavor.dev));
    final enter = find.byKey(const ValueKey('demo-enter'));
    await waitFor(tester, enter);
    final l10n = AppLocalizations.of(tester.element(enter));

    await tapWhenVisible(tester, enter);
    final controller = find.descendant(
      of: find.byWidgetPredicate(
        // A DeviceTile or, for heating devices, the heating card slot.
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('device-'),
      ),
      matching: find.text('Sterownik kotłowni'),
    );
    await waitFor(tester, controller);
    expect(find.byKey(const ValueKey('demo-banner')), findsOneWidget);

    await tapWhenVisible(tester, controller);
    await waitFor(tester, find.byKey(const ValueKey('heating-control-panel')));

    // The boiler-room light: confirm, then the simulated heartbeat.
    final light = find.byKey(const ValueKey('switch-control-demo-relay-light'));
    await tester.scrollUntilVisible(
      light,
      200,
      // The device page, not Home behind it or a nested horizontal list.
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    final toggle = find.descendant(
      of: light,
      matching: find.byKey(const ValueKey('switch-toggle')),
    );
    await tapWhenVisible(tester, toggle);
    await tapWhenVisible(tester, anyLanguageText((l) => l.switchConfirmSend));
    final awaiting = find.byKey(const ValueKey('switch-awaiting'));
    await waitFor(tester, awaiting);
    await waitFor(tester, awaiting, gone: true);

    // Hold to suspend, then resume through the consequence sheet.
    final hold = find.byKey(const ValueKey('heating-suspend-hold'));
    await tester.scrollUntilVisible(
      hold,
      -200,
      // The device page, not Home behind it or a nested horizontal list.
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
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
    // The button is shown, disabled, while the suspend command settles.
    for (
      var i = 0;
      tester.widget<ButtonStyleButton>(resume).onPressed == null;
      i++
    ) {
      if (i == 100) fail('heating-resume stayed disabled');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    await tapWhenVisible(tester, resume);
    await tapWhenVisible(tester, find.byKey(const ValueKey('resume-confirm')));
    await waitFor(tester, hold);

    // Exit: back on the connect screen, nothing of the demo left.
    await tapWhenVisible(tester, find.byKey(const ValueKey('demo-exit')));
    await waitFor(tester, enter);
    expect(find.byKey(const ValueKey('demo-banner')), findsNothing);
    expect(find.text(l10n.connectTitle), findsWidgets);
  });
}
