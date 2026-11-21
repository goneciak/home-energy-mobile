import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/presentation/setup_required_screen.dart';

import '../../support/accessibility.dart';
import '../../support/test_app.dart';

void main() {
  Future<void> pumpSetupRequired(WidgetTester tester, AppFlavor flavor) async {
    final prefs = await tester.runAsync(
      () => inMemoryPreferences(
        profile: testProfile.copyWith(initializedAt: null),
      ),
    );
    await tester.pumpWidget(
      testScreen(
        const SetupRequiredScreen(),
        overrides: [
          appConfigProvider.overrideWithValue(testConfig(flavor)),
          sharedPreferencesProvider.overrideWithValue(prefs!),
          appInfoProvider.overrideWithValue(testAppInfo),
        ],
      ),
    );
  }

  testWidgets('the dev flavor shows how to seed the dev Core', (tester) async {
    await pumpSetupRequired(tester, AppFlavor.dev);

    expect(find.text('Dokończ konfigurację w przeglądarce'), findsOneWidget);
    expect(
      find.textContaining(SetupRequiredScreen.devInitCommand),
      findsOneWidget,
    );
  });

  for (final flavor in [AppFlavor.beta, AppFlavor.prod]) {
    testWidgets('${flavor.name} has no seed hint', (tester) async {
      await pumpSetupRequired(tester, flavor);

      expect(find.text('Dokończ konfigurację w przeglądarce'), findsOneWidget);
      expect(find.textContaining('seed_core'), findsNothing);
    });
  }

  for (final flavor in AppFlavor.values) {
    testWidgets('${flavor.name} meets the accessibility guidelines', (
      tester,
    ) async {
      await pumpSetupRequired(tester, flavor);

      await expectAccessibilityGuidelines(tester);
    });
  }
}
