import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strategy_edit_controller.g.dart';

/// Saves the BASE control strategy of device [deviceId] (plan §12.5, M2
/// item 4) with value-based conflict detection:
///
/// 1. re-read `GET /devices/:id`;
/// 2. compare its base strategy (target, hysteresis, mode) and
///    `heatingSuspended` with the [StrategyBaseline] the edit started from,
///    never `configurationVersion` (bumped every minute by the schedule
///    cron, L16). A difference stops here with [StrategyEditConflict];
/// 3. otherwise `PATCH /devices/:id/control-strategy` with all three
///    fields, never retried automatically.
@riverpod
class StrategyEditController extends _$StrategyEditController {
  @override
  StrategyEditState build(String deviceId) => const StrategyEditIdle();

  /// Saves [draft], edited from [startedFrom]. To reapply after a
  /// conflict, call it again with the conflict's current baseline.
  Future<void> submit({
    required StrategyBaseline startedFrom,
    required ControlStrategy draft,
  }) async {
    if (state.isBusy) return;
    state = const StrategyEditChecking();
    final DeviceDetail fresh;
    final DateTime fetchedAt;
    try {
      final fetched = await ref
          .read(devicesRepositoryProvider)
          .fetchDevice(deviceId);
      fresh = fetched.value;
      fetchedAt = fetched.fetchedAt;
    } on ApiFailure catch (failure) {
      if (ref.mounted) state = StrategyEditFailed(failure);
      return;
    }
    if (!ref.mounted) return;

    final decision = SafetyPolicy.evaluateStrategyEdit(
      data: DeviceSnapshot(device: fresh, fetchedAt: fetchedAt),
      permission: HeatingPermission.of(ref.read(currentUserProvider)?.role),
      now: ref.read(clockProvider)(),
    );
    if (decision is Locked) {
      state = StrategyEditLocked(decision);
      return;
    }
    final conflict = StrategyConflict.detect(
      startedFrom,
      StrategyBaseline.of(fresh),
    );
    if (conflict != null) {
      state = StrategyEditConflict(conflict);
      return;
    }

    state = const StrategyEditSaving();
    try {
      final result = await ref
          .read(deviceCommandSourceProvider)
          .updateControlStrategy(deviceId, draft);
      if (!ref.mounted) return;
      state = StrategyEditSaved(
        result: result,
        suspended: fresh.heatingSuspended,
      );
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return;
      state = StrategyEditFailed(failure);
    }
    await _refreshDevice();
  }

  /// Forgets the outcome (closing the editor, discarding after a conflict).
  void reset() {
    if (!state.isBusy) state = const StrategyEditIdle();
  }

  Future<void> _refreshDevice() async {
    if (!ref.mounted) return;
    if (ref.read(deviceDetailProvider(deviceId).exists)) {
      await ref.read(deviceDetailProvider(deviceId).notifier).refresh();
      return;
    }
    try {
      await ref.read(devicesRepositoryProvider).fetchDevice(deviceId);
    } on ApiFailure {
      // Shown by the next poll of the screen.
    }
  }
}
