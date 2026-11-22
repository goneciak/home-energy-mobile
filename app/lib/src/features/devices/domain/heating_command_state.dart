import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:meta/meta.dart';

// ---------------------------------------------------------------------------
// Suspend / resume (plan §12.1)
// ---------------------------------------------------------------------------

/// Where a `PATCH /devices/:id {"heatingSuspended": …}` stands. Nothing is
/// optimistic: the screen keeps showing the last reported flag until a
/// re-read of the device shows the new one.
@immutable
sealed class SuspensionState {
  const new();

  /// A request or the confirmation polling is running; a new one is
  /// ignored.
  bool get isBusy => false;
}

final class SuspensionIdle extends SuspensionState {
  const new();

  @override
  bool operator ==(Object other) => other is SuspensionIdle;

  @override
  int get hashCode => 0;
}

/// [SafetyPolicy] refused the action on the current data.
final class SuspensionLocked extends SuspensionState {
  const new(this.decision);

  final Locked decision;

  LockReason get reason => decision.primary;

  @override
  bool operator ==(Object other) =>
      other is SuspensionLocked && other.decision == decision;

  @override
  int get hashCode => decision.hashCode;
}

/// The `PATCH` is in flight.
final class SuspensionSending extends SuspensionState {
  const new({required this.suspend});

  final bool suspend;

  @override
  bool get isBusy => true;

  @override
  bool operator ==(Object other) =>
      other is SuspensionSending && other.suspend == suspend;

  @override
  int get hashCode => suspend.hashCode;
}

/// GI Core accepted the `PATCH` at [requestedAt] (its `updatedAt`, server
/// clock); the device is re-read until `heatingSuspended` (and, on resume,
/// the effective mode) shows the change.
final class SuspensionAwaiting extends SuspensionState {
  const new({required this.suspend, required this.requestedAt});

  final bool suspend;
  final DateTime requestedAt;

  @override
  bool get isBusy => true;

  @override
  bool operator ==(Object other) =>
      other is SuspensionAwaiting &&
      other.suspend == suspend &&
      other.requestedAt == requestedAt;

  @override
  int get hashCode => Object.hash(suspend, requestedAt);
}

/// What the controller reported about its relays after a suspension.
enum RelayReport {
  /// `LEGACY_ESPHOME`: GI Core sends the relay-off commands to GI Edge
  /// controllers only, so nothing about the relays follows.
  notApplicable,

  /// GI Edge: waiting for a heartbeat after the `PATCH`.
  awaitingHeartbeat,

  /// A heartbeat after the `PATCH` reports every relay output off. The
  /// firmware never verifies the physical relay (plan §12.2).
  outputsOff,

  /// A heartbeat after the `PATCH` still reports an output on.
  outputOn,

  /// A heartbeat after the `PATCH` carries no relay outputs.
  notReported,

  /// No heartbeat after the `PATCH` within the command TTL.
  noHeartbeat,
}

/// `heatingSuspended` is now `true` on GI Core.
final class SuspendApplied extends SuspensionState {
  const new({required this.relays, this.heartbeatAt});

  final RelayReport relays;

  /// Device-level `lastSeenAt` of the heartbeat [relays] comes from.
  final DateTime? heartbeatAt;

  /// Still polling for the heartbeat.
  @override
  bool get isBusy => relays == RelayReport.awaitingHeartbeat;

  @override
  bool operator ==(Object other) =>
      other is SuspendApplied &&
      other.relays == relays &&
      other.heartbeatAt == heartbeatAt;

  @override
  int get hashCode => Object.hash(relays, heartbeatAt);
}

/// `heatingSuspended` is now `false` on GI Core. [strategyRestored]: the
/// effective mode is the base one again (or there is no base strategy);
/// `false` when the reconcile had not happened when polling stopped.
final class ResumeApplied extends SuspensionState {
  const new({required this.strategyRestored});

  final bool strategyRestored;

  @override
  bool operator ==(Object other) =>
      other is ResumeApplied && other.strategyRestored == strategyRestored;

  @override
  int get hashCode => strategyRestored.hashCode;
}

/// The flag did not change within the polling window.
final class SuspensionTimedOut extends SuspensionState {
  const new({required this.suspend});

  final bool suspend;

  @override
  bool operator ==(Object other) =>
      other is SuspensionTimedOut && other.suspend == suspend;

  @override
  int get hashCode => suspend.hashCode;
}

final class SuspensionFailed extends SuspensionState {
  const new({required this.suspend, required this.failure});

  final bool suspend;
  final ApiFailure failure;

  @override
  bool operator ==(Object other) =>
      other is SuspensionFailed &&
      other.suspend == suspend &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(suspend, failure);
}

/// The relay report of [device] for a suspension requested at
/// [requestedAt]: a heartbeat counts only when the device-level `lastSeenAt`
/// is strictly after it (server clock on both sides) and, with
/// [requireCommandedOff], no relay still reports `commanded: true`.
RelayReport relayReportAfter(
  DeviceDetail device,
  DateTime requestedAt, {
  bool requireCommandedOff = true,
}) {
  final seenAt = device.lastSeenAt;
  if (seenAt == null || !seenAt.isAfter(requestedAt)) {
    return RelayReport.awaitingHeartbeat;
  }
  final relays = [
    for (final entity in device.entities)
      if (entity.domain == EntityDomain.switch_)
        if (relayIndexOf(entity) case final index?)
          ?device.diagnostics?.relay(index),
  ];
  // Heartbeats and command delivery are separate channels in GI Core: a
  // heartbeat sent before the OFF commands were applied still reports
  // `commanded: true` and is not the report on the suspend.
  if (requireCommandedOff && relays.any((relay) => relay.commanded ?? false)) {
    return RelayReport.awaitingHeartbeat;
  }
  final outputs = [for (final relay in relays) ?relay.output];
  if (outputs.isEmpty) return RelayReport.notReported;
  return outputs.every((on) => !on)
      ? RelayReport.outputsOff
      : RelayReport.outputOn;
}

// ---------------------------------------------------------------------------
// Strategy editor (plan §12.5)
// ---------------------------------------------------------------------------

@immutable
sealed class StrategyEditState {
  const new();

  bool get isBusy => false;
}

final class StrategyEditIdle extends StrategyEditState {
  const new();

  @override
  bool operator ==(Object other) => other is StrategyEditIdle;

  @override
  int get hashCode => 0;
}

/// Re-reading the device before the `PATCH`.
final class StrategyEditChecking extends StrategyEditState {
  const new();

  @override
  bool get isBusy => true;

  @override
  bool operator ==(Object other) => other is StrategyEditChecking;

  @override
  int get hashCode => 1;
}

/// The settings changed elsewhere; nothing was sent. The user reapplies
/// (against [conflict]'s current values) or discards.
final class StrategyEditConflict extends StrategyEditState {
  const new(this.conflict);

  final StrategyConflict conflict;

  @override
  bool operator ==(Object other) =>
      other is StrategyEditConflict && other.conflict == conflict;

  @override
  int get hashCode => conflict.hashCode;
}

/// [SafetyPolicy] refused the edit on the re-read data.
final class StrategyEditLocked extends StrategyEditState {
  const new(this.decision);

  final Locked decision;

  @override
  bool operator ==(Object other) =>
      other is StrategyEditLocked && other.decision == decision;

  @override
  int get hashCode => decision.hashCode;
}

final class StrategyEditSaving extends StrategyEditState {
  const new();

  @override
  bool get isBusy => true;

  @override
  bool operator ==(Object other) => other is StrategyEditSaving;

  @override
  int get hashCode => 2;
}

/// GI Core stored the base strategy; [result] carries the base and the
/// effective strategy after its synchronous reconcile.
final class StrategyEditSaved extends StrategyEditState {
  const new({required this.result, required this.suspended});

  final ControlStrategyUpdateResult result;

  /// Heating was suspended when saving: the effective mode stays OFF.
  final bool suspended;

  @override
  bool operator ==(Object other) =>
      other is StrategyEditSaved &&
      other.result == result &&
      other.suspended == suspended;

  @override
  int get hashCode => Object.hash(result, suspended);
}

final class StrategyEditFailed extends StrategyEditState {
  const new(this.failure);

  final ApiFailure failure;

  @override
  bool operator ==(Object other) =>
      other is StrategyEditFailed && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
