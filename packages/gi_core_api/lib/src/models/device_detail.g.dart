// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceDetail _$DeviceDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_DeviceDetail', json, ($checkedConvert) {
  final val = _DeviceDetail(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
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
    configurationVersion: $checkedConvert(
      'configurationVersion',
      (v) => (v as num).toInt(),
    ),
    description: $checkedConvert('description', (v) => v as String?),
    manufacturer: $checkedConvert('manufacturer', (v) => v as String?),
    model: $checkedConvert('model', (v) => v as String?),
    firmwareVersion: $checkedConvert('firmwareVersion', (v) => v as String?),
    status: $checkedConvert(
      'status',
      (v) =>
          $enumDecodeNullable(
            _$ProductStatusEnumMap,
            v,
            unknownValue: ProductStatus.unknown,
          ) ??
          ProductStatus.unknown,
    ),
    roomId: $checkedConvert('roomId', (v) => v as String?),
    lastSeenAt: $checkedConvert(
      'lastSeenAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    entities: $checkedConvert(
      'entities',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => DeviceEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DeviceEntity>[],
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
    heatingRelayEntityId: $checkedConvert(
      'heatingRelayEntityId',
      (v) => v as String?,
    ),
    controlTemperatureEntityId: $checkedConvert(
      'controlTemperatureEntityId',
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
    pumpRelayEntityId: $checkedConvert(
      'pumpRelayEntityId',
      (v) => v as String?,
    ),
    pumpComparisonEntityId: $checkedConvert(
      'pumpComparisonEntityId',
      (v) => v as String?,
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
    lastConnectionError: $checkedConvert(
      'lastConnectionError',
      (v) => v as String?,
    ),
    lastConnectionAttemptAt: $checkedConvert(
      'lastConnectionAttemptAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    lastKnownIp: $checkedConvert('lastKnownIp', (v) => v as String?),
    hostname: $checkedConvert('hostname', (v) => v as String?),
    mac: $checkedConvert('mac', (v) => v as String?),
    diagnostics: $checkedConvert(
      'diagnostics',
      (v) => const DeviceDiagnosticsConverter().fromJson(v),
    ),
    controlStrategy: $checkedConvert(
      'controlStrategy',
      (v) => const ControlStrategyConverter().fromJson(v),
    ),
    baseControlStrategy: $checkedConvert(
      'baseControlStrategy',
      (v) => const ControlStrategyConverter().fromJson(v),
    ),
    pvHeatingConfig: $checkedConvert(
      'pvHeatingConfig',
      (v) => const PvHeatingConfigConverter().fromJson(v),
    ),
    pvProductionEntityId: $checkedConvert(
      'pvProductionEntityId',
      (v) => v as String?,
    ),
    pvConsumptionEntityId: $checkedConvert(
      'pvConsumptionEntityId',
      (v) => v as String?,
    ),
    pvBoostActive: $checkedConvert('pvBoostActive', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$DeviceDetailToJson(
  _DeviceDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'enabled': instance.enabled,
  'heatingSuspended': instance.heatingSuspended,
  'fallbackThresholdMs': instance.fallbackThresholdMs,
  'boilerEstimateWindowMinutes': instance.boilerEstimateWindowMinutes,
  'dryRun': instance.dryRun,
  'configurationVersion': instance.configurationVersion,
  'description': instance.description,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'firmwareVersion': instance.firmwareVersion,
  'status': _$ProductStatusEnumMap[instance.status]!,
  'roomId': instance.roomId,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
  'entities': instance.entities.map((e) => e.toJson()).toList(),
  'communicationMode': _$CommunicationModeEnumMap[instance.communicationMode]!,
  'inverterIntegrationMode':
      _$InverterIntegrationModeEnumMap[instance.inverterIntegrationMode]!,
  'inverterVendorProfileId': instance.inverterVendorProfileId,
  'heatingRelayEntityId': instance.heatingRelayEntityId,
  'controlTemperatureEntityId': instance.controlTemperatureEntityId,
  'localControlTemperatureSource':
      _$LocalControlTemperatureSourceEnumMap[instance
          .localControlTemperatureSource]!,
  'pumpRelayEntityId': instance.pumpRelayEntityId,
  'pumpComparisonEntityId': instance.pumpComparisonEntityId,
  'connectivityState': _$ConnectivityStateEnumMap[instance.connectivityState]!,
  'lastConnectionError': instance.lastConnectionError,
  'lastConnectionAttemptAt': instance.lastConnectionAttemptAt
      ?.toIso8601String(),
  'lastKnownIp': instance.lastKnownIp,
  'hostname': instance.hostname,
  'mac': instance.mac,
  'diagnostics': const DeviceDiagnosticsConverter().toJson(
    instance.diagnostics,
  ),
  'controlStrategy': const ControlStrategyConverter().toJson(
    instance.controlStrategy,
  ),
  'baseControlStrategy': const ControlStrategyConverter().toJson(
    instance.baseControlStrategy,
  ),
  'pvHeatingConfig': const PvHeatingConfigConverter().toJson(
    instance.pvHeatingConfig,
  ),
  'pvProductionEntityId': instance.pvProductionEntityId,
  'pvConsumptionEntityId': instance.pvConsumptionEntityId,
  'pvBoostActive': instance.pvBoostActive,
};

const _$ProductStatusEnumMap = {
  ProductStatus.online: 'online',
  ProductStatus.offline: 'offline',
  ProductStatus.connecting: 'connecting',
  ProductStatus.needsConfiguration: 'needs_configuration',
  ProductStatus.error: 'error',
  ProductStatus.unknown: 'unknown',
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

const _$ConnectivityStateEnumMap = {
  ConnectivityState.online: 'ONLINE',
  ConnectivityState.stale: 'STALE',
  ConnectivityState.offline: 'OFFLINE',
  ConnectivityState.provisioning: 'PROVISIONING',
  ConnectivityState.error: 'ERROR',
  ConnectivityState.unknown: 'UNKNOWN',
};

_DeviceEntity _$DeviceEntityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DeviceEntity', json, ($checkedConvert) {
      final val = _DeviceEntity(
        id: $checkedConvert('id', (v) => v as String),
        displayName: $checkedConvert('displayName', (v) => v as String),
        sourceName: $checkedConvert('sourceName', (v) => v as String),
        readable: $checkedConvert('readable', (v) => v as bool),
        writable: $checkedConvert('writable', (v) => v as bool),
        availability: $checkedConvert('availability', (v) => v as bool),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        domain: $checkedConvert(
          'domain',
          (v) =>
              $enumDecodeNullable(
                _$EntityDomainEnumMap,
                v,
                unknownValue: EntityDomain.unknown,
              ) ??
              EntityDomain.unknown,
        ),
        deviceClass: $checkedConvert('deviceClass', (v) => v as String?),
        value: $checkedConvert(
          'value',
          (v) => v == null
              ? const EntityValue.none()
              : const EntityValueConverter().fromJson(v),
        ),
        unit: $checkedConvert('unit', (v) => v as String?),
        lastSeenAt: $checkedConvert(
          'lastSeenAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        assignedFunction: $checkedConvert(
          'assignedFunction',
          (v) => v == null
              ? null
              : AssignedMeaning.fromJson(v as Map<String, dynamic>),
        ),
        assignedRole: $checkedConvert(
          'assignedRole',
          (v) => v == null
              ? null
              : AssignedMeaning.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DeviceEntityToJson(_DeviceEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'sourceName': instance.sourceName,
      'readable': instance.readable,
      'writable': instance.writable,
      'availability': instance.availability,
      'enabled': instance.enabled,
      'domain': _$EntityDomainEnumMap[instance.domain]!,
      'deviceClass': instance.deviceClass,
      'value': const EntityValueConverter().toJson(instance.value),
      'unit': instance.unit,
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'assignedFunction': instance.assignedFunction?.toJson(),
      'assignedRole': instance.assignedRole?.toJson(),
    };

const _$EntityDomainEnumMap = {
  EntityDomain.sensor: 'sensor',
  EntityDomain.switch_: 'switch',
  EntityDomain.binarySensor: 'binary_sensor',
  EntityDomain.number: 'number',
  EntityDomain.select: 'select',
  EntityDomain.climate: 'climate',
  EntityDomain.textSensor: 'text_sensor',
  EntityDomain.button: 'button',
  EntityDomain.unknown: 'unknown',
};

_AssignedMeaning _$AssignedMeaningFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AssignedMeaning', json, ($checkedConvert) {
      final val = _AssignedMeaning(
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AssignedMeaningToJson(_AssignedMeaning instance) =>
    <String, dynamic>{'code': instance.code, 'name': instance.name};

_ControlStrategy _$ControlStrategyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ControlStrategy', json, ($checkedConvert) {
      final val = _ControlStrategy(
        targetTemperatureCelsius: $checkedConvert(
          'targetTemperatureCelsius',
          (v) => const NumOrStringConverter().fromJson(v),
        ),
        hysteresisCelsius: $checkedConvert(
          'hysteresisCelsius',
          (v) => const NumOrStringConverter().fromJson(v),
        ),
        mode: $checkedConvert(
          'mode',
          (v) =>
              $enumDecodeNullable(
                _$ControlStrategyModeEnumMap,
                v,
                unknownValue: ControlStrategyMode.unknown,
              ) ??
              ControlStrategyMode.unknown,
        ),
      );
      return val;
    });

Map<String, dynamic> _$ControlStrategyToJson(_ControlStrategy instance) =>
    <String, dynamic>{
      'targetTemperatureCelsius': const NumOrStringConverter().toJson(
        instance.targetTemperatureCelsius,
      ),
      'hysteresisCelsius': const NumOrStringConverter().toJson(
        instance.hysteresisCelsius,
      ),
      'mode': _$ControlStrategyModeEnumMap[instance.mode]!,
    };

const _$ControlStrategyModeEnumMap = {
  ControlStrategyMode.auto: 'AUTO',
  ControlStrategyMode.off: 'OFF',
  ControlStrategyMode.manual: 'MANUAL',
  ControlStrategyMode.unknown: 'UNKNOWN',
};

_PvHeatingConfig _$PvHeatingConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PvHeatingConfig', json, ($checkedConvert) {
      final val = _PvHeatingConfig(
        safeMaxTemperatureCelsius: $checkedConvert(
          'safeMaxTemperatureCelsius',
          (v) => const NumOrStringConverter().fromJson(v),
        ),
        shortDwellMs: $checkedConvert(
          'shortDwellMs',
          (v) => (v as num).toInt(),
        ),
        longDwellMs: $checkedConvert('longDwellMs', (v) => (v as num).toInt()),
        forecastFavorableProductionRatio: $checkedConvert(
          'forecastFavorableProductionRatio',
          (v) => const NumOrStringConverter().fromJson(v),
        ),
        mode: $checkedConvert(
          'mode',
          (v) =>
              $enumDecodeNullable(
                _$PvControlModeEnumMap,
                v,
                unknownValue: PvControlMode.unknown,
              ) ??
              PvControlMode.unknown,
        ),
      );
      return val;
    });

Map<String, dynamic> _$PvHeatingConfigToJson(_PvHeatingConfig instance) =>
    <String, dynamic>{
      'safeMaxTemperatureCelsius': const NumOrStringConverter().toJson(
        instance.safeMaxTemperatureCelsius,
      ),
      'shortDwellMs': instance.shortDwellMs,
      'longDwellMs': instance.longDwellMs,
      'forecastFavorableProductionRatio': const NumOrStringConverter().toJson(
        instance.forecastFavorableProductionRatio,
      ),
      'mode': _$PvControlModeEnumMap[instance.mode]!,
    };

const _$PvControlModeEnumMap = {
  PvControlMode.disabled: 'DISABLED',
  PvControlMode.forecastOnly: 'FORECAST_ONLY',
  PvControlMode.liveInverterOnly: 'LIVE_INVERTER_ONLY',
  PvControlMode.hybrid: 'HYBRID',
  PvControlMode.unknown: 'UNKNOWN',
};
