import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/config/config_providers.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/stale_app_policy.dart';
import 'package:gi_home/src/features/diagnostics/presentation/stale_app_banner.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';

void main() {
  UnexpectedShapeFailure shape(String endpointId) =>
      UnexpectedShapeFailure(endpointId: endpointId);

  group('StaleAppPolicy (plan §16 point 4)', () {
    test('the key endpoints of the MVP', () {
      expect(StaleAppPolicy.keyEndpoints, {
        'AuthController_getMe',
        'DevicesController_list',
        'DevicesController_get',
        'SetupController_getStatus',
      });
    });

    test('3 unexpected shapes on one key endpoint suggest an update', () {
      expect(
        StaleAppPolicy.suggestsUpdate({'DevicesController_list': 2}),
        isFalse,
      );
      expect(
        StaleAppPolicy.suggestsUpdate({'DevicesController_list': 3}),
        isTrue,
      );
      // Spread over endpoints, or on endpoints outside the MVP core: no.
      expect(
        StaleAppPolicy.suggestsUpdate({
          'DevicesController_list': 2,
          'DevicesController_get': 2,
          'AuthController_getMe': 2,
        }),
        isFalse,
      );
      expect(
        StaleAppPolicy.suggestsUpdate({'RoomsController_list': 10}),
        isFalse,
      );
    });
  });

  group('DiagnosticsService.updateSuggested', () {
    test('turns on at the third unexpected shape of a key endpoint', () {
      final diagnostics = DiagnosticsService();
      var notified = 0;
      diagnostics.updateSuggested.addListener(() => notified++);

      diagnostics
        ..recordFailure(shape('DevicesController_get'))
        ..recordFailure(shape('DevicesController_get'))
        ..recordFailure(shape('RoomsController_list'))
        ..recordFailure(const ApiFailure.timeout());
      expect(diagnostics.updateSuggested.value, isFalse);

      diagnostics.recordFailure(shape('DevicesController_get'));
      expect(diagnostics.updateSuggested.value, isTrue);
      expect(notified, 1);
      expect(diagnostics.sessionUnexpectedShape, {
        'DevicesController_get': 3,
        'RoomsController_list': 1,
      });
    });

    test('counts this app session: a logout does not reset it', () async {
      final diagnostics = DiagnosticsService()
        ..recordFailure(shape('AuthController_getMe'))
        ..recordFailure(shape('AuthController_getMe'));
      await diagnostics.clear();
      expect(diagnostics.counters.unexpectedShape, isEmpty);

      diagnostics.recordFailure(shape('AuthController_getMe'));
      expect(diagnostics.updateSuggested.value, isTrue);
    });
  });

  group('StaleAppBanner', () {
    late DiagnosticsService diagnostics;
    late List<Uri> opened;

    setUp(() {
      diagnostics = DiagnosticsService();
      opened = [];
    });

    Future<void> pumpApp(WidgetTester tester, {AppConfig? config}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosticsServiceProvider.overrideWithValue(diagnostics),
            externalUrlOpenerProvider.overrideWithValue((url) async {
              opened.add(url);
              return true;
            }),
            if (config != null) appConfigProvider.overrideWithValue(config),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: const Locale('pl'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => StaleAppBannerHost(child: child!),
            home: Scaffold(
              appBar: AppBar(title: const Text('Dom')),
              body: const Center(child: Text('Ekran')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> record(WidgetTester tester, int times) async {
      for (var i = 0; i < times; i++) {
        diagnostics.recordFailure(shape('DevicesController_list'));
      }
      await tester.pumpAndSettle();
    }

    final banner = find.byKey(const ValueKey('stale-app-banner'));

    testWidgets('2 unexpected shapes show nothing; the third does', (
      tester,
    ) async {
      await pumpApp(tester);

      await record(tester, 2);
      expect(banner, findsNothing);
      expect(find.text('Zaktualizuj aplikację'), findsNothing);

      await record(tester, 1);
      expect(banner, findsOneWidget);
      expect(find.text('Zaktualizuj aplikację'), findsOneWidget);
      // Non-blocking: the screen stays usable below the banner.
      expect(find.text('Ekran'), findsOneWidget);
      expect(
        tester.getBottomLeft(banner).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(AppBar)).dy),
      );
    });

    testWidgets('without a store link it shows the text only', (tester) async {
      await pumpApp(tester);
      await record(tester, 3);

      expect(find.byKey(const ValueKey('stale-app-open-store')), findsNothing);
      expect(find.text('Otwórz sklep'), findsNothing);
      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('with a store link it opens the store', (tester) async {
      final store = Uri.parse(
        'https://play.google.com/store/apps/details?id=pl.gi.home',
      );
      await pumpApp(
        tester,
        config: AppConfig(
          flavor: AppFlavor.prod,
          flagDefaults: FeatureFlags.allOff,
          androidStoreUrl: store,
          iosStoreUrl: store,
        ),
      );
      await record(tester, 3);

      await tester.tap(find.text('Otwórz sklep'));
      expect(opened, [store]);
      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('can be hidden for the rest of the session', (tester) async {
      await pumpApp(tester);
      await record(tester, 3);

      await tester.tap(find.text('Ukryj komunikat'));
      await tester.pumpAndSettle();
      expect(banner, findsNothing);

      await record(tester, 3);
      expect(banner, findsNothing);
      expect(find.text('Ekran'), findsOneWidget);
    });
  });
}
