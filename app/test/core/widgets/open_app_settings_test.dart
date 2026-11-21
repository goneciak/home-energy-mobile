import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/app_settings_opener.dart';
import 'package:gi_home/src/core/widgets/freshness_banner.dart';
import 'package:gi_home/src/core/widgets/state_views.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fake_platform.dart';
import '../../support/test_app.dart';

/// "Otwórz ustawienia" wherever a denied local network is shown (plan §9.4).
void main() {
  late FakeSettingsOpener settings;

  setUp(() => settings = FakeSettingsOpener());

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    testScreen(
      Scaffold(body: child),
      overrides: [appSettingsOpenerProvider.overrideWithValue(settings)],
    ),
  );

  const denied = ApiFailure.localNetworkDenied(reason: 'EPERM');

  testWidgets('the error state (Home) opens the app settings', (tester) async {
    var retried = 0;
    await pump(tester, ErrorState(error: denied, onRetry: () => retried++));

    expect(
      find.textContaining('GI Home nie ma dostępu do sieci lokalnej'),
      findsOneWidget,
    );
    expect(find.text('Spróbuj ponownie'), findsOneWidget);

    await tester.tap(find.text('Otwórz ustawienia'));
    await tester.pump();

    expect(settings.opened, 1);
    expect(retried, 0);
  });

  testWidgets('the error state offers no settings for other errors', (
    tester,
  ) async {
    await pump(
      tester,
      ErrorState(error: const ApiFailure.unreachable(), onRetry: () {}),
    );

    expect(find.text('Otwórz ustawienia'), findsNothing);
  });

  testWidgets('a refresh denied over cached data opens the app settings', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 18, 7, 41);
    await pump(
      tester,
      FreshnessBanner(fetchedAt: now, error: denied, isStale: false, now: now),
    );

    await tester.tap(find.text('Otwórz ustawienia'));
    await tester.pump();

    expect(settings.opened, 1);
  });
}
