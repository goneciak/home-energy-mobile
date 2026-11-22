import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/environment/data/environment_source.dart';

/// "Now" of the environment fixtures: Sunday 2026-11-22, 11:30 UTC
/// (12:30 in Warsaw).
final environmentNow = DateTime.utc(2026, 11, 22, 11, 30);

/// One canned answer per environment read: a value, a "no data" result or
/// a failure to throw.
class FakeEnvironmentSource implements EnvironmentSource {
  new({
    this.current = const EnvironmentNoData(),
    this.hourly = const EnvironmentNoData(),
    this.daily = const EnvironmentNoData(),
    this.solar = const EnvironmentNotConfigured(),
    this.pv = const EnvironmentNotConfigured(),
    PvHeatingPlan? plan,
    this.weatherError,
    this.planError,
  }) : plan = plan ?? disabledPlan();

  /// Everything the appliance can show.
  factory available({bool stale = false}) => FakeEnvironmentSource(
    current: EnvironmentAvailable(currentWeather(stale: stale)),
    hourly: EnvironmentAvailable(hourlyWeather(stale: stale)),
    daily: EnvironmentAvailable(dailyWeather(stale: stale)),
    solar: EnvironmentAvailable(solarStatusFixture()),
    pv: EnvironmentAvailable(pvForecastFixture()),
    plan: activePlan(),
  );

  final EnvironmentResult<WeatherEnvelope<CurrentWeather>> current;
  final EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>> hourly;
  final EnvironmentResult<WeatherEnvelope<List<DailyWeather>>> daily;
  final EnvironmentResult<SolarStatus> solar;
  final EnvironmentResult<PvForecast> pv;
  final PvHeatingPlan plan;

  /// Thrown by every weather read when set.
  final ApiFailure? weatherError;

  /// Thrown by the plan read when set.
  final ApiFailure? planError;

  final List<String> calls = [];

  Future<T> _answer<T>(String name, T value, [ApiFailure? error]) async {
    calls.add(name);
    if (error != null) throw error;
    return value;
  }

  @override
  Future<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> weatherCurrent() =>
      _answer('weatherCurrent', current, weatherError);

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
  weatherHourly() => _answer('weatherHourly', hourly, weatherError);

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
  weatherDaily() => _answer('weatherDaily', daily, weatherError);

  @override
  Future<EnvironmentResult<SolarStatus>> solarCurrent() =>
      _answer('solarCurrent', solar);

  @override
  Future<EnvironmentResult<PvForecast>> pvForecast() =>
      _answer('pvForecast', pv);

  @override
  Future<PvHeatingPlan> pvHeatingPlan(String deviceId) =>
      _answer('pvHeatingPlan', plan, planError);
}

const _staleError = 'Weather provider temporarily unavailable.';

WeatherEnvelope<T> _envelope<T>(T data, {required bool stale}) =>
    WeatherEnvelope(
      data: data,
      fetchedAt: stale
          ? environmentNow.subtract(const Duration(hours: 3))
          : environmentNow.subtract(const Duration(minutes: 12)),
      stale: stale,
      lastError: stale ? _staleError : null,
    );

WeatherEnvelope<CurrentWeather> currentWeather({bool stale = false}) =>
    _envelope(
      const CurrentWeather(
        temperatureC: 3.4,
        apparentTemperatureC: 3.4,
        relativeHumidityPercent: 86,
        pressureHpa: 1014.2,
        windSpeedMps: 4.1,
        symbolCode: 'partlycloudy_day',
        precipitationMm: 0,
      ),
      stale: stale,
    );

const _hourSymbols = [
  'cloudy',
  'partlycloudy_day',
  'lightrain',
  'clearsky_night',
  'fog',
  'snow',
];

WeatherEnvelope<List<HourlyWeather>> hourlyWeather({bool stale = false}) =>
    _envelope([
      for (var i = 0; i < 30; i++)
        HourlyWeather(
          time: DateTime.utc(2026, 11, 22, 11 + i),
          temperatureC: 3.0 + (i % 5) - 2,
          precipitationMm: i.isEven ? 0 : 0.3,
          symbolCode: _hourSymbols[i % _hourSymbols.length],
        ),
    ], stale: stale);

WeatherEnvelope<List<DailyWeather>> dailyWeather({bool stale = false}) =>
    _envelope([
      const DailyWeather(
        date: LocalWallTime(2026, 11, 22),
        minimumTemperatureC: -1.5,
        maximumTemperatureC: 4,
        precipitationMm: 1.2,
        symbolCode: 'rain',
      ),
      const DailyWeather(
        date: LocalWallTime(2026, 11, 23),
        minimumTemperatureC: -3,
        maximumTemperatureC: 2.5,
        symbolCode: 'clearsky_day',
      ),
      const DailyWeather(
        date: LocalWallTime(2026, 11, 24),
        minimumTemperatureC: 0,
        maximumTemperatureC: 5.5,
        precipitationMm: 4,
        symbolCode: 'heavysnowshowersandthunder',
      ),
    ], stale: stale);

SolarStatus solarStatusFixture() => SolarStatus(
  currentElevationDegrees: 16.4,
  currentAzimuthDegrees: 182,
  aboveHorizon: true,
  sunrise: DateTime.utc(2026, 11, 22, 6, 13),
  sunset: DateTime.utc(2026, 11, 22, 14, 33),
  dayLengthSeconds: 8 * 3600 + 20 * 60,
);

PvForecast pvForecastFixture() => PvForecast(
  peakPowerKw: 6.5,
  hourly: [
    for (final (day, kw) in [(22, 2.4), (23, 3.1)])
      for (var hour = 8; hour <= 15; hour++)
        PvForecastHour(
          time: LocalWallTime(2026, 11, day, hour),
          estimatedProductionKw: hour == 12 ? kw : kw / 3,
        ),
  ],
  daily: [
    const PvForecastDay(
      date: LocalWallTime(2026, 11, 22),
      estimatedProductionKwh: 9.8,
    ),
    const PvForecastDay(
      date: LocalWallTime(2026, 11, 23),
      estimatedProductionKwh: 12.4,
    ),
  ],
);

/// The plan of a device without PV heating (what the contract stack has).
PvHeatingPlan disabledPlan({String deviceId = 'd1'}) => PvHeatingPlan(
  deviceId: deviceId,
  generatedAt: environmentNow,
  safeMaxTemperatureCelsius: 60,
  baseTargetCelsius: 55,
  mode: PvControlMode.disabled,
);

/// A hybrid plan with 16 hours, boosting around noon.
PvHeatingPlan activePlan({String deviceId = 'd1'}) => PvHeatingPlan(
  deviceId: deviceId,
  generatedAt: environmentNow,
  safeMaxTemperatureCelsius: 65,
  baseTargetCelsius: 55,
  mode: PvControlMode.hybrid,
  hours: [
    for (var hour = 6; hour < 22; hour++)
      PvHeatingPlanHour(
        time: LocalWallTime(2026, 11, 22, hour),
        estimatedProductionKw: hour < 8 || hour > 15 ? 0 : 2.6,
        forecastFavorable: hour >= 11 && hour <= 13,
        predictedBoostActive: hour >= 11 && hour <= 13,
        predictedTargetCelsius: hour >= 11 && hour <= 13 ? 65 : 55,
      ),
  ],
);
