// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heating_suspension_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(HeatingSuspensionController)
final heatingSuspensionControllerProvider =
    HeatingSuspensionControllerFamily._();

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
final class HeatingSuspensionControllerProvider
    extends $NotifierProvider<HeatingSuspensionController, SuspensionState> {
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
  HeatingSuspensionControllerProvider._({
    required HeatingSuspensionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'heatingSuspensionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$heatingSuspensionControllerHash();

  @override
  String toString() {
    return r'heatingSuspensionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HeatingSuspensionController create() => HeatingSuspensionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuspensionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuspensionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HeatingSuspensionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$heatingSuspensionControllerHash() =>
    r'c9f9d5d3619d1e094641d7bed1695bdc0db50529';

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

final class HeatingSuspensionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HeatingSuspensionController,
          SuspensionState,
          SuspensionState,
          SuspensionState,
          String
        > {
  HeatingSuspensionControllerFamily._()
    : super(
        retry: null,
        name: r'heatingSuspensionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  HeatingSuspensionControllerProvider call(String deviceId) =>
      HeatingSuspensionControllerProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'heatingSuspensionControllerProvider';
}

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

abstract class _$HeatingSuspensionController
    extends $Notifier<SuspensionState> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  SuspensionState build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SuspensionState, SuspensionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SuspensionState, SuspensionState>,
              SuspensionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
