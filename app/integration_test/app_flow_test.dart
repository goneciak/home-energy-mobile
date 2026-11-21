import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/presentation/device_tile.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end flow on a device against the live dev GI Core.
///
/// Run from `app/` in the dev flavor, with the dev credentials passed as
/// defines:
/// `flutter test integration_test/app_flow_test.dart -d emulator-5554`
/// `--flavor dev --dart-define-from-file=config/dev.json`
/// `--dart-define=GI_DEV_EMAIL=... --dart-define=GI_DEV_PASSWORD=...`
///
/// The Android emulator reaches the host's GI Core at `10.0.2.2:3000`.
/// Uses exactly one login (GI Core allows 5 per minute).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('GI_DEV_EMAIL');
  const password = String.fromEnvironment('GI_DEV_PASSWORD');
  const address = String.fromEnvironment(
    'GI_CORE_ADDRESS',
    defaultValue: '10.0.2.2:3000',
  );

  /// Pumps real frames until [finder] matches (or, with [gone], no longer
  /// matches) or [timeout] passes.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    bool gone = false,
    Duration timeout = const Duration(seconds: 30),
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

  /// Text in either app language. After login the UI follows the signed-in
  /// user's profile language, which may differ from the emulator's.
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
    await tester.pump();
    await tester.tap(finder.first);
    await tester.pump();
  }

  testWidgets('connect → login → home → device → settings → logout', (
    tester,
  ) async {
    expect(
      email.isNotEmpty && password.isNotEmpty,
      isTrue,
      reason: 'Pass GI_DEV_EMAIL and GI_DEV_PASSWORD with --dart-define.',
    );

    // The integration binding leaves text input to the real keyboard;
    // `enterText` needs the simulated one.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);

    // Clean state: no appliance profile, no stored refresh cookie.
    await SharedPreferencesAsync().clear();
    await const FlutterSecureStorage().deleteAll();

    // Not bootstrap(): its error zone and handlers would replace the test
    // binding's own.
    await runGiHome(config: AppConfig.fromEnvironment(AppFlavor.dev));
    await waitFor(tester, find.byType(TextFormField));
    // Strings follow the emulator language (Polish or English).
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    expect(find.text(l10n.connectTitle), findsWidgets);

    // Connect screen: probe the appliance and confirm it.
    await tester.enterText(find.byType(TextFormField), address);
    await tapWhenVisible(tester, find.text(l10n.connectSubmit));
    await tapWhenVisible(tester, find.text(l10n.connectConfirmYes));

    // Login.
    await waitFor(tester, find.text(l10n.loginTitle));
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, password);
    await tapWhenVisible(
      tester,
      find.widgetWithText(FilledButton, l10n.loginSubmit),
    );

    // Home with the seeded rooms and device.
    final lamp = find.descendant(
      of: find.byType(DeviceTile),
      matching: find.text('Lampa w salonie'),
    );
    await waitFor(tester, lamp);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Kotłownia'), findsWidgets);

    // Device details, then back to Home.
    await tapWhenVisible(tester, lamp);
    await waitFor(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Lampa w salonie'),
      ),
    );
    // Once the push settles, Home is covered by the details.
    await waitFor(tester, find.byType(DeviceTile), gone: true);
    // Not tester.pageBack(): it looks for package:flutter/material.dart's
    // BackButton, while the app's AppBar uses package:material_ui's.
    await tapWhenVisible(tester, find.byType(BackButton));
    await waitFor(tester, lamp);

    // Settings → logout lands on login.
    await tapWhenVisible(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: anyLanguageText((l) => l.navSettings),
      ),
    );
    await tapWhenVisible(tester, anyLanguageText((l) => l.settingsLogout));
    await waitFor(tester, anyLanguageText((l) => l.loginTitle));
    await waitFor(tester, find.byType(NavigationBar), gone: true);
  });
}
