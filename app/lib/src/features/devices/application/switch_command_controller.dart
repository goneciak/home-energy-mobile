import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/domain/switch_command_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'switch_command_controller.g.dart';

/// One switch command of entity [entityId] on device [deviceId], without
/// optimism (plan §12.2, M2 item 2).
///
/// * The communication mode comes from `GET /devices/:id`, never from the
///   `PUT` response, which does not carry it.
/// * `LEGACY_ESPHOME`: a 200 means the device echoed the command
///   ([SwitchLegacyConfirmed]).
/// * `GI_EDGE_V1`: a 200 only means queued. The device is re-read every
///   [heartbeatPollInterval] until its device-level `lastSeenAt` is strictly
///   after the response's `confirmedAt` (both server time) **and** its
///   `diagnostics.relayN.commanded` equals the request, then
///   `diagnostics.relayN` is reported ([SwitchHeartbeatObserved], or
///   [SwitchDryRunRecorded] in dry-run). Heartbeats and command delivery are
///   separate channels in GI Core, so a heartbeat sent before the command
///   was applied still carries the old `commanded` and is not taken as the
///   report. The response's `state` is never taken as the new state: in
///   dry-run it is the OLD value. At [heartbeatTimeout] the last heartbeat
///   after `confirmedAt` is reported as it is; with none the outcome is
///   [SwitchTimedOut].
/// * Any failure re-reads the device. Nothing is retried automatically and a
///   submit while busy is ignored.
@riverpod
class SwitchCommandController extends _$SwitchCommandController {
  /// How long a GI Edge report is waited for (plan §12.2). Longer than the
  /// firmware heartbeat interval (30 s) plus a few polls, so a heartbeat
  /// landing late in the window is still read; this is not the command TTL
  /// (30 s, `gi-edge-command.service.ts`).
  static const heartbeatTimeout = Duration(seconds: 45);

  static const heartbeatPollInterval = Duration(seconds: 2);

  ForegroundPoller? _poller;
  Timer? _deadline;

  // The last heartbeat after `confirmedAt` whose `commanded` did not (yet)
  // match the request; reported as it is at the deadline.
  ({RelayDiagnostics? relay, DateTime seenAt})? _unmatched;

  @override
  SwitchCommandState build(String deviceId, String entityId) {
    ref.onDispose(_stopWaiting);
    return const SwitchIdle();
  }

  /// Asks to set the switch to [requestedOn] after the user confirmed it
  /// (`ConfirmationPolicy`). [freshness] is the policy the screen judges the
  /// device data with.
  Future<void> submit({
    required bool requestedOn,
    FreshnessPolicy freshness = FreshnessPolicy.deviceDetail,
  }) async {
    if (state.isBusy) return;
    final repository = ref.read(devicesRepositoryProvider);
    final fetched = repository.lastDevice(deviceId);
    if (fetched == null) {
      state = SwitchLocked(Locked(const [LockReason.staleData]));
      return;
    }
    final device = fetched.value;
    final decision = SafetyPolicy.evaluateSwitch(
      data: DeviceSnapshot(
        device: device,
        fetchedAt: fetched.fetchedAt,
        freshness: freshness,
      ),
      entityId: entityId,
      requestedOn: requestedOn,
      permission: HeatingPermission.of(ref.read(currentUserProvider)?.role),
      now: ref.read(clockProvider)(),
    );
    if (decision is Locked) {
      state = SwitchLocked(decision);
      return;
    }

    final source = ref.read(deviceCommandSourceProvider);
    state = SwitchSending(requested: requestedOn);
    final SwitchCommandResult result;
    try {
      result = await source.setSwitchState(
        deviceId,
        entityId,
        state: requestedOn,
      );
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return;
      state = SwitchFailed(requested: requestedOn, failure: failure);
      await _refreshDevice();
      return;
    }
    if (!ref.mounted) return;

    if (device.communicationMode != CommunicationMode.giEdgeV1) {
      // Every other mode takes GI Core's synchronous ESPHome path.
      final echoed = result.state;
      if (echoed is bool) {
        state = SwitchLegacyConfirmed(
          state: echoed,
          confirmedAt: result.confirmedAt,
        );
      } else {
        state = SwitchFailed(
          requested: requestedOn,
          failure: const ApiFailure.unexpectedResponse(statusCode: 200),
        );
      }
      await _refreshDevice();
      return;
    }

    state = SwitchAwaitingHeartbeat(
      requested: requestedOn,
      confirmedAt: result.confirmedAt,
      dryRun: device.dryRun,
    );
    _waitForHeartbeat();
  }

  /// "Odśwież" after a timeout or failure: re-reads the device and forgets
  /// the outcome, so the screen shows the last reported state.
  Future<void> refresh() async {
    if (state.isBusy) return;
    await _refreshDevice();
    if (ref.mounted && !state.isBusy) state = const SwitchIdle();
  }

  /// Hides a finished outcome or lock message.
  void dismiss() {
    if (!state.isBusy) state = const SwitchIdle();
  }

  void _waitForHeartbeat() {
    _stopWaiting();
    final poller = _poller = ForegroundPoller(
      foreground: ref.read(appForegroundProvider),
      interval: heartbeatPollInterval,
      task: () async {
        await _refreshDevice();
        if (ref.mounted) _checkHeartbeat();
      },
      now: ref.read(clockProvider),
    );
    _deadline = Timer(heartbeatTimeout, () {
      if (!ref.mounted) return;
      if (state case final SwitchAwaitingHeartbeat waiting) {
        final unmatched = _unmatched;
        _stopWaiting();
        state = unmatched == null
            ? SwitchTimedOut(
                requested: waiting.requested,
                confirmedAt: waiting.confirmedAt,
              )
            : _report(waiting, unmatched.relay, unmatched.seenAt);
      }
    });
    // The first re-read waits one interval: the controller's next
    // heartbeat cannot be there yet.
    Timer(heartbeatPollInterval, () {
      if (identical(_poller, poller)) poller.start();
    });
  }

  void _checkHeartbeat() {
    final waiting = state;
    if (waiting is! SwitchAwaitingHeartbeat) return;
    final device = ref.read(devicesRepositoryProvider).lastDevice(deviceId);
    final seenAt = device?.value.lastSeenAt;
    // Server clock on both sides; `entity.value`/`entity.lastSeenAt` are
    // written optimistically on enqueue and never count (plan §12.2).
    if (device == null ||
        seenAt == null ||
        !seenAt.isAfter(waiting.confirmedAt)) {
      return;
    }
    final entity = device.value.entityById(entityId);
    final index = entity == null ? null : relayIndexOf(entity);
    final relay = index == null ? null : device.value.diagnostics?.relay(index);
    // A heartbeat sent before the controller applied the command carries the
    // old `commanded`; keep waiting for one that reflects the request.
    final commanded = relay?.commanded;
    if (commanded != null && commanded != waiting.requested) {
      _unmatched = (relay: relay, seenAt: seenAt);
      return;
    }
    _stopWaiting();
    state = _report(waiting, relay, seenAt);
  }

  static SwitchCommandState _report(
    SwitchAwaitingHeartbeat waiting,
    RelayDiagnostics? relay,
    DateTime seenAt,
  ) => waiting.dryRun
      ? SwitchDryRunRecorded(
          requested: waiting.requested,
          commanded: relay?.commanded,
          output: relay?.output,
          seenAt: seenAt,
        )
      : SwitchHeartbeatObserved(
          requested: waiting.requested,
          commanded: relay?.commanded,
          output: relay?.output,
          seenAt: seenAt,
        );

  /// Re-reads the device through the details screen's poller when it is
  /// open (so the screen shows it at once), otherwise the repository.
  /// Failures are left to the screen: the outcome state stays as it is.
  Future<void> _refreshDevice() async {
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

  void _stopWaiting() {
    _unmatched = null;
    _deadline?.cancel();
    _deadline = null;
    _poller?.dispose();
    _poller = null;
  }
}
