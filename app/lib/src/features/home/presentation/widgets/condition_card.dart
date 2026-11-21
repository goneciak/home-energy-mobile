import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';
import 'package:material_ui/material_ui.dart';

/// Look of a [ConditionLevel]: never colour alone, always icon and text.
StateLook conditionLook(AppLocalizations l10n, ConditionLevel level) =>
    switch (level) {
      ConditionLevel.good => (
        label: l10n.homeConditionGood,
        icon: Icons.check_circle_outline,
        tone: StatusTone.good,
      ),
      ConditionLevel.limitedData => (
        label: l10n.homeConditionLimitedData,
        icon: Icons.help_outline,
        tone: StatusTone.neutral,
      ),
      ConditionLevel.needsAttention => (
        label: l10n.homeConditionNeedsAttention,
        icon: Icons.warning_amber_rounded,
        tone: StatusTone.warning,
      ),
      ConditionLevel.actionRequired => (
        label: l10n.homeConditionActionRequired,
        icon: Icons.report_outlined,
        tone: StatusTone.danger,
      ),
    };

String limitedReasonText(AppLocalizations l10n, LimitedDataReason reason) =>
    switch (reason) {
      LimitedDataReason.refreshFailed => l10n.homeLimitedRefreshFailed,
      LimitedDataReason.outdated => l10n.homeLimitedOutdated,
      LimitedDataReason.heatingDetailsFailed =>
        l10n.homeLimitedHeatingDetailsFailed,
      LimitedDataReason.noDevices => l10n.homeLimitedNoDevices,
    };

/// Header of Home: the overall condition, why it may be limited and when
/// the data was received (plan §11.1).
class ConditionCard extends StatelessWidget {
  const new({
    required this.condition,
    required this.fetchedAt,
    required this.now,
    super.key,
  });

  final HomeCondition condition;
  final DateTime fetchedAt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final look = conditionLook(l10n, condition.level);
    final color = StatusChip.colorOf(tokens, look.tone);
    final details = [
      for (final reason in condition.limitedReasons)
        limitedReasonText(l10n, reason),
      if (condition.level == ConditionLevel.good) l10n.homeConditionGoodBody,
    ];

    return Semantics(
      container: true,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          side: BorderSide(color: color.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(look.icon, color: color, size: 36),
              SizedBox(width: tokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Announced when the condition changes; the update
                    // time below changes with every poll and is not.
                    MergeSemantics(
                      child: Semantics(
                        liveRegion: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(look.label, style: textTheme.headlineSmall),
                            for (final detail in details) ...[
                              const SizedBox(height: 4),
                              Text(detail, style: textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeConditionUpdated(
                        formatClockTime(l10n, fetchedAt, now),
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
