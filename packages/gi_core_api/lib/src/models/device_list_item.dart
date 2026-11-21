import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/models/enums.dart';

part 'device_list_item.freezed.dart';
part 'device_list_item.g.dart';

/// Element of `GET /devices` (`device.dto.ts` `DeviceResponseDto`).
///
/// The list is enough to recognise heating devices, the suspension banner and
/// dry-run. It carries [currentState] and [activeFaultCount], which the
/// details endpoint does not.
@freezed
abstract class DeviceListItem with _$DeviceListItem {
  const factory({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool enabled,
    required bool heatingSuspended,
    required int fallbackThresholdMs,
    required int boilerEstimateWindowMinutes,
    required bool dryRun,
    required int activeFaultCount,
    String? description,
    String? serialNumber,
    String? manufacturer,
    String? model,
    String? firmwareVersion,
    @JsonKey(unknownEnumValue: DeviceListStatus.unknown)
    @Default(DeviceListStatus.unknown)
    DeviceListStatus status,
    @JsonKey(unknownEnumValue: DeviceType.unknown)
    @Default(DeviceType.unknown)
    DeviceType type,
    String? roomId,
    DateTime? lastSeenAt,
    @JsonKey(unknownEnumValue: CommunicationMode.unknown)
    @Default(CommunicationMode.unknown)
    CommunicationMode communicationMode,
    String? lastConnectionError,
    DateTime? lastConnectionAttemptAt,
    String? lastKnownIp,
    String? heatingRelayEntityId,
    String? controlTemperatureEntityId,
    String? pumpRelayEntityId,
    String? pumpComparisonEntityId,
    @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)
    @Default(InverterIntegrationMode.unknown)
    InverterIntegrationMode inverterIntegrationMode,
    String? inverterVendorProfileId,
    @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)
    @Default(LocalControlTemperatureSource.unknown)
    LocalControlTemperatureSource localControlTemperatureSource,
    @JsonKey(unknownEnumValue: FirmwareState.unknown)
    FirmwareState? currentState,
    @Default(<Capability>[]) List<Capability> capabilities,
    @JsonKey(unknownEnumValue: ConnectivityState.unknown)
    @Default(ConnectivityState.unknown)
    ConnectivityState connectivityState,
  }) = _DeviceListItem;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$DeviceListItemFromJson(json);

  /// A heating device is one with a heating relay wired up (plan §4.1).
  bool get isHeating => heatingRelayEntityId != null;
}

/// Enabled capability of a listed device.
@freezed
abstract class Capability with _$Capability {
  const factory({
    required String id,
    @JsonKey(unknownEnumValue: CapabilityType.unknown)
    @Default(CapabilityType.unknown)
    CapabilityType type,
  }) = _Capability;

  factory fromJson(Map<String, dynamic> json) => _$CapabilityFromJson(json);
}
