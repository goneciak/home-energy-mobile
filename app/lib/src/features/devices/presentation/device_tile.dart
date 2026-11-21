import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:material_ui/material_ui.dart';

/// A device of the `GET /devices` list: name, type icon, connectivity,
/// last seen and the safety cues of the list (faults, suspended heating,
/// dry-run). Heating devices get an ember outline and label.
class DeviceTile extends StatelessWidget {
  const new({
    required this.device,
    required this.now,
    required this.onTap,
    super.key,
  });

  final DeviceListItem device;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final connectivity = connectivityLook(l10n, device.connectivityState);
    final heating = device.isHeating;
    final critical = device.currentState?.isCritical ?? false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: heating
            ? BorderSide(color: tokens.ember.withValues(alpha: 0.7))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                deviceIcon(type: device.type, isHeating: heating),
                color: heating ? tokens.ember : tokens.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: textTheme.titleMedium),
                    if (heating)
                      Text(
                        l10n.homeHeatingDevice,
                        style: textTheme.labelMedium?.copyWith(
                          color: tokens.ember,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      lastSeenLabel(l10n, device.lastSeenAt, now),
                      style: textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: connectivity.label,
                          icon: connectivity.icon,
                          tone: connectivity.tone,
                        ),
                        if (!device.enabled)
                          StatusChip(
                            label: l10n.homeDeviceDisabled,
                            icon: Icons.block,
                          ),
                        if (critical)
                          StatusChip(
                            label: firmwareStateLook(
                              l10n,
                              device.currentState!,
                            ).label,
                            icon: Icons.report_outlined,
                            tone: StatusTone.danger,
                          ),
                        if (device.activeFaultCount > 0)
                          StatusChip(
                            label: l10n.faultsCount(device.activeFaultCount),
                            icon: Icons.warning_amber_rounded,
                            tone: heating
                                ? StatusTone.danger
                                : StatusTone.warning,
                          ),
                        if (heating && device.heatingSuspended)
                          StatusChip(
                            label: l10n.badgeHeatingSuspended,
                            icon: Icons.pause_circle_outline,
                            tone: StatusTone.warning,
                          ),
                        if (device.dryRun)
                          StatusChip(
                            label: l10n.badgeDryRun,
                            icon: Icons.science_outlined,
                            tone: StatusTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
