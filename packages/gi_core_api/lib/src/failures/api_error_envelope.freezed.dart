// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiErrorEnvelope {

 String get code; int? get statusCode; String? get message; String? get path; String? get requestId; String? get timestamp;/// Validation messages keyed by dotted field path.
 Map<String, List<String>> get details;
/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<ApiErrorEnvelope> get copyWith => _$ApiErrorEnvelopeCopyWithImpl<ApiErrorEnvelope>(this as ApiErrorEnvelope, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApiErrorEnvelope;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorEnvelope&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&const DeepCollectionEquality().equals(other.details, _this.details));
}


@override
int get hashCode {
  final _this = this as ApiErrorEnvelope;
  return Object.hash(runtimeType,_this.code,_this.statusCode,_this.message,_this.path,_this.requestId,_this.timestamp,const DeepCollectionEquality().hash(_this.details));
}

@override
String toString() {
  final _this = this as ApiErrorEnvelope;
  return 'ApiErrorEnvelope(code: ${_this.code}, statusCode: ${_this.statusCode}, message: ${_this.message}, path: ${_this.path}, requestId: ${_this.requestId}, timestamp: ${_this.timestamp}, details: ${_this.details})';
}


}

/// @nodoc
abstract mixin class $ApiErrorEnvelopeCopyWith<$Res>  {
  factory $ApiErrorEnvelopeCopyWith(ApiErrorEnvelope value, $Res Function(ApiErrorEnvelope) _then) = _$ApiErrorEnvelopeCopyWithImpl;
@useResult
$Res call({
 String code, int? statusCode, String? message, String? path, String? requestId, String? timestamp, Map<String, List<String>> details
});




}
/// @nodoc
class _$ApiErrorEnvelopeCopyWithImpl<$Res>
    implements $ApiErrorEnvelopeCopyWith<$Res> {
  _$ApiErrorEnvelopeCopyWithImpl(this._self, this._then);

  final ApiErrorEnvelope _self;
  final $Res Function(ApiErrorEnvelope) _then;

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? statusCode = freezed,Object? message = freezed,Object? path = freezed,Object? requestId = freezed,Object? timestamp = freezed,Object? details = null,}) {
  return _then(ApiErrorEnvelope(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorEnvelope].
extension ApiErrorEnvelopePatterns on ApiErrorEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  int? statusCode,  String? message,  String? path,  String? requestId,  String? timestamp,  Map<String, List<String>> details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
return $default(_that.code,_that.statusCode,_that.message,_that.path,_that.requestId,_that.timestamp,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  int? statusCode,  String? message,  String? path,  String? requestId,  String? timestamp,  Map<String, List<String>> details)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope():
return $default(_that.code,_that.statusCode,_that.message,_that.path,_that.requestId,_that.timestamp,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  int? statusCode,  String? message,  String? path,  String? requestId,  String? timestamp,  Map<String, List<String>> details)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
return $default(_that.code,_that.statusCode,_that.message,_that.path,_that.requestId,_that.timestamp,_that.details);case _:
  return null;

}
}

}

/// @nodoc


class _ApiErrorEnvelope implements ApiErrorEnvelope {
  const _ApiErrorEnvelope({required this.code, this.statusCode, this.message, this.path, this.requestId, this.timestamp,  Map<String, List<String>> details = const <String, List<String>>{}}): _details = details;
  

@override final  String code;
@override final  int? statusCode;
@override final  String? message;
@override final  String? path;
@override final  String? requestId;
@override final  String? timestamp;
/// Validation messages keyed by dotted field path.
 final  Map<String, List<String>> _details;
/// Validation messages keyed by dotted field path.
@override@JsonKey() Map<String, List<String>> get details {
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_details);
}


/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorEnvelopeCopyWith<_ApiErrorEnvelope> get copyWith => __$ApiErrorEnvelopeCopyWithImpl<_ApiErrorEnvelope>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorEnvelope&&(identical(other.code, code) || other.code == code)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.path, path) || other.path == path)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.details, _details));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,statusCode,message,path,requestId,timestamp,const DeepCollectionEquality().hash(_details));
}

@override
String toString() {
    return 'ApiErrorEnvelope(code: $code, statusCode: $statusCode, message: $message, path: $path, requestId: $requestId, timestamp: $timestamp, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorEnvelopeCopyWith<$Res> implements $ApiErrorEnvelopeCopyWith<$Res> {
  factory _$ApiErrorEnvelopeCopyWith(_ApiErrorEnvelope value, $Res Function(_ApiErrorEnvelope) _then) = __$ApiErrorEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 String code, int? statusCode, String? message, String? path, String? requestId, String? timestamp, Map<String, List<String>> details
});




}
/// @nodoc
class __$ApiErrorEnvelopeCopyWithImpl<$Res>
    implements _$ApiErrorEnvelopeCopyWith<$Res> {
  __$ApiErrorEnvelopeCopyWithImpl(this._self, this._then);

  final _ApiErrorEnvelope _self;
  final $Res Function(_ApiErrorEnvelope) _then;

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? statusCode = freezed,Object? message = freezed,Object? path = freezed,Object? requestId = freezed,Object? timestamp = freezed,Object? details = null,}) {
  return _then(_ApiErrorEnvelope(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

// dart format on
