import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/domain/confirmation_policy.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';

/// Status and next action of a locked heating control (PRD §8.6).
String lockReasonText(AppLocalizations l10n, LockReason reason) =>
    switch (reason) {
      LockReason.notOwnerAdmin => l10n.lockNotOwnerAdmin,
      LockReason.heatingOrPumpRelay => l10n.lockHeatingOrPumpRelay,
      LockReason.entityMissing => l10n.lockEntityMissing,
      LockReason.notWritableSwitch => l10n.lockNotWritableSwitch,
      LockReason.entityDisabled => l10n.lockEntityDisabled,
      LockReason.entityUnavailable => l10n.lockEntityUnavailable,
      LockReason.staleData => l10n.lockStaleData,
      LockReason.suspendedOnRequest => l10n.lockSuspendedOnRequest,
      LockReason.faultLatched => l10n.lockFaultLatched,
    };

/// Effect and recovery of a confirmed heating action (PRD §8.6).
String consequenceText(AppLocalizations l10n, Consequence consequence) =>
    switch (consequence) {
      Consequence.stopsHeating => l10n.consequenceStopsHeating,
      Consequence.boilerMayStartSoon => l10n.consequenceBoilerMayStartSoon,
      Consequence.restoresBaseOrSchedule =>
        l10n.consequenceRestoresBaseOrSchedule,
      Consequence.commandNotPhysicallyVerified =>
        l10n.consequenceCommandNotPhysicallyVerified,
      Consequence.largeTargetRaise => l10n.consequenceLargeTargetRaise,
      Consequence.leavesOffMode => l10n.consequenceLeavesOffMode,
      Consequence.aboveSafeMax => l10n.consequenceAboveSafeMax,
      Consequence.dryRunOutputsStayOff => l10n.consequenceDryRunOutputsStayOff,
    };
