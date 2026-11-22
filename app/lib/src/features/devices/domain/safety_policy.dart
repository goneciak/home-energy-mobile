import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:meta/meta.dart';

/// Why a heating control is locked (plan §12). Declared in display priority:
/// the first reason of a [Locked] decision is the one the UI explains.
enum LockReason {
  /// The role may not call the endpoint (plan §12.8); controls are hidden.
  notOwnerAdmin,

  /// The device's heating or pump relay: read-only in v1 (plan §12.4).
  heatingOrPumpRelay,

  /// The entity is not (or no longer) part of the device.
  entityMissing,

  /// Not a writable switch (`ENTITY_NOT_WRITABLE`).
  notWritableSwitch,

  /// The entity is disabled (`ENTITY_DISABLED`).
  entityDisabled,

  /// The entity reports no availability.
  entityUnavailable,

  /// `connectivityState` is not ONLINE, the data is older than its freshness
  /// window or it comes from a snapshot (plan §12.6). Intentionally stricter
  /// than GI Core, which only checks the stored device status.
  staleData,

  /// Turning a switch ON while heating is suspended (`HEATING_SUSPENDED`).
  /// Applies to every switch of the device; OFF is always allowed.
  suspendedOnRequest,

  /// Firmware in FAULT or SAFE_MODE: latched until an authorized manual
  /// reset on the device; there is no reset API (plan §12.7). Blocks ON only.
  faultLatched,
}

/// Result of a [SafetyPolicy] check.
@immutable
sealed class SafetyDecision {
  const new();

  bool get isAllowed => this is Allowed;
}

/// The action may be offered.
final class Allowed extends SafetyDecision {
  const new();

  @override
  bool operator ==(Object other) => other is Allowed;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'Allowed()';
}

/// The action must not be offered; [reasons] are distinct and sorted by
/// priority.
final class Locked extends SafetyDecision {
  new(Iterable<LockReason> reasons)
    : assert(reasons.isNotEmpty, 'Locked needs at least one reason'),
      reasons = List.unmodifiable(reasons.toSet().toList()..sort(_byPriority));

  static int _byPriority(LockReason a, LockReason b) => a.index - b.index;

  final List<LockReason> reasons;

  /// The reason the UI explains first.
  LockReason get primary => reasons.first;

  /// Whether the control is hidden rather than shown disabled.
  bool get hidesControl => reasons.contains(LockReason.notOwnerAdmin);

  @override
  bool operator ==(Object other) =>
      other is Locked && _sameList(other.reasons, reasons);

  @override
  int get hashCode => Object.hashAll(reasons);

  @override
  String toString() => 'Locked($reasons)';
}

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The device data a decision is based on, with when it was received.
@immutable
final class DeviceSnapshot {
  const new({
    required this.device,
    required this.fetchedAt,
    this.fromSnapshot = false,
    this.currentState,
    this.freshness = FreshnessPolicy.deviceDetail,
  });

  final DeviceDetail device;
  final DateTime fetchedAt;

  /// Data restored from a cache or snapshot rather than a live response.
  final bool fromSnapshot;

  /// Firmware state merged from list and diagnostics (`ControllerStatus`);
  /// falls back to `device.diagnostics.currentState` when `null`.
  final FirmwareState? currentState;

  final FreshnessPolicy freshness;

  FirmwareState? get effectiveState =>
      currentState ?? device.diagnostics?.currentState;

  /// Whether control decisions may rely on this data (plan §12.6).
  bool isTrustworthyAt(DateTime now) =>
      !fromSnapshot &&
      device.connectivityState == ConnectivityState.online &&
      !freshness.isStale(fetchedAt, now);
}

/// Pure safety rules for heating controls (plan §12, PRD §8.6/§10.4).
///
/// Never optimistic: a decision only says whether a control may be offered;
/// GI Core and the firmware remain the authority and their errors are shown.
abstract final class SafetyPolicy {
  /// Whether switch [entityId] may be set to [requestedOn].
  static SafetyDecision evaluateSwitch({
    required DeviceSnapshot data,
    required String entityId,
    required bool requestedOn,
    required HeatingPermission permission,
    required DateTime now,
  }) {
    final device = data.device;
    final entity = device.entityById(entityId);
    return _decide([
      if (!permission.canSwitch) LockReason.notOwnerAdmin,
      if (entityId == device.heatingRelayEntityId ||
          entityId == device.pumpRelayEntityId)
        LockReason.heatingOrPumpRelay,
      if (entity == null)
        LockReason.entityMissing
      else ...[
        if (entity.domain != EntityDomain.switch_ || !entity.writable)
          LockReason.notWritableSwitch,
        if (!entity.enabled) LockReason.entityDisabled,
        if (!entity.availability) LockReason.entityUnavailable,
      ],
      if (!data.isTrustworthyAt(now)) LockReason.staleData,
      if (requestedOn && device.heatingSuspended) LockReason.suspendedOnRequest,
      if (requestedOn && (data.effectiveState?.isCritical ?? false))
        LockReason.faultLatched,
    ]);
  }

  /// Suspending heating is the safe direction, so it stays available on
  /// stale data, in a fault and in dry-run (plan §12.6).
  static SafetyDecision evaluateSuspend({
    required HeatingPermission permission,
  }) => _decide([if (!permission.canSuspend) LockReason.notOwnerAdmin]);

  /// Resuming heating may start the boiler, so it needs live data.
  static SafetyDecision evaluateResume({
    required DeviceSnapshot data,
    required HeatingPermission permission,
    required DateTime now,
  }) => _decide([
    if (!permission.canSuspend) LockReason.notOwnerAdmin,
    if (!data.isTrustworthyAt(now)) LockReason.staleData,
  ]);

  /// Opening the control strategy editor (plan §12.5, §12.6).
  static SafetyDecision evaluateStrategyEdit({
    required DeviceSnapshot data,
    required HeatingPermission permission,
    required DateTime now,
  }) => _decide([
    if (!permission.canEditStrategy) LockReason.notOwnerAdmin,
    if (!data.isTrustworthyAt(now)) LockReason.staleData,
  ]);

  static SafetyDecision _decide(List<LockReason> reasons) =>
      reasons.isEmpty ? const Allowed() : Locked(reasons);
}
