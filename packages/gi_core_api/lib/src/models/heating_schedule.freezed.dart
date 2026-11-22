// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heating_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HeatingSchedule {

 String get id; String get deviceId; String get name; List<int> get daysOfWeek; String get startTime; String get endTime;@NumOrStringConverter() double get targetTemperatureCelsius;@NumOrStringConverter() double get hysteresisCelsius; bool get enabled; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of HeatingSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeatingScheduleCopyWith<HeatingSchedule> get copyWith => _$HeatingScheduleCopyWithImpl<HeatingSchedule>(this as HeatingSchedule, _$identity);

  /// Serializes this HeatingSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HeatingSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeatingSchedule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.daysOfWeek, _this.daysOfWeek)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.targetTemperatureCelsius, _this.targetTemperatureCelsius) || other.targetTemperatureCelsius == _this.targetTemperatureCelsius)&&(identical(other.hysteresisCelsius, _this.hysteresisCelsius) || other.hysteresisCelsius == _this.hysteresisCelsius)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HeatingSchedule;
  return Object.hash(runtimeType,_this.id,_this.deviceId,_this.name,const DeepCollectionEquality().hash(_this.daysOfWeek),_this.startTime,_this.endTime,_this.targetTemperatureCelsius,_this.hysteresisCelsius,_this.enabled,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as HeatingSchedule;
  return 'HeatingSchedule(id: ${_this.id}, deviceId: ${_this.deviceId}, name: ${_this.name}, daysOfWeek: ${_this.daysOfWeek}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, targetTemperatureCelsius: ${_this.targetTemperatureCelsius}, hysteresisCelsius: ${_this.hysteresisCelsius}, enabled: ${_this.enabled}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $HeatingScheduleCopyWith<$Res>  {
  factory $HeatingScheduleCopyWith(HeatingSchedule value, $Res Function(HeatingSchedule) _then) = _$HeatingScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String name, List<int> daysOfWeek, String startTime, String endTime,@NumOrStringConverter() double targetTemperatureCelsius,@NumOrStringConverter() double hysteresisCelsius, bool enabled, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$HeatingScheduleCopyWithImpl<$Res>
    implements $HeatingScheduleCopyWith<$Res> {
  _$HeatingScheduleCopyWithImpl(this._self, this._then);

  final HeatingSchedule _self;
  final $Res Function(HeatingSchedule) _then;

/// Create a copy of HeatingSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? name = null,Object? daysOfWeek = null,Object? startTime = null,Object? endTime = null,Object? targetTemperatureCelsius = null,Object? hysteresisCelsius = null,Object? enabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(HeatingSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,targetTemperatureCelsius: null == targetTemperatureCelsius ? _self.targetTemperatureCelsius : targetTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,hysteresisCelsius: null == hysteresisCelsius ? _self.hysteresisCelsius : hysteresisCelsius // ignore: cast_nullable_to_non_nullable
as double,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HeatingSchedule].
extension HeatingSchedulePatterns on HeatingSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeatingSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeatingSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeatingSchedule value)  $default,){
final _that = this;
switch (_that) {
case _HeatingSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeatingSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _HeatingSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String name,  List<int> daysOfWeek,  String startTime,  String endTime, @NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius,  bool enabled,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeatingSchedule() when $default != null:
return $default(_that.id,_that.deviceId,_that.name,_that.daysOfWeek,_that.startTime,_that.endTime,_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.enabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String name,  List<int> daysOfWeek,  String startTime,  String endTime, @NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius,  bool enabled,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HeatingSchedule():
return $default(_that.id,_that.deviceId,_that.name,_that.daysOfWeek,_that.startTime,_that.endTime,_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.enabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String name,  List<int> daysOfWeek,  String startTime,  String endTime, @NumOrStringConverter()  double targetTemperatureCelsius, @NumOrStringConverter()  double hysteresisCelsius,  bool enabled,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HeatingSchedule() when $default != null:
return $default(_that.id,_that.deviceId,_that.name,_that.daysOfWeek,_that.startTime,_that.endTime,_that.targetTemperatureCelsius,_that.hysteresisCelsius,_that.enabled,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HeatingSchedule extends HeatingSchedule {
  const _HeatingSchedule({required this.id, required this.deviceId, required this.name, required  List<int> daysOfWeek, required this.startTime, required this.endTime, @NumOrStringConverter() required this.targetTemperatureCelsius, @NumOrStringConverter() required this.hysteresisCelsius, required this.enabled, required this.createdAt, required this.updatedAt}): _daysOfWeek = daysOfWeek,super._();
  factory _HeatingSchedule.fromJson(Map<String, dynamic> json) => _$HeatingScheduleFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String name;
 final  List<int> _daysOfWeek;
@override List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

@override final  String startTime;
@override final  String endTime;
@override@NumOrStringConverter() final  double targetTemperatureCelsius;
@override@NumOrStringConverter() final  double hysteresisCelsius;
@override final  bool enabled;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of HeatingSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeatingScheduleCopyWith<_HeatingSchedule> get copyWith => __$HeatingScheduleCopyWithImpl<_HeatingSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeatingScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeatingSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.daysOfWeek, _daysOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.targetTemperatureCelsius, targetTemperatureCelsius) || other.targetTemperatureCelsius == targetTemperatureCelsius)&&(identical(other.hysteresisCelsius, hysteresisCelsius) || other.hysteresisCelsius == hysteresisCelsius)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceId,name,const DeepCollectionEquality().hash(_daysOfWeek),startTime,endTime,targetTemperatureCelsius,hysteresisCelsius,enabled,createdAt,updatedAt);
}

@override
String toString() {
    return 'HeatingSchedule(id: $id, deviceId: $deviceId, name: $name, daysOfWeek: $daysOfWeek, startTime: $startTime, endTime: $endTime, targetTemperatureCelsius: $targetTemperatureCelsius, hysteresisCelsius: $hysteresisCelsius, enabled: $enabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HeatingScheduleCopyWith<$Res> implements $HeatingScheduleCopyWith<$Res> {
  factory _$HeatingScheduleCopyWith(_HeatingSchedule value, $Res Function(_HeatingSchedule) _then) = __$HeatingScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String name, List<int> daysOfWeek, String startTime, String endTime,@NumOrStringConverter() double targetTemperatureCelsius,@NumOrStringConverter() double hysteresisCelsius, bool enabled, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$HeatingScheduleCopyWithImpl<$Res>
    implements _$HeatingScheduleCopyWith<$Res> {
  __$HeatingScheduleCopyWithImpl(this._self, this._then);

  final _HeatingSchedule _self;
  final $Res Function(_HeatingSchedule) _then;

/// Create a copy of HeatingSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? name = null,Object? daysOfWeek = null,Object? startTime = null,Object? endTime = null,Object? targetTemperatureCelsius = null,Object? hysteresisCelsius = null,Object? enabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_HeatingSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,targetTemperatureCelsius: null == targetTemperatureCelsius ? _self.targetTemperatureCelsius : targetTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,hysteresisCelsius: null == hysteresisCelsius ? _self.hysteresisCelsius : hysteresisCelsius // ignore: cast_nullable_to_non_nullable
as double,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
