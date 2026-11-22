import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/data/device_snapshot_store.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:material_ui/material_ui.dart';

/// The persistent snapshot shown when a cold start cannot reach GI Home
/// (plan §8.3, G3): read-only, with "Brak połączenia z GI Home · dane z
/// 07:41" and the condition "Ograniczone dane". Nothing in it can be tapped
/// or changed; it only shows what the devices reported last time.
class OfflineSnapshotView extends StatelessWidget {
  const new({required this.snapshot, required this.now, super.key});

  final DeviceSnapshot snapshot;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final devices = [
      for (final device in snapshot.devices.value)
        if (device.enabled) device,
    ];
    return Column(
      key: const ValueKey('offline-snapshot'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MessageBanner(
          tone: MessageTone.warning,
          message: l10n.offlineBannerSince(
            formatClockTime(l10n, snapshot.devices.fetchedAt, now),
          ),
          detail: l10n.offlineSnapshotReadOnly,
        ),
        SizedBox(height: tokens.gap),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StatusChip(
            label: l10n.homeConditionLimitedData,
            icon: Icons.help_outline,
          ),
        ),
        SizedBox(height: tokens.gap / 2),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final device in devices)
                ListTile(
                  key: ValueKey('offline-device-${device.id}'),
                  leading: Icon(
                    deviceIcon(type: device.type, isHeating: device.isHeating),
                    color: tokens.textMuted,
                  ),
                  title: Text(device.name),
                  subtitle: Text(
                    connectivityLook(l10n, device.connectivityState).label,
                    style: textTheme.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ),
              if (devices.isEmpty) ListTile(title: Text(l10n.homeEmptyTitle)),
            ],
          ),
        ),
      ],
    );
  }
}
