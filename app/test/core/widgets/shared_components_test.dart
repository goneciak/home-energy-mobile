import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_label.dart';
import 'package:gi_home/src/core/widgets/gi_badge.dart';
import 'package:gi_home/src/core/widgets/permission_state.dart';
import 'package:gi_home/src/core/widgets/skeleton.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/accessibility.dart';
import '../../support/test_app.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      testScreen(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: Scaffold(body: Center(child: child)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Skeleton', () {
    const blocks = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBlock(width: 120),
        SizedBox(height: 8),
        SkeletonBlock.card(height: 80),
      ],
    );

    testWidgets('is read as a single "Ładowanie…"', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const SizedBox(width: 300, child: Skeleton(child: blocks)),
      );

      expect(
        tester.getSemantics(find.byType(Skeleton)),
        matchesSemantics(label: 'Ładowanie…'),
      );
      expect(find.bySemanticsLabel('Ładowanie…'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('fades gently, without a shimmer', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 300, child: Skeleton(child: blocks)),
      );
      double opacity() =>
          tester.widget<FadeTransition>(_skeletonFade).opacity.value;

      expect(opacity(), 1);
      await tester.pump(Skeleton.period ~/ 2);
      expect(opacity(), lessThan(1));
      expect(opacity(), greaterThanOrEqualTo(Skeleton.minOpacity));
      expect(tester.hasRunningAnimations, isTrue);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('stands still with reduced motion', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 300, child: Skeleton(child: blocks)),
        reduceMotion: true,
      );

      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(_skeletonFade).opacity.value, 1);
    });

    testWidgets('blocks use the raised surface token', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 300, child: Skeleton(child: blocks)),
      );

      final decorations = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(SkeletonBlock),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => box.decoration as BoxDecoration);
      expect(decorations.map((d) => d.color).toSet(), {
        GiTokens.dark.surfaceRaised,
      });
      // A line is a pill; a card has the card radius.
      expect(decorations.map((d) => d.borderRadius), [
        BorderRadius.circular(7),
        BorderRadius.circular(GiTokens.dark.radius),
      ]);
    });
  });

  group('GiBadge', () {
    testWidgets('shows a count, capped at 99+', (tester) async {
      await pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GiBadge.count(3, semanticLabel: '3 usterki'),
            GiBadge.count(120, semanticLabel: '120 usterek'),
            GiBadge.count(12, semanticLabel: '12', max: 9),
          ],
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('is read by its semantic label, not its text', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const GiBadge(
          text: 'Nowe',
          semanticLabel: 'Nowa wersja GI Home',
          tone: StatusTone.info,
        ),
      );

      expect(
        tester.getSemantics(find.byType(GiBadge)),
        matchesSemantics(label: 'Nowa wersja GI Home'),
      );
      expect(find.bySemanticsLabel('Nowe'), findsNothing);
      handle.dispose();
    });

    testWidgets('every tone keeps readable text', (tester) async {
      await pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tone in StatusTone.values)
              GiBadge(text: '7', semanticLabel: tone.name, tone: tone),
          ],
        ),
      );

      await expectAccessibilityGuidelines(tester);
    });
  });

  group('FreshnessLabel', () {
    final now = DateTime.utc(2026, 11, 18, 7, 41);

    testWidgets('says how old the value is', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        FreshnessLabel(
          updatedAt: now.subtract(const Duration(minutes: 2)),
          now: now,
        ),
      );

      expect(find.text('2 min temu'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(FreshnessLabel)),
        matchesSemantics(label: 'Zaktualizowano 2 min temu'),
      );
      handle.dispose();
    });

    testWidgets('a stale value says so in words, not only with colour', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        FreshnessLabel(
          updatedAt: now.subtract(const Duration(minutes: 5)),
          now: now,
          isStale: true,
        ),
      );

      expect(find.byIcon(Icons.history_toggle_off), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(FreshnessLabel)),
        matchesSemantics(
          label: 'Zaktualizowano 5 min temu, dane mogą być nieaktualne',
        ),
      );
      handle.dispose();
    });

    testWidgets('a value that never arrived waits for the first reading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, FreshnessLabel(updatedAt: null, now: now));

      expect(find.text('Czekamy na pierwszy odczyt'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(FreshnessLabel)),
        matchesSemantics(label: 'Czekamy na pierwszy odczyt'),
      );
      await expectAccessibilityGuidelines(tester);
      handle.dispose();
    });
  });

  group('PermissionState', () {
    testWidgets('explains the missing access and offers no retry', (
      tester,
    ) async {
      var closed = 0;
      await pump(
        tester,
        SingleChildScrollView(
          child: PermissionState(
            error: const ApiFailure.forbidden(
              code: 'HTTP_403',
              envelope: ApiErrorEnvelope(
                code: 'HTTP_403',
                statusCode: 403,
                message: 'Forbidden resource',
                requestId: 'req-403',
              ),
            ),
            action: OutlinedButton(
              onPressed: () => closed++,
              child: const Text('Zamknij'),
            ),
          ),
        ),
      );

      expect(find.text('Brak dostępu'), findsOneWidget);
      expect(find.textContaining('Twoja rola w GI Home'), findsOneWidget);
      expect(find.textContaining('req-403'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Spróbuj ponownie'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);

      await tester.tap(find.text('Zamknij'));
      expect(closed, 1);
      await expectAccessibilityGuidelines(tester);
    });

    testWidgets('is announced as a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const PermissionState());

      expect(
        find.semantics.byPredicate(
          (node) => node.getSemanticsData().flagsCollection.isLiveRegion,
          describeMatch: (plurality) => 'live regions',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('Brak dostępu')), findsOneWidget);
      handle.dispose();
    });
  });
}

final Finder _skeletonFade = find.descendant(
  of: find.byType(Skeleton),
  matching: find.byType(FadeTransition),
);
