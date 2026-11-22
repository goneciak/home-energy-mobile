import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/app/router/app_router.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/config/feature_flag_overrides_store.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/experimental/presentation/experimental_features_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/accessibility.dart';
import '../../support/fake_core_adapter.dart';
import '../../support/test_app.dart';

/// The hidden "Funkcje eksperymentalne" screen (plan §19.2, §19.6): seven
/// taps on the app version in Settings open it in dev and beta, never in
/// prod.
void main() {
  late SharedPreferencesWithCache prefs;

  final storedCookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'B' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17),
    absoluteExpiry: DateTime.utc(2099),
  );

  /// The signed-in app of a [flavor] build, on the Settings tab.
  Future<ProviderContainer> pumpSettings(
    WidgetTester tester,
    AppFlavor flavor,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    prefs = (await tester.runAsync(
      () => inMemoryPreferences(profile: testProfile),
    ))!;
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(
              flavor,
              flagDefaults: const {FeatureFlag.scheduleClockConversion: true},
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
          appInfoProvider.overrideWithValue(testAppInfo),
          coreHttpClientAdapterProvider.overrideWithValue(
            FakeCoreAdapter(mockCoreRoutes()),
          ),
          tokenVaultProvider.overrideWithValue(
            InMemoryTokenVault(storedCookie),
          ),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(GiHomeApp)));
  }

  Future<void> tapVersion(WidgetTester tester, int times) async {
    final version = find.byKey(const ValueKey('settings-app-version'));
    // Centred, so the navigation bar never covers it.
    await tester.scrollUntilVisible(version, 100);
    await Scrollable.ensureVisible(tester.element(version), alignment: 0.5);
    await tester.pumpAndSettle();
    for (var i = 0; i < times; i++) {
      await tester.tap(version);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  final experimental = find.byType(ExperimentalFeaturesScreen);

  for (final flavor in [AppFlavor.dev, AppFlavor.beta]) {
    testWidgets('${flavor.name}: seven taps on the version open the screen', (
      tester,
    ) async {
      await pumpSettings(tester, flavor);

      await tapVersion(tester, 6);
      expect(experimental, findsNothing);

      await tapVersion(tester, 1);
      expect(experimental, findsOneWidget);
      expect(find.text('Funkcje eksperymentalne'), findsOneWidget);
    });
  }

  testWidgets('prod: the version does nothing, not even a link opens it', (
    tester,
  ) async {
    final container = await pumpSettings(tester, AppFlavor.prod);

    await tapVersion(tester, 14);
    expect(experimental, findsNothing);
    expect(find.text('0.1.0 (1)'), findsOneWidget);

    container.read(goRouterProvider).go(AppRoutes.experimental);
    await tester.pumpAndSettle();

    expect(experimental, findsNothing);
    expect(find.text('Wersja aplikacji'), findsOneWidget);
  });

  testWidgets('dev: every flag has a switch, changes are stored and reset', (
    tester,
  ) async {
    final container = await pumpSettings(tester, AppFlavor.dev);
    await tapVersion(tester, ExperimentalFeaturesScreen.versionTapsToOpen);

    for (final title in [
      'Atrapa GI Core',
      'Przeliczanie godzin harmonogramów',
      'Sterowanie przełącznikami według integracji',
      'Prośba o dostęp do sieci lokalnej (Android)',
      'Warunkowe pobieranie urządzeń (ETag)',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    expect(find.byType(SwitchListTile), findsNWidgets(5));
    final integration = find.byKey(
      const ValueKey('flag-switchControlByIntegration'),
    );
    await tester.tap(integration);
    await tester.pumpAndSettle();

    expect(
      container.read(featureFlagsProvider).switchControlByIntegration,
      isTrue,
    );
    expect(
      jsonDecode(prefs.getString(FeatureFlagOverridesStore.overridesKey)!),
      {'switchControlByIntegration': true},
    );
    expect(
      find.descendant(
        of: integration,
        matching: find.textContaining('Zmieniono na tym telefonie'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('experimental-reset')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experimental-reset')));
    await tester.pumpAndSettle();

    expect(
      container.read(featureFlagsProvider),
      FeatureFlags(const {FeatureFlag.scheduleClockConversion: true}),
    );
    expect(prefs.getString(FeatureFlagOverridesStore.overridesKey), isNull);
    expect(find.text('Przywrócono domyślne wartości flag.'), findsOneWidget);

    // The flavor and the config it was built with.
    await tester.scrollUntilVisible(
      find.text('FLAVOR'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Wariant aplikacji'), findsOneWidget);
    // The flavor, and the value of its define.
    expect(find.text('dev'), findsNWidgets(2));
  });

  testWidgets('beta: the mock Core switch is disabled', (tester) async {
    await pumpSettings(tester, AppFlavor.beta);
    await tapVersion(tester, ExperimentalFeaturesScreen.versionTapsToOpen);

    final mock = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('flag-mockCore')),
    );
    expect(mock.onChanged, isNull);
    expect(mock.value, isFalse);
    expect(find.textContaining('tylko w wariancie dev'), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('flag-scheduleClockConversion')),
          )
          .value,
      isTrue,
    );
  });

  for (final flavor in [AppFlavor.dev, AppFlavor.beta]) {
    testWidgets('${flavor.name}: the screen meets the accessibility '
        'guidelines', (tester) async {
      await pumpSettings(tester, flavor);
      await tapVersion(tester, ExperimentalFeaturesScreen.versionTapsToOpen);
      expect(experimental, findsOneWidget);

      await expectAccessibilityGuidelines(tester);
    });
  }

  testWidgets('settings meet the accessibility guidelines', (tester) async {
    await pumpSettings(tester, AppFlavor.prod);

    await expectAccessibilityGuidelines(tester);
  });
}
