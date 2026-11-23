import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/appliance/presentation/connect_screen.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/auth/presentation/login_screen.dart';
import 'package:gi_home/src/features/settings/application/settings_providers.dart';
import 'package:gi_home/src/features/settings/data/language_preference_store.dart';
import 'package:gi_home/src/features/settings/presentation/language_selector.dart';
import 'package:gi_home/src/features/settings/presentation/language_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/accessibility.dart';
import '../../support/test_app.dart';

/// The login and connect screens follow the language preference like the
/// real app does (`MaterialApp.locale` from the provider).
class _FollowsPreference extends ConsumerWidget {
  const new(this.home);

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    theme: AppTheme.dark(),
    locale: ref.watch(languagePreferenceProvider),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

class _SignedOut extends AuthSessionNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();
}

/// The language selector of the screens before the login (plan §13.2).
void main() {
  late SharedPreferencesWithCache prefs;

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    double textScale = 1,
    Locale? phone,
  }) async {
    tester.platformDispatcher.localesTestValue = [phone ?? const Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    prefs = (await tester.runAsync(
      () => inMemoryPreferences(profile: testProfile),
    ))!;
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authSessionProvider.overrideWith(_SignedOut.new),
        ],
        child: _FollowsPreference(home),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, screen) in <(String, Widget)>[
    ('login', const LoginScreen()),
    ('connect', const ConnectScreen()),
  ]) {
    group('on the $name screen', () {
      testWidgets('shows the current choice and opens the three options', (
        tester,
      ) async {
        await pump(tester, screen);

        expect(find.text('Język: Automatycznie'), findsOneWidget);
        await tester.tap(find.byKey(LanguageSelector.selectorKey));
        await tester.pumpAndSettle();

        for (final code in [null, 'pl', 'en']) {
          expect(find.byKey(LanguageTile.optionKey(code)), findsOneWidget);
        }
      });

      testWidgets('picking English switches the screen at once and '
          'remembers it like Settings does', (tester) async {
        await pump(tester, screen);

        await tester.tap(find.byKey(LanguageSelector.selectorKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(LanguageTile.optionKey('en')));
        await tester.pumpAndSettle();

        expect(find.text('Language: English'), findsOneWidget);
        expect(find.text('Język: Automatycznie'), findsNothing);
        expect(LanguagePreferenceStore(prefs).read(), 'en');
        expect(prefs.getString(LanguagePreferenceStore.key), 'en');
      });

      testWidgets('"Automatycznie" returns to the phone language', (
        tester,
      ) async {
        await pump(tester, screen, phone: const Locale('en'));
        await tester.tap(find.byKey(LanguageSelector.selectorKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(LanguageTile.optionKey('pl')));
        await tester.pumpAndSettle();
        expect(find.text('Język: Polski'), findsOneWidget);

        await tester.tap(find.byKey(LanguageSelector.selectorKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(LanguageTile.optionKey(null)));
        await tester.pumpAndSettle();

        expect(find.text('Language: Automatic'), findsOneWidget);
        expect(prefs.containsKey(LanguagePreferenceStore.key), isFalse);
      });

      testWidgets('is a 48 dp target with a spoken label in both languages', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pump(tester, screen);

        expect(
          tester.getSize(find.byKey(LanguageSelector.selectorKey)).height,
          greaterThanOrEqualTo(48),
        );
        expect(find.bySemanticsLabel('Język: Automatycznie'), findsOneWidget);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Język: Automatycznie')),
          isSemantics(
            label: 'Język: Automatycznie',
            isButton: true,
            hasTapAction: true,
          ),
        );

        await tester.tap(find.byKey(LanguageSelector.selectorKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(LanguageTile.optionKey('en')));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Language: English'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('fits at 200% text size in both languages', (tester) async {
        for (final phone in [const Locale('pl'), const Locale('en')]) {
          await pump(tester, screen, textScale: 2, phone: phone);
          expect(tester.takeException(), isNull, reason: '$phone');
          await expectAccessibilityGuidelines(tester);
        }
      });
    });
  }
}
