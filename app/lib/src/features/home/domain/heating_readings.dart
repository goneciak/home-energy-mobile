import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/entity_presentation.dart';
import 'package:meta/meta.dart';

/// Last reported state of a boiler or pump relay entity.
///
/// It is the state the controller commanded and Core stored, not proof that
/// the relay physically switched (plan §12.2, §12.4).
enum RelayState {
  on,
  off,

  /// The entity is missing from the device or reports no usable value.
  noData,

  /// The entity is disabled or not available.
  unavailable,
}

/// Availability of a reading taken from an entity.
enum ReadingStatus {
  ok,
  noData,
  unavailable,

  /// The sensor has been silent for longer than [sensorStaleAfter]; its
  /// last value is not shown as current.
  stale,
}

/// Control temperature reading: a number when the entity reports one.
@immutable
final class TemperatureReading {
  const new({required this.status, this.value, this.unit});

  final ReadingStatus status;

  /// Set when [status] is [ReadingStatus.ok].
  final num? value;
  final String? unit;

  @override
  bool operator ==(Object other) =>
      other is TemperatureReading &&
      other.status == status &&
      other.value == value &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(status, value, unit);

  @override
  String toString() => 'TemperatureReading($status, $value $unit)';
}

/// Read-only readings of a heating card, from the entities of
/// `GET /devices/:id` pointed to by `heatingRelayEntityId`,
/// `pumpRelayEntityId` and `controlTemperatureEntityId` (plan §4.1, §12.4).
@immutable
final class HeatingReadings {
  const new({
    required this.boilerRelay,
    this.pumpRelay,
    this.controlTemperature,
  });

  /// [now] enables the stale check of the control temperature.
  factory of(DeviceDetail detail, {DateTime? now}) => HeatingReadings(
    boilerRelay: relayStateOf(detail.entityById(detail.heatingRelayEntityId)),
    pumpRelay: detail.pumpRelayEntityId == null
        ? null
        : relayStateOf(detail.entityById(detail.pumpRelayEntityId)),
    controlTemperature: detail.controlTemperatureEntityId == null
        ? null
        : temperatureOf(
            detail.entityById(detail.controlTemperatureEntityId),
            now: now,
          ),
  );

  final RelayState boilerRelay;

  /// `null` when the device has no pump relay.
  final RelayState? pumpRelay;

  /// `null` when the device has no control temperature entity.
  final TemperatureReading? controlTemperature;

  /// State of a relay entity. Core stores what the controller or GI Core
  /// reported as free-form JSON: a boolean, 0/1 from GI Edge telemetry, or
  /// text such as `"ON"`. Anything else is [RelayState.noData].
  static RelayState relayStateOf(DeviceEntity? entity) {
    if (entity == null) return RelayState.noData;
    if (!entity.enabled || !entity.availability) return RelayState.unavailable;
    return switch (entity.value) {
      EntityValueBoolean(:final value) =>
        value ? RelayState.on : RelayState.off,
      EntityValueNumber(:final value) when value == 1 => RelayState.on,
      EntityValueNumber(:final value) when value == 0 => RelayState.off,
      EntityValueText(:final value) => switch (value.trim().toLowerCase()) {
        'on' || 'true' || '1' => RelayState.on,
        'off' || 'false' || '0' => RelayState.off,
        _ => RelayState.noData,
      },
      _ => RelayState.noData,
    };
  }

  /// Temperature of an entity: a number or numeric text.
  static TemperatureReading temperatureOf(
    DeviceEntity? entity, {
    DateTime? now,
  }) {
    if (entity == null) {
      return const TemperatureReading(status: ReadingStatus.noData);
    }
    if (!entity.enabled || !entity.availability) {
      return const TemperatureReading(status: ReadingStatus.unavailable);
    }
    if (now != null && isStaleReading(entity, now)) {
      return const TemperatureReading(status: ReadingStatus.stale);
    }
    final value = switch (entity.value) {
      EntityValueNumber(:final value) when value.isFinite => value,
      EntityValueText(:final value) => switch (num.tryParse(value.trim())) {
        final parsed? when parsed.isFinite => parsed,
        _ => null,
      },
      _ => null,
    };
    final unit = entity.unit?.trim();
    return value == null
        ? const TemperatureReading(status: ReadingStatus.noData)
        : TemperatureReading(
            status: ReadingStatus.ok,
            value: value,
            unit: unit == null || unit.isEmpty ? null : unit,
          );
  }

  @override
  bool operator ==(Object other) =>
      other is HeatingReadings &&
      other.boilerRelay == boilerRelay &&
      other.pumpRelay == pumpRelay &&
      other.controlTemperature == controlTemperature;

  @override
  int get hashCode => Object.hash(boilerRelay, pumpRelay, controlTemperature);
}
