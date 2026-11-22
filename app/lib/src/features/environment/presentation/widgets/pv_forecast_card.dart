import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/environment/presentation/environment_labels.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/environment_card.dart';
import 'package:material_ui/material_ui.dart';

/// The PV production forecast (plan §4.2): hidden when the appliance has
/// no PV or no location (`400`), "no forecast" when it could not get one
/// (`500`). Times are house-local wall times, shown as they come.
class PvForecastCard extends StatelessWidget {
  const new({required this.forecast, required this.onRetry, super.key});

  final AsyncValue<EnvironmentResult<PvForecast>> forecast;
  final VoidCallback onRetry;

  /// Whether the card is shown at all: not when PV is not configured.
  static bool isVisible(AsyncValue<EnvironmentResult<PvForecast>> forecast) =>
      forecast.value is! EnvironmentNotConfigured<PvForecast>;

  @override
  Widget build(BuildContext context) {
    if (!isVisible(forecast)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final Widget body;
    if (forecast.hasError && !forecast.hasValue) {
      body = EnvironmentFailure(error: forecast.error!, onRetry: onRetry);
    } else if (!forecast.hasValue) {
      body = const EnvironmentLoading();
    } else {
      body = switch (forecast.requireValue) {
        EnvironmentAvailable(:final value) => _ForecastDetails(forecast: value),
        _ => EnvironmentNotice(
          key: const ValueKey('pv-forecast-no-data'),
          icon: Icons.wifi_off,
          title: l10n.pvForecastNoDataTitle,
          body: l10n.pvForecastNoDataBody,
        ),
      };
    }
    return EnvironmentCard(
      key: const ValueKey('pv-forecast-card'),
      title: l10n.pvForecastSection,
      icon: Icons.solar_power_outlined,
      child: body,
    );
  }
}

class _ForecastDetails extends StatelessWidget {
  const new({required this.forecast});

  final PvForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyMedium?.copyWith(color: tokens.textMuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.pvForecastPeakPower(formatNumber(l10n, forecast.peakPowerKw)),
          style: muted,
        ),
        const SizedBox(height: 8),
        if (forecast.daily.isEmpty)
          Text(l10n.commonNoData, style: textTheme.bodyMedium),
        for (final day in forecast.daily)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatWallDay(l10n, day.date),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.pvForecastDayEnergy(
                          formatNumber(l10n, day.estimatedProductionKwh),
                        ),
                        style: GiFonts.monospace(textTheme.bodyLarge),
                      ),
                    ],
                  ),
                  if (_peakOf(day.date) case final peak?)
                    Text(
                      l10n.pvForecastDayPeak(
                        formatNumber(l10n, peak.estimatedProductionKw!),
                        formatWallClock(l10n, peak.time),
                      ),
                      style: muted,
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          l10n.pvHouseTimeNote,
          style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  /// The hour of [date] with the highest estimate above zero, if any.
  PvForecastHour? _peakOf(LocalWallTime date) {
    PvForecastHour? peak;
    for (final hour in forecast.hourly) {
      final kw = hour.estimatedProductionKw;
      if (hour.time.date != date || kw == null || kw <= 0) continue;
      if (peak == null || kw > peak.estimatedProductionKw!) peak = hour;
    }
    return peak;
  }
}
