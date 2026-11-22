import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/environment/application/environment_providers.dart';
import 'package:gi_home/src/features/environment/presentation/environment_labels.dart';
import 'package:gi_home/src/features/environment/presentation/widgets/environment_card.dart';
import 'package:material_ui/material_ui.dart';

/// How many plan hours are listed before "Pokaż wszystkie godziny".
const int pvPlanCollapsedHours = 12;

/// The PV heating plan of device [deviceId] on the device screen
/// (plan §4.2), read-only.
class PvPlanSection extends ConsumerWidget {
  const new({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PvPlanCard(
    plan: ref.watch(pvHeatingPlanProvider(deviceId)),
    onRetry: () => ref.invalidate(pvHeatingPlanProvider(deviceId)),
  );
}

/// [plan] as a compact row when it is off or has no hours, otherwise its
/// mode, targets and hours. Hour times are house-local wall times, shown as
/// they come (never converted).
class PvPlanCard extends StatelessWidget {
  const new({required this.plan, required this.onRetry, super.key});

  final AsyncValue<PvHeatingPlan> plan;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (plan.hasError && !plan.hasValue) {
      return ListTile(
        key: const ValueKey('pv-plan-failed'),
        leading: const Icon(Icons.solar_power_outlined),
        title: Text(l10n.pvPlanLoadFailed),
        subtitle: Text(failureMessage(l10n, plan.error!)),
        trailing: IconButton(
          tooltip: l10n.actionRetry,
          icon: const Icon(Icons.refresh),
          onPressed: onRetry,
        ),
      );
    }
    final value = plan.value;
    if (value == null) {
      return ListTile(
        key: const ValueKey('pv-plan-loading'),
        leading: const Icon(Icons.solar_power_outlined),
        title: Text(l10n.pvPlanSection),
        subtitle: Text(l10n.commonLoading),
      );
    }
    if (value.mode == PvControlMode.disabled) {
      return ListTile(
        key: const ValueKey('pv-plan-disabled'),
        leading: const Icon(Icons.solar_power_outlined),
        title: Text(l10n.pvPlanDisabled),
        subtitle: Text(l10n.pvPlanDisabledBody),
      );
    }
    if (value.hours.isEmpty) {
      return ListTile(
        key: const ValueKey('pv-plan-no-hours'),
        leading: const Icon(Icons.solar_power_outlined),
        title: Text(l10n.pvPlanNoHours),
        subtitle: Text(l10n.pvPlanNoHoursBody),
      );
    }
    final tokens = GiTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.gap, vertical: 8),
      child: EnvironmentCard(
        key: const ValueKey('pv-plan'),
        title: l10n.pvPlanSection,
        icon: Icons.solar_power_outlined,
        child: _PlanDetails(plan: value),
      ),
    );
  }
}

class _PlanDetails extends StatefulWidget {
  const new({required this.plan});

  final PvHeatingPlan plan;

  @override
  State<_PlanDetails> createState() => _PlanDetailsState();
}

class _PlanDetailsState extends State<_PlanDetails> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyMedium?.copyWith(color: tokens.textMuted);
    final plan = widget.plan;
    final hours = plan.hours;
    final collapsible = hours.length > pvPlanCollapsedHours;
    final shown = collapsible && !_expanded
        ? hours.take(pvPlanCollapsedHours)
        : hours;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.pvPlanMode(pvModeLabel(l10n, plan.mode)), style: muted),
        Text(
          l10n.pvPlanBaseTarget(
            formatTemperature(l10n, plan.baseTargetCelsius),
          ),
          style: muted,
        ),
        Text(
          l10n.pvPlanSafeMax(
            formatTemperature(l10n, plan.safeMaxTemperatureCelsius),
          ),
          style: muted,
        ),
        const SizedBox(height: 8),
        for (final hour in shown) _HourRow(hour: hour),
        if (collapsible)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const ValueKey('pv-plan-toggle'),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? l10n.pvPlanShowLess
                    : l10n.pvPlanShowAll(hours.length),
              ),
            ),
          ),
        Text(
          l10n.pvHouseTimeNote,
          style: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  const new({required this.hour});

  final PvHeatingPlanHour hour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final time = formatWallClock(l10n, hour.time);
    final production = switch (hour.estimatedProductionKw) {
      final kw? => l10n.pvPlanProduction(formatNumber(l10n, kw)),
      null => l10n.commonNoDataValue,
    };
    final target = formatTemperature(l10n, hour.predictedTargetCelsius);
    final boost = hour.predictedBoostActive;
    final state = boost ? l10n.pvPlanBoost(target) : l10n.pvPlanNoBoost(target);
    return Semantics(
      label: l10n.pvPlanHourSemantics(
        time,
        hour.estimatedProductionKw == null ? l10n.commonNoData : production,
        state,
      ),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: GiFonts.monospace(textTheme.bodyMedium)),
            const SizedBox(width: 12),
            Icon(
              boost ? Icons.bolt : Icons.remove,
              size: 18,
              color: boost ? tokens.ember : tokens.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$state · $production',
                style: boost
                    ? textTheme.bodyMedium
                    : textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
