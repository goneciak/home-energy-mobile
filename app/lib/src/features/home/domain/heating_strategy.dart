import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// What the heating card says about control settings (plan §12.5, §20 M2
/// item 3), derived from one `GET /devices/:id`.
///
/// - [effective] is `controlStrategy`, the strategy pushed to the firmware;
///   [base] is `baseControlStrategy`, the user's default.
/// - [scheduleActive]: a heating schedule replaced the target or the
///   hysteresis. Only those two are compared, never `mode`: while heating
///   is suspended the reconciler writes `mode: OFF` into the effective
///   strategy, which is expected and shown as the suspension instead.
/// - `configurationVersion` is ignored: the schedule cron bumps it every
///   minute (L16), so it says nothing about a change.
@immutable
final class HeatingStrategySummary {
  const new({
    required this.effective,
    required this.base,
    required this.suspended,
    required this.scheduleActive,
    required this.pvBoost,
  });

  factory of(DeviceDetail device) {
    final effective = device.controlStrategy;
    final base = device.baseControlStrategy;
    final suspended = device.heatingSuspended;
    return HeatingStrategySummary(
      effective: effective,
      base: base,
      suspended: suspended,
      scheduleActive:
          !suspended &&
          effective != null &&
          base != null &&
          (effective.targetTemperatureCelsius !=
                  base.targetTemperatureCelsius ||
              effective.hysteresisCelsius != base.hysteresisCelsius),
      pvBoost: device.pvBoostActive
          ? PvBoost(
              derivedTargetCelsius:
                  device.pvHeatingConfig?.safeMaxTemperatureCelsius,
            )
          : null,
    );
  }

  final ControlStrategy? effective;
  final ControlStrategy? base;
  final bool suspended;
  final bool scheduleActive;

  /// `null` unless GI Core reports `pvBoostActive`.
  final PvBoost? pvBoost;

  /// The strategy to show as the current one: the effective one, or the
  /// base one when GI Core has not computed an effective one yet.
  ControlStrategy? get shown => effective ?? base;
}

/// An active PV-surplus boost. GI Core does not expose the boost target;
/// it boosts to `pvHeatingConfig.safeMaxTemperatureCelsius`, so the target
/// shown is derived from that and labelled as such. `null` when the
/// device has no PV heating configuration.
@immutable
final class PvBoost {
  const new({required this.derivedTargetCelsius});

  final double? derivedTargetCelsius;

  @override
  bool operator ==(Object other) =>
      other is PvBoost && other.derivedTargetCelsius == derivedTargetCelsius;

  @override
  int get hashCode => derivedTargetCelsius.hashCode;
}
