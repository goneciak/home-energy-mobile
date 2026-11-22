import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/app/gi_home_app.dart';
import 'package:gi_home/src/app/router/app_router.dart';
import 'package:gi_home/src/app/router/route_guard.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/widgets/hold_to_confirm_button.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/connection_ladder.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/appliance/data/host_resolver.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/test_app.dart';
import 'demo_core_test.dart' show boilerId, demoFixtures, light;

class _NoSecureStorage extends Mock implements FlutterSecureStorage;

/// The whole demo through the real app, providers and router (plan §19.5):
/// connect → demo → home → switch → suspend → resume → exit. Only the
/// clock, the fixture loader and the platform are replaced; the demo's own
/// transport is the one under test.
void main() {
  final l10n = lookupAppLocalizations(const Locale('pl'));
  late DateTime now;
  late _NoSecureStorage secureStorage;
  late Directory reportRoot;

  setUp(() {
    now = DateTime.utc(2026, 11, 20, 8);
    secureStorage = _NoSecureStorage();
    reportRoot = Directory.systemTemp.createTempSync('gi-demo-');
    addTearDown(() => reportRoot.deleteSync(recursive: true));
  });

  Future<(ProviderContainer, SharedPreferencesWithCache)> pumpApp(
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('pl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1200, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final prefs = (await tester.runAsync(inMemoryPreferences))!;
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appInfoProvider.overrideWithValue(testAppInfo),
          secureStorageProvider.overrideWithValue(secureStorage),
          clockProvider.overrideWithValue(() => now),
          demoFixturesLoaderProvider.overrideWithValue(
            () async => demoFixtures(),
          ),
          reportDirectoryProvider.overrideWithValue(() async => reportRoot),
          hostResolverProvider.overrideWithValue(const StaticHostResolver({})),
        ],
        child: const GiHomeApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(GiHomeApp)),
    );
    return (container, prefs);
  }

  /// Lets [duration] pass on the demo's clock and the test's timers.
  Future<void> advance(WidgetTester tester, Duration duration) async {
    now = now.add(duration);
    await tester.pump(duration);
    await tester.pump();
  }

  /// Advances a second at a time until [finder] matches (or, with [gone],
  /// stops matching).
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    bool gone = false,
  }) async {
    for (var i = 0; i < 30; i++) {
      if (finder.evaluate().isEmpty == gone) return;
      await advance(tester, const Duration(seconds: 1));
    }
    fail('Timed out waiting for $finder (gone: $gone)');
  }

  Finder inLight(Finder finder) => find.descendant(
    of: find.byKey(const ValueKey('switch-control-$light')),
    matching: finder,
  );

  testWidgets('the connect screen offers the demo visibly', (tester) async {
    await pumpApp(tester);

    expect(find.text(l10n.connectTitle), findsOneWidget);
    final entry = find.byKey(const ValueKey('demo-enter'));
    expect(entry, findsOneWidget);
    expect(
      find.descendant(of: entry, matching: find.text(l10n.demoEnter)),
      findsOneWidget,
    );
    expect(find.text('Wypróbuj wersję demonstracyjną'), findsOneWidget);
    expect(find.byKey(const ValueKey('demo-banner')), findsNothing);
  });

  testWidgets('connect → demo → home → switch → suspend → resume → exit', (
    tester,
  ) async {
    final (container, prefs) = await pumpApp(tester);

    // Enter the demo: the stored demo session restores straight to Home.
    await tester.ensureVisible(find.byKey(const ValueKey('demo-enter')));
    await tester.tap(find.byKey(const ValueKey('demo-enter')));
    await waitFor(tester, find.text('Sterownik kotłowni'));
    expect(find.byKey(const ValueKey('demo-banner')), findsOneWidget);
    expect(find.text(l10n.demoBannerMessage), findsOneWidget);
    expect(find.text(l10n.navHome), findsWidgets);
    expect(
      container.read(routeGuardStateProvider).session,
      SessionPhase.signedIn,
    );

    // Details of the heating controller.
    container.read(goRouterProvider).go(AppRoutes.device(boilerId));
    await waitFor(tester, find.byKey(const ValueKey('heating-control-panel')));

    // Switch the boiler-room light: confirmed sheet, then the heartbeat.
    final toggle = inLight(find.byKey(const ValueKey('switch-toggle')));
    await tester.dragUntilVisible(
      toggle,
      find.byType(Scrollable).hitTestable().first,
      const Offset(0, -200),
    );
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text(l10n.consequenceCommandNotPhysicallyVerified), findsOne);
    await tester.tap(find.text(l10n.switchConfirmSend));
    await waitFor(
      tester,
      inLight(find.byKey(const ValueKey('switch-awaiting'))),
    );
    await waitFor(
      tester,
      inLight(find.byKey(const ValueKey('switch-awaiting'))),
      gone: true,
    );
    expect(inLight(find.text(l10n.entityValueOn)), findsWidgets);

    // Hold to suspend.
    final hold = find.byKey(const ValueKey('heating-suspend-hold'));
    await tester.dragUntilVisible(
      hold,
      find.byType(Scrollable).hitTestable().first,
      const Offset(0, 200),
    );
    await tester.ensureVisible(hold);
    await tester.pumpAndSettle();
    final holdArea = find.descendant(
      of: hold,
      matching: find.byType(GestureDetector),
    );
    final gesture = await tester.startGesture(tester.getCenter(holdArea));
    await tester.pump(const Duration(milliseconds: 150));
    for (var i = 0; i < 4; i++) {
      await tester.pump(HoldToConfirmButton.defaultHoldDuration ~/ 3);
    }
    await gesture.up();
    final resume = find.byKey(const ValueKey('heating-resume'));
    await waitFor(tester, resume);
    final demo = container.read(demoModeProvider)!;
    expect(demo.core.deviceDetail(boilerId)!['heatingSuspended'], isTrue);
    final suspended = demo.core.deviceDetail(boilerId)!;
    expect((suspended['controlStrategy']! as Map)['mode'], 'OFF');

    // Resume with the consequence sheet.
    await tester.ensureVisible(resume);
    await tester.pumpAndSettle();
    await tester.tap(resume);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('resume-confirm')));
    await waitFor(tester, hold);
    final resumed = demo.core.deviceDetail(boilerId)!;
    expect(resumed['heatingSuspended'], isFalse);
    expect((resumed['controlStrategy']! as Map)['mode'], 'AUTO');

    // Exit: back to the connect screen, nothing of the demo kept.
    await tester.tap(find.byKey(const ValueKey('demo-exit')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.connectTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('demo-banner')), findsNothing);
    expect(container.read(demoModeProvider), isNull);
    expect(container.read(applianceProfileProvider), isNull);
    expect(ApplianceProfileStore(prefs).read(), isNull);
    verifyZeroInteractions(secureStorage);
  });

  testWidgets('demo: account screens, recovery code and logout-all (plan '
      'M3.5)', (tester) async {
    final (container, _) = await pumpApp(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('demo-enter')));
    await tester.tap(find.byKey(const ValueKey('demo-enter')));
    await waitFor(tester, find.text('Sterownik kotłowni'));

    container.read(goRouterProvider).go(AppRoutes.accountSessions);
    await waitFor(tester, find.text(l10n.sessionsThisPhone));

    container.read(goRouterProvider).go(AppRoutes.accountRecoveryCode);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recovery-code-generate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recovery-code-confirm')));
    await waitFor(tester, find.byKey(const ValueKey('recovery-code-value')));
    await tester.tap(find.byKey(const ValueKey('recovery-code-acknowledge')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recovery-code-done')));
    await tester.pumpAndSettle();

    container.read(goRouterProvider).go(AppRoutes.accountSessions);
    await waitFor(tester, find.text(l10n.sessionsThisPhone));
    final logoutAll = find.byKey(const ValueKey('sessions-logout-all'));
    await tester.ensureVisible(logoutAll);
    await tester.pumpAndSettle();
    await tester.tap(logoutAll);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sessions-confirm')));
    await tester.pumpAndSettle();

    // Logging out of every device ends the demo.
    expect(container.read(demoModeProvider), isNull);
  });
}
