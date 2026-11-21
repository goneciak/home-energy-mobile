import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// A heating write the user is about to make.
@immutable
sealed class HeatingAction {
  const new();
}

/// `PATCH /devices/:id {"heatingSuspended": true}`.
final class SuspendHeating extends HeatingAction {
  const new();
}

/// `PATCH /devices/:id {"heatingSuspended": false}`.
final class ResumeHeating extends HeatingAction {
  const new();
}

/// `PUT /devices/:id/entities/:entityId/state`.
final class SetSwitch extends HeatingAction {
  const new({required this.on});

  final bool on;
}

/// `PATCH /devices/:id/control-strategy` from [from] (the base strategy when
/// the editor opened; `null` when the device had none) to [to].
final class ChangeStrategy extends HeatingAction {
  const new({required this.from, required this.to});

  final ControlStrategy? from;
  final ControlStrategy to;
}

/// How the user confirms an action (plan §12.1, §12.5).
enum ConfirmationKind {
  /// A plain tap is enough.
  none,

  /// Press and hold (~600 ms), also exposed as an accessibility action.
  hold,

  /// A sheet listing the consequences with an explicit confirm button.
  sheet,
}

/// A consequence a confirmation names (PRD §8.6: effect and recovery).
enum Consequence {
  /// Suspend: GI Home turns heating off; resume to undo.
  stopsHeating,

  /// Resume: the boiler may start within ~30 s.
  boilerMayStartSoon,

  /// Resume: the default setting or the active schedule applies again.
  restoresBaseOrSchedule,

  /// Switch ON: the command is sent; the physical relay is not verified.
  commandNotPhysicallyVerified,

  /// Strategy: target raised by more than [ConfirmationPolicy.largeRaise].
  largeTargetRaise,

  /// Strategy: leaving OFF lets GI Home control the boiler again.
  leavesOffMode,

  /// Strategy: target above `pvHeatingConfig.safeMaxTemperatureCelsius`.
  aboveSafeMax,

  /// Dry-run: commands are recorded but outputs stay off (plan §12.3).
  dryRunOutputsStayOff,
}

/// What a confirmation must show.
@immutable
final class ConfirmationRequirement {
  const new(this.kind, [this.consequences = const []]);

  static const none = ConfirmationRequirement(ConfirmationKind.none);

  final ConfirmationKind kind;
  final List<Consequence> consequences;

  bool get needsConfirmation => kind != ConfirmationKind.none;

  @override
  bool operator ==(Object other) =>
      other is ConfirmationRequirement &&
      other.kind == kind &&
      other.consequences.length == consequences.length &&
      Iterable<int>.generate(consequences.length)
          .every((i) => other.consequences[i] == consequences[i]);

  @override
  int get hashCode => Object.hash(kind, Object.hashAll(consequences));

  @override
  String toString() => 'ConfirmationRequirement($kind, $consequences)';
}

/// Which heating actions need explicit confirmation (plan §12.1, §12.5).
abstract final class ConfirmationPolicy {
  /// Raising the target by more than this needs confirmation (plan §12.5).
  static const largeRaise = 10.0;

  static ConfirmationRequirement of(HeatingAction action, DeviceDetail device) {
    final dryRun = [if (device.dryRun) Consequence.dryRunOutputsStayOff];
    switch (action) {
      case SuspendHeating():
        // OFF is the safe direction: hold to confirm, no dialog (§12.1).
        return const ConfirmationRequirement(ConfirmationKind.hold, [
          Consequence.stopsHeating,
        ]);
      case ResumeHeating():
        return ConfirmationRequirement(ConfirmationKind.sheet, [
          Consequence.boilerMayStartSoon,
          Consequence.restoresBaseOrSchedule,
          ...dryRun,
        ]);
      case SetSwitch(on: false):
        return ConfirmationRequirement.none;
      case SetSwitch(on: true):
        return ConfirmationRequirement(ConfirmationKind.sheet, [
          Consequence.commandNotPhysicallyVerified,
          ...dryRun,
        ]);
      case ChangeStrategy(:final from, :final to):
        final safeMax = device.pvHeatingConfig?.safeMaxTemperatureCelsius;
        final consequences = [
          if (from != null &&
              to.targetTemperatureCelsius - from.targetTemperatureCelsius >
                  largeRaise)
            Consequence.largeTargetRaise,
          if (from?.mode == ControlStrategyMode.off &&
              to.mode != ControlStrategyMode.off)
            Consequence.leavesOffMode,
          if (safeMax != null && to.targetTemperatureCelsius > safeMax)
            Consequence.aboveSafeMax,
        ];
        if (consequences.isEmpty) return ConfirmationRequirement.none;
        return ConfirmationRequirement(ConfirmationKind.sheet, [
          ...consequences,
          ...dryRun,
        ]);
    }
  }
}
