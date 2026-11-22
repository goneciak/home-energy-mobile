import 'dart:math' as math;

import 'package:gi_core_api/gi_core_api.dart';

/// Synthetic, deterministic data of the demo appliance (plan §19.5) for the
/// read-only M3 endpoints: weather, sun, PV forecast and entity history.
/// Every series is derived from the request time, so the demo always shows
/// "today" without a network.
abstract final class DemoSeries {
  /// How far back the synthetic entity history reaches.
  static const historySpan = Duration(days: 7);

  /// Demo house: a fixed UTC offset stands in for the house time zone of
  /// the PV endpoints (house-local wall time without an offset).
  static const houseOffset = Duration(hours: 1);

  static const _symbols = [
    'partlycloudy_day',
    'cloudy',
    'lightrain',
    'fair_day',
    'clearsky_day',
    'rain',
    'lightsnowshowers_day',
  ];

  static DateTime _hour(DateTime t) =>
      DateTime.utc(t.year, t.month, t.day, t.hour);

  static DateTime _day(DateTime t) => DateTime.utc(t.year, t.month, t.day);

  static double _round(num v, [int digits = 1]) {
    final f = math.pow(10, digits);
    return (v * f).round() / f;
  }

  static double _temperatureAt(DateTime t) {
    final hours = t.hour + t.minute / 60;
    return 3 +
        4 * math.sin((hours - 9) / 24 * 2 * math.pi) +
        math.sin(t.day / 3);
  }

  static Map<String, Object?> _envelope(Object? data, DateTime now) => {
    'data': data,
    'fetchedAt': iso(now.subtract(const Duration(minutes: 12))),
    'stale': false,
    'lastError': null,
  };

  /// `GET /weather/current`.
  static Map<String, Object?> weatherCurrent(DateTime now) {
    final hour = _hour(now);
    final temperature = _round(_temperatureAt(hour));
    return _envelope({
      'observedAt': iso(hour),
      'temperatureC': temperature,
      'apparentTemperatureC': temperature,
      'relativeHumidityPercent': 82.0,
      'pressureHpa': 1012.4,
      'windSpeedMps': 3.6,
      'windDirectionDegrees': 225.0,
      'windGustMps': 7.1,
      'cloudCoveragePercent': 64.0,
      'symbolCode': hour.hour >= 7 && hour.hour < 15
          ? 'partlycloudy_day'
          : 'partlycloudy_night',
      'precipitationMm': 0.0,
    }, now);
  }

  /// `GET /weather/hourly`: 48 rows from the current hour (UTC).
  static Map<String, Object?> weatherHourly(DateTime now) {
    final start = _hour(now);
    return _envelope([
      for (var i = 0; i < 48; i++)
        () {
          final time = start.add(Duration(hours: i));
          final rainy = (time.hour + time.day) % 9 < 2;
          return {
            'time': '${time.toIso8601String().substring(0, 19)}Z',
            'temperatureC': _round(_temperatureAt(time)),
            'precipitationMm': rainy ? 0.4 : 0.0,
            'precipitationProbabilityPercent': rainy ? 70.0 : 10.0,
            'windSpeedMps': _round(3 + math.sin(i / 5) * 1.5),
            'cloudCoveragePercent': rainy ? 95.0 : 50.0,
            'symbolCode': rainy
                ? 'lightrain'
                : (time.hour >= 7 && time.hour < 15
                      ? 'partlycloudy_day'
                      : 'partlycloudy_night'),
          };
        }(),
    ], now);
  }

  /// `GET /weather/daily`: 7 UTC days from today.
  static Map<String, Object?> weatherDaily(DateTime now) {
    final today = _day(now);
    return _envelope([
      for (var i = 0; i < 7; i++)
        () {
          final day = today.add(Duration(days: i));
          final shift = math.sin(day.day / 3);
          return {
            'date': day.toIso8601String().substring(0, 10),
            'minimumTemperatureC': _round(-1 + shift),
            'maximumTemperatureC': _round(7 + shift),
            'precipitationMm': _round(((day.day * 7) % 5) * 0.6),
            'symbolCode': _symbols[day.day % _symbols.length],
          };
        }(),
    ], now);
  }

  /// `GET /solar/current`: a simplified sun of a November day in central
  /// Europe (sunrise 06:15 UTC, sunset 14:35 UTC).
  static Map<String, Object?> solarCurrent(DateTime now) {
    final today = _day(now);
    final sunrise = today.add(const Duration(hours: 6, minutes: 15));
    final sunset = today.add(const Duration(hours: 14, minutes: 35));
    final noon = today.add(const Duration(hours: 10, minutes: 25));
    final dayLength = sunset.difference(sunrise);
    final minutes = now.difference(today).inMinutes;
    final elevation =
        -2 +
        20 * math.sin((minutes - 6 * 60 - 15) / dayLength.inMinutes * math.pi);
    final azimuth = (minutes / (24 * 60) * 360 + 180) % 360;
    final above = now.isAfter(sunrise) && now.isBefore(sunset);
    return {
      'sunrise': iso(sunrise),
      'sunset': iso(sunset),
      'dawn': iso(sunrise.subtract(const Duration(minutes: 40))),
      'dusk': iso(sunset.add(const Duration(minutes: 40))),
      'solarNoon': iso(noon),
      'solarMidnight': iso(noon.add(const Duration(hours: 12))),
      'nextSunrise': iso(
        now.isBefore(sunrise) ? sunrise : sunrise.add(const Duration(days: 1)),
      ),
      'nextSunset': iso(
        now.isBefore(sunset) ? sunset : sunset.add(const Duration(days: 1)),
      ),
      'currentElevationDegrees': _round(
        above ? math.max(elevation, 0.5) : math.min(elevation, -0.5),
        2,
      ),
      'currentAzimuthDegrees': _round(azimuth, 2),
      'aboveHorizon': above,
      'dayLengthSeconds': dayLength.inSeconds,
    };
  }

  /// House-local wall time without an offset (`2026-11-22T13:00`).
  static String _wall(DateTime utc) =>
      utc.add(houseOffset).toIso8601String().substring(0, 16);

  /// Estimated PV production of [peakPowerKw] at the house-local `hour`.
  static double _production(DateTime local, double peakPowerKw) {
    final h = local.hour;
    if (h < 7 || h > 15) return 0;
    final shape = math.sin((h - 7 + 0.5) / 9 * math.pi);
    final cloud = 0.8 + 0.2 * math.sin(local.day * 1.7);
    return _round(peakPowerKw * 0.85 * shape * cloud, 2);
  }

  /// `GET /pv/forecast`: 3 house-local days, hourly.
  static Map<String, Object?> pvForecast(DateTime now, double peakPowerKw) {
    final localToday = _day(now.add(houseOffset));
    final hourly = <Map<String, Object?>>[];
    final daily = <Map<String, Object?>>[];
    for (var d = 0; d < 3; d++) {
      final day = localToday.add(Duration(days: d));
      var kwh = 0.0;
      for (var h = 0; h < 24; h++) {
        final local = day.add(Duration(hours: h));
        final kw = _production(local, peakPowerKw);
        kwh += kw;
        hourly.add({
          'time': local.toIso8601String().substring(0, 16),
          'shortwaveRadiationWm2': _round(kw / peakPowerKw * 1000),
          'estimatedProductionKw': kw,
        });
      }
      daily.add({
        'date': day.toIso8601String().substring(0, 10),
        'estimatedProductionKwh': _round(kwh, 2),
      });
    }
    return {'peakPowerKw': peakPowerKw, 'hourly': hourly, 'daily': daily};
  }

  /// `GET /devices/:id/pv-heating-plan` hours (FORECAST_ONLY): an hour is
  /// favourable when the estimate reaches [ratio] of the peak power.
  static List<Map<String, Object?>> pvPlanHours(
    DateTime now, {
    required double peakPowerKw,
    required double ratio,
    required num baseTarget,
    required num safeMax,
  }) {
    final start = _hour(now);
    return [
      for (var i = 0; i < 24; i++)
        () {
          final utc = start.add(Duration(hours: i));
          final kw = _production(utc.add(houseOffset), peakPowerKw);
          final favorable = kw >= peakPowerKw * ratio;
          return {
            'time': _wall(utc),
            'estimatedProductionKw': kw,
            'forecastFavorable': favorable,
            'predictedBoostActive': favorable,
            'predictedTargetCelsius': favorable ? safeMax : baseTarget,
          };
        }(),
    ];
  }

  /// A change log of [entity] over [historySpan] before [end]: a temperature
  /// sampled every 30 s (only changes are kept), or switch toggles.
  /// Deterministic for an entity id.
  static List<Map<String, Object?>> history(
    Map<String, Object?> entity,
    DateTime end,
  ) {
    final id = '${entity['id']}';
    final random = math.Random(
      id.codeUnits.fold<int>(17, (a, c) => a * 31 + c) & 0x7fffffff,
    );
    final start = end.subtract(historySpan);
    final unit = entity['unit'] as String?;
    final samples = <Map<String, Object?>>[];
    if (entity['domain'] == 'switch') {
      var at = start;
      var on = false;
      while (at.isBefore(end)) {
        samples.add({
          'at': iso(at),
          'kind': 'switch',
          'value': on,
          'unit': unit,
        });
        on = !on;
        at = at.add(Duration(minutes: 15 + random.nextInt(75)));
      }
      return samples;
    }
    final current = entity['value'];
    if (current is! num) return samples;
    final kind = entity['deviceClass'] == 'temperature'
        ? 'temperature'
        : 'numeric';
    double? last;
    var drift = 0.0;
    for (
      var at = start;
      at.isBefore(end);
      at = at.add(const Duration(seconds: 30))
    ) {
      drift = (drift + (random.nextDouble() - 0.5) * 0.08) * 0.995;
      final minutes = at.hour * 60 + at.minute;
      final daily = 2.5 * math.sin(minutes / (24 * 60) * 2 * math.pi);
      final value = _round(current + daily + drift * 10);
      if (value == last) continue;
      last = value;
      samples.add({'at': iso(at), 'kind': kind, 'value': value, 'unit': unit});
    }
    return samples;
  }

  /// A fresh recovery code in the server format (8 groups of 4 hex digits).
  static String recoveryCode(math.Random random) => [
    for (var g = 0; g < RecoveryCodeFormat.groups; g++)
      [
        for (var i = 0; i < RecoveryCodeFormat.groupLength; i++)
          random.nextInt(16).toRadixString(16).toUpperCase(),
      ].join(),
  ].join('-');

  static String iso(DateTime time) => time.toUtc().toIso8601String();
}
