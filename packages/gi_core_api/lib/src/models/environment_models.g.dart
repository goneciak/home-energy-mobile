// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherEnvelope<T> _$WeatherEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('_WeatherEnvelope', json, ($checkedConvert) {
  final val = _WeatherEnvelope<T>(
    data: $checkedConvert('data', (v) => fromJsonT(v)),
    fetchedAt: $checkedConvert('fetchedAt', (v) => DateTime.parse(v as String)),
    stale: $checkedConvert('stale', (v) => v as bool? ?? false),
    lastError: $checkedConvert('lastError', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$WeatherEnvelopeToJson<T>(
  _WeatherEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': toJsonT(instance.data),
  'fetchedAt': instance.fetchedAt.toIso8601String(),
  'stale': instance.stale,
  'lastError': instance.lastError,
};

_CurrentWeather _$CurrentWeatherFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_CurrentWeather', json, ($checkedConvert) {
  final val = _CurrentWeather(
    observedAt: $checkedConvert(
      'observedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    temperatureC: $checkedConvert(
      'temperatureC',
      (v) => (v as num?)?.toDouble(),
    ),
    apparentTemperatureC: $checkedConvert(
      'apparentTemperatureC',
      (v) => (v as num?)?.toDouble(),
    ),
    relativeHumidityPercent: $checkedConvert(
      'relativeHumidityPercent',
      (v) => (v as num?)?.toDouble(),
    ),
    pressureHpa: $checkedConvert('pressureHpa', (v) => (v as num?)?.toDouble()),
    windSpeedMps: $checkedConvert(
      'windSpeedMps',
      (v) => (v as num?)?.toDouble(),
    ),
    windDirectionDegrees: $checkedConvert(
      'windDirectionDegrees',
      (v) => (v as num?)?.toDouble(),
    ),
    windGustMps: $checkedConvert('windGustMps', (v) => (v as num?)?.toDouble()),
    cloudCoveragePercent: $checkedConvert(
      'cloudCoveragePercent',
      (v) => (v as num?)?.toDouble(),
    ),
    symbolCode: $checkedConvert('symbolCode', (v) => v as String?),
    precipitationMm: $checkedConvert(
      'precipitationMm',
      (v) => (v as num?)?.toDouble(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CurrentWeatherToJson(_CurrentWeather instance) =>
    <String, dynamic>{
      'observedAt': instance.observedAt?.toIso8601String(),
      'temperatureC': instance.temperatureC,
      'apparentTemperatureC': instance.apparentTemperatureC,
      'relativeHumidityPercent': instance.relativeHumidityPercent,
      'pressureHpa': instance.pressureHpa,
      'windSpeedMps': instance.windSpeedMps,
      'windDirectionDegrees': instance.windDirectionDegrees,
      'windGustMps': instance.windGustMps,
      'cloudCoveragePercent': instance.cloudCoveragePercent,
      'symbolCode': instance.symbolCode,
      'precipitationMm': instance.precipitationMm,
    };

_HourlyWeather _$HourlyWeatherFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HourlyWeather', json, ($checkedConvert) {
      final val = _HourlyWeather(
        time: $checkedConvert('time', (v) => DateTime.parse(v as String)),
        temperatureC: $checkedConvert(
          'temperatureC',
          (v) => (v as num?)?.toDouble(),
        ),
        precipitationMm: $checkedConvert(
          'precipitationMm',
          (v) => (v as num?)?.toDouble(),
        ),
        precipitationProbabilityPercent: $checkedConvert(
          'precipitationProbabilityPercent',
          (v) => (v as num?)?.toDouble(),
        ),
        windSpeedMps: $checkedConvert(
          'windSpeedMps',
          (v) => (v as num?)?.toDouble(),
        ),
        cloudCoveragePercent: $checkedConvert(
          'cloudCoveragePercent',
          (v) => (v as num?)?.toDouble(),
        ),
        symbolCode: $checkedConvert('symbolCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$HourlyWeatherToJson(
  _HourlyWeather instance,
) => <String, dynamic>{
  'time': instance.time.toIso8601String(),
  'temperatureC': instance.temperatureC,
  'precipitationMm': instance.precipitationMm,
  'precipitationProbabilityPercent': instance.precipitationProbabilityPercent,
  'windSpeedMps': instance.windSpeedMps,
  'cloudCoveragePercent': instance.cloudCoveragePercent,
  'symbolCode': instance.symbolCode,
};

_DailyWeather _$DailyWeatherFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DailyWeather', json, ($checkedConvert) {
      final val = _DailyWeather(
        date: $checkedConvert(
          'date',
          (v) => const LocalDateConverter().fromJson(v as String),
        ),
        minimumTemperatureC: $checkedConvert(
          'minimumTemperatureC',
          (v) => (v as num?)?.toDouble(),
        ),
        maximumTemperatureC: $checkedConvert(
          'maximumTemperatureC',
          (v) => (v as num?)?.toDouble(),
        ),
        precipitationMm: $checkedConvert(
          'precipitationMm',
          (v) => (v as num?)?.toDouble() ?? 0,
        ),
        symbolCode: $checkedConvert('symbolCode', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DailyWeatherToJson(_DailyWeather instance) =>
    <String, dynamic>{
      'date': const LocalDateConverter().toJson(instance.date),
      'minimumTemperatureC': instance.minimumTemperatureC,
      'maximumTemperatureC': instance.maximumTemperatureC,
      'precipitationMm': instance.precipitationMm,
      'symbolCode': instance.symbolCode,
    };

_SolarStatus _$SolarStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SolarStatus', json, ($checkedConvert) {
      final val = _SolarStatus(
        currentElevationDegrees: $checkedConvert(
          'currentElevationDegrees',
          (v) => (v as num).toDouble(),
        ),
        currentAzimuthDegrees: $checkedConvert(
          'currentAzimuthDegrees',
          (v) => (v as num).toDouble(),
        ),
        aboveHorizon: $checkedConvert('aboveHorizon', (v) => v as bool),
        sunrise: $checkedConvert(
          'sunrise',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        sunset: $checkedConvert(
          'sunset',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        dawn: $checkedConvert(
          'dawn',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        dusk: $checkedConvert(
          'dusk',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        solarNoon: $checkedConvert(
          'solarNoon',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        solarMidnight: $checkedConvert(
          'solarMidnight',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        nextSunrise: $checkedConvert(
          'nextSunrise',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        nextSunset: $checkedConvert(
          'nextSunset',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        dayLengthSeconds: $checkedConvert(
          'dayLengthSeconds',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SolarStatusToJson(_SolarStatus instance) =>
    <String, dynamic>{
      'currentElevationDegrees': instance.currentElevationDegrees,
      'currentAzimuthDegrees': instance.currentAzimuthDegrees,
      'aboveHorizon': instance.aboveHorizon,
      'sunrise': instance.sunrise?.toIso8601String(),
      'sunset': instance.sunset?.toIso8601String(),
      'dawn': instance.dawn?.toIso8601String(),
      'dusk': instance.dusk?.toIso8601String(),
      'solarNoon': instance.solarNoon?.toIso8601String(),
      'solarMidnight': instance.solarMidnight?.toIso8601String(),
      'nextSunrise': instance.nextSunrise?.toIso8601String(),
      'nextSunset': instance.nextSunset?.toIso8601String(),
      'dayLengthSeconds': instance.dayLengthSeconds,
    };

_PvForecast _$PvForecastFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_PvForecast',
  json,
  ($checkedConvert) {
    final val = _PvForecast(
      peakPowerKw: $checkedConvert('peakPowerKw', (v) => (v as num).toDouble()),
      hourly: $checkedConvert(
        'hourly',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => PvForecastHour.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <PvForecastHour>[],
      ),
      daily: $checkedConvert(
        'daily',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => PvForecastDay.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <PvForecastDay>[],
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$PvForecastToJson(_PvForecast instance) =>
    <String, dynamic>{
      'peakPowerKw': instance.peakPowerKw,
      'hourly': instance.hourly.map((e) => e.toJson()).toList(),
      'daily': instance.daily.map((e) => e.toJson()).toList(),
    };

_PvForecastHour _$PvForecastHourFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PvForecastHour', json, ($checkedConvert) {
      final val = _PvForecastHour(
        time: $checkedConvert(
          'time',
          (v) => const LocalWallTimeConverter().fromJson(v as String),
        ),
        shortwaveRadiationWm2: $checkedConvert(
          'shortwaveRadiationWm2',
          (v) => (v as num?)?.toDouble(),
        ),
        estimatedProductionKw: $checkedConvert(
          'estimatedProductionKw',
          (v) => (v as num?)?.toDouble(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PvForecastHourToJson(_PvForecastHour instance) =>
    <String, dynamic>{
      'time': const LocalWallTimeConverter().toJson(instance.time),
      'shortwaveRadiationWm2': instance.shortwaveRadiationWm2,
      'estimatedProductionKw': instance.estimatedProductionKw,
    };

_PvForecastDay _$PvForecastDayFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PvForecastDay', json, ($checkedConvert) {
      final val = _PvForecastDay(
        date: $checkedConvert(
          'date',
          (v) => const LocalDateConverter().fromJson(v as String),
        ),
        estimatedProductionKwh: $checkedConvert(
          'estimatedProductionKwh',
          (v) => (v as num).toDouble(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PvForecastDayToJson(_PvForecastDay instance) =>
    <String, dynamic>{
      'date': const LocalDateConverter().toJson(instance.date),
      'estimatedProductionKwh': instance.estimatedProductionKwh,
    };

_PvHeatingPlan _$PvHeatingPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PvHeatingPlan', json, ($checkedConvert) {
      final val = _PvHeatingPlan(
        deviceId: $checkedConvert('deviceId', (v) => v as String),
        generatedAt: $checkedConvert(
          'generatedAt',
          (v) => DateTime.parse(v as String),
        ),
        safeMaxTemperatureCelsius: $checkedConvert(
          'safeMaxTemperatureCelsius',
          (v) => (v as num).toDouble(),
        ),
        baseTargetCelsius: $checkedConvert(
          'baseTargetCelsius',
          (v) => (v as num).toDouble(),
        ),
        mode: $checkedConvert(
          'mode',
          (v) =>
              $enumDecodeNullable(
                _$PvControlModeEnumMap,
                v,
                unknownValue: PvControlMode.unknown,
              ) ??
              PvControlMode.unknown,
        ),
        hours: $checkedConvert(
          'hours',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) =>
                        PvHeatingPlanHour.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const <PvHeatingPlanHour>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$PvHeatingPlanToJson(_PvHeatingPlan instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'safeMaxTemperatureCelsius': instance.safeMaxTemperatureCelsius,
      'baseTargetCelsius': instance.baseTargetCelsius,
      'mode': _$PvControlModeEnumMap[instance.mode]!,
      'hours': instance.hours.map((e) => e.toJson()).toList(),
    };

const _$PvControlModeEnumMap = {
  PvControlMode.disabled: 'DISABLED',
  PvControlMode.forecastOnly: 'FORECAST_ONLY',
  PvControlMode.liveInverterOnly: 'LIVE_INVERTER_ONLY',
  PvControlMode.hybrid: 'HYBRID',
  PvControlMode.unknown: 'UNKNOWN',
};

_PvHeatingPlanHour _$PvHeatingPlanHourFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PvHeatingPlanHour', json, ($checkedConvert) {
      final val = _PvHeatingPlanHour(
        time: $checkedConvert(
          'time',
          (v) => const LocalWallTimeConverter().fromJson(v as String),
        ),
        forecastFavorable: $checkedConvert(
          'forecastFavorable',
          (v) => v as bool,
        ),
        predictedBoostActive: $checkedConvert(
          'predictedBoostActive',
          (v) => v as bool,
        ),
        predictedTargetCelsius: $checkedConvert(
          'predictedTargetCelsius',
          (v) => (v as num).toDouble(),
        ),
        estimatedProductionKw: $checkedConvert(
          'estimatedProductionKw',
          (v) => (v as num?)?.toDouble(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PvHeatingPlanHourToJson(_PvHeatingPlanHour instance) =>
    <String, dynamic>{
      'time': const LocalWallTimeConverter().toJson(instance.time),
      'forecastFavorable': instance.forecastFavorable,
      'predictedBoostActive': instance.predictedBoostActive,
      'predictedTargetCelsius': instance.predictedTargetCelsius,
      'estimatedProductionKw': instance.estimatedProductionKw,
    };
