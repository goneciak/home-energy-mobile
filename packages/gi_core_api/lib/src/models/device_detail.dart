import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/converters/json_converters.dart';
import 'package:gi_core_api/src/models/entity_value.dart';
import 'package:gi_core_api/src/models/enums.dart';

part 'device_detail.freezed.dart';
part 'device_detail.g.dart';

/// `GET /devices/:id` (`device-details-query.service.ts`).
///
/// Unlike the list it carries entities, strategies and diagnostics, but NOT
/// `currentState`/`activeFaultCount`; take those from the cached list item.
/// Its [status] is the lowercase product vocabulary.
///
/// [controlStrategy], [baseControlStrategy], [pvHeatingConfig] and
/// [diagnostics] are raw JSONB columns returned as stored; an unusable blob
/// decodes to `null` (hiding that section) instead of failing the device.
@freezed
abstract class DeviceDetail with _$DeviceDetail {
  const factory({
    required String id,
    required String name,
    required bool enabled,
    required bool heatingSuspended,
    required int fallbackThresholdMs,
    required int boilerEstimateWindowMinutes,
    required bool dryRun,
    required int configurationVersion,
    String? description,
    String? manufacturer,
    String? model,
    String? firmwareVersion,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    @Default(ProductStatus.unknown)
    ProductStatus status,
    String? roomId,
    DateTime? lastSeenAt,
    @Default(<DeviceEntity>[]) List<DeviceEntity> entities,
    @JsonKey(unknownEnumValue: CommunicationMode.unknown)
    @Default(CommunicationMode.unknown)
    CommunicationMode communicationMode,
    @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)
    @Default(InverterIntegrationMode.unknown)
    InverterIntegrationMode inverterIntegrationMode,
    String? inverterVendorProfileId,
    String? heatingRelayEntityId,
    String? controlTemperatureEntityId,
    @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)
    @Default(LocalControlTemperatureSource.unknown)
    LocalControlTemperatureSource localControlTemperatureSource,
    String? pumpRelayEntityId,
    String? pumpComparisonEntityId,
    @JsonKey(unknownEnumValue: ConnectivityState.unknown)
    @Default(ConnectivityState.unknown)
    ConnectivityState connectivityState,
    String? lastConnectionError,
    DateTime? lastConnectionAttemptAt,
    String? lastKnownIp,
    String? hostname,
    String? mac,
    @DeviceDiagnosticsConverter() DeviceDiagnostics? diagnostics,
    @ControlStrategyConverter() ControlStrategy? controlStrategy,
    @ControlStrategyConverter() ControlStrategy? baseControlStrategy,
    @PvHeatingConfigConverter() PvHeatingConfig? pvHeatingConfig,
    String? pvProductionEntityId,
    String? pvConsumptionEntityId,
    @Default(false) bool pvBoostActive,
  }) = _DeviceDetail;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$DeviceDetailFromJson(json);

  bool get isHeating => heatingRelayEntityId != null;

  /// The entity with [entityId], or `null` when it is not (or no longer) part
  /// of this device.
  DeviceEntity? entityById(String? entityId) {
    if (entityId == null) return null;
    for (final entity in entities) {
      if (entity.id == entityId) return entity;
    }
    return null;
  }
}

/// Entity of a device (`DeviceEntityResponseDto`).
@freezed
abstract class DeviceEntity with _$DeviceEntity {
  const factory({
    required String id,
    required String displayName,
    required String sourceName,
    required bool readable,
    required bool writable,
    required bool availability,
    required bool enabled,
    @JsonKey(unknownEnumValue: EntityDomain.unknown)
    @Default(EntityDomain.unknown)
    EntityDomain domain,
    String? deviceClass,
    @EntityValueConverter() @Default(EntityValue.none()) EntityValue value,
    String? unit,
    DateTime? lastSeenAt,
    AssignedMeaning? assignedFunction,
    AssignedMeaning? assignedRole,
  }) = _DeviceEntity;

  factory fromJson(Map<String, dynamic> json) => _$DeviceEntityFromJson(json);
}

/// Function or role assigned to an entity (`{code, name}`).
@freezed
abstract class AssignedMeaning with _$AssignedMeaning {
  const factory({required String code, required String name}) =
      _AssignedMeaning;

  factory fromJson(Map<String, dynamic> json) =>
      _$AssignedMeaningFromJson(json);
}

/// `{targetTemperatureCelsius, hysteresisCelsius, mode}`.
@freezed
abstract class ControlStrategy with _$ControlStrategy {
  const factory({
    @NumOrStringConverter() required double targetTemperatureCelsius,
    @NumOrStringConverter() required double hysteresisCelsius,
    @JsonKey(unknownEnumValue: ControlStrategyMode.unknown)
    @Default(ControlStrategyMode.unknown)
    ControlStrategyMode mode,
  }) = _ControlStrategy;

  factory fromJson(Map<String, dynamic> json) =>
      _$ControlStrategyFromJson(json);
}

/// Decodes a stored strategy like the backend's `toControlStrategyDto`: a
/// blob without numeric target and hysteresis or a string mode is `null`.
class ControlStrategyConverter
    implements JsonConverter<ControlStrategy?, Object?> {
  const new();

  @override
  ControlStrategy? fromJson(Object? json) {
    if (json is! Map) return null;
    final raw = json.cast<String, Object?>();
    if (finiteNumberOrNull(raw['targetTemperatureCelsius']) == null ||
        finiteNumberOrNull(raw['hysteresisCelsius']) == null ||
        raw['mode'] is! String) {
      return null;
    }
    return ControlStrategy.fromJson(raw);
  }

  @override
  Object? toJson(ControlStrategy? value) => value?.toJson();
}

/// PV-surplus heating configuration; `null` on the device means DISABLED.
@freezed
abstract class PvHeatingConfig with _$PvHeatingConfig {
  const factory({
    @NumOrStringConverter() required double safeMaxTemperatureCelsius,
    required int shortDwellMs,
    required int longDwellMs,
    @NumOrStringConverter() required double forecastFavorableProductionRatio,
    @JsonKey(unknownEnumValue: PvControlMode.unknown)
    @Default(PvControlMode.unknown)
    PvControlMode mode,
  }) = _PvHeatingConfig;

  factory fromJson(Map<String, dynamic> json) =>
      _$PvHeatingConfigFromJson(json);

  /// Backend `DEFAULT_PV_HEATING_CONFIG` values for keys older rows lack.
  static const defaultShortDwellMs = 120000;
  static const defaultLongDwellMs = 600000;
  static const defaultForecastFavorableProductionRatio = 0.4;
}

/// Decodes a stored PV configuration like the backend's
/// `parsePvHeatingConfig`: no string mode or no numeric temperature ceiling
/// means `null`; missing or mistyped dwell times and ratio take the defaults.
class PvHeatingConfigConverter
    implements JsonConverter<PvHeatingConfig?, Object?> {
  const new();

  @override
  PvHeatingConfig? fromJson(Object? json) {
    if (json is! Map) return null;
    final raw = json.cast<String, Object?>();
    final ceiling = finiteNumberOrNull(raw['safeMaxTemperatureCelsius']);
    if (raw['mode'] is! String || ceiling == null) return null;
    double number(String key, num fallback) =>
        finiteNumberOrNull(raw[key]) ?? fallback.toDouble();
    return PvHeatingConfig.fromJson({
      'mode': raw['mode'],
      'safeMaxTemperatureCelsius': ceiling,
      'shortDwellMs': number(
        'shortDwellMs',
        PvHeatingConfig.defaultShortDwellMs,
      ).round(),
      'longDwellMs': number(
        'longDwellMs',
        PvHeatingConfig.defaultLongDwellMs,
      ).round(),
      'forecastFavorableProductionRatio': number(
        'forecastFavorableProductionRatio',
        PvHeatingConfig.defaultForecastFavorableProductionRatio,
      ),
    });
  }

  @override
  Object? toJson(PvHeatingConfig? value) => value?.toJson();
}

/// Raw GI Edge heartbeat body with defensive accessors. Its shape is owned by
/// firmware, so every accessor tolerates a missing or mistyped key.
@freezed
abstract class DeviceDiagnostics with _$DeviceDiagnostics {
  const factory(Map<String, Object?> raw) = _DeviceDiagnostics;

  const new _();

  /// Firmware state machine state (`currentState`).
  FirmwareState? get currentState =>
      FirmwareState.tryParse(raw['currentState']);

  /// Number of entries in `activeFaults`, or `null` when absent.
  int? get activeFaultCount => switch (raw['activeFaults']) {
    final List<Object?> faults => faults.length,
    _ => null,
  };

  /// `safetyInterlockActive`, or `null` when absent.
  bool? get safetyInterlockActive => _bool(raw['safetyInterlockActive']);

  /// Time since the controller booted (`uptimeMs`).
  Duration? get uptime => switch (raw['uptimeMs']) {
    final num ms when ms >= 0 => Duration(milliseconds: ms.round()),
    _ => null,
  };

  /// Wi-Fi signal strength in dBm (`wifi.rssi`).
  int? get wifiRssi => switch (raw['wifi']) {
    {'rssi': final num rssi} => rssi.round(),
    _ => null,
  };

  /// Number of controller boots (`bootCount`).
  int? get bootCount => switch (raw['bootCount']) {
    final num count when count >= 0 => count.round(),
    _ => null,
  };

  /// The controller detected repeated restarts (`rebootLoopDetected`).
  bool? get rebootLoopDetected => _bool(raw['rebootLoopDetected']);

  static bool? _bool(Object? value) => value is bool ? value : null;
}

/// Diagnostics are `null` for legacy devices; any non-object value is treated
/// the same way rather than failing the whole device.
class DeviceDiagnosticsConverter
    implements JsonConverter<DeviceDiagnostics?, Object?> {
  const new();

  @override
  DeviceDiagnostics? fromJson(Object? json) => switch (json) {
    final Map<String, Object?> map => DeviceDiagnostics(map),
    final Map<Object?, Object?> map => DeviceDiagnostics(map.cast()),
    _ => null,
  };

  @override
  Object? toJson(DeviceDiagnostics? value) => value?.raw;
}
