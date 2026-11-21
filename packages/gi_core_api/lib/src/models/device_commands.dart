import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/device_detail.dart';

part 'device_commands.freezed.dart';
part 'device_commands.g.dart';

/// 200 body of `PUT /devices/:id/entities/:entityId/state`
/// (`esphome-switch-command.service.ts`).
///
/// **[state] is NOT the new state of the switch.** What it means depends on
/// the device's `communicationMode`, which the response does not carry (read
/// it from `GET /devices/:id`), and the response never states the outcome:
///
/// * `LEGACY_ESPHOME`: the value the device echoed back synchronously; the
///   entity was written with it and [confirmedAt] is that write time.
/// * `GI_EDGE_V1`, dry-run off: the *requested* value, written optimistically
///   before the controller acted; [confirmedAt] is the request time. Only a
///   heartbeat with `Device.lastSeenAt` after [confirmedAt] tells what the
///   controller did (`diagnostics.relayN`, see [DeviceDiagnostics.relay]).
/// * `GI_EDGE_V1`, dry-run on: the entity's *old* value; nothing was written
///   and [confirmedAt] is the request time, not persisted anywhere.
///
/// Firmware never confirms the physical relay state, so no branch proves the
/// relay switched (plan §12.2). [state] and [availability] are passed through
/// as raw JSON values.
@freezed
abstract class SwitchCommandResult with _$SwitchCommandResult {
  const factory({
    required String entityId,
    required DateTime confirmedAt,
    Object? state,
    Object? availability,
  }) = _SwitchCommandResult;

  factory fromJson(Map<String, dynamic> json) =>
      _$SwitchCommandResultFromJson(json);
}

/// 200 body of `PATCH /devices/:id/control-strategy`
/// (`control-strategy.service.ts`, a Prisma select).
///
/// [baseControlStrategy] is what the user set; [controlStrategy] is the
/// effective strategy after the synchronous reconcile (a matching heating
/// schedule's target and hysteresis, and mode `OFF` while heating is
/// suspended). Either decodes to `null` when the stored blob is unusable.
/// [configurationVersion] grows on every reconcile and is informational only
/// (plan L16): detect conflicts by comparing values.
@freezed
abstract class ControlStrategyUpdateResult with _$ControlStrategyUpdateResult {
  const factory({
    required int configurationVersion,
    @ControlStrategyConverter() ControlStrategy? controlStrategy,
    @ControlStrategyConverter() ControlStrategy? baseControlStrategy,
  }) = _ControlStrategyUpdateResult;

  factory fromJson(Map<String, dynamic> json) =>
      _$ControlStrategyUpdateResultFromJson(json);
}
