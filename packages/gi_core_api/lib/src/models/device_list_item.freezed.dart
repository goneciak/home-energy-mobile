// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceListItem {

 String get id; String get name; DateTime get createdAt; DateTime get updatedAt; bool get enabled; bool get heatingSuspended; int get fallbackThresholdMs; int get boilerEstimateWindowMinutes; bool get dryRun; int get activeFaultCount; String? get description; String? get serialNumber; String? get manufacturer; String? get model; String? get firmwareVersion;@JsonKey(unknownEnumValue: DeviceListStatus.unknown) DeviceListStatus get status;@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType get type; String? get roomId; DateTime? get lastSeenAt;@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode get communicationMode; String? get lastConnectionError; DateTime? get lastConnectionAttemptAt; String? get lastKnownIp; String? get heatingRelayEntityId; String? get controlTemperatureEntityId; String? get pumpRelayEntityId; String? get pumpComparisonEntityId;@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode get inverterIntegrationMode; String? get inverterVendorProfileId;@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource get localControlTemperatureSource;@JsonKey(unknownEnumValue: FirmwareState.unknown) FirmwareState? get currentState; List<Capability> get capabilities;@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState get connectivityState;
/// Create a copy of DeviceListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceListItemCopyWith<DeviceListItem> get copyWith => _$DeviceListItemCopyWithImpl<DeviceListItem>(this as DeviceListItem, _$identity);

  /// Serializes this DeviceListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceListItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.heatingSuspended, _this.heatingSuspended) || other.heatingSuspended == _this.heatingSuspended)&&(identical(other.fallbackThresholdMs, _this.fallbackThresholdMs) || other.fallbackThresholdMs == _this.fallbackThresholdMs)&&(identical(other.boilerEstimateWindowMinutes, _this.boilerEstimateWindowMinutes) || other.boilerEstimateWindowMinutes == _this.boilerEstimateWindowMinutes)&&(identical(other.dryRun, _this.dryRun) || other.dryRun == _this.dryRun)&&(identical(other.activeFaultCount, _this.activeFaultCount) || other.activeFaultCount == _this.activeFaultCount)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.serialNumber, _this.serialNumber) || other.serialNumber == _this.serialNumber)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmwareVersion, _this.firmwareVersion) || other.firmwareVersion == _this.firmwareVersion)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.communicationMode, _this.communicationMode) || other.communicationMode == _this.communicationMode)&&(identical(other.lastConnectionError, _this.lastConnectionError) || other.lastConnectionError == _this.lastConnectionError)&&(identical(other.lastConnectionAttemptAt, _this.lastConnectionAttemptAt) || other.lastConnectionAttemptAt == _this.lastConnectionAttemptAt)&&(identical(other.lastKnownIp, _this.lastKnownIp) || other.lastKnownIp == _this.lastKnownIp)&&(identical(other.heatingRelayEntityId, _this.heatingRelayEntityId) || other.heatingRelayEntityId == _this.heatingRelayEntityId)&&(identical(other.controlTemperatureEntityId, _this.controlTemperatureEntityId) || other.controlTemperatureEntityId == _this.controlTemperatureEntityId)&&(identical(other.pumpRelayEntityId, _this.pumpRelayEntityId) || other.pumpRelayEntityId == _this.pumpRelayEntityId)&&(identical(other.pumpComparisonEntityId, _this.pumpComparisonEntityId) || other.pumpComparisonEntityId == _this.pumpComparisonEntityId)&&(identical(other.inverterIntegrationMode, _this.inverterIntegrationMode) || other.inverterIntegrationMode == _this.inverterIntegrationMode)&&(identical(other.inverterVendorProfileId, _this.inverterVendorProfileId) || other.inverterVendorProfileId == _this.inverterVendorProfileId)&&(identical(other.localControlTemperatureSource, _this.localControlTemperatureSource) || other.localControlTemperatureSource == _this.localControlTemperatureSource)&&(identical(other.currentState, _this.currentState) || other.currentState == _this.currentState)&&const DeepCollectionEquality().equals(other.capabilities, _this.capabilities)&&(identical(other.connectivityState, _this.connectivityState) || other.connectivityState == _this.connectivityState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceListItem;
  return Object.hashAll([runtimeType,_this.id,_this.name,_this.createdAt,_this.updatedAt,_this.enabled,_this.heatingSuspended,_this.fallbackThresholdMs,_this.boilerEstimateWindowMinutes,_this.dryRun,_this.activeFaultCount,_this.description,_this.serialNumber,_this.manufacturer,_this.model,_this.firmwareVersion,_this.status,_this.type,_this.roomId,_this.lastSeenAt,_this.communicationMode,_this.lastConnectionError,_this.lastConnectionAttemptAt,_this.lastKnownIp,_this.heatingRelayEntityId,_this.controlTemperatureEntityId,_this.pumpRelayEntityId,_this.pumpComparisonEntityId,_this.inverterIntegrationMode,_this.inverterVendorProfileId,_this.localControlTemperatureSource,_this.currentState,const DeepCollectionEquality().hash(_this.capabilities),_this.connectivityState]);
}

@override
String toString() {
  final _this = this as DeviceListItem;
  return 'DeviceListItem(id: ${_this.id}, name: ${_this.name}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, enabled: ${_this.enabled}, heatingSuspended: ${_this.heatingSuspended}, fallbackThresholdMs: ${_this.fallbackThresholdMs}, boilerEstimateWindowMinutes: ${_this.boilerEstimateWindowMinutes}, dryRun: ${_this.dryRun}, activeFaultCount: ${_this.activeFaultCount}, description: ${_this.description}, serialNumber: ${_this.serialNumber}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmwareVersion: ${_this.firmwareVersion}, status: ${_this.status}, type: ${_this.type}, roomId: ${_this.roomId}, lastSeenAt: ${_this.lastSeenAt}, communicationMode: ${_this.communicationMode}, lastConnectionError: ${_this.lastConnectionError}, lastConnectionAttemptAt: ${_this.lastConnectionAttemptAt}, lastKnownIp: ${_this.lastKnownIp}, heatingRelayEntityId: ${_this.heatingRelayEntityId}, controlTemperatureEntityId: ${_this.controlTemperatureEntityId}, pumpRelayEntityId: ${_this.pumpRelayEntityId}, pumpComparisonEntityId: ${_this.pumpComparisonEntityId}, inverterIntegrationMode: ${_this.inverterIntegrationMode}, inverterVendorProfileId: ${_this.inverterVendorProfileId}, localControlTemperatureSource: ${_this.localControlTemperatureSource}, currentState: ${_this.currentState}, capabilities: ${_this.capabilities}, connectivityState: ${_this.connectivityState})';
}


}

/// @nodoc
abstract mixin class $DeviceListItemCopyWith<$Res>  {
  factory $DeviceListItemCopyWith(DeviceListItem value, $Res Function(DeviceListItem) _then) = _$DeviceListItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, bool enabled, bool heatingSuspended, int fallbackThresholdMs, int boilerEstimateWindowMinutes, bool dryRun, int activeFaultCount, String? description, String? serialNumber, String? manufacturer, String? model, String? firmwareVersion,@JsonKey(unknownEnumValue: DeviceListStatus.unknown) DeviceListStatus status,@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType type, String? roomId, DateTime? lastSeenAt,@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode communicationMode, String? lastConnectionError, DateTime? lastConnectionAttemptAt, String? lastKnownIp, String? heatingRelayEntityId, String? controlTemperatureEntityId, String? pumpRelayEntityId, String? pumpComparisonEntityId,@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode inverterIntegrationMode, String? inverterVendorProfileId,@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource localControlTemperatureSource,@JsonKey(unknownEnumValue: FirmwareState.unknown) FirmwareState? currentState, List<Capability> capabilities,@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState connectivityState
});




}
/// @nodoc
class _$DeviceListItemCopyWithImpl<$Res>
    implements $DeviceListItemCopyWith<$Res> {
  _$DeviceListItemCopyWithImpl(this._self, this._then);

  final DeviceListItem _self;
  final $Res Function(DeviceListItem) _then;

/// Create a copy of DeviceListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? enabled = null,Object? heatingSuspended = null,Object? fallbackThresholdMs = null,Object? boilerEstimateWindowMinutes = null,Object? dryRun = null,Object? activeFaultCount = null,Object? description = freezed,Object? serialNumber = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmwareVersion = freezed,Object? status = null,Object? type = null,Object? roomId = freezed,Object? lastSeenAt = freezed,Object? communicationMode = null,Object? lastConnectionError = freezed,Object? lastConnectionAttemptAt = freezed,Object? lastKnownIp = freezed,Object? heatingRelayEntityId = freezed,Object? controlTemperatureEntityId = freezed,Object? pumpRelayEntityId = freezed,Object? pumpComparisonEntityId = freezed,Object? inverterIntegrationMode = null,Object? inverterVendorProfileId = freezed,Object? localControlTemperatureSource = null,Object? currentState = freezed,Object? capabilities = null,Object? connectivityState = null,}) {
  return _then(DeviceListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,heatingSuspended: null == heatingSuspended ? _self.heatingSuspended : heatingSuspended // ignore: cast_nullable_to_non_nullable
as bool,fallbackThresholdMs: null == fallbackThresholdMs ? _self.fallbackThresholdMs : fallbackThresholdMs // ignore: cast_nullable_to_non_nullable
as int,boilerEstimateWindowMinutes: null == boilerEstimateWindowMinutes ? _self.boilerEstimateWindowMinutes : boilerEstimateWindowMinutes // ignore: cast_nullable_to_non_nullable
as int,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,activeFaultCount: null == activeFaultCount ? _self.activeFaultCount : activeFaultCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceListStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,communicationMode: null == communicationMode ? _self.communicationMode : communicationMode // ignore: cast_nullable_to_non_nullable
as CommunicationMode,lastConnectionError: freezed == lastConnectionError ? _self.lastConnectionError : lastConnectionError // ignore: cast_nullable_to_non_nullable
as String?,lastConnectionAttemptAt: freezed == lastConnectionAttemptAt ? _self.lastConnectionAttemptAt : lastConnectionAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastKnownIp: freezed == lastKnownIp ? _self.lastKnownIp : lastKnownIp // ignore: cast_nullable_to_non_nullable
as String?,heatingRelayEntityId: freezed == heatingRelayEntityId ? _self.heatingRelayEntityId : heatingRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,controlTemperatureEntityId: freezed == controlTemperatureEntityId ? _self.controlTemperatureEntityId : controlTemperatureEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpRelayEntityId: freezed == pumpRelayEntityId ? _self.pumpRelayEntityId : pumpRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpComparisonEntityId: freezed == pumpComparisonEntityId ? _self.pumpComparisonEntityId : pumpComparisonEntityId // ignore: cast_nullable_to_non_nullable
as String?,inverterIntegrationMode: null == inverterIntegrationMode ? _self.inverterIntegrationMode : inverterIntegrationMode // ignore: cast_nullable_to_non_nullable
as InverterIntegrationMode,inverterVendorProfileId: freezed == inverterVendorProfileId ? _self.inverterVendorProfileId : inverterVendorProfileId // ignore: cast_nullable_to_non_nullable
as String?,localControlTemperatureSource: null == localControlTemperatureSource ? _self.localControlTemperatureSource : localControlTemperatureSource // ignore: cast_nullable_to_non_nullable
as LocalControlTemperatureSource,currentState: freezed == currentState ? _self.currentState : currentState // ignore: cast_nullable_to_non_nullable
as FirmwareState?,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,connectivityState: null == connectivityState ? _self.connectivityState : connectivityState // ignore: cast_nullable_to_non_nullable
as ConnectivityState,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceListItem].
extension DeviceListItemPatterns on DeviceListItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceListItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceListItem value)  $default,){
final _that = this;
switch (_that) {
case _DeviceListItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceListItem value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceListItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int activeFaultCount,  String? description,  String? serialNumber,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: DeviceListStatus.unknown)  DeviceListStatus status, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String? roomId,  DateTime? lastSeenAt, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? heatingRelayEntityId,  String? controlTemperatureEntityId,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource, @JsonKey(unknownEnumValue: FirmwareState.unknown)  FirmwareState? currentState,  List<Capability> capabilities, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceListItem() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.activeFaultCount,_that.description,_that.serialNumber,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.type,_that.roomId,_that.lastSeenAt,_that.communicationMode,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.localControlTemperatureSource,_that.currentState,_that.capabilities,_that.connectivityState);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int activeFaultCount,  String? description,  String? serialNumber,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: DeviceListStatus.unknown)  DeviceListStatus status, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String? roomId,  DateTime? lastSeenAt, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? heatingRelayEntityId,  String? controlTemperatureEntityId,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource, @JsonKey(unknownEnumValue: FirmwareState.unknown)  FirmwareState? currentState,  List<Capability> capabilities, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState)  $default,) {final _that = this;
switch (_that) {
case _DeviceListItem():
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.activeFaultCount,_that.description,_that.serialNumber,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.type,_that.roomId,_that.lastSeenAt,_that.communicationMode,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.localControlTemperatureSource,_that.currentState,_that.capabilities,_that.connectivityState);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int activeFaultCount,  String? description,  String? serialNumber,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: DeviceListStatus.unknown)  DeviceListStatus status, @JsonKey(unknownEnumValue: DeviceType.unknown)  DeviceType type,  String? roomId,  DateTime? lastSeenAt, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? heatingRelayEntityId,  String? controlTemperatureEntityId,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource, @JsonKey(unknownEnumValue: FirmwareState.unknown)  FirmwareState? currentState,  List<Capability> capabilities, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState)?  $default,) {final _that = this;
switch (_that) {
case _DeviceListItem() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.activeFaultCount,_that.description,_that.serialNumber,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.type,_that.roomId,_that.lastSeenAt,_that.communicationMode,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.localControlTemperatureSource,_that.currentState,_that.capabilities,_that.connectivityState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceListItem extends DeviceListItem {
  const _DeviceListItem({required this.id, required this.name, required this.createdAt, required this.updatedAt, required this.enabled, required this.heatingSuspended, required this.fallbackThresholdMs, required this.boilerEstimateWindowMinutes, required this.dryRun, required this.activeFaultCount, this.description, this.serialNumber, this.manufacturer, this.model, this.firmwareVersion, @JsonKey(unknownEnumValue: DeviceListStatus.unknown) this.status = DeviceListStatus.unknown, @JsonKey(unknownEnumValue: DeviceType.unknown) this.type = DeviceType.unknown, this.roomId, this.lastSeenAt, @JsonKey(unknownEnumValue: CommunicationMode.unknown) this.communicationMode = CommunicationMode.unknown, this.lastConnectionError, this.lastConnectionAttemptAt, this.lastKnownIp, this.heatingRelayEntityId, this.controlTemperatureEntityId, this.pumpRelayEntityId, this.pumpComparisonEntityId, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) this.inverterIntegrationMode = InverterIntegrationMode.unknown, this.inverterVendorProfileId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) this.localControlTemperatureSource = LocalControlTemperatureSource.unknown, @JsonKey(unknownEnumValue: FirmwareState.unknown) this.currentState,  List<Capability> capabilities = const <Capability>[], @JsonKey(unknownEnumValue: ConnectivityState.unknown) this.connectivityState = ConnectivityState.unknown}): _capabilities = capabilities,super._();
  factory _DeviceListItem.fromJson(Map<String, dynamic> json) => _$DeviceListItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  bool enabled;
@override final  bool heatingSuspended;
@override final  int fallbackThresholdMs;
@override final  int boilerEstimateWindowMinutes;
@override final  bool dryRun;
@override final  int activeFaultCount;
@override final  String? description;
@override final  String? serialNumber;
@override final  String? manufacturer;
@override final  String? model;
@override final  String? firmwareVersion;
@override@JsonKey(unknownEnumValue: DeviceListStatus.unknown) final  DeviceListStatus status;
@override@JsonKey(unknownEnumValue: DeviceType.unknown) final  DeviceType type;
@override final  String? roomId;
@override final  DateTime? lastSeenAt;
@override@JsonKey(unknownEnumValue: CommunicationMode.unknown) final  CommunicationMode communicationMode;
@override final  String? lastConnectionError;
@override final  DateTime? lastConnectionAttemptAt;
@override final  String? lastKnownIp;
@override final  String? heatingRelayEntityId;
@override final  String? controlTemperatureEntityId;
@override final  String? pumpRelayEntityId;
@override final  String? pumpComparisonEntityId;
@override@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) final  InverterIntegrationMode inverterIntegrationMode;
@override final  String? inverterVendorProfileId;
@override@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) final  LocalControlTemperatureSource localControlTemperatureSource;
@override@JsonKey(unknownEnumValue: FirmwareState.unknown) final  FirmwareState? currentState;
 final  List<Capability> _capabilities;
@override@JsonKey() List<Capability> get capabilities {
  if (_capabilities is EqualUnmodifiableListView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capabilities);
}

@override@JsonKey(unknownEnumValue: ConnectivityState.unknown) final  ConnectivityState connectivityState;

/// Create a copy of DeviceListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceListItemCopyWith<_DeviceListItem> get copyWith => __$DeviceListItemCopyWithImpl<_DeviceListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceListItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.heatingSuspended, heatingSuspended) || other.heatingSuspended == heatingSuspended)&&(identical(other.fallbackThresholdMs, fallbackThresholdMs) || other.fallbackThresholdMs == fallbackThresholdMs)&&(identical(other.boilerEstimateWindowMinutes, boilerEstimateWindowMinutes) || other.boilerEstimateWindowMinutes == boilerEstimateWindowMinutes)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.activeFaultCount, activeFaultCount) || other.activeFaultCount == activeFaultCount)&&(identical(other.description, description) || other.description == description)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.communicationMode, communicationMode) || other.communicationMode == communicationMode)&&(identical(other.lastConnectionError, lastConnectionError) || other.lastConnectionError == lastConnectionError)&&(identical(other.lastConnectionAttemptAt, lastConnectionAttemptAt) || other.lastConnectionAttemptAt == lastConnectionAttemptAt)&&(identical(other.lastKnownIp, lastKnownIp) || other.lastKnownIp == lastKnownIp)&&(identical(other.heatingRelayEntityId, heatingRelayEntityId) || other.heatingRelayEntityId == heatingRelayEntityId)&&(identical(other.controlTemperatureEntityId, controlTemperatureEntityId) || other.controlTemperatureEntityId == controlTemperatureEntityId)&&(identical(other.pumpRelayEntityId, pumpRelayEntityId) || other.pumpRelayEntityId == pumpRelayEntityId)&&(identical(other.pumpComparisonEntityId, pumpComparisonEntityId) || other.pumpComparisonEntityId == pumpComparisonEntityId)&&(identical(other.inverterIntegrationMode, inverterIntegrationMode) || other.inverterIntegrationMode == inverterIntegrationMode)&&(identical(other.inverterVendorProfileId, inverterVendorProfileId) || other.inverterVendorProfileId == inverterVendorProfileId)&&(identical(other.localControlTemperatureSource, localControlTemperatureSource) || other.localControlTemperatureSource == localControlTemperatureSource)&&(identical(other.currentState, currentState) || other.currentState == currentState)&&const DeepCollectionEquality().equals(other.capabilities, _capabilities)&&(identical(other.connectivityState, connectivityState) || other.connectivityState == connectivityState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,name,createdAt,updatedAt,enabled,heatingSuspended,fallbackThresholdMs,boilerEstimateWindowMinutes,dryRun,activeFaultCount,description,serialNumber,manufacturer,model,firmwareVersion,status,type,roomId,lastSeenAt,communicationMode,lastConnectionError,lastConnectionAttemptAt,lastKnownIp,heatingRelayEntityId,controlTemperatureEntityId,pumpRelayEntityId,pumpComparisonEntityId,inverterIntegrationMode,inverterVendorProfileId,localControlTemperatureSource,currentState,const DeepCollectionEquality().hash(_capabilities),connectivityState]);
}

@override
String toString() {
    return 'DeviceListItem(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, enabled: $enabled, heatingSuspended: $heatingSuspended, fallbackThresholdMs: $fallbackThresholdMs, boilerEstimateWindowMinutes: $boilerEstimateWindowMinutes, dryRun: $dryRun, activeFaultCount: $activeFaultCount, description: $description, serialNumber: $serialNumber, manufacturer: $manufacturer, model: $model, firmwareVersion: $firmwareVersion, status: $status, type: $type, roomId: $roomId, lastSeenAt: $lastSeenAt, communicationMode: $communicationMode, lastConnectionError: $lastConnectionError, lastConnectionAttemptAt: $lastConnectionAttemptAt, lastKnownIp: $lastKnownIp, heatingRelayEntityId: $heatingRelayEntityId, controlTemperatureEntityId: $controlTemperatureEntityId, pumpRelayEntityId: $pumpRelayEntityId, pumpComparisonEntityId: $pumpComparisonEntityId, inverterIntegrationMode: $inverterIntegrationMode, inverterVendorProfileId: $inverterVendorProfileId, localControlTemperatureSource: $localControlTemperatureSource, currentState: $currentState, capabilities: $capabilities, connectivityState: $connectivityState)';
}


}

/// @nodoc
abstract mixin class _$DeviceListItemCopyWith<$Res> implements $DeviceListItemCopyWith<$Res> {
  factory _$DeviceListItemCopyWith(_DeviceListItem value, $Res Function(_DeviceListItem) _then) = __$DeviceListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, bool enabled, bool heatingSuspended, int fallbackThresholdMs, int boilerEstimateWindowMinutes, bool dryRun, int activeFaultCount, String? description, String? serialNumber, String? manufacturer, String? model, String? firmwareVersion,@JsonKey(unknownEnumValue: DeviceListStatus.unknown) DeviceListStatus status,@JsonKey(unknownEnumValue: DeviceType.unknown) DeviceType type, String? roomId, DateTime? lastSeenAt,@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode communicationMode, String? lastConnectionError, DateTime? lastConnectionAttemptAt, String? lastKnownIp, String? heatingRelayEntityId, String? controlTemperatureEntityId, String? pumpRelayEntityId, String? pumpComparisonEntityId,@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode inverterIntegrationMode, String? inverterVendorProfileId,@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource localControlTemperatureSource,@JsonKey(unknownEnumValue: FirmwareState.unknown) FirmwareState? currentState, List<Capability> capabilities,@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState connectivityState
});




}
/// @nodoc
class __$DeviceListItemCopyWithImpl<$Res>
    implements _$DeviceListItemCopyWith<$Res> {
  __$DeviceListItemCopyWithImpl(this._self, this._then);

  final _DeviceListItem _self;
  final $Res Function(_DeviceListItem) _then;

/// Create a copy of DeviceListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? enabled = null,Object? heatingSuspended = null,Object? fallbackThresholdMs = null,Object? boilerEstimateWindowMinutes = null,Object? dryRun = null,Object? activeFaultCount = null,Object? description = freezed,Object? serialNumber = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmwareVersion = freezed,Object? status = null,Object? type = null,Object? roomId = freezed,Object? lastSeenAt = freezed,Object? communicationMode = null,Object? lastConnectionError = freezed,Object? lastConnectionAttemptAt = freezed,Object? lastKnownIp = freezed,Object? heatingRelayEntityId = freezed,Object? controlTemperatureEntityId = freezed,Object? pumpRelayEntityId = freezed,Object? pumpComparisonEntityId = freezed,Object? inverterIntegrationMode = null,Object? inverterVendorProfileId = freezed,Object? localControlTemperatureSource = null,Object? currentState = freezed,Object? capabilities = null,Object? connectivityState = null,}) {
  return _then(_DeviceListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,heatingSuspended: null == heatingSuspended ? _self.heatingSuspended : heatingSuspended // ignore: cast_nullable_to_non_nullable
as bool,fallbackThresholdMs: null == fallbackThresholdMs ? _self.fallbackThresholdMs : fallbackThresholdMs // ignore: cast_nullable_to_non_nullable
as int,boilerEstimateWindowMinutes: null == boilerEstimateWindowMinutes ? _self.boilerEstimateWindowMinutes : boilerEstimateWindowMinutes // ignore: cast_nullable_to_non_nullable
as int,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,activeFaultCount: null == activeFaultCount ? _self.activeFaultCount : activeFaultCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceListStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeviceType,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,communicationMode: null == communicationMode ? _self.communicationMode : communicationMode // ignore: cast_nullable_to_non_nullable
as CommunicationMode,lastConnectionError: freezed == lastConnectionError ? _self.lastConnectionError : lastConnectionError // ignore: cast_nullable_to_non_nullable
as String?,lastConnectionAttemptAt: freezed == lastConnectionAttemptAt ? _self.lastConnectionAttemptAt : lastConnectionAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastKnownIp: freezed == lastKnownIp ? _self.lastKnownIp : lastKnownIp // ignore: cast_nullable_to_non_nullable
as String?,heatingRelayEntityId: freezed == heatingRelayEntityId ? _self.heatingRelayEntityId : heatingRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,controlTemperatureEntityId: freezed == controlTemperatureEntityId ? _self.controlTemperatureEntityId : controlTemperatureEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpRelayEntityId: freezed == pumpRelayEntityId ? _self.pumpRelayEntityId : pumpRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpComparisonEntityId: freezed == pumpComparisonEntityId ? _self.pumpComparisonEntityId : pumpComparisonEntityId // ignore: cast_nullable_to_non_nullable
as String?,inverterIntegrationMode: null == inverterIntegrationMode ? _self.inverterIntegrationMode : inverterIntegrationMode // ignore: cast_nullable_to_non_nullable
as InverterIntegrationMode,inverterVendorProfileId: freezed == inverterVendorProfileId ? _self.inverterVendorProfileId : inverterVendorProfileId // ignore: cast_nullable_to_non_nullable
as String?,localControlTemperatureSource: null == localControlTemperatureSource ? _self.localControlTemperatureSource : localControlTemperatureSource // ignore: cast_nullable_to_non_nullable
as LocalControlTemperatureSource,currentState: freezed == currentState ? _self.currentState : currentState // ignore: cast_nullable_to_non_nullable
as FirmwareState?,capabilities: null == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<Capability>,connectivityState: null == connectivityState ? _self.connectivityState : connectivityState // ignore: cast_nullable_to_non_nullable
as ConnectivityState,
  ));
}


}


/// @nodoc
mixin _$Capability {

 String get id;@JsonKey(unknownEnumValue: CapabilityType.unknown) CapabilityType get type;
/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilityCopyWith<Capability> get copyWith => _$CapabilityCopyWithImpl<Capability>(this as Capability, _$identity);

  /// Serializes this Capability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Capability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Capability&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Capability;
  return Object.hash(runtimeType,_this.id,_this.type);
}

@override
String toString() {
  final _this = this as Capability;
  return 'Capability(id: ${_this.id}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $CapabilityCopyWith<$Res>  {
  factory $CapabilityCopyWith(Capability value, $Res Function(Capability) _then) = _$CapabilityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: CapabilityType.unknown) CapabilityType type
});




}
/// @nodoc
class _$CapabilityCopyWithImpl<$Res>
    implements $CapabilityCopyWith<$Res> {
  _$CapabilityCopyWithImpl(this._self, this._then);

  final Capability _self;
  final $Res Function(Capability) _then;

/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,}) {
  return _then(Capability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CapabilityType,
  ));
}

}


/// Adds pattern-matching-related methods to [Capability].
extension CapabilityPatterns on Capability {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Capability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Capability value)  $default,){
final _that = this;
switch (_that) {
case _Capability():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Capability value)?  $default,){
final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: CapabilityType.unknown)  CapabilityType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that.id,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: CapabilityType.unknown)  CapabilityType type)  $default,) {final _that = this;
switch (_that) {
case _Capability():
return $default(_that.id,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: CapabilityType.unknown)  CapabilityType type)?  $default,) {final _that = this;
switch (_that) {
case _Capability() when $default != null:
return $default(_that.id,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Capability implements Capability {
  const _Capability({required this.id, @JsonKey(unknownEnumValue: CapabilityType.unknown) this.type = CapabilityType.unknown});
  factory _Capability.fromJson(Map<String, dynamic> json) => _$CapabilityFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: CapabilityType.unknown) final  CapabilityType type;

/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapabilityCopyWith<_Capability> get copyWith => __$CapabilityCopyWithImpl<_Capability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapabilityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Capability&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type);
}

@override
String toString() {
    return 'Capability(id: $id, type: $type)';
}


}

/// @nodoc
abstract mixin class _$CapabilityCopyWith<$Res> implements $CapabilityCopyWith<$Res> {
  factory _$CapabilityCopyWith(_Capability value, $Res Function(_Capability) _then) = __$CapabilityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: CapabilityType.unknown) CapabilityType type
});




}
/// @nodoc
class __$CapabilityCopyWithImpl<$Res>
    implements _$CapabilityCopyWith<$Res> {
  __$CapabilityCopyWithImpl(this._self, this._then);

  final _Capability _self;
  final $Res Function(_Capability) _then;

/// Create a copy of Capability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,}) {
  return _then(_Capability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CapabilityType,
  ));
}


}

// dart format on
