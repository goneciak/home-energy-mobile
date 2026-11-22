// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthSessionInfo {

 String get id; DateTime get createdAt; DateTime get expiresAt; bool get current; DateTime? get lastUsedAt; String? get userAgent; String? get ipAddress;
/// Create a copy of AuthSessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionInfoCopyWith<AuthSessionInfo> get copyWith => _$AuthSessionInfoCopyWithImpl<AuthSessionInfo>(this as AuthSessionInfo, _$identity);

  /// Serializes this AuthSessionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthSessionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.userAgent, _this.userAgent) || other.userAgent == _this.userAgent)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthSessionInfo;
  return Object.hash(runtimeType,_this.id,_this.createdAt,_this.expiresAt,_this.current,_this.lastUsedAt,_this.userAgent,_this.ipAddress);
}

@override
String toString() {
  final _this = this as AuthSessionInfo;
  return 'AuthSessionInfo(id: ${_this.id}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, current: ${_this.current}, lastUsedAt: ${_this.lastUsedAt}, userAgent: ${_this.userAgent}, ipAddress: ${_this.ipAddress})';
}


}

/// @nodoc
abstract mixin class $AuthSessionInfoCopyWith<$Res>  {
  factory $AuthSessionInfoCopyWith(AuthSessionInfo value, $Res Function(AuthSessionInfo) _then) = _$AuthSessionInfoCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime expiresAt, bool current, DateTime? lastUsedAt, String? userAgent, String? ipAddress
});




}
/// @nodoc
class _$AuthSessionInfoCopyWithImpl<$Res>
    implements $AuthSessionInfoCopyWith<$Res> {
  _$AuthSessionInfoCopyWithImpl(this._self, this._then);

  final AuthSessionInfo _self;
  final $Res Function(AuthSessionInfo) _then;

/// Create a copy of AuthSessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? expiresAt = null,Object? current = null,Object? lastUsedAt = freezed,Object? userAgent = freezed,Object? ipAddress = freezed,}) {
  return _then(AuthSessionInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSessionInfo].
extension AuthSessionInfoPatterns on AuthSessionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime expiresAt,  bool current,  DateTime? lastUsedAt,  String? userAgent,  String? ipAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionInfo() when $default != null:
return $default(_that.id,_that.createdAt,_that.expiresAt,_that.current,_that.lastUsedAt,_that.userAgent,_that.ipAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime expiresAt,  bool current,  DateTime? lastUsedAt,  String? userAgent,  String? ipAddress)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionInfo():
return $default(_that.id,_that.createdAt,_that.expiresAt,_that.current,_that.lastUsedAt,_that.userAgent,_that.ipAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime expiresAt,  bool current,  DateTime? lastUsedAt,  String? userAgent,  String? ipAddress)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionInfo() when $default != null:
return $default(_that.id,_that.createdAt,_that.expiresAt,_that.current,_that.lastUsedAt,_that.userAgent,_that.ipAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSessionInfo implements AuthSessionInfo {
  const _AuthSessionInfo({required this.id, required this.createdAt, required this.expiresAt, this.current = false, this.lastUsedAt, this.userAgent, this.ipAddress});
  factory _AuthSessionInfo.fromJson(Map<String, dynamic> json) => _$AuthSessionInfoFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override@JsonKey() final  bool current;
@override final  DateTime? lastUsedAt;
@override final  String? userAgent;
@override final  String? ipAddress;

/// Create a copy of AuthSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionInfoCopyWith<_AuthSessionInfo> get copyWith => __$AuthSessionInfoCopyWithImpl<_AuthSessionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt,expiresAt,current,lastUsedAt,userAgent,ipAddress);
}

@override
String toString() {
    return 'AuthSessionInfo(id: $id, createdAt: $createdAt, expiresAt: $expiresAt, current: $current, lastUsedAt: $lastUsedAt, userAgent: $userAgent, ipAddress: $ipAddress)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionInfoCopyWith<$Res> implements $AuthSessionInfoCopyWith<$Res> {
  factory _$AuthSessionInfoCopyWith(_AuthSessionInfo value, $Res Function(_AuthSessionInfo) _then) = __$AuthSessionInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime expiresAt, bool current, DateTime? lastUsedAt, String? userAgent, String? ipAddress
});




}
/// @nodoc
class __$AuthSessionInfoCopyWithImpl<$Res>
    implements _$AuthSessionInfoCopyWith<$Res> {
  __$AuthSessionInfoCopyWithImpl(this._self, this._then);

  final _AuthSessionInfo _self;
  final $Res Function(_AuthSessionInfo) _then;

/// Create a copy of AuthSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? expiresAt = null,Object? current = null,Object? lastUsedAt = freezed,Object? userAgent = freezed,Object? ipAddress = freezed,}) {
  return _then(_AuthSessionInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecoveryCodeResult {

 String get recoveryCode;
/// Create a copy of RecoveryCodeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryCodeResultCopyWith<RecoveryCodeResult> get copyWith => _$RecoveryCodeResultCopyWithImpl<RecoveryCodeResult>(this as RecoveryCodeResult, _$identity);

  /// Serializes this RecoveryCodeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecoveryCodeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryCodeResult&&(identical(other.recoveryCode, _this.recoveryCode) || other.recoveryCode == _this.recoveryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecoveryCodeResult;
  return Object.hash(runtimeType,_this.recoveryCode);
}



}

/// @nodoc
abstract mixin class $RecoveryCodeResultCopyWith<$Res>  {
  factory $RecoveryCodeResultCopyWith(RecoveryCodeResult value, $Res Function(RecoveryCodeResult) _then) = _$RecoveryCodeResultCopyWithImpl;
@useResult
$Res call({
 String recoveryCode
});




}
/// @nodoc
class _$RecoveryCodeResultCopyWithImpl<$Res>
    implements $RecoveryCodeResultCopyWith<$Res> {
  _$RecoveryCodeResultCopyWithImpl(this._self, this._then);

  final RecoveryCodeResult _self;
  final $Res Function(RecoveryCodeResult) _then;

/// Create a copy of RecoveryCodeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recoveryCode = null,}) {
  return _then(RecoveryCodeResult(
recoveryCode: null == recoveryCode ? _self.recoveryCode : recoveryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveryCodeResult].
extension RecoveryCodeResultPatterns on RecoveryCodeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryCodeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryCodeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryCodeResult value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryCodeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryCodeResult value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryCodeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recoveryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryCodeResult() when $default != null:
return $default(_that.recoveryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recoveryCode)  $default,) {final _that = this;
switch (_that) {
case _RecoveryCodeResult():
return $default(_that.recoveryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recoveryCode)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryCodeResult() when $default != null:
return $default(_that.recoveryCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecoveryCodeResult extends RecoveryCodeResult {
  const _RecoveryCodeResult({required this.recoveryCode}): super._();
  factory _RecoveryCodeResult.fromJson(Map<String, dynamic> json) => _$RecoveryCodeResultFromJson(json);

@override final  String recoveryCode;

/// Create a copy of RecoveryCodeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryCodeResultCopyWith<_RecoveryCodeResult> get copyWith => __$RecoveryCodeResultCopyWithImpl<_RecoveryCodeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecoveryCodeResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryCodeResult&&(identical(other.recoveryCode, recoveryCode) || other.recoveryCode == recoveryCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,recoveryCode);
}



}

/// @nodoc
abstract mixin class _$RecoveryCodeResultCopyWith<$Res> implements $RecoveryCodeResultCopyWith<$Res> {
  factory _$RecoveryCodeResultCopyWith(_RecoveryCodeResult value, $Res Function(_RecoveryCodeResult) _then) = __$RecoveryCodeResultCopyWithImpl;
@override @useResult
$Res call({
 String recoveryCode
});




}
/// @nodoc
class __$RecoveryCodeResultCopyWithImpl<$Res>
    implements _$RecoveryCodeResultCopyWith<$Res> {
  __$RecoveryCodeResultCopyWithImpl(this._self, this._then);

  final _RecoveryCodeResult _self;
  final $Res Function(_RecoveryCodeResult) _then;

/// Create a copy of RecoveryCodeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recoveryCode = null,}) {
  return _then(_RecoveryCodeResult(
recoveryCode: null == recoveryCode ? _self.recoveryCode : recoveryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
