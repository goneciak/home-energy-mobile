import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/pv_forecast_card.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/solar_card.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/weather_card.dart';
import 'package:material_ui/material_ui.dart';

/// "Pogoda i słońce" (plan §4.2): weather now, by hour and by day, the sun
/// and the PV production forecast. Read-only for every role; each card has
/// its own honest state (G3): no data in the appliance, no location, or GI
/// Home unreachable.
class WeatherScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final now = ref.watch(clockProvider)();
    final zone = ref.watch(houseZoneProvider);
    final current = ref.watch(weatherCurrentProvider);
    final hourly = ref.watch(weatherHourlyProvider);
    final daily = ref.watch(weatherDailyProvider);
    final solar = ref.watch(solarStatusProvider);
    final pv = ref.watch(pvForecastProvider);

    void retryWeather() => ref
      ..invalidate(weatherCurrentProvider)
      ..invalidate(weatherHourlyProvider)
      ..invalidate(weatherDailyProvider);

    Future<void> refresh() async {
      retryWeather();
      ref
        ..invalidate(solarStatusProvider)
        ..invalidate(pvForecastProvider);
      try {
        await Future.wait([
          ref.read(weatherCurrentProvider.future),
          ref.read(weatherHourlyProvider.future),
          ref.read(weatherDailyProvider.future),
          ref.read(solarStatusProvider.future),
          ref.read(pvForecastProvider.future),
        ]);
      } on Object {
        // Shown by the card that failed.
      }
    }

    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.weatherTitle)),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(tokens.gap),
          children: [
            WeatherCard(
              current: current,
              hourly: hourly,
              daily: daily,
              zone: zone,
              now: now,
              onRetry: retryWeather,
            ),
            gap,
            SolarCard(
              solar: solar,
              zone: zone,
              onRetry: () => ref.invalidate(solarStatusProvider),
            ),
            if (PvForecastCard.isVisible(pv)) ...[
              gap,
              PvForecastCard(
                forecast: pv,
                onRetry: () => ref.invalidate(pvForecastProvider),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
