import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_label.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/environment/presentation/environment_labels.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/environment_card.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:material_ui/material_ui.dart';

/// How many hours the strip shows (the appliance has up to 72).
const int weatherStripHours = 24;

/// The weather: now, the next hours and the next days (plan §4.2). A
/// `503` is "no weather data" (no internet in the appliance, G3), a stale
/// envelope gets a warning with the appliance's reason.
class WeatherCard extends StatelessWidget {
  const new({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.zone,
    required this.now,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<EnvironmentResult<WeatherEnvelope<CurrentWeather>>> current;
  final AsyncValue<EnvironmentResult<WeatherEnvelope<List<HourlyWeather>>>>
  hourly;
  final AsyncValue<EnvironmentResult<WeatherEnvelope<List<DailyWeather>>>>
  daily;
  final ScheduleZone zone;
  final DateTime now;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final gap = SizedBox(height: tokens.gap);

    final Widget body;
    if (current.hasError && !current.hasValue) {
      body = EnvironmentFailure(error: current.error!, onRetry: onRetry);
    } else if (!current.hasValue) {
      body = const EnvironmentLoading();
    } else {
      body = switch (current.requireValue) {
        EnvironmentAvailable(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CurrentWeather(envelope: value, now: now),
            gap,
            _Subheader(l10n.weatherHourlySection),
            _section(
              hourly,
              (envelope) =>
                  _HourlyStrip(hours: envelope.data, zone: zone, now: now),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _Note(weatherZoneNote(l10n, zone)),
            ),
            gap,
            _Subheader(l10n.weatherDailySection),
            _section(daily, (envelope) => _DailyList(days: envelope.data)),
            _Note(l10n.weatherDaysUtc),
          ],
        ),
        _ => const _WeatherNoData(),
      };
    }

    return EnvironmentCard(
      key: const ValueKey('weather-card'),
      title: l10n.weatherSection,
      icon: Icons.wb_cloudy_outlined,
      child: body,
    );
  }

  Widget _section<T>(
    AsyncValue<EnvironmentResult<WeatherEnvelope<T>>> value,
    Widget Function(WeatherEnvelope<T> envelope) build,
  ) {
    if (value.hasError && !value.hasValue) {
      return EnvironmentFailure(error: value.error!, onRetry: onRetry);
    }
    if (!value.hasValue) return const EnvironmentLoading();
    return switch (value.requireValue) {
      EnvironmentAvailable(:final value) => build(value),
      _ => const _WeatherNoData(),
    };
  }
}

class _WeatherNoData extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => EnvironmentNotice(
    key: const ValueKey('weather-no-data'),
    icon: Icons.wifi_off,
    title: context.l10n.weatherNoDataTitle,
    body: context.l10n.weatherNoDataBody,
  );
}

class _Subheader extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

class _Note extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: GiTokens.of(context).textMuted),
  );
}

class _CurrentWeather extends StatelessWidget {
  const new({required this.envelope, required this.now});

  final WeatherEnvelope<CurrentWeather> envelope;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final weather = envelope.data;
    final condition = weatherConditionLabel(l10n, weather.symbolCode);
    final temperature = weatherTemperatureText(l10n, weather.temperatureC);
    final details = [
      if (weather.relativeHumidityPercent case final value?)
        l10n.weatherHumidity(formatNumber(l10n, value.round())),
      if (weather.windSpeedMps case final value?)
        l10n.weatherWind(formatNumber(l10n, value)),
      if (weather.pressureHpa case final value?)
        l10n.weatherPressure(formatNumber(l10n, value.round())),
      if (weather.precipitationMm case final value?)
        l10n.weatherPrecipitation(formatNumber(l10n, value)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (envelope.stale) ...[
          MessageBanner(
            key: const ValueKey('weather-stale'),
            tone: MessageTone.warning,
            message: l10n.weatherStaleBanner,
            detail: envelope.lastError,
          ),
          SizedBox(height: tokens.gap),
        ],
        MergeSemantics(
          child: Row(
            children: [
              WeatherSymbol(weather.symbolCode, size: 48, color: tokens.ember),
              SizedBox(width: tokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(temperature, style: textTheme.headlineMedium),
                    Text(condition, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: tokens.gap,
            runSpacing: 4,
            children: [
              for (final detail in details)
                Text(
                  detail,
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        FreshnessLabel(
          updatedAt: envelope.fetchedAt,
          now: now,
          isStale: envelope.stale,
        ),
      ],
    );
  }
}

class _HourlyStrip extends StatelessWidget {
  const new({required this.hours, required this.zone, required this.now});

  final List<HourlyWeather> hours;
  final ScheduleZone zone;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // From the hour in progress on.
    final from = now.toUtc().subtract(const Duration(hours: 1));
    final shown = hours
        .where((hour) => hour.time.isAfter(from))
        .take(weatherStripHours)
        .toList();
    if (shown.isEmpty) {
      return Text(
        l10n.commonNoData,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return SingleChildScrollView(
      key: const ValueKey('weather-hourly'),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final hour in shown)
            _HourCell(
              time: formatHouseClock(l10n, hour.time, zone),
              hour: hour,
            ),
        ],
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const new({required this.time, required this.hour});

  final String time;
  final HourlyWeather hour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final temperature = weatherTemperatureText(l10n, hour.temperatureC);
    return Semantics(
      label: l10n.weatherHourSemantics(
        time,
        temperature,
        weatherConditionLabel(l10n, hour.symbolCode),
      ),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Text(
              time,
              style: GiFonts.monospace(textTheme.bodySmall)
                  .copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 4),
            WeatherSymbol(hour.symbolCode),
            const SizedBox(height: 4),
            Text(temperature, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DailyList extends StatelessWidget {
  const new({required this.days});

  final List<DailyWeather> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return Text(
        context.l10n.commonNoData,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      key: const ValueKey('weather-daily'),
      children: [for (final day in days) _DayRow(day: day)],
    );
  }
}

class _DayRow extends StatelessWidget {
  const new({required this.day});

  final DailyWeather day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final date = formatWallDay(l10n, day.date);
    final min = weatherTemperatureText(l10n, day.minimumTemperatureC);
    final max = weatherTemperatureText(l10n, day.maximumTemperatureC);
    final precipitation = formatNumber(l10n, day.precipitationMm);
    return Semantics(
      label: l10n.weatherDaySemantics(
        date,
        min,
        max,
        precipitation,
        weatherConditionLabel(l10n, day.symbolCode),
      ),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            WeatherSymbol(day.symbolCode),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: textTheme.bodyLarge),
                  Text(
                    '$min / $max · ${l10n.weatherPrecipitation(precipitation)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
