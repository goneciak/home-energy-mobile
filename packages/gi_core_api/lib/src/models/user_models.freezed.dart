// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get email; String get firstName; bool get enabled; bool get mustChangePassword; DateTime get createdAt; DateTime get updatedAt; String? get lastName; String? get locale;@JsonKey(unknownEnumValue: UserRole.unknown) UserRole get role; DateTime? get lastLoginAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.mustChangePassword, _this.mustChangePassword) || other.mustChangePassword == _this.mustChangePassword)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.lastLoginAt, _this.lastLoginAt) || other.lastLoginAt == _this.lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.id,_this.email,_this.firstName,_this.enabled,_this.mustChangePassword,_this.createdAt,_this.updatedAt,_this.lastName,_this.locale,_this.role,_this.lastLoginAt);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(id: ${_this.id}, email: ${_this.email}, firstName: ${_this.firstName}, enabled: ${_this.enabled}, mustChangePassword: ${_this.mustChangePassword}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, lastName: ${_this.lastName}, locale: ${_this.locale}, role: ${_this.role}, lastLoginAt: ${_this.lastLoginAt})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String email, String firstName, bool enabled, bool mustChangePassword, DateTime createdAt, DateTime updatedAt, String? lastName, String? locale,@JsonKey(unknownEnumValue: UserRole.unknown) UserRole role, DateTime? lastLoginAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? enabled = null,Object? mustChangePassword = null,Object? createdAt = null,Object? updatedAt = null,Object? lastName = freezed,Object? locale = freezed,Object? role = null,Object? lastLoginAt = freezed,}) {
  return _then(UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String firstName,  bool enabled,  bool mustChangePassword,  DateTime createdAt,  DateTime updatedAt,  String? lastName,  String? locale, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.enabled,_that.mustChangePassword,_that.createdAt,_that.updatedAt,_that.lastName,_that.locale,_that.role,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String firstName,  bool enabled,  bool mustChangePassword,  DateTime createdAt,  DateTime updatedAt,  String? lastName,  String? locale, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.email,_that.firstName,_that.enabled,_that.mustChangePassword,_that.createdAt,_that.updatedAt,_that.lastName,_that.locale,_that.role,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String firstName,  bool enabled,  bool mustChangePassword,  DateTime createdAt,  DateTime updatedAt,  String? lastName,  String? locale, @JsonKey(unknownEnumValue: UserRole.unknown)  UserRole role,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.enabled,_that.mustChangePassword,_that.createdAt,_that.updatedAt,_that.lastName,_that.locale,_that.role,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.email, required this.firstName, required this.enabled, required this.mustChangePassword, required this.createdAt, required this.updatedAt, this.lastName, this.locale, @JsonKey(unknownEnumValue: UserRole.unknown) this.role = UserRole.unknown, this.lastLoginAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String email;
@override final  String firstName;
@override final  bool enabled;
@override final  bool mustChangePassword;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? lastName;
@override final  String? locale;
@override@JsonKey(unknownEnumValue: UserRole.unknown) final  UserRole role;
@override final  DateTime? lastLoginAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,firstName,enabled,mustChangePassword,createdAt,updatedAt,lastName,locale,role,lastLoginAt);
}

@override
String toString() {
    return 'UserProfile(id: $id, email: $email, firstName: $firstName, enabled: $enabled, mustChangePassword: $mustChangePassword, createdAt: $createdAt, updatedAt: $updatedAt, lastName: $lastName, locale: $locale, role: $role, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String firstName, bool enabled, bool mustChangePassword, DateTime createdAt, DateTime updatedAt, String? lastName, String? locale,@JsonKey(unknownEnumValue: UserRole.unknown) UserRole role, DateTime? lastLoginAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? enabled = null,Object? mustChangePassword = null,Object? createdAt = null,Object? updatedAt = null,Object? lastName = freezed,Object? locale = freezed,Object? role = null,Object? lastLoginAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChangePasswordResult {

 int get revokedSessions;
/// Create a copy of ChangePasswordResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordResultCopyWith<ChangePasswordResult> get copyWith => _$ChangePasswordResultCopyWithImpl<ChangePasswordResult>(this as ChangePasswordResult, _$identity);

  /// Serializes this ChangePasswordResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangePasswordResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordResult&&(identical(other.revokedSessions, _this.revokedSessions) || other.revokedSessions == _this.revokedSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangePasswordResult;
  return Object.hash(runtimeType,_this.revokedSessions);
}

@override
String toString() {
  final _this = this as ChangePasswordResult;
  return 'ChangePasswordResult(revokedSessions: ${_this.revokedSessions})';
}


}

/// @nodoc
abstract mixin class $ChangePasswordResultCopyWith<$Res>  {
  factory $ChangePasswordResultCopyWith(ChangePasswordResult value, $Res Function(ChangePasswordResult) _then) = _$ChangePasswordResultCopyWithImpl;
@useResult
$Res call({
 int revokedSessions
});




}
/// @nodoc
class _$ChangePasswordResultCopyWithImpl<$Res>
    implements $ChangePasswordResultCopyWith<$Res> {
  _$ChangePasswordResultCopyWithImpl(this._self, this._then);

  final ChangePasswordResult _self;
  final $Res Function(ChangePasswordResult) _then;

/// Create a copy of ChangePasswordResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revokedSessions = null,}) {
  return _then(ChangePasswordResult(
revokedSessions: null == revokedSessions ? _self.revokedSessions : revokedSessions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangePasswordResult].
extension ChangePasswordResultPatterns on ChangePasswordResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordResult value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordResult value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int revokedSessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordResult() when $default != null:
return $default(_that.revokedSessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int revokedSessions)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordResult():
return $default(_that.revokedSessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int revokedSessions)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordResult() when $default != null:
return $default(_that.revokedSessions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangePasswordResult implements ChangePasswordResult {
  const _ChangePasswordResult({required this.revokedSessions});
  factory _ChangePasswordResult.fromJson(Map<String, dynamic> json) => _$ChangePasswordResultFromJson(json);

@override final  int revokedSessions;

/// Create a copy of ChangePasswordResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordResultCopyWith<_ChangePasswordResult> get copyWith => __$ChangePasswordResultCopyWithImpl<_ChangePasswordResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangePasswordResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordResult&&(identical(other.revokedSessions, revokedSessions) || other.revokedSessions == revokedSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,revokedSessions);
}

@override
String toString() {
    return 'ChangePasswordResult(revokedSessions: $revokedSessions)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordResultCopyWith<$Res> implements $ChangePasswordResultCopyWith<$Res> {
  factory _$ChangePasswordResultCopyWith(_ChangePasswordResult value, $Res Function(_ChangePasswordResult) _then) = __$ChangePasswordResultCopyWithImpl;
@override @useResult
$Res call({
 int revokedSessions
});




}
/// @nodoc
class __$ChangePasswordResultCopyWithImpl<$Res>
    implements _$ChangePasswordResultCopyWith<$Res> {
  __$ChangePasswordResultCopyWithImpl(this._self, this._then);

  final _ChangePasswordResult _self;
  final $Res Function(_ChangePasswordResult) _then;

/// Create a copy of ChangePasswordResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revokedSessions = null,}) {
  return _then(_ChangePasswordResult(
revokedSessions: null == revokedSessions ? _self.revokedSessions : revokedSessions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
