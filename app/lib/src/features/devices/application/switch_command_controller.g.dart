// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_command_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(SwitchCommandController)
final switchCommandControllerProvider = SwitchCommandControllerFamily._();

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
final class SwitchCommandControllerProvider
    extends $NotifierProvider<SwitchCommandController, SwitchCommandState> {
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
  SwitchCommandControllerProvider._({
    required SwitchCommandControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'switchCommandControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$switchCommandControllerHash();

  @override
  String toString() {
    return r'switchCommandControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SwitchCommandController create() => SwitchCommandController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwitchCommandState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwitchCommandState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SwitchCommandControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$switchCommandControllerHash() =>
    r'0d047203febb534e1acf889dcf199767201cb909';

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

final class SwitchCommandControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SwitchCommandController,
          SwitchCommandState,
          SwitchCommandState,
          SwitchCommandState,
          (String, String)
        > {
  SwitchCommandControllerFamily._()
    : super(
        retry: null,
        name: r'switchCommandControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  SwitchCommandControllerProvider call(String deviceId, String entityId) =>
      SwitchCommandControllerProvider._(
        argument: (deviceId, entityId),
        from: this,
      );

  @override
  String toString() => r'switchCommandControllerProvider';
}

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

abstract class _$SwitchCommandController extends $Notifier<SwitchCommandState> {
  late final _$args = ref.$arg as (String, String);
  String get deviceId => _$args.$1;
  String get entityId => _$args.$2;

  SwitchCommandState build(String deviceId, String entityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SwitchCommandState, SwitchCommandState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SwitchCommandState, SwitchCommandState>,
              SwitchCommandState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
