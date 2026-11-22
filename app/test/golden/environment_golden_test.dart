@Tags(['golden'])
library;

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';
import 'package:gi_home/src/features/environment/data/environment_source.dart';
import 'package:gi_home/src/features/environment/presentation/weather_screen.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/pv_plan_card.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:material_ui/material_ui.dart';

import '../features/demo/demo_core_test.dart' show boilerId, demoFixtures;
import '../support/environment_fixtures.dart';
import '../support/golden.dart';

/// Weather, sun, PV forecast and PV plan (plan §4.2, G3): every honest
/// state of the cards. The app has one (dark) theme (D11), so there is no
/// light variant.
void main() {
  final warsaw = IanaScheduleZone.tryParse('Europe/Warsaw')!;

  List<Override> overrides(EnvironmentSource source, {DateTime? now}) => [
    environmentSourceProvider.overrideWithValue(source),
    houseZoneProvider.overrideWithValue(warsaw),
    clockProvider.overrideWithValue(() => now ?? environmentNow),
  ];

  const phones = [GoldenDevice.smallPhone, GoldenDevice.largePhone];

  screenGoldens(
    'Weather: everything available',
    fileName: 'weather_available',
    screen: () => const WeatherScreen(),
    overrides: () => overrides(FakeEnvironmentSource.available()),
  );

  screenGoldens(
    'Weather: stale forecast',
    fileName: 'weather_stale',
    devices: phones,
    screen: () => const WeatherScreen(),
    overrides: () => overrides(FakeEnvironmentSource.available(stale: true)),
  );

  screenGoldens(
    'Weather: 503 no data, solar 400, PV hidden',
    fileName: 'weather_no_data',
    devices: phones,
    screen: () => const WeatherScreen(),
    overrides: () => overrides(FakeEnvironmentSource()),
  );

  screenGoldens(
    'Weather: PV forecast 500, GI Home unreachable for weather',
    fileName: 'weather_failures',
    devices: phones,
    screen: () => const WeatherScreen(),
    overrides: () => overrides(
      FakeEnvironmentSource(
        weatherError: const ApiFailure.unreachable(),
        solar: EnvironmentAvailable(solarStatusFixture()),
        pv: const EnvironmentNoData(),
      ),
    ),
  );

  screenGoldens(
    'PV plan: disabled and with hours',
    fileName: 'pv_plan',
    devices: phones,
    screen: () => const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PvPlanSection(deviceId: 'off'),
            PvPlanSection(deviceId: 'd1'),
          ],
        ),
      ),
    ),
    overrides: () => overrides(_PerDevicePlans()),
  );

  // Demo mode (plan §19.5): the screen fed by the demo appliance's data.
  final demoNow = DateTime.utc(2026, 11, 22, 11, 30);
  screenGoldens(
    'Weather: demo mode',
    fileName: 'weather_demo',
    devices: phones,
    screen: () => const WeatherScreen(),
    overrides: () => overrides(
      _DemoEnvironmentSource(
        DemoCore.fromJsonString(demoFixtures(), now: () => demoNow),
      ),
      now: demoNow,
    ),
  );
}

/// Device `off` has PV heating disabled, every other the active plan.
final class _PerDevicePlans extends FakeEnvironmentSource {
  new() : super(plan: activePlan());

  @override
  Future<PvHeatingPlan> pvHeatingPlan(String deviceId) async =>
      deviceId == 'off' ? disabledPlan(deviceId: 'off') : activePlan();
}

/// Environment reads answered by the demo appliance in memory.
final class _DemoEnvironmentSource implements EnvironmentSource {
  new(this._core);

  final DemoCore _core;

  Map<String, Object?> _get(String path) =>
      _core.handle('GET', '/api/v1$path', null).body! as Map<String, Object?>;

  WeatherEnvelope<T> _weather<T>(
    String path,
    T Function(Object? json) decode,
  ) => WeatherEnvelope.fromJson(_get(path), decode);

  @override
  Future<EnvironmentResult<WeatherEnvelope<CurrentWeather>>>
  weatherCurrent() async => EnvironmentAvailable(
    _weather(
      '/weather/current',
      (json) => CurrentWeather.fromJson(json! as Map<String, Object?>),
    ),
  );

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
  weatherHourly() async => EnvironmentAvailable(
    _weather(
      '/weather/hourly',
      (json) => [
        for (final row in json! as List<Object?>)
          HourlyWeather.fromJson(row! as Map<String, Object?>),
      ],
    ),
  );

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
  weatherDaily() async => EnvironmentAvailable(
    _weather(
      '/weather/daily',
      (json) => [
        for (final row in json! as List<Object?>)
          DailyWeather.fromJson(row! as Map<String, Object?>),
      ],
    ),
  );

  @override
  Future<EnvironmentResult<SolarStatus>> solarCurrent() async =>
      EnvironmentAvailable(SolarStatus.fromJson(_get('/solar/current')));

  @override
  Future<EnvironmentResult<PvForecast>> pvForecast() async =>
      EnvironmentAvailable(PvForecast.fromJson(_get('/pv/forecast')));

  @override
  Future<PvHeatingPlan> pvHeatingPlan(String deviceId) async =>
      PvHeatingPlan.fromJson(_get('/devices/$boilerId/pv-heating-plan'));
}
