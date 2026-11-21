// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceDetail {

 String get id; String get name; bool get enabled; bool get heatingSuspended; int get fallbackThresholdMs; int get boilerEstimateWindowMinutes; bool get dryRun; int get configurationVersion; String? get description; String? get manufacturer; String? get model; String? get firmwareVersion;@JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus get status; String? get roomId; DateTime? get lastSeenAt; List<DeviceEntity> get entities;@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode get communicationMode;@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode get inverterIntegrationMode; String? get inverterVendorProfileId; String? get heatingRelayEntityId; String? get controlTemperatureEntityId;@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource get localControlTemperatureSource; String? get pumpRelayEntityId; String? get pumpComparisonEntityId;@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState get connectivityState; String? get lastConnectionError; DateTime? get lastConnectionAttemptAt; String? get lastKnownIp; String? get hostname; String? get mac;@DeviceDiagnosticsConverter() DeviceDiagnostics? get diagnostics;@ControlStrategyConverter() ControlStrategy? get controlStrategy;@ControlStrategyConverter() ControlStrategy? get baseControlStrategy;@PvHeatingConfigConverter() PvHeatingConfig? get pvHeatingConfig; String? get pvProductionEntityId; String? get pvConsumptionEntityId; bool get pvBoostActive;
/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceDetailCopyWith<DeviceDetail> get copyWith => _$DeviceDetailCopyWithImpl<DeviceDetail>(this as DeviceDetail, _$identity);

  /// Serializes this DeviceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.heatingSuspended, _this.heatingSuspended) || other.heatingSuspended == _this.heatingSuspended)&&(identical(other.fallbackThresholdMs, _this.fallbackThresholdMs) || other.fallbackThresholdMs == _this.fallbackThresholdMs)&&(identical(other.boilerEstimateWindowMinutes, _this.boilerEstimateWindowMinutes) || other.boilerEstimateWindowMinutes == _this.boilerEstimateWindowMinutes)&&(identical(other.dryRun, _this.dryRun) || other.dryRun == _this.dryRun)&&(identical(other.configurationVersion, _this.configurationVersion) || other.configurationVersion == _this.configurationVersion)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmwareVersion, _this.firmwareVersion) || other.firmwareVersion == _this.firmwareVersion)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&const DeepCollectionEquality().equals(other.entities, _this.entities)&&(identical(other.communicationMode, _this.communicationMode) || other.communicationMode == _this.communicationMode)&&(identical(other.inverterIntegrationMode, _this.inverterIntegrationMode) || other.inverterIntegrationMode == _this.inverterIntegrationMode)&&(identical(other.inverterVendorProfileId, _this.inverterVendorProfileId) || other.inverterVendorProfileId == _this.inverterVendorProfileId)&&(identical(other.heatingRelayEntityId, _this.heatingRelayEntityId) || other.heatingRelayEntityId == _this.heatingRelayEntityId)&&(identical(other.controlTemperatureEntityId, _this.controlTemperatureEntityId) || other.controlTemperatureEntityId == _this.controlTemperatureEntityId)&&(identical(other.localControlTemperatureSource, _this.localControlTemperatureSource) || other.localControlTemperatureSource == _this.localControlTemperatureSource)&&(identical(other.pumpRelayEntityId, _this.pumpRelayEntityId) || other.pumpRelayEntityId == _this.pumpRelayEntityId)&&(identical(other.pumpComparisonEntityId, _this.pumpComparisonEntityId) || other.pumpComparisonEntityId == _this.pumpComparisonEntityId)&&(identical(other.connectivityState, _this.connectivityState) || other.connectivityState == _this.connectivityState)&&(identical(other.lastConnectionError, _this.lastConnectionError) || other.lastConnectionError == _this.lastConnectionError)&&(identical(other.lastConnectionAttemptAt, _this.lastConnectionAttemptAt) || other.lastConnectionAttemptAt == _this.lastConnectionAttemptAt)&&(identical(other.lastKnownIp, _this.lastKnownIp) || other.lastKnownIp == _this.lastKnownIp)&&(identical(other.hostname, _this.hostname) || other.hostname == _this.hostname)&&(identical(other.mac, _this.mac) || other.mac == _this.mac)&&(identical(other.diagnostics, _this.diagnostics) || other.diagnostics == _this.diagnostics)&&(identical(other.controlStrategy, _this.controlStrategy) || other.controlStrategy == _this.controlStrategy)&&(identical(other.baseControlStrategy, _this.baseControlStrategy) || other.baseControlStrategy == _this.baseControlStrategy)&&(identical(other.pvHeatingConfig, _this.pvHeatingConfig) || other.pvHeatingConfig == _this.pvHeatingConfig)&&(identical(other.pvProductionEntityId, _this.pvProductionEntityId) || other.pvProductionEntityId == _this.pvProductionEntityId)&&(identical(other.pvConsumptionEntityId, _this.pvConsumptionEntityId) || other.pvConsumptionEntityId == _this.pvConsumptionEntityId)&&(identical(other.pvBoostActive, _this.pvBoostActive) || other.pvBoostActive == _this.pvBoostActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceDetail;
  return Object.hashAll([runtimeType,_this.id,_this.name,_this.enabled,_this.heatingSuspended,_this.fallbackThresholdMs,_this.boilerEstimateWindowMinutes,_this.dryRun,_this.configurationVersion,_this.description,_this.manufacturer,_this.model,_this.firmwareVersion,_this.status,_this.roomId,_this.lastSeenAt,const DeepCollectionEquality().hash(_this.entities),_this.communicationMode,_this.inverterIntegrationMode,_this.inverterVendorProfileId,_this.heatingRelayEntityId,_this.controlTemperatureEntityId,_this.localControlTemperatureSource,_this.pumpRelayEntityId,_this.pumpComparisonEntityId,_this.connectivityState,_this.lastConnectionError,_this.lastConnectionAttemptAt,_this.lastKnownIp,_this.hostname,_this.mac,_this.diagnostics,_this.controlStrategy,_this.baseControlStrategy,_this.pvHeatingConfig,_this.pvProductionEntityId,_this.pvConsumptionEntityId,_this.pvBoostActive]);
}

@override
String toString() {
  final _this = this as DeviceDetail;
  return 'DeviceDetail(id: ${_this.id}, name: ${_this.name}, enabled: ${_this.enabled}, heatingSuspended: ${_this.heatingSuspended}, fallbackThresholdMs: ${_this.fallbackThresholdMs}, boilerEstimateWindowMinutes: ${_this.boilerEstimateWindowMinutes}, dryRun: ${_this.dryRun}, configurationVersion: ${_this.configurationVersion}, description: ${_this.description}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmwareVersion: ${_this.firmwareVersion}, status: ${_this.status}, roomId: ${_this.roomId}, lastSeenAt: ${_this.lastSeenAt}, entities: ${_this.entities}, communicationMode: ${_this.communicationMode}, inverterIntegrationMode: ${_this.inverterIntegrationMode}, inverterVendorProfileId: ${_this.inverterVendorProfileId}, heatingRelayEntityId: ${_this.heatingRelayEntityId}, controlTemperatureEntityId: ${_this.controlTemperatureEntityId}, localControlTemperatureSource: ${_this.localControlTemperatureSource}, pumpRelayEntityId: ${_this.pumpRelayEntityId}, pumpComparisonEntityId: ${_this.pumpComparisonEntityId}, connectivityState: ${_this.connectivityState}, lastConnectionError: ${_this.lastConnectionError}, lastConnectionAttemptAt: ${_this.lastConnectionAttemptAt}, lastKnownIp: ${_this.lastKnownIp}, hostname: ${_this.hostname}, mac: ${_this.mac}, diagnostics: ${_this.diagnostics}, controlStrategy: ${_this.controlStrategy}, baseControlStrategy: ${_this.baseControlStrategy}, pvHeatingConfig: ${_this.pvHeatingConfig}, pvProductionEntityId: ${_this.pvProductionEntityId}, pvConsumptionEntityId: ${_this.pvConsumptionEntityId}, pvBoostActive: ${_this.pvBoostActive})';
}


}

/// @nodoc
abstract mixin class $DeviceDetailCopyWith<$Res>  {
  factory $DeviceDetailCopyWith(DeviceDetail value, $Res Function(DeviceDetail) _then) = _$DeviceDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool enabled, bool heatingSuspended, int fallbackThresholdMs, int boilerEstimateWindowMinutes, bool dryRun, int configurationVersion, String? description, String? manufacturer, String? model, String? firmwareVersion,@JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status, String? roomId, DateTime? lastSeenAt, List<DeviceEntity> entities,@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode communicationMode,@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode inverterIntegrationMode, String? inverterVendorProfileId, String? heatingRelayEntityId, String? controlTemperatureEntityId,@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource localControlTemperatureSource, String? pumpRelayEntityId, String? pumpComparisonEntityId,@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState connectivityState, String? lastConnectionError, DateTime? lastConnectionAttemptAt, String? lastKnownIp, String? hostname, String? mac,@DeviceDiagnosticsConverter() DeviceDiagnostics? diagnostics,@ControlStrategyConverter() ControlStrategy? controlStrategy,@ControlStrategyConverter() ControlStrategy? baseControlStrategy,@PvHeatingConfigConverter() PvHeatingConfig? pvHeatingConfig, String? pvProductionEntityId, String? pvConsumptionEntityId, bool pvBoostActive
});


$DeviceDiagnosticsCopyWith<$Res>? get diagnostics;$ControlStrategyCopyWith<$Res>? get controlStrategy;$ControlStrategyCopyWith<$Res>? get baseControlStrategy;$PvHeatingConfigCopyWith<$Res>? get pvHeatingConfig;

}
/// @nodoc
class _$DeviceDetailCopyWithImpl<$Res>
    implements $DeviceDetailCopyWith<$Res> {
  _$DeviceDetailCopyWithImpl(this._self, this._then);

  final DeviceDetail _self;
  final $Res Function(DeviceDetail) _then;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? heatingSuspended = null,Object? fallbackThresholdMs = null,Object? boilerEstimateWindowMinutes = null,Object? dryRun = null,Object? configurationVersion = null,Object? description = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmwareVersion = freezed,Object? status = null,Object? roomId = freezed,Object? lastSeenAt = freezed,Object? entities = null,Object? communicationMode = null,Object? inverterIntegrationMode = null,Object? inverterVendorProfileId = freezed,Object? heatingRelayEntityId = freezed,Object? controlTemperatureEntityId = freezed,Object? localControlTemperatureSource = null,Object? pumpRelayEntityId = freezed,Object? pumpComparisonEntityId = freezed,Object? connectivityState = null,Object? lastConnectionError = freezed,Object? lastConnectionAttemptAt = freezed,Object? lastKnownIp = freezed,Object? hostname = freezed,Object? mac = freezed,Object? diagnostics = freezed,Object? controlStrategy = freezed,Object? baseControlStrategy = freezed,Object? pvHeatingConfig = freezed,Object? pvProductionEntityId = freezed,Object? pvConsumptionEntityId = freezed,Object? pvBoostActive = null,}) {
  return _then(DeviceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,heatingSuspended: null == heatingSuspended ? _self.heatingSuspended : heatingSuspended // ignore: cast_nullable_to_non_nullable
as bool,fallbackThresholdMs: null == fallbackThresholdMs ? _self.fallbackThresholdMs : fallbackThresholdMs // ignore: cast_nullable_to_non_nullable
as int,boilerEstimateWindowMinutes: null == boilerEstimateWindowMinutes ? _self.boilerEstimateWindowMinutes : boilerEstimateWindowMinutes // ignore: cast_nullable_to_non_nullable
as int,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,configurationVersion: null == configurationVersion ? _self.configurationVersion : configurationVersion // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,entities: null == entities ? _self.entities : entities // ignore: cast_nullable_to_non_nullable
as List<DeviceEntity>,communicationMode: null == communicationMode ? _self.communicationMode : communicationMode // ignore: cast_nullable_to_non_nullable
as CommunicationMode,inverterIntegrationMode: null == inverterIntegrationMode ? _self.inverterIntegrationMode : inverterIntegrationMode // ignore: cast_nullable_to_non_nullable
as InverterIntegrationMode,inverterVendorProfileId: freezed == inverterVendorProfileId ? _self.inverterVendorProfileId : inverterVendorProfileId // ignore: cast_nullable_to_non_nullable
as String?,heatingRelayEntityId: freezed == heatingRelayEntityId ? _self.heatingRelayEntityId : heatingRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,controlTemperatureEntityId: freezed == controlTemperatureEntityId ? _self.controlTemperatureEntityId : controlTemperatureEntityId // ignore: cast_nullable_to_non_nullable
as String?,localControlTemperatureSource: null == localControlTemperatureSource ? _self.localControlTemperatureSource : localControlTemperatureSource // ignore: cast_nullable_to_non_nullable
as LocalControlTemperatureSource,pumpRelayEntityId: freezed == pumpRelayEntityId ? _self.pumpRelayEntityId : pumpRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpComparisonEntityId: freezed == pumpComparisonEntityId ? _self.pumpComparisonEntityId : pumpComparisonEntityId // ignore: cast_nullable_to_non_nullable
as String?,connectivityState: null == connectivityState ? _self.connectivityState : connectivityState // ignore: cast_nullable_to_non_nullable
as ConnectivityState,lastConnectionError: freezed == lastConnectionError ? _self.lastConnectionError : lastConnectionError // ignore: cast_nullable_to_non_nullable
as String?,lastConnectionAttemptAt: freezed == lastConnectionAttemptAt ? _self.lastConnectionAttemptAt : lastConnectionAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastKnownIp: freezed == lastKnownIp ? _self.lastKnownIp : lastKnownIp // ignore: cast_nullable_to_non_nullable
as String?,hostname: freezed == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String?,mac: freezed == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String?,diagnostics: freezed == diagnostics ? _self.diagnostics : diagnostics // ignore: cast_nullable_to_non_nullable
as DeviceDiagnostics?,controlStrategy: freezed == controlStrategy ? _self.controlStrategy : controlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,baseControlStrategy: freezed == baseControlStrategy ? _self.baseControlStrategy : baseControlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,pvHeatingConfig: freezed == pvHeatingConfig ? _self.pvHeatingConfig : pvHeatingConfig // ignore: cast_nullable_to_non_nullable
as PvHeatingConfig?,pvProductionEntityId: freezed == pvProductionEntityId ? _self.pvProductionEntityId : pvProductionEntityId // ignore: cast_nullable_to_non_nullable
as String?,pvConsumptionEntityId: freezed == pvConsumptionEntityId ? _self.pvConsumptionEntityId : pvConsumptionEntityId // ignore: cast_nullable_to_non_nullable
as String?,pvBoostActive: null == pvBoostActive ? _self.pvBoostActive : pvBoostActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceDiagnosticsCopyWith<$Res>? get diagnostics {
    if (_self.diagnostics == null) {
    return null;
  }

  return $DeviceDiagnosticsCopyWith<$Res>(_self.diagnostics!, (value) {
    return _then(_self.copyWith(diagnostics: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ControlStrategyCopyWith<$Res>? get controlStrategy {
    if (_self.controlStrategy == null) {
    return null;
  }

  return $ControlStrategyCopyWith<$Res>(_self.controlStrategy!, (value) {
    return _then(_self.copyWith(controlStrategy: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ControlStrategyCopyWith<$Res>? get baseControlStrategy {
    if (_self.baseControlStrategy == null) {
    return null;
  }

  return $ControlStrategyCopyWith<$Res>(_self.baseControlStrategy!, (value) {
    return _then(_self.copyWith(baseControlStrategy: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PvHeatingConfigCopyWith<$Res>? get pvHeatingConfig {
    if (_self.pvHeatingConfig == null) {
    return null;
  }

  return $PvHeatingConfigCopyWith<$Res>(_self.pvHeatingConfig!, (value) {
    return _then(_self.copyWith(pvHeatingConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeviceDetail].
extension DeviceDetailPatterns on DeviceDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceDetail value)  $default,){
final _that = this;
switch (_that) {
case _DeviceDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int configurationVersion,  String? description,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: ProductStatus.unknown)  ProductStatus status,  String? roomId,  DateTime? lastSeenAt,  List<DeviceEntity> entities, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId,  String? heatingRelayEntityId,  String? controlTemperatureEntityId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? hostname,  String? mac, @DeviceDiagnosticsConverter()  DeviceDiagnostics? diagnostics, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy, @PvHeatingConfigConverter()  PvHeatingConfig? pvHeatingConfig,  String? pvProductionEntityId,  String? pvConsumptionEntityId,  bool pvBoostActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.configurationVersion,_that.description,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.roomId,_that.lastSeenAt,_that.entities,_that.communicationMode,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.localControlTemperatureSource,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.connectivityState,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.hostname,_that.mac,_that.diagnostics,_that.controlStrategy,_that.baseControlStrategy,_that.pvHeatingConfig,_that.pvProductionEntityId,_that.pvConsumptionEntityId,_that.pvBoostActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int configurationVersion,  String? description,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: ProductStatus.unknown)  ProductStatus status,  String? roomId,  DateTime? lastSeenAt,  List<DeviceEntity> entities, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId,  String? heatingRelayEntityId,  String? controlTemperatureEntityId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? hostname,  String? mac, @DeviceDiagnosticsConverter()  DeviceDiagnostics? diagnostics, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy, @PvHeatingConfigConverter()  PvHeatingConfig? pvHeatingConfig,  String? pvProductionEntityId,  String? pvConsumptionEntityId,  bool pvBoostActive)  $default,) {final _that = this;
switch (_that) {
case _DeviceDetail():
return $default(_that.id,_that.name,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.configurationVersion,_that.description,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.roomId,_that.lastSeenAt,_that.entities,_that.communicationMode,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.localControlTemperatureSource,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.connectivityState,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.hostname,_that.mac,_that.diagnostics,_that.controlStrategy,_that.baseControlStrategy,_that.pvHeatingConfig,_that.pvProductionEntityId,_that.pvConsumptionEntityId,_that.pvBoostActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool enabled,  bool heatingSuspended,  int fallbackThresholdMs,  int boilerEstimateWindowMinutes,  bool dryRun,  int configurationVersion,  String? description,  String? manufacturer,  String? model,  String? firmwareVersion, @JsonKey(unknownEnumValue: ProductStatus.unknown)  ProductStatus status,  String? roomId,  DateTime? lastSeenAt,  List<DeviceEntity> entities, @JsonKey(unknownEnumValue: CommunicationMode.unknown)  CommunicationMode communicationMode, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown)  InverterIntegrationMode inverterIntegrationMode,  String? inverterVendorProfileId,  String? heatingRelayEntityId,  String? controlTemperatureEntityId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown)  LocalControlTemperatureSource localControlTemperatureSource,  String? pumpRelayEntityId,  String? pumpComparisonEntityId, @JsonKey(unknownEnumValue: ConnectivityState.unknown)  ConnectivityState connectivityState,  String? lastConnectionError,  DateTime? lastConnectionAttemptAt,  String? lastKnownIp,  String? hostname,  String? mac, @DeviceDiagnosticsConverter()  DeviceDiagnostics? diagnostics, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy, @PvHeatingConfigConverter()  PvHeatingConfig? pvHeatingConfig,  String? pvProductionEntityId,  String? pvConsumptionEntityId,  bool pvBoostActive)?  $default,) {final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
return $default(_that.id,_that.name,_that.enabled,_that.heatingSuspended,_that.fallbackThresholdMs,_that.boilerEstimateWindowMinutes,_that.dryRun,_that.configurationVersion,_that.description,_that.manufacturer,_that.model,_that.firmwareVersion,_that.status,_that.roomId,_that.lastSeenAt,_that.entities,_that.communicationMode,_that.inverterIntegrationMode,_that.inverterVendorProfileId,_that.heatingRelayEntityId,_that.controlTemperatureEntityId,_that.localControlTemperatureSource,_that.pumpRelayEntityId,_that.pumpComparisonEntityId,_that.connectivityState,_that.lastConnectionError,_that.lastConnectionAttemptAt,_that.lastKnownIp,_that.hostname,_that.mac,_that.diagnostics,_that.controlStrategy,_that.baseControlStrategy,_that.pvHeatingConfig,_that.pvProductionEntityId,_that.pvConsumptionEntityId,_that.pvBoostActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceDetail extends DeviceDetail {
  const _DeviceDetail({required this.id, required this.name, required this.enabled, required this.heatingSuspended, required this.fallbackThresholdMs, required this.boilerEstimateWindowMinutes, required this.dryRun, required this.configurationVersion, this.description, this.manufacturer, this.model, this.firmwareVersion, @JsonKey(unknownEnumValue: ProductStatus.unknown) this.status = ProductStatus.unknown, this.roomId, this.lastSeenAt,  List<DeviceEntity> entities = const <DeviceEntity>[], @JsonKey(unknownEnumValue: CommunicationMode.unknown) this.communicationMode = CommunicationMode.unknown, @JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) this.inverterIntegrationMode = InverterIntegrationMode.unknown, this.inverterVendorProfileId, this.heatingRelayEntityId, this.controlTemperatureEntityId, @JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) this.localControlTemperatureSource = LocalControlTemperatureSource.unknown, this.pumpRelayEntityId, this.pumpComparisonEntityId, @JsonKey(unknownEnumValue: ConnectivityState.unknown) this.connectivityState = ConnectivityState.unknown, this.lastConnectionError, this.lastConnectionAttemptAt, this.lastKnownIp, this.hostname, this.mac, @DeviceDiagnosticsConverter() this.diagnostics, @ControlStrategyConverter() this.controlStrategy, @ControlStrategyConverter() this.baseControlStrategy, @PvHeatingConfigConverter() this.pvHeatingConfig, this.pvProductionEntityId, this.pvConsumptionEntityId, this.pvBoostActive = false}): _entities = entities,super._();
  factory _DeviceDetail.fromJson(Map<String, dynamic> json) => _$DeviceDetailFromJson(json);

@override final  String id;
@override final  String name;
@override final  bool enabled;
@override final  bool heatingSuspended;
@override final  int fallbackThresholdMs;
@override final  int boilerEstimateWindowMinutes;
@override final  bool dryRun;
@override final  int configurationVersion;
@override final  String? description;
@override final  String? manufacturer;
@override final  String? model;
@override final  String? firmwareVersion;
@override@JsonKey(unknownEnumValue: ProductStatus.unknown) final  ProductStatus status;
@override final  String? roomId;
@override final  DateTime? lastSeenAt;
 final  List<DeviceEntity> _entities;
@override@JsonKey() List<DeviceEntity> get entities {
  if (_entities is EqualUnmodifiableListView) return _entities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entities);
}

@override@JsonKey(unknownEnumValue: CommunicationMode.unknown) final  CommunicationMode communicationMode;
@override@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) final  InverterIntegrationMode inverterIntegrationMode;
@override final  String? inverterVendorProfileId;
@override final  String? heatingRelayEntityId;
@override final  String? controlTemperatureEntityId;
@override@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) final  LocalControlTemperatureSource localControlTemperatureSource;
@override final  String? pumpRelayEntityId;
@override final  String? pumpComparisonEntityId;
@override@JsonKey(unknownEnumValue: ConnectivityState.unknown) final  ConnectivityState connectivityState;
@override final  String? lastConnectionError;
@override final  DateTime? lastConnectionAttemptAt;
@override final  String? lastKnownIp;
@override final  String? hostname;
@override final  String? mac;
@override@DeviceDiagnosticsConverter() final  DeviceDiagnostics? diagnostics;
@override@ControlStrategyConverter() final  ControlStrategy? controlStrategy;
@override@ControlStrategyConverter() final  ControlStrategy? baseControlStrategy;
@override@PvHeatingConfigConverter() final  PvHeatingConfig? pvHeatingConfig;
@override final  String? pvProductionEntityId;
@override final  String? pvConsumptionEntityId;
@override@JsonKey() final  bool pvBoostActive;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceDetailCopyWith<_DeviceDetail> get copyWith => __$DeviceDetailCopyWithImpl<_DeviceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.heatingSuspended, heatingSuspended) || other.heatingSuspended == heatingSuspended)&&(identical(other.fallbackThresholdMs, fallbackThresholdMs) || other.fallbackThresholdMs == fallbackThresholdMs)&&(identical(other.boilerEstimateWindowMinutes, boilerEstimateWindowMinutes) || other.boilerEstimateWindowMinutes == boilerEstimateWindowMinutes)&&(identical(other.dryRun, dryRun) || other.dryRun == dryRun)&&(identical(other.configurationVersion, configurationVersion) || other.configurationVersion == configurationVersion)&&(identical(other.description, description) || other.description == description)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.status, status) || other.status == status)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&const DeepCollectionEquality().equals(other.entities, _entities)&&(identical(other.communicationMode, communicationMode) || other.communicationMode == communicationMode)&&(identical(other.inverterIntegrationMode, inverterIntegrationMode) || other.inverterIntegrationMode == inverterIntegrationMode)&&(identical(other.inverterVendorProfileId, inverterVendorProfileId) || other.inverterVendorProfileId == inverterVendorProfileId)&&(identical(other.heatingRelayEntityId, heatingRelayEntityId) || other.heatingRelayEntityId == heatingRelayEntityId)&&(identical(other.controlTemperatureEntityId, controlTemperatureEntityId) || other.controlTemperatureEntityId == controlTemperatureEntityId)&&(identical(other.localControlTemperatureSource, localControlTemperatureSource) || other.localControlTemperatureSource == localControlTemperatureSource)&&(identical(other.pumpRelayEntityId, pumpRelayEntityId) || other.pumpRelayEntityId == pumpRelayEntityId)&&(identical(other.pumpComparisonEntityId, pumpComparisonEntityId) || other.pumpComparisonEntityId == pumpComparisonEntityId)&&(identical(other.connectivityState, connectivityState) || other.connectivityState == connectivityState)&&(identical(other.lastConnectionError, lastConnectionError) || other.lastConnectionError == lastConnectionError)&&(identical(other.lastConnectionAttemptAt, lastConnectionAttemptAt) || other.lastConnectionAttemptAt == lastConnectionAttemptAt)&&(identical(other.lastKnownIp, lastKnownIp) || other.lastKnownIp == lastKnownIp)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.mac, mac) || other.mac == mac)&&(identical(other.diagnostics, diagnostics) || other.diagnostics == diagnostics)&&(identical(other.controlStrategy, controlStrategy) || other.controlStrategy == controlStrategy)&&(identical(other.baseControlStrategy, baseControlStrategy) || other.baseControlStrategy == baseControlStrategy)&&(identical(other.pvHeatingConfig, pvHeatingConfig) || other.pvHeatingConfig == pvHeatingConfig)&&(identical(other.pvProductionEntityId, pvProductionEntityId) || other.pvProductionEntityId == pvProductionEntityId)&&(identical(other.pvConsumptionEntityId, pvConsumptionEntityId) || other.pvConsumptionEntityId == pvConsumptionEntityId)&&(identical(other.pvBoostActive, pvBoostActive) || other.pvBoostActive == pvBoostActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,name,enabled,heatingSuspended,fallbackThresholdMs,boilerEstimateWindowMinutes,dryRun,configurationVersion,description,manufacturer,model,firmwareVersion,status,roomId,lastSeenAt,const DeepCollectionEquality().hash(_entities),communicationMode,inverterIntegrationMode,inverterVendorProfileId,heatingRelayEntityId,controlTemperatureEntityId,localControlTemperatureSource,pumpRelayEntityId,pumpComparisonEntityId,connectivityState,lastConnectionError,lastConnectionAttemptAt,lastKnownIp,hostname,mac,diagnostics,controlStrategy,baseControlStrategy,pvHeatingConfig,pvProductionEntityId,pvConsumptionEntityId,pvBoostActive]);
}

@override
String toString() {
    return 'DeviceDetail(id: $id, name: $name, enabled: $enabled, heatingSuspended: $heatingSuspended, fallbackThresholdMs: $fallbackThresholdMs, boilerEstimateWindowMinutes: $boilerEstimateWindowMinutes, dryRun: $dryRun, configurationVersion: $configurationVersion, description: $description, manufacturer: $manufacturer, model: $model, firmwareVersion: $firmwareVersion, status: $status, roomId: $roomId, lastSeenAt: $lastSeenAt, entities: $entities, communicationMode: $communicationMode, inverterIntegrationMode: $inverterIntegrationMode, inverterVendorProfileId: $inverterVendorProfileId, heatingRelayEntityId: $heatingRelayEntityId, controlTemperatureEntityId: $controlTemperatureEntityId, localControlTemperatureSource: $localControlTemperatureSource, pumpRelayEntityId: $pumpRelayEntityId, pumpComparisonEntityId: $pumpComparisonEntityId, connectivityState: $connectivityState, lastConnectionError: $lastConnectionError, lastConnectionAttemptAt: $lastConnectionAttemptAt, lastKnownIp: $lastKnownIp, hostname: $hostname, mac: $mac, diagnostics: $diagnostics, controlStrategy: $controlStrategy, baseControlStrategy: $baseControlStrategy, pvHeatingConfig: $pvHeatingConfig, pvProductionEntityId: $pvProductionEntityId, pvConsumptionEntityId: $pvConsumptionEntityId, pvBoostActive: $pvBoostActive)';
}


}

/// @nodoc
abstract mixin class _$DeviceDetailCopyWith<$Res> implements $DeviceDetailCopyWith<$Res> {
  factory _$DeviceDetailCopyWith(_DeviceDetail value, $Res Function(_DeviceDetail) _then) = __$DeviceDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool enabled, bool heatingSuspended, int fallbackThresholdMs, int boilerEstimateWindowMinutes, bool dryRun, int configurationVersion, String? description, String? manufacturer, String? model, String? firmwareVersion,@JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status, String? roomId, DateTime? lastSeenAt, List<DeviceEntity> entities,@JsonKey(unknownEnumValue: CommunicationMode.unknown) CommunicationMode communicationMode,@JsonKey(unknownEnumValue: InverterIntegrationMode.unknown) InverterIntegrationMode inverterIntegrationMode, String? inverterVendorProfileId, String? heatingRelayEntityId, String? controlTemperatureEntityId,@JsonKey(unknownEnumValue: LocalControlTemperatureSource.unknown) LocalControlTemperatureSource localControlTemperatureSource, String? pumpRelayEntityId, String? pumpComparisonEntityId,@JsonKey(unknownEnumValue: ConnectivityState.unknown) ConnectivityState connectivityState, String? lastConnectionError, DateTime? lastConnectionAttemptAt, String? lastKnownIp, String? hostname, String? mac,@DeviceDiagnosticsConverter() DeviceDiagnostics? diagnostics,@ControlStrategyConverter() ControlStrategy? controlStrategy,@ControlStrategyConverter() ControlStrategy? baseControlStrategy,@PvHeatingConfigConverter() PvHeatingConfig? pvHeatingConfig, String? pvProductionEntityId, String? pvConsumptionEntityId, bool pvBoostActive
});


@override $DeviceDiagnosticsCopyWith<$Res>? get diagnostics;@override $ControlStrategyCopyWith<$Res>? get controlStrategy;@override $ControlStrategyCopyWith<$Res>? get baseControlStrategy;@override $PvHeatingConfigCopyWith<$Res>? get pvHeatingConfig;

}
/// @nodoc
class __$DeviceDetailCopyWithImpl<$Res>
    implements _$DeviceDetailCopyWith<$Res> {
  __$DeviceDetailCopyWithImpl(this._self, this._then);

  final _DeviceDetail _self;
  final $Res Function(_DeviceDetail) _then;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? enabled = null,Object? heatingSuspended = null,Object? fallbackThresholdMs = null,Object? boilerEstimateWindowMinutes = null,Object? dryRun = null,Object? configurationVersion = null,Object? description = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmwareVersion = freezed,Object? status = null,Object? roomId = freezed,Object? lastSeenAt = freezed,Object? entities = null,Object? communicationMode = null,Object? inverterIntegrationMode = null,Object? inverterVendorProfileId = freezed,Object? heatingRelayEntityId = freezed,Object? controlTemperatureEntityId = freezed,Object? localControlTemperatureSource = null,Object? pumpRelayEntityId = freezed,Object? pumpComparisonEntityId = freezed,Object? connectivityState = null,Object? lastConnectionError = freezed,Object? lastConnectionAttemptAt = freezed,Object? lastKnownIp = freezed,Object? hostname = freezed,Object? mac = freezed,Object? diagnostics = freezed,Object? controlStrategy = freezed,Object? baseControlStrategy = freezed,Object? pvHeatingConfig = freezed,Object? pvProductionEntityId = freezed,Object? pvConsumptionEntityId = freezed,Object? pvBoostActive = null,}) {
  return _then(_DeviceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,heatingSuspended: null == heatingSuspended ? _self.heatingSuspended : heatingSuspended // ignore: cast_nullable_to_non_nullable
as bool,fallbackThresholdMs: null == fallbackThresholdMs ? _self.fallbackThresholdMs : fallbackThresholdMs // ignore: cast_nullable_to_non_nullable
as int,boilerEstimateWindowMinutes: null == boilerEstimateWindowMinutes ? _self.boilerEstimateWindowMinutes : boilerEstimateWindowMinutes // ignore: cast_nullable_to_non_nullable
as int,dryRun: null == dryRun ? _self.dryRun : dryRun // ignore: cast_nullable_to_non_nullable
as bool,configurationVersion: null == configurationVersion ? _self.configurationVersion : configurationVersion // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,entities: null == entities ? _self._entities : entities // ignore: cast_nullable_to_non_nullable
as List<DeviceEntity>,communicationMode: null == communicationMode ? _self.communicationMode : communicationMode // ignore: cast_nullable_to_non_nullable
as CommunicationMode,inverterIntegrationMode: null == inverterIntegrationMode ? _self.inverterIntegrationMode : inverterIntegrationMode // ignore: cast_nullable_to_non_nullable
as InverterIntegrationMode,inverterVendorProfileId: freezed == inverterVendorProfileId ? _self.inverterVendorProfileId : inverterVendorProfileId // ignore: cast_nullable_to_non_nullable
as String?,heatingRelayEntityId: freezed == heatingRelayEntityId ? _self.heatingRelayEntityId : heatingRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,controlTemperatureEntityId: freezed == controlTemperatureEntityId ? _self.controlTemperatureEntityId : controlTemperatureEntityId // ignore: cast_nullable_to_non_nullable
as String?,localControlTemperatureSource: null == localControlTemperatureSource ? _self.localControlTemperatureSource : localControlTemperatureSource // ignore: cast_nullable_to_non_nullable
as LocalControlTemperatureSource,pumpRelayEntityId: freezed == pumpRelayEntityId ? _self.pumpRelayEntityId : pumpRelayEntityId // ignore: cast_nullable_to_non_nullable
as String?,pumpComparisonEntityId: freezed == pumpComparisonEntityId ? _self.pumpComparisonEntityId : pumpComparisonEntityId // ignore: cast_nullable_to_non_nullable
as String?,connectivityState: null == connectivityState ? _self.connectivityState : connectivityState // ignore: cast_nullable_to_non_nullable
as ConnectivityState,lastConnectionError: freezed == lastConnectionError ? _self.lastConnectionError : lastConnectionError // ignore: cast_nullable_to_non_nullable
as String?,lastConnectionAttemptAt: freezed == lastConnectionAttemptAt ? _self.lastConnectionAttemptAt : lastConnectionAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastKnownIp: freezed == lastKnownIp ? _self.lastKnownIp : lastKnownIp // ignore: cast_nullable_to_non_nullable
as String?,hostname: freezed == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String?,mac: freezed == mac ? _self.mac : mac // ignore: cast_nullable_to_non_nullable
as String?,diagnostics: freezed == diagnostics ? _self.diagnostics : diagnostics // ignore: cast_nullable_to_non_nullable
as DeviceDiagnostics?,controlStrategy: freezed == controlStrategy ? _self.controlStrategy : controlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,baseControlStrategy: freezed == baseControlStrategy ? _self.baseControlStrategy : baseControlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,pvHeatingConfig: freezed == pvHeatingConfig ? _self.pvHeatingConfig : pvHeatingConfig // ignore: cast_nullable_to_non_nullable
as PvHeatingConfig?,pvProductionEntityId: freezed == pvProductionEntityId ? _self.pvProductionEntityId : pvProductionEntityId // ignore: cast_nullable_to_non_nullable
as String?,pvConsumptionEntityId: freezed == pvConsumptionEntityId ? _self.pvConsumptionEntityId : pvConsumptionEntityId // ignore: cast_nullable_to_non_nullable
as String?,pvBoostActive: null == pvBoostActive ? _self.pvBoostActive : pvBoostActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceDiagnosticsCopyWith<$Res>? get diagnostics {
    if (_self.diagnostics == null) {
    return null;
  }

  return $DeviceDiagnosticsCopyWith<$Res>(_self.diagnostics!, (value) {
    return _then(_self.copyWith(diagnostics: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ControlStrategyCopyWith<$Res>? get controlStrategy {
    if (_self.controlStrategy == null) {
    return null;
  }

  return $ControlStrategyCopyWith<$Res>(_self.controlStrategy!, (value) {
    return _then(_self.copyWith(controlStrategy: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ControlStrategyCopyWith<$Res>? get baseControlStrategy {
    if (_self.baseControlStrategy == null) {
    return null;
  }

  return $ControlStrategyCopyWith<$Res>(_self.baseControlStrategy!, (value) {
    return _then(_self.copyWith(baseControlStrategy: value));
  });
}/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PvHeatingConfigCopyWith<$Res>? get pvHeatingConfig {
    if (_self.pvHeatingConfig == null) {
    return null;
  }

  return $PvHeatingConfigCopyWith<$Res>(_self.pvHeatingConfig!, (value) {
    return _then(_self.copyWith(pvHeatingConfig: value));
  });
}
}


/// @nodoc
mixin _$DeviceEntity {

 String get id; String get displayName; String get sourceName; bool get readable; bool get writable; bool get availability; bool get enabled;@JsonKey(unknownEnumValue: EntityDomain.unknown) EntityDomain get domain; String? get deviceClass;@EntityValueConverter() EntityValue get value; String? get unit; DateTime? get lastSeenAt; AssignedMeaning? get assignedFunction; AssignedMeaning? get assignedRole;
/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceEntityCopyWith<DeviceEntity> get copyWith => _$DeviceEntityCopyWithImpl<DeviceEntity>(this as DeviceEntity, _$identity);

  /// Serializes this DeviceEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.sourceName, _this.sourceName) || other.sourceName == _this.sourceName)&&(identical(other.readable, _this.readable) || other.readable == _this.readable)&&(identical(other.writable, _this.writable) || other.writable == _this.writable)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.deviceClass, _this.deviceClass) || other.deviceClass == _this.deviceClass)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.assignedFunction, _this.assignedFunction) || other.assignedFunction == _this.assignedFunction)&&(identical(other.assignedRole, _this.assignedRole) || other.assignedRole == _this.assignedRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceEntity;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.sourceName,_this.readable,_this.writable,_this.availability,_this.enabled,_this.domain,_this.deviceClass,_this.value,_this.unit,_this.lastSeenAt,_this.assignedFunction,_this.assignedRole);
}

@override
String toString() {
  final _this = this as DeviceEntity;
  return 'DeviceEntity(id: ${_this.id}, displayName: ${_this.displayName}, sourceName: ${_this.sourceName}, readable: ${_this.readable}, writable: ${_this.writable}, availability: ${_this.availability}, enabled: ${_this.enabled}, domain: ${_this.domain}, deviceClass: ${_this.deviceClass}, value: ${_this.value}, unit: ${_this.unit}, lastSeenAt: ${_this.lastSeenAt}, assignedFunction: ${_this.assignedFunction}, assignedRole: ${_this.assignedRole})';
}


}

/// @nodoc
abstract mixin class $DeviceEntityCopyWith<$Res>  {
  factory $DeviceEntityCopyWith(DeviceEntity value, $Res Function(DeviceEntity) _then) = _$DeviceEntityCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String sourceName, bool readable, bool writable, bool availability, bool enabled,@JsonKey(unknownEnumValue: EntityDomain.unknown) EntityDomain domain, String? deviceClass,@EntityValueConverter() EntityValue value, String? unit, DateTime? lastSeenAt, AssignedMeaning? assignedFunction, AssignedMeaning? assignedRole
});


$EntityValueCopyWith<$Res> get value;$AssignedMeaningCopyWith<$Res>? get assignedFunction;$AssignedMeaningCopyWith<$Res>? get assignedRole;

}
/// @nodoc
class _$DeviceEntityCopyWithImpl<$Res>
    implements $DeviceEntityCopyWith<$Res> {
  _$DeviceEntityCopyWithImpl(this._self, this._then);

  final DeviceEntity _self;
  final $Res Function(DeviceEntity) _then;

/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? sourceName = null,Object? readable = null,Object? writable = null,Object? availability = null,Object? enabled = null,Object? domain = null,Object? deviceClass = freezed,Object? value = null,Object? unit = freezed,Object? lastSeenAt = freezed,Object? assignedFunction = freezed,Object? assignedRole = freezed,}) {
  return _then(DeviceEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,readable: null == readable ? _self.readable : readable // ignore: cast_nullable_to_non_nullable
as bool,writable: null == writable ? _self.writable : writable // ignore: cast_nullable_to_non_nullable
as bool,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as EntityDomain,deviceClass: freezed == deviceClass ? _self.deviceClass : deviceClass // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as EntityValue,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedFunction: freezed == assignedFunction ? _self.assignedFunction : assignedFunction // ignore: cast_nullable_to_non_nullable
as AssignedMeaning?,assignedRole: freezed == assignedRole ? _self.assignedRole : assignedRole // ignore: cast_nullable_to_non_nullable
as AssignedMeaning?,
  ));
}
/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntityValueCopyWith<$Res> get value {
  
  return $EntityValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedMeaningCopyWith<$Res>? get assignedFunction {
    if (_self.assignedFunction == null) {
    return null;
  }

  return $AssignedMeaningCopyWith<$Res>(_self.assignedFunction!, (value) {
    return _then(_self.copyWith(assignedFunction: value));
  });
}/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedMeaningCopyWith<$Res>? get assignedRole {
    if (_self.assignedRole == null) {
    return null;
  }

  return $AssignedMeaningCopyWith<$Res>(_self.assignedRole!, (value) {
    return _then(_self.copyWith(assignedRole: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeviceEntity].
extension DeviceEntityPatterns on DeviceEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceEntity value)  $default,){
final _that = this;
switch (_that) {
case _DeviceEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String sourceName,  bool readable,  bool writable,  bool availability,  bool enabled, @JsonKey(unknownEnumValue: EntityDomain.unknown)  EntityDomain domain,  String? deviceClass, @EntityValueConverter()  EntityValue value,  String? unit,  DateTime? lastSeenAt,  AssignedMeaning? assignedFunction,  AssignedMeaning? assignedRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceEntity() when $default != null:
return $default(_that.id,_that.displayName,_that.sourceName,_that.readable,_that.writable,_that.availability,_that.enabled,_that.domain,_that.deviceClass,_that.value,_that.unit,_that.lastSeenAt,_that.assignedFunction,_that.assignedRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String sourceName,  bool readable,  bool writable,  bool availability,  bool enabled, @JsonKey(unknownEnumValue: EntityDomain.unknown)  EntityDomain domain,  String? deviceClass, @EntityValueConverter()  EntityValue value,  String? unit,  DateTime? lastSeenAt,  AssignedMeaning? assignedFunction,  AssignedMeaning? assignedRole)  $default,) {final _that = this;
switch (_that) {
case _DeviceEntity():
return $default(_that.id,_that.displayName,_that.sourceName,_that.readable,_that.writable,_that.availability,_that.enabled,_that.domain,_that.deviceClass,_that.value,_that.unit,_that.lastSeenAt,_that.assignedFunction,_that.assignedRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String sourceName,  bool readable,  bool writable,  bool availability,  bool enabled, @JsonKey(unknownEnumValue: EntityDomain.unknown)  EntityDomain domain,  String? deviceClass, @EntityValueConverter()  EntityValue value,  String? unit,  DateTime? lastSeenAt,  AssignedMeaning? assignedFunction,  AssignedMeaning? assignedRole)?  $default,) {final _that = this;
switch (_that) {
case _DeviceEntity() when $default != null:
return $default(_that.id,_that.displayName,_that.sourceName,_that.readable,_that.writable,_that.availability,_that.enabled,_that.domain,_that.deviceClass,_that.value,_that.unit,_that.lastSeenAt,_that.assignedFunction,_that.assignedRole);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceEntity implements DeviceEntity {
  const _DeviceEntity({required this.id, required this.displayName, required this.sourceName, required this.readable, required this.writable, required this.availability, required this.enabled, @JsonKey(unknownEnumValue: EntityDomain.unknown) this.domain = EntityDomain.unknown, this.deviceClass, @EntityValueConverter() this.value = const EntityValue.none(), this.unit, this.lastSeenAt, this.assignedFunction, this.assignedRole});
  factory _DeviceEntity.fromJson(Map<String, dynamic> json) => _$DeviceEntityFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String sourceName;
@override final  bool readable;
@override final  bool writable;
@override final  bool availability;
@override final  bool enabled;
@override@JsonKey(unknownEnumValue: EntityDomain.unknown) final  EntityDomain domain;
@override final  String? deviceClass;
@override@JsonKey()@EntityValueConverter() final  EntityValue value;
@override final  String? unit;
@override final  DateTime? lastSeenAt;
@override final  AssignedMeaning? assignedFunction;
@override final  AssignedMeaning? assignedRole;

/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceEntityCopyWith<_DeviceEntity> get copyWith => __$DeviceEntityCopyWithImpl<_DeviceEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceEntityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.readable, readable) || other.readable == readable)&&(identical(other.writable, writable) || other.writable == writable)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.deviceClass, deviceClass) || other.deviceClass == deviceClass)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.assignedFunction, assignedFunction) || other.assignedFunction == assignedFunction)&&(identical(other.assignedRole, assignedRole) || other.assignedRole == assignedRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,sourceName,readable,writable,availability,enabled,domain,deviceClass,value,unit,lastSeenAt,assignedFunction,assignedRole);
}

@override
String toString() {
    return 'DeviceEntity(id: $id, displayName: $displayName, sourceName: $sourceName, readable: $readable, writable: $writable, availability: $availability, enabled: $enabled, domain: $domain, deviceClass: $deviceClass, value: $value, unit: $unit, lastSeenAt: $lastSeenAt, assignedFunction: $assignedFunction, assignedRole: $assignedRole)';
}


}

/// @nodoc
abstract mixin class _$DeviceEntityCopyWith<$Res> implements $DeviceEntityCopyWith<$Res> {
  factory _$DeviceEntityCopyWith(_DeviceEntity value, $Res Function(_DeviceEntity) _then) = __$DeviceEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String sourceName, bool readable, bool writable, bool availability, bool enabled,@JsonKey(unknownEnumValue: EntityDomain.unknown) EntityDomain domain, String? deviceClass,@EntityValueConverter() EntityValue value, String? unit, DateTime? lastSeenAt, AssignedMeaning? assignedFunction, AssignedMeaning? assignedRole
});


@override $EntityValueCopyWith<$Res> get value;@override $AssignedMeaningCopyWith<$Res>? get assignedFunction;@override $AssignedMeaningCopyWith<$Res>? get assignedRole;

}
/// @nodoc
class __$DeviceEntityCopyWithImpl<$Res>
    implements _$DeviceEntityCopyWith<$Res> {
  __$DeviceEntityCopyWithImpl(this._self, this._then);

  final _DeviceEntity _self;
  final $Res Function(_DeviceEntity) _then;

/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? sourceName = null,Object? readable = null,Object? writable = null,Object? availability = null,Object? enabled = null,Object? domain = null,Object? deviceClass = freezed,Object? value = null,Object? unit = freezed,Object? lastSeenAt = freezed,Object? assignedFunction = freezed,Object? assignedRole = freezed,}) {
  return _then(_DeviceEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,readable: null == readable ? _self.readable : readable // ignore: cast_nullable_to_non_nullable
as bool,writable: null == writable ? _self.writable : writable // ignore: cast_nullable_to_non_nullable
as bool,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as EntityDomain,deviceClass: freezed == deviceClass ? _self.deviceClass : deviceClass // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as EntityValue,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedFunction: freezed == assignedFunction ? _self.assignedFunction : assignedFunction // ignore: cast_nullable_to_non_nullable
as AssignedMeaning?,assignedRole: freezed == assignedRole ? _self.assignedRole : assignedRole // ignore: cast_nullable_to_non_nullable
as AssignedMeaning?,
  ));
}

/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntityValueCopyWith<$Res> get value {
  
  return $EntityValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedMeaningCopyWith<$Res>? get assignedFunction {
    if (_self.assignedFunction == null) {
    return null;
  }

  return $AssignedMeaningCopyWith<$Res>(_self.assignedFunction!, (value) {
    return _then(_self.copyWith(assignedFunction: value));
  });
}/// Create a copy of DeviceEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedMeaningCopyWith<$Res>? get assignedRole {
    if (_self.assignedRole == null) {
    return null;
  }

  return $AssignedMeaningCopyWith<$Res>(_self.assignedRole!, (value) {
    return _then(_self.copyWith(assignedRole: value));
  });
}
}


/// @nodoc
mixin _$AssignedMeaning {

 String get code; String get name;
/// Create a copy of AssignedMeaning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedMeaningCopyWith<AssignedMeaning> get copyWith => _$AssignedMeaningCopyWithImpl<AssignedMeaning>(this as AssignedMeaning, _$identity);

  /// Serializes this AssignedMeaning to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssignedMeaning;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedMeaning&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssignedMeaning;
  return Object.hash(runtimeType,_this.code,_this.name);
}

@override
String toString() {
  final _this = this as AssignedMeaning;
  return 'AssignedMeaning(code: ${_this.code}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $AssignedMeaningCopyWith<$Res>  {
  factory $AssignedMeaningCopyWith(AssignedMeaning value, $Res Function(AssignedMeaning) _then) = _$AssignedMeaningCopyWithImpl;
@useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class _$AssignedMeaningCopyWithImpl<$Res>
    implements $AssignedMeaningCopyWith<$Res> {
  _$AssignedMeaningCopyWithImpl(this._self, this._then);

  final AssignedMeaning _self;
  final $Res Function(AssignedMeaning) _then;

/// Create a copy of AssignedMeaning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,}) {
  return _then(AssignedMeaning(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedMeaning].
extension AssignedMeaningPatterns on AssignedMeaning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedMeaning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedMeaning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedMeaning value)  $default,){
final _that = this;
switch (_that) {
case _AssignedMeaning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedMeaning value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedMeaning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedMeaning() when $default != null:
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _AssignedMeaning():
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _AssignedMeaning() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignedMeaning implements AssignedMeaning {
  const _AssignedMeaning({required this.code, required this.name});
  factory _AssignedMeaning.fromJson(Map<String, dynamic> json) => _$AssignedMeaningFromJson(json);

@override final  String code;
@override final  String name;

/// Create a copy of AssignedMeaning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedMeaningCopyWith<_AssignedMeaning> get copyWith => __$AssignedMeaningCopyWithImpl<_AssignedMeaning>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedMeaningToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedMeaning&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name);
}

@override
String toString() {
    return 'AssignedMeaning(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$AssignedMeaningCopyWith<$Res> implements $AssignedMeaningCopyWith<$Res> {
  factory _$AssignedMeaningCopyWith(_AssignedMeaning value, $Res Function(_AssignedMeaning) _then) = __$AssignedMeaningCopyWithImpl;
@override @useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class __$AssignedMeaningCopyWithImpl<$Res>
    implements _$AssignedMeaningCopyWith<$Res> {
  __$AssignedMeaningCopyWithImpl(this._self, this._then);

  final _AssignedMeaning _self;
  final $Res Function(_AssignedMeaning) _then;

/// Create a copy of AssignedMeaning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,}) {
  return _then(_AssignedMeaning(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ControlStrategy {

@NumOrStringConverter() double get targetTemperatureCelsius;@NumOrStringConverter() double get hysteresisCelsius;@JsonKey(unknownEnumValue: ControlStrategyMode.unknown) ControlStrategyMode get mode;
/// Create a copy of ControlStrategy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ControlStrategyCopyWith<ControlStrategy> get copyWith => _$ControlStrategyCopyWithImpl<ControlStrategy>(this as ControlStrategy, _$identity);

  /// Serializes this ControlStrategy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ControlStrategy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ControlStrategy&&(identical(other.targetTemperatureCelsius, _this.targetTemperatureCelsius) || other.targetTemperatureCelsius == _this.targetTemperatureCelsius)&&(identical(other.hysteresisCelsius, _this.hysteresisCelsius) || other.hysteresisCelsius == _this.hysteresisCelsius)&&(identical(other.mode, _this.mode) || other.mode == _this.mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ControlStrategy;
  return Object.hash(runtimeType,_this.targetTemperatureCelsius,_this.hysteresisCelsius,_this.mode);
}

@override
String toString() {
  final _this = this as ControlStrategy;
  return 'ControlStrategy(targetTemperatureCelsius: ${_this.targetTemperatureCelsius}, hysteresisCelsius: ${_this.hysteresisCelsius}, mode: ${_this.mode})';
}


}

/// @nodoc
abstract mixin class $ControlStrategyCopyWith<$Res>  {
  factory $ControlStrategyCopyWith(ControlStrategy value, $Res Function(ControlStrategy) _then) = _$ControlStrategyCopyWithImpl;
@useResult
$Res call({
@NumOrStringConverter() double targetTemperatureCelsius,@NumOrStringConverter() double hysteresisCelsius,@JsonKey(unknownEnumValue: ControlStrategyMode.unknown) ControlStrategyMode mode
});




}
/// @nodoc
class _$ControlStrategyCopyWithImpl<$Res>
    implements $ControlStrategyCopyWith<$Res> {
  _$ControlStrategyCopyWithImpl(this._self, this._then);

  final ControlStrategy _self;
  final $Res Function(ControlStrategy) _then;

/// Create a copy of ControlStrategy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetTemperatureCelsius = null,Object? hysteresisCelsius = null,Object? mode = null,}) {
  return _then(ControlStrategy(
targetTemperatureCelsius: null == targetTemperatureCelsius ? _self.targetTemperatureCelsius : targetTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,hysteresisCelsius: null == hysteresisCelsius ? _self.hysteresisCelsius : hysteresisCelsius // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ControlStrategyMode,
  ));
}

}


/// Adds pattern-matching-related methods to [ControlStrategy].
extension ControlStrategyPatterns on ControlStrategy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ControlStrategy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ControlStrategy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ControlStrategy value)  $default,){
final _that = this;
switch (_that) {
case _ControlStrategy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ControlStrategy value)?  $default,){
final _that = this;
switch (_that) {
case _ControlStrategy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius, @JsonKey(unknownEnumValue: ControlStrategyMode.unknown)  ControlStrategyMode mode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ControlStrategy() when $default != null:
return $default(_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.mode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius, @JsonKey(unknownEnumValue: ControlStrategyMode.unknown)  ControlStrategyMode mode)  $default,) {final _that = this;
switch (_that) {
case _ControlStrategy():
return $default(_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.mode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius, @JsonKey(unknownEnumValue: ControlStrategyMode.unknown)  ControlStrategyMode mode)?  $default,) {final _that = this;
switch (_that) {
case _ControlStrategy() when $default != null:
return $default(_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.mode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ControlStrategy implements ControlStrategy {
  const _ControlStrategy({@NumOrStringConverter() required this.targetTemperatureCelsius, @NumOrStringConverter() required this.hysteresisCelsius, @JsonKey(unknownEnumValue: ControlStrategyMode.unknown) this.mode = ControlStrategyMode.unknown});
  factory _ControlStrategy.fromJson(Map<String, dynamic> json) => _$ControlStrategyFromJson(json);

@override@NumOrStringConverter() final  double targetTemperatureCelsius;
@override@NumOrStringConverter() final  double hysteresisCelsius;
@override@JsonKey(unknownEnumValue: ControlStrategyMode.unknown) final  ControlStrategyMode mode;

/// Create a copy of ControlStrategy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ControlStrategyCopyWith<_ControlStrategy> get copyWith => __$ControlStrategyCopyWithImpl<_ControlStrategy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ControlStrategyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ControlStrategy&&(identical(other.targetTemperatureCelsius, targetTemperatureCelsius) || other.targetTemperatureCelsius == targetTemperatureCelsius)&&(identical(other.hysteresisCelsius, hysteresisCelsius) || other.hysteresisCelsius == hysteresisCelsius)&&(identical(other.mode, mode) || other.mode == mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,targetTemperatureCelsius,hysteresisCelsius,mode);
}

@override
String toString() {
    return 'ControlStrategy(targetTemperatureCelsius: $targetTemperatureCelsius, hysteresisCelsius: $hysteresisCelsius, mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$ControlStrategyCopyWith<$Res> implements $ControlStrategyCopyWith<$Res> {
  factory _$ControlStrategyCopyWith(_ControlStrategy value, $Res Function(_ControlStrategy) _then) = __$ControlStrategyCopyWithImpl;
@override @useResult
$Res call({
@NumOrStringConverter() double targetTemperatureCelsius,@NumOrStringConverter() double hysteresisCelsius,@JsonKey(unknownEnumValue: ControlStrategyMode.unknown) ControlStrategyMode mode
});




}
/// @nodoc
class __$ControlStrategyCopyWithImpl<$Res>
    implements _$ControlStrategyCopyWith<$Res> {
  __$ControlStrategyCopyWithImpl(this._self, this._then);

  final _ControlStrategy _self;
  final $Res Function(_ControlStrategy) _then;

/// Create a copy of ControlStrategy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetTemperatureCelsius = null,Object? hysteresisCelsius = null,Object? mode = null,}) {
  return _then(_ControlStrategy(
targetTemperatureCelsius: null == targetTemperatureCelsius ? _self.targetTemperatureCelsius : targetTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,hysteresisCelsius: null == hysteresisCelsius ? _self.hysteresisCelsius : hysteresisCelsius // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ControlStrategyMode,
  ));
}


}


/// @nodoc
mixin _$PvHeatingConfig {

@NumOrStringConverter() double get safeMaxTemperatureCelsius; int get shortDwellMs; int get longDwellMs;@NumOrStringConverter() double get forecastFavorableProductionRatio;@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode get mode;
/// Create a copy of PvHeatingConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvHeatingConfigCopyWith<PvHeatingConfig> get copyWith => _$PvHeatingConfigCopyWithImpl<PvHeatingConfig>(this as PvHeatingConfig, _$identity);

  /// Serializes this PvHeatingConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvHeatingConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvHeatingConfig&&(identical(other.safeMaxTemperatureCelsius, _this.safeMaxTemperatureCelsius) || other.safeMaxTemperatureCelsius == _this.safeMaxTemperatureCelsius)&&(identical(other.shortDwellMs, _this.shortDwellMs) || other.shortDwellMs == _this.shortDwellMs)&&(identical(other.longDwellMs, _this.longDwellMs) || other.longDwellMs == _this.longDwellMs)&&(identical(other.forecastFavorableProductionRatio, _this.forecastFavorableProductionRatio) || other.forecastFavorableProductionRatio == _this.forecastFavorableProductionRatio)&&(identical(other.mode, _this.mode) || other.mode == _this.mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvHeatingConfig;
  return Object.hash(runtimeType,_this.safeMaxTemperatureCelsius,_this.shortDwellMs,_this.longDwellMs,_this.forecastFavorableProductionRatio,_this.mode);
}

@override
String toString() {
  final _this = this as PvHeatingConfig;
  return 'PvHeatingConfig(safeMaxTemperatureCelsius: ${_this.safeMaxTemperatureCelsius}, shortDwellMs: ${_this.shortDwellMs}, longDwellMs: ${_this.longDwellMs}, forecastFavorableProductionRatio: ${_this.forecastFavorableProductionRatio}, mode: ${_this.mode})';
}


}

/// @nodoc
abstract mixin class $PvHeatingConfigCopyWith<$Res>  {
  factory $PvHeatingConfigCopyWith(PvHeatingConfig value, $Res Function(PvHeatingConfig) _then) = _$PvHeatingConfigCopyWithImpl;
@useResult
$Res call({
@NumOrStringConverter() double safeMaxTemperatureCelsius, int shortDwellMs, int longDwellMs,@NumOrStringConverter() double forecastFavorableProductionRatio,@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode mode
});




}
/// @nodoc
class _$PvHeatingConfigCopyWithImpl<$Res>
    implements $PvHeatingConfigCopyWith<$Res> {
  _$PvHeatingConfigCopyWithImpl(this._self, this._then);

  final PvHeatingConfig _self;
  final $Res Function(PvHeatingConfig) _then;

/// Create a copy of PvHeatingConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? safeMaxTemperatureCelsius = null,Object? shortDwellMs = null,Object? longDwellMs = null,Object? forecastFavorableProductionRatio = null,Object? mode = null,}) {
  return _then(PvHeatingConfig(
safeMaxTemperatureCelsius: null == safeMaxTemperatureCelsius ? _self.safeMaxTemperatureCelsius : safeMaxTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,shortDwellMs: null == shortDwellMs ? _self.shortDwellMs : shortDwellMs // ignore: cast_nullable_to_non_nullable
as int,longDwellMs: null == longDwellMs ? _self.longDwellMs : longDwellMs // ignore: cast_nullable_to_non_nullable
as int,forecastFavorableProductionRatio: null == forecastFavorableProductionRatio ? _self.forecastFavorableProductionRatio : forecastFavorableProductionRatio // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PvControlMode,
  ));
}

}


/// Adds pattern-matching-related methods to [PvHeatingConfig].
extension PvHeatingConfigPatterns on PvHeatingConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvHeatingConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvHeatingConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvHeatingConfig value)  $default,){
final _that = this;
switch (_that) {
case _PvHeatingConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvHeatingConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PvHeatingConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NumOrStringConverter()  double safeMaxTemperatureCelsius,  int shortDwellMs,  int longDwellMs, @NumOrStringConverter()  double forecastFavorableProductionRatio, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvHeatingConfig() when $default != null:
return $default(_that.safeMaxTemperatureCelsius,_that.shortDwellMs,_that.longDwellMs,_that.forecastFavorableProductionRatio,_that.mode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NumOrStringConverter()  double safeMaxTemperatureCelsius,  int shortDwellMs,  int longDwellMs, @NumOrStringConverter()  double forecastFavorableProductionRatio, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode)  $default,) {final _that = this;
switch (_that) {
case _PvHeatingConfig():
return $default(_that.safeMaxTemperatureCelsius,_that.shortDwellMs,_that.longDwellMs,_that.forecastFavorableProductionRatio,_that.mode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NumOrStringConverter()  double safeMaxTemperatureCelsius,  int shortDwellMs,  int longDwellMs, @NumOrStringConverter()  double forecastFavorableProductionRatio, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode)?  $default,) {final _that = this;
switch (_that) {
case _PvHeatingConfig() when $default != null:
return $default(_that.safeMaxTemperatureCelsius,_that.shortDwellMs,_that.longDwellMs,_that.forecastFavorableProductionRatio,_that.mode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvHeatingConfig implements PvHeatingConfig {
  const _PvHeatingConfig({@NumOrStringConverter() required this.safeMaxTemperatureCelsius, required this.shortDwellMs, required this.longDwellMs, @NumOrStringConverter() required this.forecastFavorableProductionRatio, @JsonKey(unknownEnumValue: PvControlMode.unknown) this.mode = PvControlMode.unknown});
  factory _PvHeatingConfig.fromJson(Map<String, dynamic> json) => _$PvHeatingConfigFromJson(json);

@override@NumOrStringConverter() final  double safeMaxTemperatureCelsius;
@override final  int shortDwellMs;
@override final  int longDwellMs;
@override@NumOrStringConverter() final  double forecastFavorableProductionRatio;
@override@JsonKey(unknownEnumValue: PvControlMode.unknown) final  PvControlMode mode;

/// Create a copy of PvHeatingConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvHeatingConfigCopyWith<_PvHeatingConfig> get copyWith => __$PvHeatingConfigCopyWithImpl<_PvHeatingConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvHeatingConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvHeatingConfig&&(identical(other.safeMaxTemperatureCelsius, safeMaxTemperatureCelsius) || other.safeMaxTemperatureCelsius == safeMaxTemperatureCelsius)&&(identical(other.shortDwellMs, shortDwellMs) || other.shortDwellMs == shortDwellMs)&&(identical(other.longDwellMs, longDwellMs) || other.longDwellMs == longDwellMs)&&(identical(other.forecastFavorableProductionRatio, forecastFavorableProductionRatio) || other.forecastFavorableProductionRatio == forecastFavorableProductionRatio)&&(identical(other.mode, mode) || other.mode == mode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,safeMaxTemperatureCelsius,shortDwellMs,longDwellMs,forecastFavorableProductionRatio,mode);
}

@override
String toString() {
    return 'PvHeatingConfig(safeMaxTemperatureCelsius: $safeMaxTemperatureCelsius, shortDwellMs: $shortDwellMs, longDwellMs: $longDwellMs, forecastFavorableProductionRatio: $forecastFavorableProductionRatio, mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$PvHeatingConfigCopyWith<$Res> implements $PvHeatingConfigCopyWith<$Res> {
  factory _$PvHeatingConfigCopyWith(_PvHeatingConfig value, $Res Function(_PvHeatingConfig) _then) = __$PvHeatingConfigCopyWithImpl;
@override @useResult
$Res call({
@NumOrStringConverter() double safeMaxTemperatureCelsius, int shortDwellMs, int longDwellMs,@NumOrStringConverter() double forecastFavorableProductionRatio,@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode mode
});




}
/// @nodoc
class __$PvHeatingConfigCopyWithImpl<$Res>
    implements _$PvHeatingConfigCopyWith<$Res> {
  __$PvHeatingConfigCopyWithImpl(this._self, this._then);

  final _PvHeatingConfig _self;
  final $Res Function(_PvHeatingConfig) _then;

/// Create a copy of PvHeatingConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? safeMaxTemperatureCelsius = null,Object? shortDwellMs = null,Object? longDwellMs = null,Object? forecastFavorableProductionRatio = null,Object? mode = null,}) {
  return _then(_PvHeatingConfig(
safeMaxTemperatureCelsius: null == safeMaxTemperatureCelsius ? _self.safeMaxTemperatureCelsius : safeMaxTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,shortDwellMs: null == shortDwellMs ? _self.shortDwellMs : shortDwellMs // ignore: cast_nullable_to_non_nullable
as int,longDwellMs: null == longDwellMs ? _self.longDwellMs : longDwellMs // ignore: cast_nullable_to_non_nullable
as int,forecastFavorableProductionRatio: null == forecastFavorableProductionRatio ? _self.forecastFavorableProductionRatio : forecastFavorableProductionRatio // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PvControlMode,
  ));
}


}

/// @nodoc
mixin _$DeviceDiagnostics {

 Map<String, Object?> get raw;
/// Create a copy of DeviceDiagnostics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceDiagnosticsCopyWith<DeviceDiagnostics> get copyWith => _$DeviceDiagnosticsCopyWithImpl<DeviceDiagnostics>(this as DeviceDiagnostics, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceDiagnostics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceDiagnostics&&const DeepCollectionEquality().equals(other.raw, _this.raw));
}


@override
int get hashCode {
  final _this = this as DeviceDiagnostics;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.raw));
}

@override
String toString() {
  final _this = this as DeviceDiagnostics;
  return 'DeviceDiagnostics(raw: ${_this.raw})';
}


}

/// @nodoc
abstract mixin class $DeviceDiagnosticsCopyWith<$Res>  {
  factory $DeviceDiagnosticsCopyWith(DeviceDiagnostics value, $Res Function(DeviceDiagnostics) _then) = _$DeviceDiagnosticsCopyWithImpl;
@useResult
$Res call({
 Map<String, Object?> raw
});




}
/// @nodoc
class _$DeviceDiagnosticsCopyWithImpl<$Res>
    implements $DeviceDiagnosticsCopyWith<$Res> {
  _$DeviceDiagnosticsCopyWithImpl(this._self, this._then);

  final DeviceDiagnostics _self;
  final $Res Function(DeviceDiagnostics) _then;

/// Create a copy of DeviceDiagnostics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? raw = null,}) {
  return _then(DeviceDiagnostics(
null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceDiagnostics].
extension DeviceDiagnosticsPatterns on DeviceDiagnostics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceDiagnostics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceDiagnostics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceDiagnostics value)  $default,){
final _that = this;
switch (_that) {
case _DeviceDiagnostics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceDiagnostics value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceDiagnostics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Object?> raw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceDiagnostics() when $default != null:
return $default(_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Object?> raw)  $default,) {final _that = this;
switch (_that) {
case _DeviceDiagnostics():
return $default(_that.raw);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Object?> raw)?  $default,) {final _that = this;
switch (_that) {
case _DeviceDiagnostics() when $default != null:
return $default(_that.raw);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceDiagnostics extends DeviceDiagnostics {
  const _DeviceDiagnostics( Map<String, Object?> raw): _raw = raw,super._();
  

 final  Map<String, Object?> _raw;
@override Map<String, Object?> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of DeviceDiagnostics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceDiagnosticsCopyWith<_DeviceDiagnostics> get copyWith => __$DeviceDiagnosticsCopyWithImpl<_DeviceDiagnostics>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceDiagnostics&&const DeepCollectionEquality().equals(other.raw, _raw));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_raw));
}

@override
String toString() {
    return 'DeviceDiagnostics(raw: $raw)';
}


}

/// @nodoc
abstract mixin class _$DeviceDiagnosticsCopyWith<$Res> implements $DeviceDiagnosticsCopyWith<$Res> {
  factory _$DeviceDiagnosticsCopyWith(_DeviceDiagnostics value, $Res Function(_DeviceDiagnostics) _then) = __$DeviceDiagnosticsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Object?> raw
});




}
/// @nodoc
class __$DeviceDiagnosticsCopyWithImpl<$Res>
    implements _$DeviceDiagnosticsCopyWith<$Res> {
  __$DeviceDiagnosticsCopyWithImpl(this._self, this._then);

  final _DeviceDiagnostics _self;
  final $Res Function(_DeviceDiagnostics) _then;

/// Create a copy of DeviceDiagnostics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? raw = null,}) {
  return _then(_DeviceDiagnostics(
null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

/// @nodoc
mixin _$RelayDiagnostics {

 bool? get output; bool? get commanded;
/// Create a copy of RelayDiagnostics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelayDiagnosticsCopyWith<RelayDiagnostics> get copyWith => _$RelayDiagnosticsCopyWithImpl<RelayDiagnostics>(this as RelayDiagnostics, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RelayDiagnostics;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelayDiagnostics&&(identical(other.output, _this.output) || other.output == _this.output)&&(identical(other.commanded, _this.commanded) || other.commanded == _this.commanded));
}


@override
int get hashCode {
  final _this = this as RelayDiagnostics;
  return Object.hash(runtimeType,_this.output,_this.commanded);
}

@override
String toString() {
  final _this = this as RelayDiagnostics;
  return 'RelayDiagnostics(output: ${_this.output}, commanded: ${_this.commanded})';
}


}

/// @nodoc
abstract mixin class $RelayDiagnosticsCopyWith<$Res>  {
  factory $RelayDiagnosticsCopyWith(RelayDiagnostics value, $Res Function(RelayDiagnostics) _then) = _$RelayDiagnosticsCopyWithImpl;
@useResult
$Res call({
 bool? output, bool? commanded
});




}
/// @nodoc
class _$RelayDiagnosticsCopyWithImpl<$Res>
    implements $RelayDiagnosticsCopyWith<$Res> {
  _$RelayDiagnosticsCopyWithImpl(this._self, this._then);

  final RelayDiagnostics _self;
  final $Res Function(RelayDiagnostics) _then;

/// Create a copy of RelayDiagnostics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? output = freezed,Object? commanded = freezed,}) {
  return _then(RelayDiagnostics(
output: freezed == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as bool?,commanded: freezed == commanded ? _self.commanded : commanded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [RelayDiagnostics].
extension RelayDiagnosticsPatterns on RelayDiagnostics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelayDiagnostics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelayDiagnostics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelayDiagnostics value)  $default,){
final _that = this;
switch (_that) {
case _RelayDiagnostics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelayDiagnostics value)?  $default,){
final _that = this;
switch (_that) {
case _RelayDiagnostics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? output,  bool? commanded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelayDiagnostics() when $default != null:
return $default(_that.output,_that.commanded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? output,  bool? commanded)  $default,) {final _that = this;
switch (_that) {
case _RelayDiagnostics():
return $default(_that.output,_that.commanded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? output,  bool? commanded)?  $default,) {final _that = this;
switch (_that) {
case _RelayDiagnostics() when $default != null:
return $default(_that.output,_that.commanded);case _:
  return null;

}
}

}

/// @nodoc


class _RelayDiagnostics implements RelayDiagnostics {
  const _RelayDiagnostics({this.output, this.commanded});
  

@override final  bool? output;
@override final  bool? commanded;

/// Create a copy of RelayDiagnostics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelayDiagnosticsCopyWith<_RelayDiagnostics> get copyWith => __$RelayDiagnosticsCopyWithImpl<_RelayDiagnostics>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelayDiagnostics&&(identical(other.output, output) || other.output == output)&&(identical(other.commanded, commanded) || other.commanded == commanded));
}


@override
int get hashCode {
    return Object.hash(runtimeType,output,commanded);
}

@override
String toString() {
    return 'RelayDiagnostics(output: $output, commanded: $commanded)';
}


}

/// @nodoc
abstract mixin class _$RelayDiagnosticsCopyWith<$Res> implements $RelayDiagnosticsCopyWith<$Res> {
  factory _$RelayDiagnosticsCopyWith(_RelayDiagnostics value, $Res Function(_RelayDiagnostics) _then) = __$RelayDiagnosticsCopyWithImpl;
@override @useResult
$Res call({
 bool? output, bool? commanded
});




}
/// @nodoc
class __$RelayDiagnosticsCopyWithImpl<$Res>
    implements _$RelayDiagnosticsCopyWith<$Res> {
  __$RelayDiagnosticsCopyWithImpl(this._self, this._then);

  final _RelayDiagnostics _self;
  final $Res Function(_RelayDiagnostics) _then;

/// Create a copy of RelayDiagnostics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? output = freezed,Object? commanded = freezed,}) {
  return _then(_RelayDiagnostics(
output: freezed == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as bool?,commanded: freezed == commanded ? _self.commanded : commanded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
