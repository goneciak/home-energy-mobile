import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/enums.dart';
import 'package:gi_core_api/src/models/local_wall_time.dart';

part 'environment_models.freezed.dart';
part 'environment_models.g.dart';

/// Outcome of a weather, solar or PV read whose "no data" answers are an
/// expected state, not an error (plan §4.2):
/// * weather `503 HTTP_503` (no cached data yet) → [EnvironmentNoData];
/// * solar / PV forecast `400 HTTP_400` (no house coordinates, no PV) →
///   [EnvironmentNotConfigured] (hide the card);
/// * PV forecast `500` (Open-Meteo failed, uncaught on the server) →
///   [EnvironmentNoData].
@immutable
sealed class EnvironmentResult<T> {
  const new();

  /// The value, or `null` for the two "nothing to show" outcomes.
  T? get valueOrNull => switch (this) {
    EnvironmentAvailable(:final value) => value,
    _ => null,
  };
}

final class EnvironmentAvailable<T> extends EnvironmentResult<T> {
  const new(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is EnvironmentAvailable<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EnvironmentAvailable($value)';
}

/// The appliance has nothing to show right now (provider down, cache empty).
final class EnvironmentNoData<T> extends EnvironmentResult<T> {
  const new();

  @override
  bool operator ==(Object other) => other is EnvironmentNoData<T>;

  @override
  int get hashCode => (EnvironmentNoData).hashCode;

  @override
  String toString() => 'EnvironmentNoData()';
}

/// The appliance lacks the setup the data needs (house coordinates, PV).
final class EnvironmentNotConfigured<T> extends EnvironmentResult<T> {
  const new();

  @override
  bool operator ==(Object other) => other is EnvironmentNotConfigured<T>;

  @override
  int get hashCode => (EnvironmentNotConfigured).hashCode;

  @override
  String toString() => 'EnvironmentNotConfigured()';
}

/// `GET /weather/*` envelope. [stale] is true when the last provider refresh
/// failed and [data] is an older cache ([lastError] says why).
@Freezed(genericArgumentFactories: true)
abstract class WeatherEnvelope<T> with _$WeatherEnvelope<T> {
  const factory({
    required T data,
    required DateTime fetchedAt,
    @Default(false) bool stale,
    String? lastError,
  }) = _WeatherEnvelope<T>;

  factory fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$WeatherEnvelopeFromJson(json, fromJsonT);
}

/// `GET /weather/current` data (met.no). Every number is nullable;
/// [apparentTemperatureC] is the air temperature, not a real "feels like".
@freezed
abstract class CurrentWeather with _$CurrentWeather {
  const factory({
    DateTime? observedAt,
    double? temperatureC,
    double? apparentTemperatureC,
    double? relativeHumidityPercent,
    double? pressureHpa,
    double? windSpeedMps,
    double? windDirectionDegrees,
    double? windGustMps,
    double? cloudCoveragePercent,
    String? symbolCode,
    double? precipitationMm,
  }) = _CurrentWeather;

  factory fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
}

/// One `GET /weather/hourly` row (at most 72); [time] is UTC.
@freezed
abstract class HourlyWeather with _$HourlyWeather {
  const factory({
    required DateTime time,
    double? temperatureC,
    double? precipitationMm,
    double? precipitationProbabilityPercent,
    double? windSpeedMps,
    double? cloudCoveragePercent,
    String? symbolCode,
  }) = _HourlyWeather;

  factory fromJson(Map<String, dynamic> json) => _$HourlyWeatherFromJson(json);
}

/// One `GET /weather/daily` row; [date] is the UTC day (`YYYY-MM-DD`).
@freezed
abstract class DailyWeather with _$DailyWeather {
  const factory({
    @LocalDateConverter() required LocalWallTime date,
    double? minimumTemperatureC,
    double? maximumTemperatureC,
    @Default(0) double precipitationMm,
    String? symbolCode,
  }) = _DailyWeather;

  factory fromJson(Map<String, dynamic> json) => _$DailyWeatherFromJson(json);
}

/// `GET /solar/current`, computed on the appliance without network.
@freezed
abstract class SolarStatus with _$SolarStatus {
  const factory({
    required double currentElevationDegrees,
    required double currentAzimuthDegrees,
    required bool aboveHorizon,
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? dawn,
    DateTime? dusk,
    DateTime? solarNoon,
    DateTime? solarMidnight,
    DateTime? nextSunrise,
    DateTime? nextSunset,
    int? dayLengthSeconds,
  }) = _SolarStatus;

  factory fromJson(Map<String, dynamic> json) => _$SolarStatusFromJson(json);
}

/// `GET /pv/forecast` (Open-Meteo, 3 days, cached 30 min on the appliance).
@freezed
abstract class PvForecast with _$PvForecast {
  const factory({
    required double peakPowerKw,
    @Default(<PvForecastHour>[]) List<PvForecastHour> hourly,
    @Default(<PvForecastDay>[]) List<PvForecastDay> daily,
  }) = _PvForecast;

  factory fromJson(Map<String, dynamic> json) => _$PvForecastFromJson(json);
}

/// [time] is house-local wall time without an offset.
@freezed
abstract class PvForecastHour with _$PvForecastHour {
  const factory({
    @LocalWallTimeConverter() required LocalWallTime time,
    double? shortwaveRadiationWm2,
    double? estimatedProductionKw,
  }) = _PvForecastHour;

  factory fromJson(Map<String, dynamic> json) => _$PvForecastHourFromJson(json);
}

/// [date] is a house-local day.
@freezed
abstract class PvForecastDay with _$PvForecastDay {
  const factory({
    @LocalDateConverter() required LocalWallTime date,
    required double estimatedProductionKwh,
  }) = _PvForecastDay;

  factory fromJson(Map<String, dynamic> json) => _$PvForecastDayFromJson(json);
}

/// `GET /devices/:id/pv-heating-plan`. [hours] is empty when the mode is
/// [PvControlMode.disabled] or the forecast is unavailable; the endpoint
/// never fails for a missing PV setup.
@freezed
abstract class PvHeatingPlan with _$PvHeatingPlan {
  const factory({
    required String deviceId,
    required DateTime generatedAt,
    required double safeMaxTemperatureCelsius,
    required double baseTargetCelsius,
    @JsonKey(unknownEnumValue: PvControlMode.unknown)
    @Default(PvControlMode.unknown)
    PvControlMode mode,
    @Default(<PvHeatingPlanHour>[]) List<PvHeatingPlanHour> hours,
  }) = _PvHeatingPlan;

  factory fromJson(Map<String, dynamic> json) => _$PvHeatingPlanFromJson(json);
}

/// [time] is house-local wall time without an offset.
@freezed
abstract class PvHeatingPlanHour with _$PvHeatingPlanHour {
  const factory({
    @LocalWallTimeConverter() required LocalWallTime time,
    required bool forecastFavorable,
    required bool predictedBoostActive,
    required double predictedTargetCelsius,
    double? estimatedProductionKw,
  }) = _PvHeatingPlanHour;

  factory fromJson(Map<String, dynamic> json) =>
      _$PvHeatingPlanHourFromJson(json);
}
