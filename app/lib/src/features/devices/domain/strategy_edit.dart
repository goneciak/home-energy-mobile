import 'package:gi_core_api/gi_core_api.dart';
import 'package:meta/meta.dart';

/// Limits of the control strategy editor (plan §12.5). GI Core accepts a
/// target of 0–100 °C; the UI is deliberately narrower.
abstract final class StrategyLimits {
  static const targetMin = 5.0;
  static const targetMax = 80.0;
  static const targetStep = 0.5;
  static const hysteresisMin = 1.0;
  static const hysteresisMax = 20.0;
  static const hysteresisStep = 0.5;
}

/// Why an editor field is not accepted.
enum StrategyFieldError {
  /// Empty or not a number.
  notANumber,

  /// Outside the field's range.
  outOfRange,

  /// Not a multiple of the field's step.
  notOnStep,
}

/// Client-side validation of the strategy editor, mirroring GI Core's DTO
/// (`targetTemperatureCelsius` 0–100, `hysteresisCelsius` 1–20, a known
/// mode) within the narrower UI limits of [StrategyLimits].
abstract final class StrategyValidation {
  /// Parses a decimal typed with either `,` or `.`; `null` when it is not a
  /// finite number.
  static double? parse(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value != null && value.isFinite ? value : null;
  }

  static StrategyFieldError? target(String text) => _check(
    text,
    StrategyLimits.targetMin,
    StrategyLimits.targetMax,
    StrategyLimits.targetStep,
  );

  static StrategyFieldError? hysteresis(String text) => _check(
    text,
    StrategyLimits.hysteresisMin,
    StrategyLimits.hysteresisMax,
    StrategyLimits.hysteresisStep,
  );

  static StrategyFieldError? _check(
    String text,
    double min,
    double max,
    double step,
  ) {
    final value = parse(text);
    if (value == null) return StrategyFieldError.notANumber;
    if (value < min || value > max) return StrategyFieldError.outOfRange;
    final steps = value / step;
    if ((steps - steps.round()).abs() > 1e-9) {
      return StrategyFieldError.notOnStep;
    }
    return null;
  }

  /// The strategy to send, or `null` when a field is invalid or [mode] is
  /// not a known mode.
  static ControlStrategy? draft({
    required String target,
    required String hysteresis,
    required ControlStrategyMode mode,
  }) {
    if (StrategyValidation.target(target) != null ||
        StrategyValidation.hysteresis(hysteresis) != null ||
        mode == ControlStrategyMode.unknown) {
      return null;
    }
    return ControlStrategy(
      targetTemperatureCelsius: parse(target)!,
      hysteresisCelsius: parse(hysteresis)!,
      mode: mode,
    );
  }
}

/// What an edit started from: the BASE strategy and the suspension
/// (plan §12.5). `configurationVersion` is deliberately absent: the
/// schedule cron bumps it every minute (L16), so only values are compared.
@immutable
final class StrategyBaseline {
  const new({required this.base, required this.suspended});

  factory of(DeviceDetail device) => StrategyBaseline(
    base: device.baseControlStrategy,
    suspended: device.heatingSuspended,
  );

  /// `null` when the device has no base strategy yet.
  final ControlStrategy? base;
  final bool suspended;

  @override
  bool operator ==(Object other) =>
      other is StrategyBaseline &&
      other.base == base &&
      other.suspended == suspended;

  @override
  int get hashCode => Object.hash(base, suspended);

  @override
  String toString() => 'StrategyBaseline($base, suspended: $suspended)';
}

/// A field that changed elsewhere while the user was editing.
enum StrategyConflictField { target, hysteresis, mode, suspended }

/// Someone changed the settings between opening the editor ([started]) and
/// saving ([current]).
@immutable
final class StrategyConflict {
  const new({required this.started, required this.current});

  final StrategyBaseline started;
  final StrategyBaseline current;

  /// The conflict between [started] and [current], or `null` when the
  /// values are the same.
  static StrategyConflict? detect(
    StrategyBaseline started,
    StrategyBaseline current,
  ) => started == current
      ? null
      : StrategyConflict(started: started, current: current);

  /// What differs, in display order. A base strategy that appeared or
  /// disappeared counts as every strategy field changing.
  List<StrategyConflictField> get fields {
    final a = started.base;
    final b = current.base;
    return [
      if (a?.targetTemperatureCelsius != b?.targetTemperatureCelsius)
        StrategyConflictField.target,
      if (a?.hysteresisCelsius != b?.hysteresisCelsius)
        StrategyConflictField.hysteresis,
      if (a?.mode != b?.mode) StrategyConflictField.mode,
      if (started.suspended != current.suspended)
        StrategyConflictField.suspended,
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is StrategyConflict &&
      other.started == started &&
      other.current == current;

  @override
  int get hashCode => Object.hash(started, current);

  @override
  String toString() => 'StrategyConflict($started -> $current)';
}
