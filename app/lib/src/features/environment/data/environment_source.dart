import 'package:gi_core_api/gi_core_api.dart';

/// Weather, sun, PV forecast and PV heating plan reads (plan §4.2). The
/// "no data" answers (weather 503, solar and PV 400, PV 500) come back as
/// [EnvironmentResult]s; every other failure is thrown as [ApiFailure].
///
/// Never probes these endpoints for features: their 400 and 503 mean
/// "nothing to show", not "no route" (plan §16).
abstract interface class EnvironmentSource {
  Future<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> weatherCurrent();

  Future<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
  weatherHourly();

  Future<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>> weatherDaily();

  Future<EnvironmentResult<SolarStatus>> solarCurrent();

  Future<EnvironmentResult<PvForecast>> pvForecast();

  /// `GET /devices/:id/pv-heating-plan`; never fails for a missing PV setup.
  Future<PvHeatingPlan> pvHeatingPlan(String deviceId);
}

/// [EnvironmentSource] backed by the GI Core client.
final class GiCoreEnvironmentSource implements EnvironmentSource {
  const new(this._client);

  final GiCoreClient _client;

  @override
  Future<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> weatherCurrent() =>
      _client.weatherCurrent();

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
  weatherHourly() => _client.weatherHourly();

  @override
  Future<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
  weatherDaily() => _client.weatherDaily();

  @override
  Future<EnvironmentResult<SolarStatus>> solarCurrent() =>
      _client.solarCurrent();

  @override
  Future<EnvironmentResult<PvForecast>> pvForecast() => _client.pvForecast();

  @override
  Future<PvHeatingPlan> pvHeatingPlan(String deviceId) =>
      _client.pvHeatingPlan(deviceId);
}
