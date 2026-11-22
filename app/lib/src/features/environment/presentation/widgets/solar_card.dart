import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/environment/presentation/environment_labels.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/environment_card.dart';
import 'package:gi_home/src/features/schedules/domain/schedule_clock.dart';
import 'package:material_ui/material_ui.dart';

/// Sunrise, sunset and day length (plan §4.2). Without house coordinates
/// (`400`) it says where to set them: the app never writes the location.
class SolarCard extends StatelessWidget {
  const new({
    required this.solar,
    required this.zone,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<EnvironmentResult<SolarStatus>> solar;
  final ScheduleZone zone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget body;
    if (solar.hasError && !solar.hasValue) {
      body = EnvironmentFailure(error: solar.error!, onRetry: onRetry);
    } else if (!solar.hasValue) {
      body = const EnvironmentLoading();
    } else {
      body = switch (solar.requireValue) {
        EnvironmentAvailable(:final value) => _SolarDetails(
          solar: value,
          zone: zone,
        ),
        EnvironmentNotConfigured() => MessageBanner(
          key: const ValueKey('solar-not-configured'),
          tone: MessageTone.info,
          message: l10n.solarNotConfigured,
        ),
        EnvironmentNoData() => EnvironmentNotice(
          key: const ValueKey('solar-no-data'),
          icon: Icons.wifi_off,
          title: l10n.solarNoData,
        ),
      };
    }
    return EnvironmentCard(
      key: const ValueKey('solar-card'),
      title: l10n.solarSection,
      icon: Icons.wb_sunny_outlined,
      child: body,
    );
  }
}

class _SolarDetails extends StatelessWidget {
  const new({required this.solar, required this.zone});

  final SolarStatus solar;
  final ScheduleZone zone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    String clock(DateTime? time) => time == null
        ? l10n.commonNoDataValue
        : formatHouseClock(l10n, time, zone);
    final dayLength = solar.dayLengthSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          icon: Icons.wb_twilight,
          label: l10n.solarSunrise,
          value: clock(solar.sunrise ?? solar.nextSunrise),
        ),
        _Row(
          icon: Icons.nights_stay_outlined,
          label: l10n.solarSunset,
          value: clock(solar.sunset ?? solar.nextSunset),
        ),
        _Row(
          icon: Icons.timelapse,
          label: l10n.solarDayLength,
          value: dayLength == null
              ? l10n.commonNoDataValue
              : formatDuration(l10n, Duration(seconds: dayLength)),
        ),
        const SizedBox(height: 4),
        Text(
          solar.aboveHorizon
              ? l10n.solarAboveHorizon(
                  formatNumber(l10n, solar.currentElevationDegrees.round()),
                )
              : l10n.solarBelowHorizon,
          style: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        ),
        Text(
          weatherZoneNote(l10n, zone),
          style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: tokens.textMuted),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: textTheme.bodyLarge)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GiFonts.monospace(textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
