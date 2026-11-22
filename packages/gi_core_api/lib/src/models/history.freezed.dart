// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntityHistory {

 String get entityId; DateTime get from; DateTime get to; List<HistorySample> get samples;
/// Create a copy of EntityHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityHistoryCopyWith<EntityHistory> get copyWith => _$EntityHistoryCopyWithImpl<EntityHistory>(this as EntityHistory, _$identity);

  /// Serializes this EntityHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EntityHistory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityHistory&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&const DeepCollectionEquality().equals(other.samples, _this.samples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EntityHistory;
  return Object.hash(runtimeType,_this.entityId,_this.from,_this.to,const DeepCollectionEquality().hash(_this.samples));
}

@override
String toString() {
  final _this = this as EntityHistory;
  return 'EntityHistory(entityId: ${_this.entityId}, from: ${_this.from}, to: ${_this.to}, samples: ${_this.samples})';
}


}

/// @nodoc
abstract mixin class $EntityHistoryCopyWith<$Res>  {
  factory $EntityHistoryCopyWith(EntityHistory value, $Res Function(EntityHistory) _then) = _$EntityHistoryCopyWithImpl;
@useResult
$Res call({
 String entityId, DateTime from, DateTime to, List<HistorySample> samples
});




}
/// @nodoc
class _$EntityHistoryCopyWithImpl<$Res>
    implements $EntityHistoryCopyWith<$Res> {
  _$EntityHistoryCopyWithImpl(this._self, this._then);

  final EntityHistory _self;
  final $Res Function(EntityHistory) _then;

/// Create a copy of EntityHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityId = null,Object? from = null,Object? to = null,Object? samples = null,}) {
  return _then(EntityHistory(
entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<HistorySample>,
  ));
}

}


/// Adds pattern-matching-related methods to [EntityHistory].
extension EntityHistoryPatterns on EntityHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntityHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntityHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntityHistory value)  $default,){
final _that = this;
switch (_that) {
case _EntityHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntityHistory value)?  $default,){
final _that = this;
switch (_that) {
case _EntityHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityId,  DateTime from,  DateTime to,  List<HistorySample> samples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntityHistory() when $default != null:
return $default(_that.entityId,_that.from,_that.to,_that.samples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityId,  DateTime from,  DateTime to,  List<HistorySample> samples)  $default,) {final _that = this;
switch (_that) {
case _EntityHistory():
return $default(_that.entityId,_that.from,_that.to,_that.samples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityId,  DateTime from,  DateTime to,  List<HistorySample> samples)?  $default,) {final _that = this;
switch (_that) {
case _EntityHistory() when $default != null:
return $default(_that.entityId,_that.from,_that.to,_that.samples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntityHistory implements EntityHistory {
  const _EntityHistory({required this.entityId, required this.from, required this.to,  List<HistorySample> samples = const <HistorySample>[]}): _samples = samples;
  factory _EntityHistory.fromJson(Map<String, dynamic> json) => _$EntityHistoryFromJson(json);

@override final  String entityId;
@override final  DateTime from;
@override final  DateTime to;
 final  List<HistorySample> _samples;
@override@JsonKey() List<HistorySample> get samples {
  if (_samples is EqualUnmodifiableListView) return _samples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samples);
}


/// Create a copy of EntityHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntityHistoryCopyWith<_EntityHistory> get copyWith => __$EntityHistoryCopyWithImpl<_EntityHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntityHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntityHistory&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&const DeepCollectionEquality().equals(other.samples, _samples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityId,from,to,const DeepCollectionEquality().hash(_samples));
}

@override
String toString() {
    return 'EntityHistory(entityId: $entityId, from: $from, to: $to, samples: $samples)';
}


}

/// @nodoc
abstract mixin class _$EntityHistoryCopyWith<$Res> implements $EntityHistoryCopyWith<$Res> {
  factory _$EntityHistoryCopyWith(_EntityHistory value, $Res Function(_EntityHistory) _then) = __$EntityHistoryCopyWithImpl;
@override @useResult
$Res call({
 String entityId, DateTime from, DateTime to, List<HistorySample> samples
});




}
/// @nodoc
class __$EntityHistoryCopyWithImpl<$Res>
    implements _$EntityHistoryCopyWith<$Res> {
  __$EntityHistoryCopyWithImpl(this._self, this._then);

  final _EntityHistory _self;
  final $Res Function(_EntityHistory) _then;

/// Create a copy of EntityHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityId = null,Object? from = null,Object? to = null,Object? samples = null,}) {
  return _then(_EntityHistory(
entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self._samples : samples // ignore: cast_nullable_to_non_nullable
as List<HistorySample>,
  ));
}


}


/// @nodoc
mixin _$HistorySample {

 DateTime get at;@JsonKey(unknownEnumValue: HistorySampleKind.unknown) HistorySampleKind get kind; Object? get value; String? get unit;
/// Create a copy of HistorySample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistorySampleCopyWith<HistorySample> get copyWith => _$HistorySampleCopyWithImpl<HistorySample>(this as HistorySample, _$identity);

  /// Serializes this HistorySample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HistorySample;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistorySample&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&const DeepCollectionEquality().equals(other.value, _this.value)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HistorySample;
  return Object.hash(runtimeType,_this.at,_this.kind,const DeepCollectionEquality().hash(_this.value),_this.unit);
}

@override
String toString() {
  final _this = this as HistorySample;
  return 'HistorySample(at: ${_this.at}, kind: ${_this.kind}, value: ${_this.value}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $HistorySampleCopyWith<$Res>  {
  factory $HistorySampleCopyWith(HistorySample value, $Res Function(HistorySample) _then) = _$HistorySampleCopyWithImpl;
@useResult
$Res call({
 DateTime at,@JsonKey(unknownEnumValue: HistorySampleKind.unknown) HistorySampleKind kind, Object? value, String? unit
});




}
/// @nodoc
class _$HistorySampleCopyWithImpl<$Res>
    implements $HistorySampleCopyWith<$Res> {
  _$HistorySampleCopyWithImpl(this._self, this._then);

  final HistorySample _self;
  final $Res Function(HistorySample) _then;

/// Create a copy of HistorySample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? at = null,Object? kind = null,Object? value = freezed,Object? unit = freezed,}) {
  return _then(HistorySample(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HistorySampleKind,value: freezed == value ? _self.value : value ,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistorySample].
extension HistorySamplePatterns on HistorySample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistorySample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistorySample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistorySample value)  $default,){
final _that = this;
switch (_that) {
case _HistorySample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistorySample value)?  $default,){
final _that = this;
switch (_that) {
case _HistorySample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime at, @JsonKey(unknownEnumValue: HistorySampleKind.unknown)  HistorySampleKind kind,  Object? value,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistorySample() when $default != null:
return $default(_that.at,_that.kind,_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime at, @JsonKey(unknownEnumValue: HistorySampleKind.unknown)  HistorySampleKind kind,  Object? value,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _HistorySample():
return $default(_that.at,_that.kind,_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime at, @JsonKey(unknownEnumValue: HistorySampleKind.unknown)  HistorySampleKind kind,  Object? value,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _HistorySample() when $default != null:
return $default(_that.at,_that.kind,_that.value,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistorySample extends HistorySample {
  const _HistorySample({required this.at, @JsonKey(unknownEnumValue: HistorySampleKind.unknown) this.kind = HistorySampleKind.unknown, this.value, this.unit}): super._();
  factory _HistorySample.fromJson(Map<String, dynamic> json) => _$HistorySampleFromJson(json);

@override final  DateTime at;
@override@JsonKey(unknownEnumValue: HistorySampleKind.unknown) final  HistorySampleKind kind;
@override final  Object? value;
@override final  String? unit;

/// Create a copy of HistorySample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistorySampleCopyWith<_HistorySample> get copyWith => __$HistorySampleCopyWithImpl<_HistorySample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistorySampleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistorySample&&(identical(other.at, at) || other.at == at)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,at,kind,const DeepCollectionEquality().hash(value),unit);
}

@override
String toString() {
    return 'HistorySample(at: $at, kind: $kind, value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$HistorySampleCopyWith<$Res> implements $HistorySampleCopyWith<$Res> {
  factory _$HistorySampleCopyWith(_HistorySample value, $Res Function(_HistorySample) _then) = __$HistorySampleCopyWithImpl;
@override @useResult
$Res call({
 DateTime at,@JsonKey(unknownEnumValue: HistorySampleKind.unknown) HistorySampleKind kind, Object? value, String? unit
});




}
/// @nodoc
class __$HistorySampleCopyWithImpl<$Res>
    implements _$HistorySampleCopyWith<$Res> {
  __$HistorySampleCopyWithImpl(this._self, this._then);

  final _HistorySample _self;
  final $Res Function(_HistorySample) _then;

/// Create a copy of HistorySample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? at = null,Object? kind = null,Object? value = freezed,Object? unit = freezed,}) {
  return _then(_HistorySample(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HistorySampleKind,value: freezed == value ? _self.value : value ,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
