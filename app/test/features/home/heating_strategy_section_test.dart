import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/home/presentation/widgets/heating_strategy_section.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fixtures.dart';
import '../../support/test_app.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  const owner = HeatingPermission(
    canSwitch: true,
    canSuspend: true,
    canEditStrategy: true,
  );
  const viewer = HeatingPermission(
    canSwitch: false,
    canSuspend: false,
    canEditStrategy: false,
  );

  Map<String, Object?> strategy(num target, num hysteresis, String mode) => {
    'targetTemperatureCelsius': target,
    'hysteresisCelsius': hysteresis,
    'mode': mode,
  };

  Future<void> pump(
    WidgetTester tester, {
    Map<String, Object?> overrides = const {},
    HeatingPermission permission = owner,
    bool faultLatched = false,
    VoidCallback? onResume,
  }) async {
    await tester.pumpWidget(
      testScreen(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HeatingStrategySection(
                detail: Fetched(
                  fixtureDetail({
                    'controlStrategy': strategy(55, 4, 'AUTO'),
                    'baseControlStrategy': strategy(55, 4, 'AUTO'),
                    'dryRun': false,
                    ...overrides,
                  }),
                  now,
                ),
                permission: permission,
                faultLatched: faultLatched,
                now: now,
                onResume: onResume,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  testWidgets('base only: effective strategy, mode and source', (tester) async {
    await pump(tester);
    expect(find.text('Cel 55,0 °C, histereza 4,0 °C'), findsOneWidget);
    expect(find.text('GI Home steruje kotłem'), findsOneWidget);
    expect(key('heating-schedule-active'), findsNothing);
    expect(key('heating-suspended-banner'), findsNothing);
    expect(key('heating-pv-boost'), findsNothing);
    expect(key('heating-dry-run-banner'), findsNothing);
    expect(key('heating-fault-latched'), findsNothing);
    expect(key('heating-strategy-source'), findsOneWidget);
    expect(find.textContaining('Według GI Home · dane z'), findsOneWidget);
  });

  testWidgets('every mode has its description', (tester) async {
    for (final (mode, text) in [
      ('OFF', 'Sterowanie wyłączone – GI Home nie będzie włączać kotła'),
      ('MANUAL', 'GI Home nie steruje automatycznie'),
      ('BOOST', 'Nieznany tryb sterowania'),
    ]) {
      await pump(tester, overrides: {'controlStrategy': strategy(55, 4, mode)});
      expect(find.text(text), findsOneWidget, reason: mode);
    }
  });

  testWidgets('schedule active: effective value plus the default', (
    tester,
  ) async {
    await pump(
      tester,
      overrides: {'controlStrategy': strategy(21, 0.5, 'AUTO')},
    );
    expect(find.text('Cel 21,0 °C, histereza 0,5 °C'), findsOneWidget);
    expect(find.text('Harmonogram aktywny'), findsOneWidget);
    expect(
      find.text('Ustawienie domyślne: 55,0 °C, histereza 4,0 °C'),
      findsOneWidget,
    );
  });

  testWidgets('mode OFF alone is not a schedule', (tester) async {
    await pump(tester, overrides: {'controlStrategy': strategy(55, 4, 'OFF')});
    expect(find.text('Harmonogram aktywny'), findsNothing);
  });

  testWidgets('suspended: prominent, mode OFF ignored, resume for owner', (
    tester,
  ) async {
    var resumed = 0;
    await pump(
      tester,
      overrides: {
        'heatingSuspended': true,
        'controlStrategy': strategy(21, 4, 'OFF'),
      },
      onResume: () => resumed++,
    );
    expect(find.text('Ogrzewanie wstrzymane'), findsOneWidget);
    expect(find.textContaining('nie włączy kotła'), findsOneWidget);
    expect(find.text('Harmonogram aktywny'), findsNothing);
    expect(
      find.text('Sterowanie wyłączone – GI Home nie będzie włączać kotła'),
      findsNothing,
    );
    await tester.tap(key('heating-resume'));
    expect(resumed, 1);
  });

  testWidgets('suspended, owner without a resume action: points to details', (
    tester,
  ) async {
    await pump(tester, overrides: {'heatingSuspended': true});
    expect(key('heating-resume'), findsNothing);
    expect(find.textContaining('otwórz szczegóły urządzenia'), findsOneWidget);
  });

  testWidgets('suspended, USER view: no resume, ask the owner', (tester) async {
    await pump(
      tester,
      overrides: {'heatingSuspended': true},
      permission: viewer,
      onResume: () {},
    );
    expect(key('heating-resume'), findsNothing);
    expect(
      find.textContaining('może właściciel lub administrator'),
      findsOneWidget,
    );
  });

  testWidgets('PV boost with configuration: derived target', (tester) async {
    await pump(
      tester,
      overrides: {
        'pvBoostActive': true,
        'pvHeatingConfig': {'mode': 'HYBRID', 'safeMaxTemperatureCelsius': 75},
      },
    );
    expect(find.text('Dogrzewanie z PV: grzanie do 75,0 °C'), findsOneWidget);
    expect(
      find.text('Cel wyliczony z limitu bezpieczeństwa PV'),
      findsOneWidget,
    );
  });

  testWidgets('PV boost without configuration: unknown target', (tester) async {
    await pump(tester, overrides: {'pvBoostActive': true});
    expect(
      find.text('Dogrzewanie z PV aktywne – cel nieznany'),
      findsOneWidget,
    );
  });

  testWidgets('dry-run banner and latched fault', (tester) async {
    await pump(tester, overrides: {'dryRun': true}, faultLatched: true);
    expect(
      find.text('Tryb testowy: przekaźniki nie przełączają się fizycznie'),
      findsOneWidget,
    );
    expect(key('heating-fault-latched'), findsOneWidget);
    expect(
      find.textContaining('ręcznego resetu na urządzeniu'),
      findsOneWidget,
    );
  });

  testWidgets('no strategies', (tester) async {
    await pump(
      tester,
      overrides: {'controlStrategy': null, 'baseControlStrategy': null},
    );
    expect(key('heating-strategy-none'), findsOneWidget);
    expect(key('heating-strategy'), findsNothing);
  });

  test('English strings exist', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.heatingScheduleActive, 'Schedule active');
    expect(en.heatingSuspendedTitle, 'Heating suspended');
  });
}
