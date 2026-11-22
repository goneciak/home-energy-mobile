import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';
import 'package:gi_home/src/features/environment/presentation/weather_screen.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/pv_plan_card.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/environment_fixtures.dart';
import '../../support/test_app.dart';

final IanaScheduleZone warsaw = IanaScheduleZone.tryParse('Europe/Warsaw')!;

void main() {
  final l10n = lookupAppLocalizations(const Locale('pl'));

  List<Override> overrides(
    FakeEnvironmentSource source, {
    ScheduleZone? zone,
  }) => [
    environmentSourceProvider.overrideWithValue(source),
    houseZoneProvider.overrideWithValue(zone ?? warsaw),
    clockProvider.overrideWithValue(() => environmentNow),
  ];

  Future<void> pumpWeather(
    WidgetTester tester,
    FakeEnvironmentSource source, {
    ScheduleZone? zone,
  }) async {
    tester.view
      ..physicalSize = const Size(1200, 4000)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testScreen(
        const WeatherScreen(),
        overrides: overrides(source, zone: zone),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('WeatherScreen', () {
    testWidgets('200: now, hours in the home zone, days, sun and PV', (
      tester,
    ) async {
      await pumpWeather(tester, FakeEnvironmentSource.available());

      expect(find.text('3,4 °C'), findsOneWidget);
      expect(find.text(l10n.weatherGlyphPartlyCloudy), findsOneWidget);
      expect(find.text(l10n.weatherHumidity('86')), findsOneWidget);
      expect(find.byKey(const ValueKey('weather-stale')), findsNothing);
      // 11:00 UTC is 12:00 in Warsaw; the past hour is skipped.
      expect(find.bySemanticsLabel(RegExp('^12:00: ')), findsOneWidget);
      expect(
        find.text(l10n.weatherTimesHouseZone('Europe/Warsaw')),
        findsWidgets,
      );
      expect(find.byKey(const ValueKey('weather-daily')), findsOneWidget);
      expect(find.text(l10n.weatherDaysUtc), findsOneWidget);
      // Sun: 06:13 UTC → 07:13, 14:33 UTC → 15:33, 8 h 20 min.
      expect(find.text('07:13'), findsOneWidget);
      expect(find.text('15:33'), findsOneWidget);
      // PV: kWh per day and the peak at the house-local time, as it came.
      expect(find.text(l10n.pvForecastDayEnergy('9,8')), findsOneWidget);
      expect(find.text(l10n.pvForecastDayPeak('2,4', '12:00')), findsOneWidget);
      expect(find.text(l10n.pvHouseTimeNote), findsOneWidget);
    });

    testWidgets('the phone zone is named as such for a USER', (tester) async {
      await pumpWeather(
        tester,
        FakeEnvironmentSource.available(),
        zone: const PhoneScheduleZone(),
      );
      expect(find.text(l10n.weatherTimesPhoneZone), findsWidgets);
    });

    testWidgets('stale: a warning with the appliance reason', (tester) async {
      await pumpWeather(tester, FakeEnvironmentSource.available(stale: true));

      expect(find.byKey(const ValueKey('weather-stale')), findsOneWidget);
      expect(find.text(l10n.weatherStaleBanner), findsOneWidget);
      expect(
        find.text('Weather provider temporarily unavailable.'),
        findsOneWidget,
      );
      expect(find.text('3,4 °C'), findsOneWidget, reason: 'old data stays');
    });

    testWidgets('503: no weather data, not "GI Home unreachable"', (
      tester,
    ) async {
      await pumpWeather(tester, FakeEnvironmentSource());

      expect(find.byKey(const ValueKey('weather-no-data')), findsOneWidget);
      expect(find.text(l10n.weatherNoDataTitle), findsOneWidget);
      expect(find.text(l10n.errorUnreachable), findsNothing);
      expect(find.byKey(const ValueKey('weather-hourly')), findsNothing);
    });

    testWidgets('400: set the house location; the PV card is hidden', (
      tester,
    ) async {
      await pumpWeather(tester, FakeEnvironmentSource());

      expect(find.byKey(const ValueKey('solar-not-configured')), findsOne);
      expect(find.text(l10n.solarNotConfigured), findsOneWidget);
      expect(find.byKey(const ValueKey('pv-forecast-card')), findsNothing);
      expect(find.text(l10n.pvForecastSection), findsNothing);
    });

    testWidgets('PV 500: "no PV forecast" instead of a crash', (tester) async {
      await pumpWeather(
        tester,
        FakeEnvironmentSource(pv: const EnvironmentNoData()),
      );

      expect(find.byKey(const ValueKey('pv-forecast-no-data')), findsOne);
      expect(find.text(l10n.pvForecastNoDataTitle), findsOneWidget);
    });

    testWidgets('GI Home unreachable: the failure and "Spróbuj ponownie"', (
      tester,
    ) async {
      final source = FakeEnvironmentSource(
        weatherError: const ApiFailure.unreachable(),
      );
      await pumpWeather(tester, source);

      expect(find.text(l10n.errorUnreachable), findsOneWidget);
      final before = source.calls.where((c) => c == 'weatherCurrent').length;
      await tester.tap(find.text(l10n.actionRetry));
      await tester.pumpAndSettle();
      expect(
        source.calls.where((c) => c == 'weatherCurrent').length,
        before + 1,
      );
    });
  });

  group('PvPlanSection', () {
    Future<void> pumpPlan(
      WidgetTester tester,
      FakeEnvironmentSource source,
    ) async {
      tester.view
        ..physicalSize = const Size(1200, 4000)
        ..devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testScreen(
          const Scaffold(
            body: SingleChildScrollView(child: PvPlanSection(deviceId: 'd1')),
          ),
          overrides: overrides(source),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('DISABLED: one compact row', (tester) async {
      await pumpPlan(tester, FakeEnvironmentSource());
      expect(find.byKey(const ValueKey('pv-plan-disabled')), findsOneWidget);
      expect(find.text(l10n.pvPlanDisabled), findsOneWidget);
    });

    testWidgets('enabled without hours: no forecast, compact', (tester) async {
      await pumpPlan(
        tester,
        FakeEnvironmentSource(plan: activePlan().copyWith(hours: const [])),
      );
      expect(find.byKey(const ValueKey('pv-plan-no-hours')), findsOneWidget);
    });

    testWidgets('hours: targets, boosts at house-local times, show all', (
      tester,
    ) async {
      await pumpPlan(tester, FakeEnvironmentSource(plan: activePlan()));
      expect(find.text(l10n.pvPlanMode(l10n.pvModeHybrid)), findsOneWidget);
      expect(find.text(l10n.pvPlanBaseTarget('55,0')), findsOneWidget);
      expect(find.text(l10n.pvPlanSafeMax('65,0')), findsOneWidget);
      // 16 hours, 12 shown: 06:00-17:00; "12:00" is a boost, as it came.
      expect(
        find.bySemanticsLabel(
          l10n.pvPlanHourSemantics(
            '12:00',
            l10n.pvPlanProduction('2,6'),
            l10n.pvPlanBoost('65,0'),
          ),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('^21:00: ')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('pv-plan-toggle')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('^21:00: ')), findsOneWidget);
      expect(find.text(l10n.pvPlanShowLess), findsOneWidget);
    });

    testWidgets('a failed read offers a retry', (tester) async {
      final source = FakeEnvironmentSource(
        planError: const ApiFailure.unreachable(),
      );
      await pumpPlan(tester, source);
      expect(find.byKey(const ValueKey('pv-plan-failed')), findsOneWidget);
      await tester.tap(find.byTooltip(l10n.actionRetry));
      await tester.pumpAndSettle();
      expect(source.calls.where((c) => c == 'pvHeatingPlan'), hasLength(2));
    });
  });
}
