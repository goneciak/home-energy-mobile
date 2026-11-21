import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/status_chip.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/home/domain/heating_strategy.dart';
import 'package:material_ui/material_ui.dart';

/// Control settings of a heating device on its card (plan §12.5, §20 M2
/// item 3): the effective strategy the firmware gets, the default one when
/// a schedule replaced it, a PV boost, and a prominent suspension with its
/// next action. Every value names its source and time (PRD §10.4).
///
/// The dry-run banner and a latched fault (FAULT/SAFE_MODE, which only an
/// authorised manual reset on the device clears; plan §12.7) are shown
/// here too, so the card never implies a physical action.
class HeatingStrategySection extends StatelessWidget {
  const new({
    required this.detail,
    required this.permission,
    required this.faultLatched,
    required this.now,
    this.onResume,
    super.key,
  });

  final Fetched<DeviceDetail> detail;
  final HeatingPermission permission;

  /// The controller reports FAULT or SAFE_MODE (from the list or details).
  final bool faultLatched;
  final DateTime now;

  /// Resumes heating; offered only to a user allowed to (plan §12.8).
  /// Without it the user is pointed to the device details.
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final device = detail.value;
    final summary = HeatingStrategySummary.of(device);
    final muted = textTheme.bodySmall?.copyWith(color: tokens.textMuted);
    final shown = summary.shown;
    final base = summary.base;
    final pvBoost = summary.pvBoost;
    final onResume = this.onResume;

    String temp(double value) => formatTemperature(l10n, value);

    final children = <Widget>[
      if (faultLatched)
        MessageBanner(
          key: const ValueKey('heating-fault-latched'),
          message: l10n.lockFaultLatched,
        ),
      if (summary.suspended)
        MessageBanner(
          key: const ValueKey('heating-suspended-banner'),
          tone: MessageTone.warning,
          message: l10n.heatingSuspendedTitle,
          detail: [
            l10n.heatingSuspendedEffect,
            if (!permission.canSuspend)
              l10n.heatingSuspendedAskOwner
            else if (onResume == null)
              l10n.heatingSuspendedResumeHint,
          ].join(' '),
          action: permission.canSuspend && onResume != null
              ? OutlinedButton.icon(
                  key: const ValueKey('heating-resume'),
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.heatingResumeAction),
                )
              : null,
        ),
      if (device.dryRun)
        MessageBanner(
          key: const ValueKey('heating-dry-run-banner'),
          tone: MessageTone.warning,
          message: l10n.dryRunBanner,
        ),
      if (shown == null)
        Text(
          l10n.heatingStrategyNone,
          key: const ValueKey('heating-strategy-none'),
          style: textTheme.bodyMedium,
        )
      else
        Row(
          key: const ValueKey('heating-strategy'),
          children: [
            Icon(Icons.tune, size: 18, color: tokens.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.heatingStrategyTarget(
                      temp(shown.targetTemperatureCelsius),
                      temp(shown.hysteresisCelsius),
                    ),
                    style: GiFonts.monospace(textTheme.titleSmall)
                        .copyWith(color: tokens.text),
                  ),
                  // While suspended the effective mode is OFF by design;
                  // the suspension above says what that means.
                  if (!summary.suspended)
                    Text(_modeText(l10n, shown.mode), style: muted),
                ],
              ),
            ),
          ],
        ),
      if (summary.scheduleActive && base != null)
        Wrap(
          key: const ValueKey('heating-schedule-active'),
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusChip(
              label: l10n.heatingScheduleActive,
              icon: Icons.schedule,
              tone: StatusTone.info,
            ),
            Text(
              l10n.heatingStrategyDefault(
                temp(base.targetTemperatureCelsius),
                temp(base.hysteresisCelsius),
              ),
              style: muted,
            ),
          ],
        ),
      if (pvBoost != null)
        Row(
          key: const ValueKey('heating-pv-boost'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wb_sunny_outlined, size: 18, color: tokens.ember),
            const SizedBox(width: 8),
            Expanded(
              child: switch (pvBoost.derivedTargetCelsius) {
                final target? => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.heatingPvBoost(temp(target)),
                      style: textTheme.bodyMedium,
                    ),
                    Text(l10n.heatingPvBoostDerived, style: muted),
                  ],
                ),
                null => Text(
                  l10n.heatingPvBoostUnknownTarget,
                  style: textTheme.bodyMedium,
                ),
              },
            ),
          ],
        ),
      Text(
        l10n.heatingStrategySource(
          formatClockTime(l10n, detail.fetchedAt, now),
        ),
        key: const ValueKey('heating-strategy-source'),
        style: muted,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: 6),
          child,
        ],
      ],
    );
  }

  static String _modeText(AppLocalizations l10n, ControlStrategyMode mode) =>
      switch (mode) {
        ControlStrategyMode.auto => l10n.heatingStrategyModeAuto,
        ControlStrategyMode.off => l10n.heatingStrategyModeOff,
        ControlStrategyMode.manual => l10n.heatingStrategyModeManual,
        ControlStrategyMode.unknown => l10n.heatingStrategyModeUnknown,
      };
}
