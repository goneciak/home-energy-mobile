import 'package:json_annotation/json_annotation.dart';

part 'enums.g.dart';

// Every vocabulary below is tolerant (plan §6.4): a value the client does not
// know decodes to `unknown` instead of failing the whole response. Where the
// backend itself defines `UNKNOWN`, the same member covers both cases.
//
// The three device status vocabularies are deliberately separate types and
// must never be merged:
// * [DeviceListStatus]  - stored status, UPPERCASE, from `GET /devices`;
// * [ProductStatus]     - derived status, lowercase, from `GET /devices/:id`;
// * [ConnectivityState] - computed from status + lastSeenAt, both endpoints.

/// Role of a GI Core user (`common/enums/user-role.enum.ts`).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserRole { owner, admin, user, service, unknown }

/// Stored device status as returned by the device list.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DeviceListStatus {
  online,
  offline,
  provisioning,
  updating,
  error,
  unknown,
}

/// Product-level status computed by the device details endpoint.
@JsonEnum(fieldRename: FieldRename.snake)
enum ProductStatus {
  online,
  offline,
  connecting,
  needsConfiguration,
  error,
  unknown,
}

/// Effective connectivity (STALE after 5 min, OFFLINE after 15 min).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ConnectivityState { online, stale, offline, provisioning, error, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DeviceType {
  generic,
  esp32,
  esp8266,
  homeAssistant,
  gateway,
  virtual,
  unknown,
}

enum CommunicationMode {
  @JsonValue('LEGACY_ESPHOME')
  legacyEsphome,
  @JsonValue('GI_EDGE_V1')
  giEdgeV1,
  @JsonValue('SIMULATION')
  simulation,
  @JsonValue('REPLAY')
  replay,
  @JsonValue('UNKNOWN')
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum InverterIntegrationMode { sunspec, vendorProfile, disabled, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum LocalControlTemperatureSource {
  supply,
  @JsonValue('RETURN')
  return_,
  boilerEstimate,
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CapabilityType {
  relay,
  temperature,
  humidity,
  pressure,
  power,
  energy,
  light,
  dimmer,
  rgb,
  @JsonValue('SWITCH')
  switch_,
  button,
  motion,
  contact,
  pwm,
  boiler,
  thermostat,
  battery,
  pv,
  ota,
  wifi,
  ble,
  unknown,
}

/// Firmware state machine state reported in GI Edge heartbeats.
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum FirmwareState {
  boot,
  selfTest,
  ready,
  idle,
  heatingRequested,
  heatingVerifying,
  heating,
  stopping,
  fault,
  safeMode,
  unknown;

  /// Decodes a raw firmware state; `null` when [raw] is not a string.
  static FirmwareState? tryParse(Object? raw) => raw is String
      ? $enumDecode(_$FirmwareStateEnumMap, raw, unknownValue: unknown)
      : null;

  /// States that require the user's action (plan §11.1).
  bool get isCritical => this == fault || this == safeMode;
}

/// Entity domain, lowercased by the device details endpoint.
@JsonEnum(fieldRename: FieldRename.snake)
enum EntityDomain {
  sensor,
  @JsonValue('switch')
  switch_,
  binarySensor,
  number,
  select,
  climate,
  textSensor,
  button,
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ControlStrategyMode { auto, off, manual, unknown }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PvControlMode { disabled, forecastOnly, liveInverterOnly, hybrid, unknown }
