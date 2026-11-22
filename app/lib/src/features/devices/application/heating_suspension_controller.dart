import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/polling_budget.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_detail_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'heating_suspension_controller.g.dart';

/// Suspends or resumes heating of device [deviceId] (plan §12.1, M2 item 5)
/// with `PATCH /devices/:id {"heatingSuspended": …}` and nothing else.
///
/// * Never optimistic: after a 200 the device is re-read every
///   [pollInterval] until `heatingSuspended` shows the request. GI Core
///   turns the relays off and rewrites the effective strategy
///   asynchronously, after answering.
/// * Suspend on `GI_EDGE_V1`: GI Core commands every switch OFF. Once the
///   flag is set, polling goes on until a heartbeat strictly after the
///   `PATCH` (its `updatedAt`, server clock) reports every
///   `diagnostics.relayN.commanded` off, then its outputs ([RelayReport]).
///   At [heartbeatTimeout] the last heartbeat after the `PATCH` is reported
///   as it is, or [RelayReport.noHeartbeat] without one; no claim about
///   the physical relay is ever made.
///   `LEGACY_ESPHOME` relays are not switched by that command
///   ([RelayReport.notApplicable]).
/// * Resume: polling goes on until the effective mode is the base mode
///   again (the reconciler restores it), or [confirmTimeout] passes.
/// * Nothing is retried automatically; a submit while busy is ignored.
@riverpod
class HeatingSuspensionController extends _$HeatingSuspensionController {
  static const Duration pollInterval = PollingBudget.postCommandPoll;

  /// How long the flag (and, on resume, the restored mode) is waited for.
  static const confirmTimeout = Duration(seconds: 30);

  /// How long a GI Edge report is waited for once the flag is set (plan
  /// §12.2): longer than the 30 s heartbeat interval plus a few polls. Not
  /// the command TTL.
  static const heartbeatTimeout = Duration(seconds: 45);

  ForegroundPoller? _poller;
  Timer? _deadline;
  Timer? _firstPoll;

  @override
  SuspensionState build(String deviceId) {
    ref.onDispose(_stopPolling);
    return const SuspensionIdle();
  }

  /// Suspends ([suspend] `true`, after the hold gesture) or resumes (after
  /// the consequence sheet). [freshness] is the policy the screen judges
  /// the device data with.
  Future<void> submit({
    required bool suspend,
    FreshnessPolicy freshness = FreshnessPolicy.deviceDetail,
  }) async {
    if (state.isBusy) return;
    final permission = HeatingPermission.of(
      ref.read(currentUserProvider)?.role,
    );
    final fetched = ref.read(devicesRepositoryProvider).lastDevice(deviceId);
    final SafetyDecision decision;
    if (suspend) {
      decision = SafetyPolicy.evaluateSuspend(permission: permission);
    } else if (fetched == null) {
      decision = Locked(const [LockReason.staleData]);
    } else {
      decision = SafetyPolicy.evaluateResume(
        data: DeviceSnapshot(
          device: fetched.value,
          fetchedAt: fetched.fetchedAt,
          freshness: freshness,
        ),
        permission: permission,
        now: ref.read(clockProvider)(),
      );
    }
    if (decision is Locked) {
      state = SuspensionLocked(decision);
      return;
    }

    state = SuspensionSending(suspend: suspend);
    final DeviceListItem response;
    try {
      response = await ref
          .read(deviceCommandSourceProvider)
          .setHeatingSuspended(deviceId, suspended: suspend);
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return;
      state = SuspensionFailed(suspend: suspend, failure: failure);
      await _refreshDevice();
      return;
    }
    if (!ref.mounted) return;
    state = SuspensionAwaiting(
      suspend: suspend,
      requestedAt: response.updatedAt,
    );
    _poll(confirmTimeout, onTimeout: _confirmTimedOut);
  }

  /// "Odśwież" after a timeout or failure: re-reads the device and forgets
  /// the outcome.
  Future<void> refresh() async {
    if (state.isBusy) return;
    await _refreshDevice();
    if (ref.mounted && !state.isBusy) state = const SuspensionIdle();
  }

  /// Hides a finished outcome or lock message.
  void dismiss() {
    if (!state.isBusy) state = const SuspensionIdle();
  }

  // The request time of the running command, kept across states.
  DateTime? _requestedAt;

  void _poll(Duration timeout, {required void Function() onTimeout}) {
    _stopPolling();
    if (state case SuspensionAwaiting(:final requestedAt)) {
      _requestedAt = requestedAt;
    }
    final poller = _poller = ForegroundPoller(
      foreground: ref.read(appForegroundProvider),
      interval: pollInterval,
      task: () async {
        await _refreshDevice();
        if (ref.mounted) _check();
      },
      now: ref.read(clockProvider),
    );
    _deadline = Timer(timeout, () {
      if (ref.mounted) onTimeout();
    });
    // GI Core answers before its async side effects; the first re-read
    // waits one interval.
    _firstPoll = Timer(pollInterval, () {
      if (identical(_poller, poller)) poller.start();
    });
  }

  void _check() {
    final current = state;
    final requestedAt = _requestedAt;
    final device = ref.read(devicesRepositoryProvider).lastDevice(deviceId);
    if (device == null || requestedAt == null) return;
    final detail = device.value;
    switch (current) {
      case SuspensionAwaiting(suspend: true):
        if (!detail.heatingSuspended) return;
        if (detail.communicationMode != CommunicationMode.giEdgeV1) {
          _stopPolling();
          state = const SuspendApplied(relays: RelayReport.notApplicable);
          return;
        }
        state = const SuspendApplied(relays: RelayReport.awaitingHeartbeat);
        _restartDeadline(heartbeatTimeout, _heartbeatTimedOut);
        _checkHeartbeat(detail, requestedAt);
      case SuspendApplied(relays: RelayReport.awaitingHeartbeat):
        _checkHeartbeat(detail, requestedAt);
      case SuspensionAwaiting(suspend: false):
        if (detail.heatingSuspended) return;
        if (_strategyRestored(detail)) {
          _stopPolling();
          state = const ResumeApplied(strategyRestored: true);
        }
      default:
        return;
    }
  }

  void _checkHeartbeat(DeviceDetail detail, DateTime requestedAt) {
    final report = relayReportAfter(detail, requestedAt);
    if (report == RelayReport.awaitingHeartbeat) return;
    _stopPolling();
    state = SuspendApplied(relays: report, heartbeatAt: detail.lastSeenAt);
  }

  /// The reconciler restored the base mode (nothing to restore without a
  /// base or effective strategy).
  static bool _strategyRestored(DeviceDetail detail) {
    final base = detail.baseControlStrategy;
    final effective = detail.controlStrategy;
    return base == null || effective == null || effective.mode == base.mode;
  }

  void _confirmTimedOut() {
    final current = state;
    if (current is! SuspensionAwaiting) return;
    _stopPolling();
    final device = ref.read(devicesRepositoryProvider).lastDevice(deviceId);
    // Resumed, but the mode is not back yet: say so instead of a timeout.
    if (!current.suspend && device != null && !device.value.heatingSuspended) {
      state = const ResumeApplied(strategyRestored: false);
      return;
    }
    state = SuspensionTimedOut(suspend: current.suspend);
  }

  void _heartbeatTimedOut() {
    if (state case SuspendApplied(relays: RelayReport.awaitingHeartbeat)) {
      _stopPolling();
      final requestedAt = _requestedAt;
      final detail = ref
          .read(devicesRepositoryProvider)
          .lastDevice(deviceId)
          ?.value;
      final report = detail == null || requestedAt == null
          ? RelayReport.awaitingHeartbeat
          : relayReportAfter(detail, requestedAt, requireCommandedOff: false);
      state = report == RelayReport.awaitingHeartbeat
          ? const SuspendApplied(relays: RelayReport.noHeartbeat)
          : SuspendApplied(relays: report, heartbeatAt: detail?.lastSeenAt);
    }
  }

  void _restartDeadline(Duration timeout, void Function() onTimeout) {
    _deadline?.cancel();
    _deadline = Timer(timeout, () {
      if (ref.mounted) onTimeout();
    });
  }

  /// Re-reads the device through the details screen's poller when it is
  /// open (so the screen shows it at once), otherwise the repository.
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

  void _stopPolling() {
    _deadline?.cancel();
    _deadline = null;
    _firstPoll?.cancel();
    _firstPoll = null;
    _poller?.dispose();
    _poller = null;
  }
}
