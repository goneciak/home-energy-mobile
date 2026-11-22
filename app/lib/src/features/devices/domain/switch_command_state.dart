import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:meta/meta.dart';

/// Where one switch command stands (plan §12.2, M2 item 2).
///
/// No state says the relay physically switched: the firmware never confirms
/// the physical relay (backend `docs/safety.md`: `confirmed_physical_state`
/// is always UNKNOWN). The best a state can say is that the device echoed
/// the command ([SwitchLegacyConfirmed]) or what the controller reported in
/// its next heartbeat ([SwitchHeartbeatObserved], [SwitchDryRunRecorded]).
@immutable
sealed class SwitchCommandState {
  const new();

  /// A request or confirmation is in flight; a second submit is ignored.
  bool get isBusy => this is SwitchSending || this is SwitchAwaitingHeartbeat;
}

/// Nothing sent yet (or the last outcome was dismissed).
final class SwitchIdle extends SwitchCommandState {
  const new();

  @override
  bool operator ==(Object other) => other is SwitchIdle;

  @override
  int get hashCode => (SwitchIdle).hashCode;

  @override
  String toString() => 'SwitchIdle()';
}

/// [SafetyPolicy] refused the command before anything was sent.
final class SwitchLocked extends SwitchCommandState {
  const new(this.decision);

  final Locked decision;

  LockReason get reason => decision.primary;

  @override
  bool operator ==(Object other) =>
      other is SwitchLocked && other.decision == decision;

  @override
  int get hashCode => decision.hashCode;

  @override
  String toString() => 'SwitchLocked($decision)';
}

/// The `PUT` is in flight.
final class SwitchSending extends SwitchCommandState {
  const new({required this.requested});

  final bool requested;

  @override
  bool operator ==(Object other) =>
      other is SwitchSending && other.requested == requested;

  @override
  int get hashCode => Object.hash(SwitchSending, requested);

  @override
  String toString() => 'SwitchSending($requested)';
}

/// `LEGACY_ESPHOME`: the device echoed the command synchronously. This is
/// "the device confirmed the command", not a verified relay position.
final class SwitchLegacyConfirmed extends SwitchCommandState {
  const new({required this.state, required this.confirmedAt});

  /// The echoed value as GI Core stored it.
  final bool state;

  /// Server time of the confirmation.
  final DateTime confirmedAt;

  @override
  bool operator ==(Object other) =>
      other is SwitchLegacyConfirmed &&
      other.state == state &&
      other.confirmedAt == confirmedAt;

  @override
  int get hashCode => Object.hash(state, confirmedAt);

  @override
  String toString() => 'SwitchLegacyConfirmed($state, $confirmedAt)';
}

/// `GI_EDGE_V1`: the command was queued; waiting for a heartbeat whose
/// device-level `lastSeenAt` is strictly after [confirmedAt].
final class SwitchAwaitingHeartbeat extends SwitchCommandState {
  const new({
    required this.requested,
    required this.confirmedAt,
    required this.dryRun,
  });

  final bool requested;

  /// Server time of the request (`confirmedAt` of the `PUT` response).
  final DateTime confirmedAt;

  /// The device was in dry-run when the command was sent.
  final bool dryRun;

  @override
  bool operator ==(Object other) =>
      other is SwitchAwaitingHeartbeat &&
      other.requested == requested &&
      other.confirmedAt == confirmedAt &&
      other.dryRun == dryRun;

  @override
  int get hashCode => Object.hash(requested, confirmedAt, dryRun);

  @override
  String toString() =>
      'SwitchAwaitingHeartbeat($requested, $confirmedAt, dryRun: $dryRun)';
}

/// `GI_EDGE_V1`: a heartbeat arrived after the command. [commanded] is what
/// the firmware was asked to do and [output] what it drives
/// (`diagnostics.relayN`); either is `null` when the heartbeat does not
/// report it. Neither is the physical relay state.
final class SwitchHeartbeatObserved extends SwitchCommandState {
  const new({
    required this.requested,
    required this.commanded,
    required this.output,
    required this.seenAt,
  });

  final bool requested;
  final bool? commanded;
  final bool? output;

  /// Device-level `lastSeenAt` of the heartbeat (server time).
  final DateTime seenAt;

  @override
  bool operator ==(Object other) =>
      other is SwitchHeartbeatObserved &&
      other.requested == requested &&
      other.commanded == commanded &&
      other.output == output &&
      other.seenAt == seenAt;

  @override
  int get hashCode => Object.hash(requested, commanded, output, seenAt);

  @override
  String toString() =>
      'SwitchHeartbeatObserved($requested, commanded: $commanded, '
      'output: $output, at: $seenAt)';
}

/// `GI_EDGE_V1` in dry-run: a heartbeat arrived after the command; the
/// firmware recorded it ([commanded]) but its outputs stay off.
final class SwitchDryRunRecorded extends SwitchCommandState {
  const new({
    required this.requested,
    required this.commanded,
    required this.output,
    required this.seenAt,
  });

  final bool requested;
  final bool? commanded;
  final bool? output;
  final DateTime seenAt;

  @override
  bool operator ==(Object other) =>
      other is SwitchDryRunRecorded &&
      other.requested == requested &&
      other.commanded == commanded &&
      other.output == output &&
      other.seenAt == seenAt;

  @override
  int get hashCode => Object.hash(requested, commanded, output, seenAt);

  @override
  String toString() =>
      'SwitchDryRunRecorded($requested, commanded: $commanded, '
      'output: $output, at: $seenAt)';
}

/// `GI_EDGE_V1`: no heartbeat within the command's TTL. The state of the
/// switch is unknown until the device is refreshed.
final class SwitchTimedOut extends SwitchCommandState {
  const new({required this.requested, required this.confirmedAt});

  final bool requested;
  final DateTime confirmedAt;

  @override
  bool operator ==(Object other) =>
      other is SwitchTimedOut &&
      other.requested == requested &&
      other.confirmedAt == confirmedAt;

  @override
  int get hashCode => Object.hash(SwitchTimedOut, requested, confirmedAt);

  @override
  String toString() => 'SwitchTimedOut($requested, $confirmedAt)';
}

/// The `PUT` failed. Never retried automatically.
final class SwitchFailed extends SwitchCommandState {
  const new({required this.requested, required this.failure});

  final bool requested;
  final ApiFailure failure;

  /// The device may or may not have executed the command (502/504, no
  /// answer): the state is unknown until refreshed.
  bool get outcomeUnknown => failure.isCommandOutcomeUnknown;

  @override
  bool operator ==(Object other) =>
      other is SwitchFailed &&
      other.requested == requested &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(requested, failure);

  @override
  String toString() => 'SwitchFailed($requested, $failure)';
}

final _relayName = RegExp(r'^relay_?(\d+)$', caseSensitive: false);

/// The GI Edge relay number of [entity] (`relay_N` / `relayN` as its
/// external id, exposed as `sourceName`), or `null` when it is not a relay.
int? relayIndexOf(DeviceEntity entity) {
  final match = _relayName.firstMatch(entity.sourceName.trim());
  return match == null ? null : int.parse(match.group(1)!);
}

/// Whether GI Core wrote switch [entity] of GI Edge [device] after the last
/// heartbeat. Core sets `entity.value`/`entity.lastSeenAt` optimistically
/// when it queues a command, so such a value is requested, not reported
/// (plan §12.2, ADR 0009). A heartbeat itself rewrites relay entities a
/// moment after the device row, hence the [heartbeatWriteSlack]. Always
/// `false` for other modes.
bool switchValueUnconfirmed(DeviceDetail device, DeviceEntity entity) {
  if (device.communicationMode != CommunicationMode.giEdgeV1) return false;
  final heartbeatAt = device.lastSeenAt;
  if (heartbeatAt == null) return true;
  final writtenAt = entity.lastSeenAt;
  return writtenAt != null &&
      writtenAt.isAfter(heartbeatAt.add(heartbeatWriteSlack));
}

/// How long after the device row a heartbeat may still write its entities.
const heartbeatWriteSlack = Duration(seconds: 2);

/// The last *reported* state of switch [entity] of [device], or `null` when
/// unknown or not yet reported by the device.
///
/// On GI Edge relays reported in `diagnostics.relayN` (written only by a
/// heartbeat) it is the driven `output`, or in dry-run (where `output` stays
/// off) the `commanded` state the controller keeps; `entity.value` is not
/// used there, since Core writes it optimistically on enqueue. Other GI
/// Edge switches use the entity value unless [switchValueUnconfirmed];
/// every other mode uses the entity value.
bool? reportedSwitchState(DeviceDetail device, DeviceEntity entity) {
  final entityValue = switch (entity.value) {
    EntityValueBoolean(:final value) => value,
    _ => null,
  };
  if (device.communicationMode != CommunicationMode.giEdgeV1) {
    return entityValue;
  }
  final index = relayIndexOf(entity);
  final relay = index == null ? null : device.diagnostics?.relay(index);
  if (relay != null) {
    return device.dryRun ? relay.commanded : relay.output;
  }
  return switchValueUnconfirmed(device, entity) ? null : entityValue;
}
