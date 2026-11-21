import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';
import 'package:material_ui/material_ui.dart';

/// What is wrong with the device of an [AttentionItem], in words.
String attentionText(AppLocalizations l10n, AttentionItem item) =>
    switch (item.kind) {
      AttentionKind.firmwareFault => l10n.attentionFirmwareFault,
      AttentionKind.connectivityError => l10n.attentionConnectivityError,
      AttentionKind.heatingFaults => l10n.attentionHeatingFaults(
        item.device.activeFaultCount,
      ),
      AttentionKind.faults => l10n.faultsCount(item.device.activeFaultCount),
      AttentionKind.offline => l10n.connectivityLostLocalControl,
      AttentionKind.stale => l10n.attentionStale,
      AttentionKind.heatingSuspended => l10n.badgeHeatingSuspended,
      AttentionKind.dryRun => l10n.dryRunBanner,
      AttentionKind.needsConfiguration => l10n.attentionNeedsConfiguration,
      AttentionKind.heatingDetailsUnavailable => l10n.heatingCardFailed,
      AttentionKind.noData => l10n.attentionNoData,
    };

/// The most severe [HomeCondition.suggestions], each opening its device,
/// and how many more items there are (plan §11.1).
class AttentionList extends StatelessWidget {
  const new({required this.condition, required this.onOpenDevice, super.key});

  final HomeCondition condition;
  final ValueChanged<String> onOpenDevice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final hidden = condition.hiddenItemCount;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final item in condition.suggestions)
            ListTile(
              key: ValueKey('attention-${item.device.id}-${item.kind.name}'),
              leading: Icon(
                _iconOf(item.kind),
                color: StatusChip.colorOf(tokens, _toneOf(item.kind.level)),
              ),
              title: Text(item.device.name),
              subtitle: Text(attentionText(l10n, item)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenDevice(item.device.id),
            ),
          if (hidden > 0)
            ListTile(
              dense: true,
              title: Text(
                l10n.homeAttentionMore(hidden),
                style: TextStyle(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  static StatusTone _toneOf(ConditionLevel level) => switch (level) {
    ConditionLevel.actionRequired => StatusTone.danger,
    ConditionLevel.needsAttention => StatusTone.warning,
    ConditionLevel.limitedData || ConditionLevel.good => StatusTone.neutral,
  };

  static IconData _iconOf(AttentionKind kind) => switch (kind) {
    AttentionKind.firmwareFault => Icons.report_outlined,
    AttentionKind.connectivityError => Icons.error_outline,
    AttentionKind.heatingFaults ||
    AttentionKind.faults => Icons.warning_amber_rounded,
    AttentionKind.offline => Icons.wifi_off,
    AttentionKind.stale => Icons.wifi_2_bar,
    AttentionKind.heatingSuspended => Icons.pause_circle_outline,
    AttentionKind.dryRun => Icons.science_outlined,
    AttentionKind.needsConfiguration => Icons.tune,
    AttentionKind.heatingDetailsUnavailable => Icons.sync_problem,
    AttentionKind.noData => Icons.help_outline,
  };
}
