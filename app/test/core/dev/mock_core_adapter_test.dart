import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/dev/mock_core_adapter.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/test_app.dart';

/// The dev flavor's mock GI Core (feature flag `mockCore`) is the transport
/// only in dev with the flag on, and never reaches beta or prod.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerFor(
    AppFlavor flavor, {
    bool mockCoreDefault = false,
    List<Override> overrides = const [],
  }) async {
    final prefs = await inMemoryPreferences(profile: testProfile);
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          testConfig(
            flavor,
            flagDefaults: {FeatureFlag.mockCore: mockCoreDefault},
          ),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        appInfoProvider.overrideWithValue(testAppInfo),
        tokenVaultProvider.overrideWithValue(InMemoryTokenVault()),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('dev uses the network until the flag is switched on', () async {
    final container = await containerFor(AppFlavor.dev);

    expect(container.read(coreHttpClientAdapterProvider), isNull);

    await container
        .read(featureFlagsProvider.notifier)
        .set(FeatureFlag.mockCore, value: true);

    expect(
      container.read(coreHttpClientAdapterProvider),
      isA<MockCoreAdapter>(),
    );
  });

  test('a dev config can start with the mock switched on', () async {
    final container = await containerFor(AppFlavor.dev, mockCoreDefault: true);

    expect(
      container.read(coreHttpClientAdapterProvider),
      isA<MockCoreAdapter>(),
    );
  });

  for (final flavor in [AppFlavor.beta, AppFlavor.prod]) {
    test(
      '${flavor.name} never uses the mock, whatever the flags say',
      () async {
        final container = await containerFor(
          flavor,
          mockCoreDefault: true,
          overrides: [
            // Even flags that claim the mock is on.
            featureFlagsProvider.overrideWithValue(
              FeatureFlags(const {FeatureFlag.mockCore: true}),
            ),
          ],
        );

        expect(container.read(featureFlagsProvider).mockCore, isTrue);
        expect(container.read(coreHttpClientAdapterProvider), isNull);
      },
    );
  }

  test('switching the flag rebuilds the GI Core client', () async {
    final container = await containerFor(AppFlavor.dev);
    final notifier = container.read(featureFlagsProvider.notifier);
    // Keep the clients alive as a screen would.
    container.listen(giCoreClientProvider, (_, _) {});

    final real = container.read(giCoreClientProvider);
    await notifier.set(FeatureFlag.mockCore, value: true);
    final mocked = container.read(giCoreClientProvider);
    await notifier.set(FeatureFlag.scheduleClockConversion, value: true);
    final unchanged = container.read(giCoreClientProvider);
    await notifier.set(FeatureFlag.mockCore, value: false);

    expect(real, isNotNull);
    expect(mocked, isNot(same(real)));
    // Other flags leave the client alone.
    expect(unchanged, same(mocked));
    expect(container.read(giCoreClientProvider), isNot(same(mocked)));
  });

  testWidgets('dev with the mock: connect, sign in and see the mock home', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = await tester.runAsync(inMemoryPreferences);
    final vault = InMemoryTokenVault();
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          appConfigProvider.overrideWithValue(
            testConfig(
              AppFlavor.dev,
              flagDefaults: const {FeatureFlag.mockCore: true},
            ),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
          tokenVaultProvider.overrideWith(
            (ref) => ref.watch(applianceProfileProvider) == null ? null : vault,
          ),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '10.0.2.2:3000');
    await tester.tap(find.text('Sprawdź'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tak, połącz'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'dev@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'anything');
    await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj'));
    await tester.pumpAndSettle();

    expect(find.text('Kotłownia'), findsOneWidget);
    expect(find.text('Sterownik kotłowni'), findsOneWidget);
    expect(find.text('Lampa w salonie'), findsOneWidget);
    expect(vault.cookie, isNotNull);
  });
}
