// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_commands.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwitchCommandResult {

 String get entityId; DateTime get confirmedAt; Object? get state; Object? get availability;
/// Create a copy of SwitchCommandResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwitchCommandResultCopyWith<SwitchCommandResult> get copyWith => _$SwitchCommandResultCopyWithImpl<SwitchCommandResult>(this as SwitchCommandResult, _$identity);

  /// Serializes this SwitchCommandResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SwitchCommandResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwitchCommandResult&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.confirmedAt, _this.confirmedAt) || other.confirmedAt == _this.confirmedAt)&&const DeepCollectionEquality().equals(other.state, _this.state)&&const DeepCollectionEquality().equals(other.availability, _this.availability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SwitchCommandResult;
  return Object.hash(runtimeType,_this.entityId,_this.confirmedAt,const DeepCollectionEquality().hash(_this.state),const DeepCollectionEquality().hash(_this.availability));
}

@override
String toString() {
  final _this = this as SwitchCommandResult;
  return 'SwitchCommandResult(entityId: ${_this.entityId}, confirmedAt: ${_this.confirmedAt}, state: ${_this.state}, availability: ${_this.availability})';
}


}

/// @nodoc
abstract mixin class $SwitchCommandResultCopyWith<$Res>  {
  factory $SwitchCommandResultCopyWith(SwitchCommandResult value, $Res Function(SwitchCommandResult) _then) = _$SwitchCommandResultCopyWithImpl;
@useResult
$Res call({
 String entityId, DateTime confirmedAt, Object? state, Object? availability
});




}
/// @nodoc
class _$SwitchCommandResultCopyWithImpl<$Res>
    implements $SwitchCommandResultCopyWith<$Res> {
  _$SwitchCommandResultCopyWithImpl(this._self, this._then);

  final SwitchCommandResult _self;
  final $Res Function(SwitchCommandResult) _then;

/// Create a copy of SwitchCommandResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityId = null,Object? confirmedAt = null,Object? state = freezed,Object? availability = freezed,}) {
  return _then(SwitchCommandResult(
entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: freezed == state ? _self.state : state ,availability: freezed == availability ? _self.availability : availability ,
  ));
}

}


/// Adds pattern-matching-related methods to [SwitchCommandResult].
extension SwitchCommandResultPatterns on SwitchCommandResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwitchCommandResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwitchCommandResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwitchCommandResult value)  $default,){
final _that = this;
switch (_that) {
case _SwitchCommandResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwitchCommandResult value)?  $default,){
final _that = this;
switch (_that) {
case _SwitchCommandResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityId,  DateTime confirmedAt,  Object? state,  Object? availability)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwitchCommandResult() when $default != null:
return $default(_that.entityId,_that.confirmedAt,_that.state,_that.availability);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityId,  DateTime confirmedAt,  Object? state,  Object? availability)  $default,) {final _that = this;
switch (_that) {
case _SwitchCommandResult():
return $default(_that.entityId,_that.confirmedAt,_that.state,_that.availability);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityId,  DateTime confirmedAt,  Object? state,  Object? availability)?  $default,) {final _that = this;
switch (_that) {
case _SwitchCommandResult() when $default != null:
return $default(_that.entityId,_that.confirmedAt,_that.state,_that.availability);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwitchCommandResult implements SwitchCommandResult {
  const _SwitchCommandResult({required this.entityId, required this.confirmedAt, this.state, this.availability});
  factory _SwitchCommandResult.fromJson(Map<String, dynamic> json) => _$SwitchCommandResultFromJson(json);

@override final  String entityId;
@override final  DateTime confirmedAt;
@override final  Object? state;
@override final  Object? availability;

/// Create a copy of SwitchCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwitchCommandResultCopyWith<_SwitchCommandResult> get copyWith => __$SwitchCommandResultCopyWithImpl<_SwitchCommandResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwitchCommandResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwitchCommandResult&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&const DeepCollectionEquality().equals(other.state, state)&&const DeepCollectionEquality().equals(other.availability, availability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityId,confirmedAt,const DeepCollectionEquality().hash(state),const DeepCollectionEquality().hash(availability));
}

@override
String toString() {
    return 'SwitchCommandResult(entityId: $entityId, confirmedAt: $confirmedAt, state: $state, availability: $availability)';
}


}

/// @nodoc
abstract mixin class _$SwitchCommandResultCopyWith<$Res> implements $SwitchCommandResultCopyWith<$Res> {
  factory _$SwitchCommandResultCopyWith(_SwitchCommandResult value, $Res Function(_SwitchCommandResult) _then) = __$SwitchCommandResultCopyWithImpl;
@override @useResult
$Res call({
 String entityId, DateTime confirmedAt, Object? state, Object? availability
});




}
/// @nodoc
class __$SwitchCommandResultCopyWithImpl<$Res>
    implements _$SwitchCommandResultCopyWith<$Res> {
  __$SwitchCommandResultCopyWithImpl(this._self, this._then);

  final _SwitchCommandResult _self;
  final $Res Function(_SwitchCommandResult) _then;

/// Create a copy of SwitchCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityId = null,Object? confirmedAt = null,Object? state = freezed,Object? availability = freezed,}) {
  return _then(_SwitchCommandResult(
entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: freezed == state ? _self.state : state ,availability: freezed == availability ? _self.availability : availability ,
  ));
}


}


/// @nodoc
mixin _$ControlStrategyUpdateResult {

 int get configurationVersion;@ControlStrategyConverter() ControlStrategy? get controlStrategy;@ControlStrategyConverter() ControlStrategy? get baseControlStrategy;
/// Create a copy of ControlStrategyUpdateResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ControlStrategyUpdateResultCopyWith<ControlStrategyUpdateResult> get copyWith => _$ControlStrategyUpdateResultCopyWithImpl<ControlStrategyUpdateResult>(this as ControlStrategyUpdateResult, _$identity);

  /// Serializes this ControlStrategyUpdateResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ControlStrategyUpdateResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ControlStrategyUpdateResult&&(identical(other.configurationVersion, _this.configurationVersion) || other.configurationVersion == _this.configurationVersion)&&(identical(other.controlStrategy, _this.controlStrategy) || other.controlStrategy == _this.controlStrategy)&&(identical(other.baseControlStrategy, _this.baseControlStrategy) || other.baseControlStrategy == _this.baseControlStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ControlStrategyUpdateResult;
  return Object.hash(runtimeType,_this.configurationVersion,_this.controlStrategy,_this.baseControlStrategy);
}

@override
String toString() {
  final _this = this as ControlStrategyUpdateResult;
  return 'ControlStrategyUpdateResult(configurationVersion: ${_this.configurationVersion}, controlStrategy: ${_this.controlStrategy}, baseControlStrategy: ${_this.baseControlStrategy})';
}


}

/// @nodoc
abstract mixin class $ControlStrategyUpdateResultCopyWith<$Res>  {
  factory $ControlStrategyUpdateResultCopyWith(ControlStrategyUpdateResult value, $Res Function(ControlStrategyUpdateResult) _then) = _$ControlStrategyUpdateResultCopyWithImpl;
@useResult
$Res call({
 int configurationVersion,@ControlStrategyConverter() ControlStrategy? controlStrategy,@ControlStrategyConverter() ControlStrategy? baseControlStrategy
});


$ControlStrategyCopyWith<$Res>? get controlStrategy;$ControlStrategyCopyWith<$Res>? get baseControlStrategy;

}
/// @nodoc
class _$ControlStrategyUpdateResultCopyWithImpl<$Res>
    implements $ControlStrategyUpdateResultCopyWith<$Res> {
  _$ControlStrategyUpdateResultCopyWithImpl(this._self, this._then);

  final ControlStrategyUpdateResult _self;
  final $Res Function(ControlStrategyUpdateResult) _then;

/// Create a copy of ControlStrategyUpdateResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configurationVersion = null,Object? controlStrategy = freezed,Object? baseControlStrategy = freezed,}) {
  return _then(ControlStrategyUpdateResult(
configurationVersion: null == configurationVersion ? _self.configurationVersion : configurationVersion // ignore: cast_nullable_to_non_nullable
as int,controlStrategy: freezed == controlStrategy ? _self.controlStrategy : controlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,baseControlStrategy: freezed == baseControlStrategy ? _self.baseControlStrategy : baseControlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,
  ));
}
/// Create a copy of ControlStrategyUpdateResult
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
}/// Create a copy of ControlStrategyUpdateResult
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
}
}


/// Adds pattern-matching-related methods to [ControlStrategyUpdateResult].
extension ControlStrategyUpdateResultPatterns on ControlStrategyUpdateResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ControlStrategyUpdateResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ControlStrategyUpdateResult value)  $default,){
final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ControlStrategyUpdateResult value)?  $default,){
final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int configurationVersion, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult() when $default != null:
return $default(_that.configurationVersion,_that.controlStrategy,_that.baseControlStrategy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int configurationVersion, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy)  $default,) {final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult():
return $default(_that.configurationVersion,_that.controlStrategy,_that.baseControlStrategy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int configurationVersion, @ControlStrategyConverter()  ControlStrategy? controlStrategy, @ControlStrategyConverter()  ControlStrategy? baseControlStrategy)?  $default,) {final _that = this;
switch (_that) {
case _ControlStrategyUpdateResult() when $default != null:
return $default(_that.configurationVersion,_that.controlStrategy,_that.baseControlStrategy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ControlStrategyUpdateResult implements ControlStrategyUpdateResult {
  const _ControlStrategyUpdateResult({required this.configurationVersion, @ControlStrategyConverter() this.controlStrategy, @ControlStrategyConverter() this.baseControlStrategy});
  factory _ControlStrategyUpdateResult.fromJson(Map<String, dynamic> json) => _$ControlStrategyUpdateResultFromJson(json);

@override final  int configurationVersion;
@override@ControlStrategyConverter() final  ControlStrategy? controlStrategy;
@override@ControlStrategyConverter() final  ControlStrategy? baseControlStrategy;

/// Create a copy of ControlStrategyUpdateResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ControlStrategyUpdateResultCopyWith<_ControlStrategyUpdateResult> get copyWith => __$ControlStrategyUpdateResultCopyWithImpl<_ControlStrategyUpdateResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ControlStrategyUpdateResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ControlStrategyUpdateResult&&(identical(other.configurationVersion, configurationVersion) || other.configurationVersion == configurationVersion)&&(identical(other.controlStrategy, controlStrategy) || other.controlStrategy == controlStrategy)&&(identical(other.baseControlStrategy, baseControlStrategy) || other.baseControlStrategy == baseControlStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,configurationVersion,controlStrategy,baseControlStrategy);
}

@override
String toString() {
    return 'ControlStrategyUpdateResult(configurationVersion: $configurationVersion, controlStrategy: $controlStrategy, baseControlStrategy: $baseControlStrategy)';
}


}

/// @nodoc
abstract mixin class _$ControlStrategyUpdateResultCopyWith<$Res> implements $ControlStrategyUpdateResultCopyWith<$Res> {
  factory _$ControlStrategyUpdateResultCopyWith(_ControlStrategyUpdateResult value, $Res Function(_ControlStrategyUpdateResult) _then) = __$ControlStrategyUpdateResultCopyWithImpl;
@override @useResult
$Res call({
 int configurationVersion,@ControlStrategyConverter() ControlStrategy? controlStrategy,@ControlStrategyConverter() ControlStrategy? baseControlStrategy
});


@override $ControlStrategyCopyWith<$Res>? get controlStrategy;@override $ControlStrategyCopyWith<$Res>? get baseControlStrategy;

}
/// @nodoc
class __$ControlStrategyUpdateResultCopyWithImpl<$Res>
    implements _$ControlStrategyUpdateResultCopyWith<$Res> {
  __$ControlStrategyUpdateResultCopyWithImpl(this._self, this._then);

  final _ControlStrategyUpdateResult _self;
  final $Res Function(_ControlStrategyUpdateResult) _then;

/// Create a copy of ControlStrategyUpdateResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configurationVersion = null,Object? controlStrategy = freezed,Object? baseControlStrategy = freezed,}) {
  return _then(_ControlStrategyUpdateResult(
configurationVersion: null == configurationVersion ? _self.configurationVersion : configurationVersion // ignore: cast_nullable_to_non_nullable
as int,controlStrategy: freezed == controlStrategy ? _self.controlStrategy : controlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,baseControlStrategy: freezed == baseControlStrategy ? _self.baseControlStrategy : baseControlStrategy // ignore: cast_nullable_to_non_nullable
as ControlStrategy?,
  ));
}

/// Create a copy of ControlStrategyUpdateResult
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
}/// Create a copy of ControlStrategyUpdateResult
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
}
}

// dart format on
