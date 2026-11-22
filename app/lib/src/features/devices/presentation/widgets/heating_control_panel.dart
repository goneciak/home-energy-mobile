import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/hold_to_confirm_button.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/core/widgets/section_header.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/heating_suspension_controller.dart';
import 'package:gi_home/src/features/devices/domain/confirmation_policy.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/presentation/device_labels.dart';
import 'package:gi_home/src/features/devices/presentation/heating_safety_labels.dart';
import 'package:gi_home/src/features/devices/presentation/widgets/strategy_editor_sheet.dart';
import 'package:gi_home/src/features/home/domain/heating_readings.dart';
import 'package:material_ui/material_ui.dart';

/// Heating controls of a heating device on its details screen (plan §12.1,
/// §12.5, M2 items 4–5), for OWNER/ADMIN only (plan §12.8):
///
/// * not suspended: press-and-hold "suspend" ([HoldToConfirmButton]);
/// * suspended: "resume" behind the consequence sheet ([ResumeSheet]);
/// * the strategy editor ([StrategyEditorSheet]), locked on stale data;
/// * the outcome of the last suspend/resume.
class HeatingControlPanel extends ConsumerWidget {
  const new({
    required this.detail,
    required this.freshness,
    required this.now,
    super.key,
  });

  final Fetched<DeviceDetail> detail;

  /// The policy the screen judges [detail] with.
  final FreshnessPolicy freshness;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final device = detail.value;
    final permission = HeatingPermission.of(
      ref.watch(currentUserProvider.select((user) => user?.role)),
    );
    final provider = heatingSuspensionControllerProvider(device.id);
    final command = ref.watch(provider);
    if (!permission.canSuspend && !permission.canEditStrategy) {
      return const SizedBox.shrink();
    }
    final snapshot = DeviceSnapshot(
      device: device,
      fetchedAt: detail.fetchedAt,
      freshness: freshness,
    );
    final editDecision = SafetyPolicy.evaluateStrategyEdit(
      data: snapshot,
      permission: permission,
      now: now,
    );
    final resumeDecision = SafetyPolicy.evaluateResume(
      data: snapshot,
      permission: permission,
      now: now,
    );

    Future<void> suspend() =>
        ref.read(provider.notifier).submit(suspend: true, freshness: freshness);

    Future<void> accessibleSuspend() async {
      if (await showSuspendConfirmation(context)) await suspend();
    }

    Future<void> resume() async {
      if (await showResumeSheet(context, detail: detail, now: now)) {
        await ref
            .read(provider.notifier)
            .submit(suspend: false, freshness: freshness);
      }
    }

    final children = <Widget>[
      if (permission.canSuspend)
        if (device.heatingSuspended)
          if (resumeDecision case Locked(:final primary))
            MessageBanner(
              tone: MessageTone.warning,
              message: lockReasonText(l10n, primary),
            )
          else
            FilledButton.icon(
              key: const ValueKey('heating-resume'),
              onPressed: command.isBusy ? null : resume,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.heatingResumeAction),
            )
        else
          HoldToConfirmButton(
            key: const ValueKey('heating-suspend-hold'),
            label: l10n.suspendHoldAction,
            icon: Icons.pause_circle_outline,
            hint: l10n.suspendHoldHint,
            semanticsHint: l10n.suspendA11yHint,
            onConfirmed: command.isBusy ? null : suspend,
            onAccessibleActivate: command.isBusy ? null : accessibleSuspend,
          ),
      if (SuspensionOutcome.visible(command))
        SuspensionOutcome(
          state: command,
          now: now,
          onRefresh: () => ref.read(provider.notifier).refresh(),
        ),
      if (permission.canEditStrategy)
        if (editDecision case Locked(:final primary))
          Text(
            lockReasonText(l10n, primary),
            key: const ValueKey('strategy-edit-locked'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: tokens.textMuted),
          )
        else
          OutlinedButton.icon(
            key: const ValueKey('strategy-edit'),
            onPressed: () => showStrategyEditor(context, detail: detail),
            icon: const Icon(Icons.tune),
            label: Text(l10n.strategyEditAction),
          ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.heatingControlSection),
        Padding(
          padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) const SizedBox(height: 8),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The accessible path of the hold gesture: a dialog naming what
/// suspending does. Resolves to `true` only on "Wstrzymaj ogrzewanie".
Future<bool> showSuspendConfirmation(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.suspendConfirmTitle),
      content: Text(consequenceText(l10n, Consequence.stopsHeating)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey('suspend-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.suspendConfirmAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Asks before resuming (plan §12.1). Resolves to `true` only on
/// "Wznów ogrzewanie".
Future<bool> showResumeSheet(
  BuildContext context, {
  required Fetched<DeviceDetail> detail,
  required DateTime now,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => ResumeSheet(detail: detail, now: now),
  );
  return confirmed ?? false;
}

/// The consequence sheet of resuming heating (plan §12.1, PRD §8.6): the
/// consequences from `ConfirmationPolicy`, the setting that will apply and
/// the control temperature with the age of its data.
class ResumeSheet extends StatelessWidget {
  const new({required this.detail, required this.now, super.key});

  final Fetched<DeviceDetail> detail;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final device = detail.value;
    final requirement = ConfirmationPolicy.of(const ResumeHeating(), device);
    final base = device.baseControlStrategy;
    final temperature = HeatingReadings.of(device).controlTemperature;
    final value = temperature?.value;

    Widget line(IconData icon, String text, {Key? key}) => Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, tokens.gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.resumeSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.gap),
            for (final consequence in requirement.consequences)
              line(Icons.info_outline, consequenceText(l10n, consequence)),
            if (base != null)
              line(
                Icons.tune,
                l10n.resumeSheetWillApply(strategyValueText(l10n, base)),
                key: const ValueKey('resume-will-apply'),
              ),
            line(
              Icons.thermostat,
              value == null
                  ? l10n.resumeSheetTemperatureMissing
                  : l10n.resumeSheetTemperature(
                      _withUnit(
                        formatTemperature(l10n, value),
                        temperature?.unit,
                      ),
                      formatClockTime(l10n, detail.fetchedAt, now),
                    ),
              key: const ValueKey('resume-temperature'),
            ),
            SizedBox(height: tokens.gap),
            FilledButton(
              key: const ValueKey('resume-confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.heatingResumeAction),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }

  static String _withUnit(String text, String? unit) =>
      unit == null ? text : '$text $unit';
}

/// "55,0 °C, histereza 4,0 °C, Auto".
String strategyValueText(AppLocalizations l10n, ControlStrategy strategy) =>
    l10n.strategyValue(
      formatTemperature(l10n, strategy.targetTemperatureCelsius),
      formatTemperature(l10n, strategy.hysteresisCelsius),
      strategyModeShort(l10n, strategy.mode),
    );

String strategyModeShort(AppLocalizations l10n, ControlStrategyMode mode) =>
    switch (mode) {
      ControlStrategyMode.auto => l10n.strategyModeAutoShort,
      ControlStrategyMode.off => l10n.strategyModeOffShort,
      ControlStrategyMode.manual => l10n.strategyModeManualShort,
      ControlStrategyMode.unknown => l10n.heatingStrategyModeUnknown,
    };

/// The outcome of the last suspend or resume. Never claims a physical relay
/// state (plan §12.2).
class SuspensionOutcome extends StatelessWidget {
  const new({
    required this.state,
    required this.now,
    required this.onRefresh,
    super.key,
  });

  /// Whether [state] has anything to show.
  static bool visible(SuspensionState state) => state is! SuspensionIdle;

  final SuspensionState state;
  final DateTime now;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final refresh = OutlinedButton(
      key: const ValueKey('suspension-refresh'),
      onPressed: onRefresh,
      child: Text(l10n.actionRefresh),
    );
    String time(DateTime? at) =>
        at == null ? l10n.commonNoDataValue : formatClockTime(l10n, at, now);
    return KeyedSubtree(
      key: const ValueKey('suspension-outcome'),
      child: switch (state) {
        SuspensionIdle() => const SizedBox.shrink(),
        SuspensionLocked(:final reason) => MessageBanner(
          tone: MessageTone.warning,
          message: lockReasonText(l10n, reason),
        ),
        SuspensionSending() => _Progress(l10n.switchCommandSending),
        SuspensionAwaiting(:final suspend) => _Progress(
          suspend ? l10n.suspendAwaiting : l10n.resumeAwaiting,
        ),
        SuspendApplied(:final relays, :final heartbeatAt) => switch (relays) {
          RelayReport.awaitingHeartbeat => _Progress(
            l10n.suspendAppliedAwaitingHeartbeat,
          ),
          RelayReport.notApplicable => MessageBanner(
            tone: MessageTone.info,
            message: l10n.suspendAppliedLegacy,
          ),
          RelayReport.outputsOff => MessageBanner(
            tone: MessageTone.info,
            message: l10n.suspendAppliedOutputsOff(time(heartbeatAt)),
          ),
          RelayReport.outputOn => MessageBanner(
            message: l10n.suspendAppliedOutputOn(time(heartbeatAt)),
            action: refresh,
          ),
          RelayReport.notReported => MessageBanner(
            tone: MessageTone.warning,
            message: l10n.suspendAppliedNotReported,
          ),
          RelayReport.noHeartbeat => MessageBanner(
            tone: MessageTone.warning,
            message: l10n.suspendAppliedNoHeartbeat,
            action: refresh,
          ),
        },
        ResumeApplied(:final strategyRestored) => MessageBanner(
          tone: strategyRestored ? MessageTone.info : MessageTone.warning,
          message: strategyRestored
              ? l10n.resumeApplied
              : l10n.resumeAppliedPending,
          action: strategyRestored ? null : refresh,
        ),
        SuspensionTimedOut(:final suspend) => MessageBanner(
          tone: MessageTone.warning,
          message: suspend ? l10n.suspendTimedOut : l10n.resumeTimedOut,
          action: refresh,
        ),
        SuspensionFailed(:final failure) => MessageBanner(
          message: failureMessage(l10n, failure),
          detail: failureRequestIdLine(l10n, failure),
          monospaceDetail: true,
          action: refresh,
        ),
      },
    );
  }
}

class _Progress extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      const SizedBox(width: 12),
      Expanded(child: Semantics(liveRegion: true, child: Text(text))),
    ],
  );
}
