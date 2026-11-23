import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/errors/failure_messages.dart';
import 'package:gi_home/src/core/formatting/time_format.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:gi_home/src/core/widgets/freshness_label.dart';
import 'package:gi_home/src/core/widgets/message_banner.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/switch_command_controller.dart';
import 'package:gi_home/src/features/devices/domain/confirmation_policy.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:gi_home/src/features/devices/presentation/heating_safety_labels.dart';
import 'package:material_ui/material_ui.dart';

/// The control below a switch entity on the device details screen (plan
/// §12.2, §12.4, §12.6): the toggle when the role may switch and
/// [SafetyPolicy] allows the change, otherwise the lock reason, plus the
/// outcome of the last command.
class SwitchEntityControl extends ConsumerWidget {
  const new({
    required this.detail,
    required this.entity,
    required this.freshness,
    required this.now,
    super.key,
  });

  final Fetched<DeviceDetail> detail;
  final DeviceEntity entity;

  /// The policy the screen judges [detail] with.
  final FreshnessPolicy freshness;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = detail.value;
    final permission = HeatingPermission.of(
      ref.watch(currentUserProvider.select((user) => user?.role)),
    );
    final provider = switchCommandControllerProvider(device.id, entity.id);
    final command = ref.watch(provider);
    // Never the optimistic `entity.value` of a GI Edge relay (plan §12.2).
    final current = reportedSwitchState(device, entity);
    final relayIndex = device.communicationMode == CommunicationMode.giEdgeV1
        ? relayIndexOf(entity)
        : null;
    final commanded = relayIndex == null
        ? null
        : device.diagnostics?.relay(relayIndex)?.commanded;
    final decision = SafetyPolicy.evaluateSwitch(
      data: DeviceSnapshot(
        device: device,
        fetchedAt: detail.fetchedAt,
        freshness: freshness,
      ),
      entityId: entity.id,
      requestedOn: !(current ?? false),
      permission: permission,
      now: now,
    );

    Future<void> toggle(bool on) async {
      final requirement = ConfirmationPolicy.of(SetSwitch(on: on), device);
      if (requirement.needsConfirmation) {
        final confirmed = await showSwitchConfirmation(
          context,
          name: entity.displayName,
          requirement: requirement,
        );
        if (!confirmed) return;
      }
      await ref
          .read(provider.notifier)
          .submit(requestedOn: on, freshness: freshness);
    }

    return SwitchCommandPanel(
      entityName: entity.displayName,
      current: current,
      decision: decision,
      command: command,
      fetchedAt: detail.fetchedAt,
      now: now,
      onToggle: toggle,
      onRefresh: () => ref.read(provider.notifier).refresh(),
      commanded: commanded,
      dryRun: device.dryRun,
    );
  }
}

/// Asks before a switch command that needs it (`ConfirmationPolicy`),
/// naming its consequences. Resolves to `true` only on "Wyślij polecenie".
Future<bool> showSwitchConfirmation(
  BuildContext context, {
  required String name,
  required ConfirmationRequirement requirement,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) =>
        SwitchConfirmationSheet(name: name, requirement: requirement),
  );
  return confirmed ?? false;
}

/// The consequence sheet of a switch command (PRD §8.6).
class SwitchConfirmationSheet extends StatelessWidget {
  const new({required this.name, required this.requirement, super.key});

  final String name;
  final ConfirmationRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, tokens.gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.switchConfirmOnTitle(name),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.gap),
            for (final consequence in requirement.consequences)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(consequenceText(l10n, consequence))),
                  ],
                ),
              ),
            SizedBox(height: tokens.gap),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.switchConfirmSend),
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
}

/// What [SwitchEntityControl] shows, without providers (goldens, tests).
///
/// The toggle appears only when [decision] allows the change and no command
/// is in flight; it always shows the last *reported* value ([current]),
/// never the requested one (no optimistic UI).
class SwitchCommandPanel extends StatelessWidget {
  const new({
    required this.entityName,
    required this.current,
    required this.decision,
    required this.command,
    required this.fetchedAt,
    required this.now,
    required this.onToggle,
    required this.onRefresh,
    this.commanded,
    this.dryRun = false,
    super.key,
  });

  final String entityName;

  /// What the controller commands the relay to (`diagnostics.relayN
  /// .commanded`), shown read-only for boiler and pump relays (plan §12.4)
  /// and as the dry-run hint (§12.3); `null` when not reported.
  final bool? commanded;

  /// The device is in dry-run: outputs do not switch.
  final bool dryRun;

  /// Last reported value of the switch; `null` when unknown.
  final bool? current;

  /// [SafetyPolicy] decision for switching to `!current`.
  final SafetyDecision decision;
  final SwitchCommandState command;

  /// When the device data was received, for the stale lock.
  final DateTime fetchedAt;
  final DateTime now;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = GiTokens.of(context);
    final decision = this.decision;
    final current = this.current;
    final commanded = this.commanded;
    final textTheme = Theme.of(context).textTheme;
    final readOnlyRelay =
        decision is Locked &&
        decision.reasons.contains(LockReason.heatingOrPumpRelay);
    final commandedHint = commanded == null || !(dryRun || readOnlyRelay)
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (dryRun
                  ? l10n.switchDryRunWouldSet
                  : l10n.switchControllerCommanded)(
                commanded ? l10n.entityValueOn : l10n.entityValueOff,
              ),
              key: const ValueKey('switch-commanded'),
              style: textTheme.bodySmall,
            ),
          );
    // Heating and pump relays are read-only for every role (plan §12.4).
    if (readOnlyRelay) {
      return Padding(
        padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LockLine(lockReasonText(l10n, LockReason.heatingOrPumpRelay)),
            ?commandedHint,
          ],
        ),
      );
    }
    // A role that may not switch sees the plain reading only (plan §12.8).
    if (decision is Locked && decision.hidesControl) {
      return commandedHint == null
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, 8),
              child: commandedHint,
            );
    }
    final canToggle = decision.isAllowed && current != null && !command.isBusy;

    final children = <Widget>[
      if (decision is Locked) _LockLine(lockReasonText(l10n, decision.primary)),
      if (decision is Locked && decision.primary == LockReason.staleData)
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 26),
          child: FreshnessLabel(updatedAt: fetchedAt, now: now, isStale: true),
        ),
      if (canToggle)
        Row(
          children: [
            Expanded(
              child: Text(
                current ? l10n.entityValueOn : l10n.entityValueOff,
                style: textTheme.bodyMedium,
              ),
            ),
            Semantics(
              label: entityName,
              child: Switch(
                key: const ValueKey('switch-toggle'),
                value: current,
                onChanged: onToggle,
              ),
            ),
          ],
        ),
      ?commandedHint,
      if (_outcome(l10n, now) case final outcome?)
        Padding(padding: const EdgeInsets.only(top: 8), child: outcome),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.gap, 0, tokens.gap, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget? _outcome(AppLocalizations l10n, DateTime now) {
    String onOff(bool? value) => switch (value) {
      true => l10n.entityValueOn,
      false => l10n.entityValueOff,
      null => l10n.switchValueAwaitingReport,
    };
    final refresh = OutlinedButton(
      key: const ValueKey('switch-refresh'),
      onPressed: onRefresh,
      child: Text(l10n.actionRefresh),
    );
    return switch (command) {
      SwitchIdle() => null,
      SwitchLocked(:final reason) => MessageBanner(
        tone: MessageTone.warning,
        message: lockReasonText(l10n, reason),
      ),
      SwitchSending() => Row(
        key: const ValueKey('switch-sending'),
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(l10n.switchCommandSending),
            ),
          ),
        ],
      ),
      SwitchLegacyConfirmed(:final state, :final confirmedAt) => MessageBanner(
        tone: MessageTone.info,
        message: l10n.switchCommandLegacyConfirmed(
          onOff(state),
          formatClockTime(l10n, confirmedAt, now),
        ),
      ),
      SwitchAwaitingHeartbeat() => Row(
        key: const ValueKey('switch-awaiting'),
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(l10n.switchCommandAwaitingHeartbeat),
            ),
          ),
        ],
      ),
      SwitchHeartbeatObserved(:final commanded, :final output) => MessageBanner(
        tone: MessageTone.info,
        message: l10n.switchCommandHeartbeatObserved(
          onOff(commanded),
          onOff(output),
        ),
      ),
      SwitchDryRunRecorded(:final commanded) => MessageBanner(
        tone: MessageTone.warning,
        message: l10n.switchCommandDryRunRecorded(onOff(commanded)),
      ),
      SwitchTimedOut() => MessageBanner(
        tone: MessageTone.warning,
        message: l10n.switchCommandTimedOut,
        action: refresh,
      ),
      SwitchFailed(:final failure) => MessageBanner(
        message: failureMessage(l10n, failure),
        detail: failureRequestIdLine(l10n, failure),
        monospaceDetail: true,
        action: refresh,
      ),
    };
  }
}

class _LockLine extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = GiTokens.of(context);
    return Row(
      key: const ValueKey('switch-lock'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 18, color: tokens.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
        ),
      ],
    );
  }
}
