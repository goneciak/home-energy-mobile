// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceListItem _$DeviceListItemFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_DeviceListItem', json, ($checkedConvert) {
  final val = _DeviceListItem(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    enabled: $checkedConvert('enabled', (v) => v as bool),
    heatingSuspended: $checkedConvert('heatingSuspended', (v) => v as bool),
    fallbackThresholdMs: $checkedConvert(
      'fallbackThresholdMs',
      (v) => (v as num).toInt(),
    ),
    boilerEstimateWindowMinutes: $checkedConvert(
      'boilerEstimateWindowMinutes',
      (v) => (v as num).toInt(),
    ),
    dryRun: $checkedConvert('dryRun', (v) => v as bool),
    activeFaultCount: $checkedConvert(
      'activeFaultCount',
      (v) => (v as num).toInt(),
    ),
    description: $checkedConvert('description', (v) => v as String?),
    serialNumber: $checkedConvert('serialNumber', (v) => v as String?),
    manufacturer: $checkedConvert('manufacturer', (v) => v as String?),
    model: $checkedConvert('model', (v) => v as String?),
    firmwareVersion: $checkedConvert('firmwareVersion', (v) => v as String?),
    status: $checkedConvert(
      'status',
      (v) =>
          $enumDecodeNullable(
            _$DeviceListStatusEnumMap,
            v,
            unknownValue: DeviceListStatus.unknown,
          ) ??
          DeviceListStatus.unknown,
    ),
    type: $checkedConvert(
      'type',
      (v) =>
          $enumDecodeNullable(
            _$DeviceTypeEnumMap,
            v,
            unknownValue: DeviceType.unknown,
          ) ??
          DeviceType.unknown,
    ),
    roomId: $checkedConvert('roomId', (v) => v as String?),
    lastSeenAt: $checkedConvert(
      'lastSeenAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    communicationMode: $checkedConvert(
      'communicationMode',
      (v) =>
          $enumDecodeNullable(
            _$CommunicationModeEnumMap,
            v,
            unknownValue: CommunicationMode.unknown,
          ) ??
          CommunicationMode.unknown,
    ),
    lastConnectionError: $checkedConvert(
      'lastConnectionError',
      (v) => v as String?,
    ),
    lastConnectionAttemptAt: $checkedConvert(
      'lastConnectionAttemptAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    lastKnownIp: $checkedConvert('lastKnownIp', (v) => v as String?),
    heatingRelayEntityId: $checkedConvert(
      'heatingRelayEntityId',
      (v) => v as String?,
    ),
    controlTemperatureEntityId: $checkedConvert(
      'controlTemperatureEntityId',
      (v) => v as String?,
    ),
    pumpRelayEntityId: $checkedConvert(
      'pumpRelayEntityId',
      (v) => v as String?,
    ),
    pumpComparisonEntityId: $checkedConvert(
      'pumpComparisonEntityId',
      (v) => v as String?,
    ),
    inverterIntegrationMode: $checkedConvert(
      'inverterIntegrationMode',
      (v) =>
          $enumDecodeNullable(
            _$InverterIntegrationModeEnumMap,
            v,
            unknownValue: InverterIntegrationMode.unknown,
          ) ??
          InverterIntegrationMode.unknown,
    ),
    inverterVendorProfileId: $checkedConvert(
      'inverterVendorProfileId',
      (v) => v as String?,
    ),
    localControlTemperatureSource: $checkedConvert(
      'localControlTemperatureSource',
      (v) =>
          $enumDecodeNullable(
            _$LocalControlTemperatureSourceEnumMap,
            v,
            unknownValue: LocalControlTemperatureSource.unknown,
          ) ??
          LocalControlTemperatureSource.unknown,
    ),
    currentState: $checkedConvert(
      'currentState',
      (v) => $enumDecodeNullable(
        _$FirmwareStateEnumMap,
        v,
        unknownValue: FirmwareState.unknown,
      ),
    ),
    capabilities: $checkedConvert(
      'capabilities',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => Capability.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Capability>[],
    ),
    connectivityState: $checkedConvert(
      'connectivityState',
      (v) =>
          $enumDecodeNullable(
            _$ConnectivityStateEnumMap,
            v,
            unknownValue: ConnectivityState.unknown,
          ) ??
          ConnectivityState.unknown,
    ),
  );
  return val;
});

Map<String, dynamic> _$DeviceListItemToJson(
  _DeviceListItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'enabled': instance.enabled,
  'heatingSuspended': instance.heatingSuspended,
  'fallbackThresholdMs': instance.fallbackThresholdMs,
  'boilerEstimateWindowMinutes': instance.boilerEstimateWindowMinutes,
  'dryRun': instance.dryRun,
  'activeFaultCount': instance.activeFaultCount,
  'description': instance.description,
  'serialNumber': instance.serialNumber,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'firmwareVersion': instance.firmwareVersion,
  'status': _$DeviceListStatusEnumMap[instance.status]!,
  'type': _$DeviceTypeEnumMap[instance.type]!,
  'roomId': instance.roomId,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
  'communicationMode': _$CommunicationModeEnumMap[instance.communicationMode]!,
  'lastConnectionError': instance.lastConnectionError,
  'lastConnectionAttemptAt': instance.lastConnectionAttemptAt
      ?.toIso8601String(),
  'lastKnownIp': instance.lastKnownIp,
  'heatingRelayEntityId': instance.heatingRelayEntityId,
  'controlTemperatureEntityId': instance.controlTemperatureEntityId,
  'pumpRelayEntityId': instance.pumpRelayEntityId,
  'pumpComparisonEntityId': instance.pumpComparisonEntityId,
  'inverterIntegrationMode':
      _$InverterIntegrationModeEnumMap[instance.inverterIntegrationMode]!,
  'inverterVendorProfileId': instance.inverterVendorProfileId,
  'localControlTemperatureSource':
      _$LocalControlTemperatureSourceEnumMap[instance
          .localControlTemperatureSource]!,
  'currentState': _$FirmwareStateEnumMap[instance.currentState],
  'capabilities': instance.capabilities.map((e) => e.toJson()).toList(),
  'connectivityState': _$ConnectivityStateEnumMap[instance.connectivityState]!,
};

const _$DeviceListStatusEnumMap = {
  DeviceListStatus.online: 'ONLINE',
  DeviceListStatus.offline: 'OFFLINE',
  DeviceListStatus.provisioning: 'PROVISIONING',
  DeviceListStatus.updating: 'UPDATING',
  DeviceListStatus.error: 'ERROR',
  DeviceListStatus.unknown: 'UNKNOWN',
};

const _$DeviceTypeEnumMap = {
  DeviceType.generic: 'GENERIC',
  DeviceType.esp32: 'ESP32',
  DeviceType.esp8266: 'ESP8266',
  DeviceType.homeAssistant: 'HOME_ASSISTANT',
  DeviceType.gateway: 'GATEWAY',
  DeviceType.virtual: 'VIRTUAL',
  DeviceType.unknown: 'UNKNOWN',
};

const _$CommunicationModeEnumMap = {
  CommunicationMode.legacyEsphome: 'LEGACY_ESPHOME',
  CommunicationMode.giEdgeV1: 'GI_EDGE_V1',
  CommunicationMode.simulation: 'SIMULATION',
  CommunicationMode.replay: 'REPLAY',
  CommunicationMode.unknown: 'UNKNOWN',
};

const _$InverterIntegrationModeEnumMap = {
  InverterIntegrationMode.sunspec: 'SUNSPEC',
  InverterIntegrationMode.vendorProfile: 'VENDOR_PROFILE',
  InverterIntegrationMode.disabled: 'DISABLED',
  InverterIntegrationMode.unknown: 'UNKNOWN',
};

const _$LocalControlTemperatureSourceEnumMap = {
  LocalControlTemperatureSource.supply: 'SUPPLY',
  LocalControlTemperatureSource.return_: 'RETURN',
  LocalControlTemperatureSource.boilerEstimate: 'BOILER_ESTIMATE',
  LocalControlTemperatureSource.unknown: 'UNKNOWN',
};

const _$FirmwareStateEnumMap = {
  FirmwareState.boot: 'BOOT',
  FirmwareState.selfTest: 'SELF_TEST',
  FirmwareState.ready: 'READY',
  FirmwareState.idle: 'IDLE',
  FirmwareState.heatingRequested: 'HEATING_REQUESTED',
  FirmwareState.heatingVerifying: 'HEATING_VERIFYING',
  FirmwareState.heating: 'HEATING',
  FirmwareState.stopping: 'STOPPING',
  FirmwareState.fault: 'FAULT',
  FirmwareState.safeMode: 'SAFE_MODE',
  FirmwareState.unknown: 'UNKNOWN',
};

const _$ConnectivityStateEnumMap = {
  ConnectivityState.online: 'ONLINE',
  ConnectivityState.stale: 'STALE',
  ConnectivityState.offline: 'OFFLINE',
  ConnectivityState.provisioning: 'PROVISIONING',
  ConnectivityState.error: 'ERROR',
  ConnectivityState.unknown: 'UNKNOWN',
};

_Capability _$CapabilityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Capability', json, ($checkedConvert) {
      final val = _Capability(
        id: $checkedConvert('id', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) =>
              $enumDecodeNullable(
                _$CapabilityTypeEnumMap,
                v,
                unknownValue: CapabilityType.unknown,
              ) ??
              CapabilityType.unknown,
        ),
      );
      return val;
    });

Map<String, dynamic> _$CapabilityToJson(_Capability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CapabilityTypeEnumMap[instance.type]!,
    };

const _$CapabilityTypeEnumMap = {
  CapabilityType.relay: 'RELAY',
  CapabilityType.temperature: 'TEMPERATURE',
  CapabilityType.humidity: 'HUMIDITY',
  CapabilityType.pressure: 'PRESSURE',
  CapabilityType.power: 'POWER',
  CapabilityType.energy: 'ENERGY',
  CapabilityType.light: 'LIGHT',
  CapabilityType.dimmer: 'DIMMER',
  CapabilityType.rgb: 'RGB',
  CapabilityType.switch_: 'SWITCH',
  CapabilityType.button: 'BUTTON',
  CapabilityType.motion: 'MOTION',
  CapabilityType.contact: 'CONTACT',
  CapabilityType.pwm: 'PWM',
  CapabilityType.boiler: 'BOILER',
  CapabilityType.thermostat: 'THERMOSTAT',
  CapabilityType.battery: 'BATTERY',
  CapabilityType.pv: 'PV',
  CapabilityType.ota: 'OTA',
  CapabilityType.wifi: 'WIFI',
  CapabilityType.ble: 'BLE',
  CapabilityType.unknown: 'UNKNOWN',
};
