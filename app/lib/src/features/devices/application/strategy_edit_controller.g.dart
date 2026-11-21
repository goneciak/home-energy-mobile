// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(StrategyEditController)
final strategyEditControllerProvider = StrategyEditControllerFamily._();

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
final class StrategyEditControllerProvider
    extends $NotifierProvider<StrategyEditController, StrategyEditState> {
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
  StrategyEditControllerProvider._({
    required StrategyEditControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'strategyEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$strategyEditControllerHash();

  @override
  String toString() {
    return r'strategyEditControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StrategyEditController create() => StrategyEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StrategyEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StrategyEditState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StrategyEditControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$strategyEditControllerHash() =>
    r'67f610edec1cda835a4e2c329a4f7fed5190ca97';

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

final class StrategyEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StrategyEditController,
          StrategyEditState,
          StrategyEditState,
          StrategyEditState,
          String
        > {
  StrategyEditControllerFamily._()
    : super(
        retry: null,
        name: r'strategyEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  StrategyEditControllerProvider call(String deviceId) =>
      StrategyEditControllerProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'strategyEditControllerProvider';
}

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

abstract class _$StrategyEditController extends $Notifier<StrategyEditState> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  StrategyEditState build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StrategyEditState, StrategyEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StrategyEditState, StrategyEditState>,
              StrategyEditState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
