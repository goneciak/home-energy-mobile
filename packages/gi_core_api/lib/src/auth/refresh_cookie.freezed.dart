// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_cookie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RefreshCookie {

 String get name; String get value; String get path; DateTime get obtainedAt;/// Wall-clock end of the 30-day session; `null` for a session cookie.
 DateTime? get absoluteExpiry;/// Incremented on every rotation; helps diagnose write-ahead issues.
 int get generation;
/// Create a copy of RefreshCookie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshCookieCopyWith<RefreshCookie> get copyWith => _$RefreshCookieCopyWithImpl<RefreshCookie>(this as RefreshCookie, _$identity);

  /// Serializes this RefreshCookie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RefreshCookie;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshCookie&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.obtainedAt, _this.obtainedAt) || other.obtainedAt == _this.obtainedAt)&&(identical(other.absoluteExpiry, _this.absoluteExpiry) || other.absoluteExpiry == _this.absoluteExpiry)&&(identical(other.generation, _this.generation) || other.generation == _this.generation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RefreshCookie;
  return Object.hash(runtimeType,_this.name,_this.value,_this.path,_this.obtainedAt,_this.absoluteExpiry,_this.generation);
}



}

/// @nodoc
abstract mixin class $RefreshCookieCopyWith<$Res>  {
  factory $RefreshCookieCopyWith(RefreshCookie value, $Res Function(RefreshCookie) _then) = _$RefreshCookieCopyWithImpl;
@useResult
$Res call({
 String name, String value, String path, DateTime obtainedAt, DateTime? absoluteExpiry, int generation
});




}
/// @nodoc
class _$RefreshCookieCopyWithImpl<$Res>
    implements $RefreshCookieCopyWith<$Res> {
  _$RefreshCookieCopyWithImpl(this._self, this._then);

  final RefreshCookie _self;
  final $Res Function(RefreshCookie) _then;

/// Create a copy of RefreshCookie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,Object? path = null,Object? obtainedAt = null,Object? absoluteExpiry = freezed,Object? generation = null,}) {
  return _then(RefreshCookie(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,obtainedAt: null == obtainedAt ? _self.obtainedAt : obtainedAt // ignore: cast_nullable_to_non_nullable
as DateTime,absoluteExpiry: freezed == absoluteExpiry ? _self.absoluteExpiry : absoluteExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshCookie].
extension RefreshCookiePatterns on RefreshCookie {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshCookie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshCookie() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshCookie value)  $default,){
final _that = this;
switch (_that) {
case _RefreshCookie():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshCookie value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshCookie() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value,  String path,  DateTime obtainedAt,  DateTime? absoluteExpiry,  int generation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshCookie() when $default != null:
return $default(_that.name,_that.value,_that.path,_that.obtainedAt,_that.absoluteExpiry,_that.generation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value,  String path,  DateTime obtainedAt,  DateTime? absoluteExpiry,  int generation)  $default,) {final _that = this;
switch (_that) {
case _RefreshCookie():
return $default(_that.name,_that.value,_that.path,_that.obtainedAt,_that.absoluteExpiry,_that.generation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value,  String path,  DateTime obtainedAt,  DateTime? absoluteExpiry,  int generation)?  $default,) {final _that = this;
switch (_that) {
case _RefreshCookie() when $default != null:
return $default(_that.name,_that.value,_that.path,_that.obtainedAt,_that.absoluteExpiry,_that.generation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshCookie extends RefreshCookie {
  const _RefreshCookie({required this.name, required this.value, required this.path, required this.obtainedAt, this.absoluteExpiry, this.generation = 0}): super._();
  factory _RefreshCookie.fromJson(Map<String, dynamic> json) => _$RefreshCookieFromJson(json);

@override final  String name;
@override final  String value;
@override final  String path;
@override final  DateTime obtainedAt;
/// Wall-clock end of the 30-day session; `null` for a session cookie.
@override final  DateTime? absoluteExpiry;
/// Incremented on every rotation; helps diagnose write-ahead issues.
@override@JsonKey() final  int generation;

/// Create a copy of RefreshCookie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshCookieCopyWith<_RefreshCookie> get copyWith => __$RefreshCookieCopyWithImpl<_RefreshCookie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshCookieToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshCookie&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.path, path) || other.path == path)&&(identical(other.obtainedAt, obtainedAt) || other.obtainedAt == obtainedAt)&&(identical(other.absoluteExpiry, absoluteExpiry) || other.absoluteExpiry == absoluteExpiry)&&(identical(other.generation, generation) || other.generation == generation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,value,path,obtainedAt,absoluteExpiry,generation);
}



}

/// @nodoc
abstract mixin class _$RefreshCookieCopyWith<$Res> implements $RefreshCookieCopyWith<$Res> {
  factory _$RefreshCookieCopyWith(_RefreshCookie value, $Res Function(_RefreshCookie) _then) = __$RefreshCookieCopyWithImpl;
@override @useResult
$Res call({
 String name, String value, String path, DateTime obtainedAt, DateTime? absoluteExpiry, int generation
});




}
/// @nodoc
class __$RefreshCookieCopyWithImpl<$Res>
    implements _$RefreshCookieCopyWith<$Res> {
  __$RefreshCookieCopyWithImpl(this._self, this._then);

  final _RefreshCookie _self;
  final $Res Function(_RefreshCookie) _then;

/// Create a copy of RefreshCookie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,Object? path = null,Object? obtainedAt = null,Object? absoluteExpiry = freezed,Object? generation = null,}) {
  return _then(_RefreshCookie(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,obtainedAt: null == obtainedAt ? _self.obtainedAt : obtainedAt // ignore: cast_nullable_to_non_nullable
as DateTime,absoluteExpiry: freezed == absoluteExpiry ? _self.absoluteExpiry : absoluteExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
