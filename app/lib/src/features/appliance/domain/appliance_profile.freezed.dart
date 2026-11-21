// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appliance_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApplianceProfile {

/// Random id scoping secure-storage keys to this profile.
 String get profileId;/// Display name: the appliance's device name, or its host.
 String get label;/// Normalised origin, e.g. `http://192.168.1.20:3000`: the active
/// address, always the first of [hosts].
 String get baseUrl;/// Origins this appliance has answered on, most recent first, without
/// duplicates and at most [maxHosts] (plan §7.1). The connection ladder
/// tries them first (plan §9.2). Profiles saved before this field
/// existed load with `[baseUrl]`.
 List<String> get hosts; String? get deviceName;/// Appliance fingerprint (plan §9.3); `null` until the appliance is set
/// up. The session cookie is only ever sent to a matching appliance.
 DateTime? get initializedAt;/// Pre-fills the login form; cleared by "Zmień użytkownika".
 String? get lastUserEmail;/// Id of the user last signed in (plan §7.1): set after login and every
/// `GET /auth/me`, cleared by "Zmień użytkownika". Scopes per-user
/// state such as the profile language restored on a cold start.
 String? get lastUserId;/// Whether the one-time "not encrypted" notice (plan §9.4) was shown
/// when an `http://` address of this profile was confirmed. A new
/// profile (a replaced appliance) starts without it.
 bool get cleartextNoticeShown;
/// Create a copy of ApplianceProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplianceProfileCopyWith<ApplianceProfile> get copyWith => _$ApplianceProfileCopyWithImpl<ApplianceProfile>(this as ApplianceProfile, _$identity);

  /// Serializes this ApplianceProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApplianceProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplianceProfile&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.initializedAt, _this.initializedAt) || other.initializedAt == _this.initializedAt)&&(identical(other.lastUserEmail, _this.lastUserEmail) || other.lastUserEmail == _this.lastUserEmail)&&(identical(other.lastUserId, _this.lastUserId) || other.lastUserId == _this.lastUserId)&&(identical(other.cleartextNoticeShown, _this.cleartextNoticeShown) || other.cleartextNoticeShown == _this.cleartextNoticeShown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApplianceProfile;
  return Object.hash(runtimeType,_this.profileId,_this.label,_this.baseUrl,const DeepCollectionEquality().hash(_this.hosts),_this.deviceName,_this.initializedAt,_this.lastUserEmail,_this.lastUserId,_this.cleartextNoticeShown);
}

@override
String toString() {
  final _this = this as ApplianceProfile;
  return 'ApplianceProfile(profileId: ${_this.profileId}, label: ${_this.label}, baseUrl: ${_this.baseUrl}, hosts: ${_this.hosts}, deviceName: ${_this.deviceName}, initializedAt: ${_this.initializedAt}, lastUserEmail: ${_this.lastUserEmail}, lastUserId: ${_this.lastUserId}, cleartextNoticeShown: ${_this.cleartextNoticeShown})';
}


}

/// @nodoc
abstract mixin class $ApplianceProfileCopyWith<$Res>  {
  factory $ApplianceProfileCopyWith(ApplianceProfile value, $Res Function(ApplianceProfile) _then) = _$ApplianceProfileCopyWithImpl;
@useResult
$Res call({
 String profileId, String label, String baseUrl, List<String> hosts, String? deviceName, DateTime? initializedAt, String? lastUserEmail, String? lastUserId, bool cleartextNoticeShown
});




}
/// @nodoc
class _$ApplianceProfileCopyWithImpl<$Res>
    implements $ApplianceProfileCopyWith<$Res> {
  _$ApplianceProfileCopyWithImpl(this._self, this._then);

  final ApplianceProfile _self;
  final $Res Function(ApplianceProfile) _then;

/// Create a copy of ApplianceProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? label = null,Object? baseUrl = null,Object? hosts = null,Object? deviceName = freezed,Object? initializedAt = freezed,Object? lastUserEmail = freezed,Object? lastUserId = freezed,Object? cleartextNoticeShown = null,}) {
  return _then(ApplianceProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<String>,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUserEmail: freezed == lastUserEmail ? _self.lastUserEmail : lastUserEmail // ignore: cast_nullable_to_non_nullable
as String?,lastUserId: freezed == lastUserId ? _self.lastUserId : lastUserId // ignore: cast_nullable_to_non_nullable
as String?,cleartextNoticeShown: null == cleartextNoticeShown ? _self.cleartextNoticeShown : cleartextNoticeShown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ApplianceProfile].
extension ApplianceProfilePatterns on ApplianceProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplianceProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplianceProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplianceProfile value)  $default,){
final _that = this;
switch (_that) {
case _ApplianceProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplianceProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ApplianceProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String label,  String baseUrl,  List<String> hosts,  String? deviceName,  DateTime? initializedAt,  String? lastUserEmail,  String? lastUserId,  bool cleartextNoticeShown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplianceProfile() when $default != null:
return $default(_that.profileId,_that.label,_that.baseUrl,_that.hosts,_that.deviceName,_that.initializedAt,_that.lastUserEmail,_that.lastUserId,_that.cleartextNoticeShown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String label,  String baseUrl,  List<String> hosts,  String? deviceName,  DateTime? initializedAt,  String? lastUserEmail,  String? lastUserId,  bool cleartextNoticeShown)  $default,) {final _that = this;
switch (_that) {
case _ApplianceProfile():
return $default(_that.profileId,_that.label,_that.baseUrl,_that.hosts,_that.deviceName,_that.initializedAt,_that.lastUserEmail,_that.lastUserId,_that.cleartextNoticeShown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String label,  String baseUrl,  List<String> hosts,  String? deviceName,  DateTime? initializedAt,  String? lastUserEmail,  String? lastUserId,  bool cleartextNoticeShown)?  $default,) {final _that = this;
switch (_that) {
case _ApplianceProfile() when $default != null:
return $default(_that.profileId,_that.label,_that.baseUrl,_that.hosts,_that.deviceName,_that.initializedAt,_that.lastUserEmail,_that.lastUserId,_that.cleartextNoticeShown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplianceProfile extends ApplianceProfile {
  const _ApplianceProfile({required this.profileId, required this.label, required this.baseUrl,  List<String> hosts = const <String>[], this.deviceName, this.initializedAt, this.lastUserEmail, this.lastUserId, this.cleartextNoticeShown = false}): _hosts = hosts,super._();
  factory _ApplianceProfile.fromJson(Map<String, dynamic> json) => _$ApplianceProfileFromJson(json);

/// Random id scoping secure-storage keys to this profile.
@override final  String profileId;
/// Display name: the appliance's device name, or its host.
@override final  String label;
/// Normalised origin, e.g. `http://192.168.1.20:3000`: the active
/// address, always the first of [hosts].
@override final  String baseUrl;
/// Origins this appliance has answered on, most recent first, without
/// duplicates and at most [maxHosts] (plan §7.1). The connection ladder
/// tries them first (plan §9.2). Profiles saved before this field
/// existed load with `[baseUrl]`.
 final  List<String> _hosts;
/// Origins this appliance has answered on, most recent first, without
/// duplicates and at most [maxHosts] (plan §7.1). The connection ladder
/// tries them first (plan §9.2). Profiles saved before this field
/// existed load with `[baseUrl]`.
@override@JsonKey() List<String> get hosts {
  if (_hosts is EqualUnmodifiableListView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hosts);
}

@override final  String? deviceName;
/// Appliance fingerprint (plan §9.3); `null` until the appliance is set
/// up. The session cookie is only ever sent to a matching appliance.
@override final  DateTime? initializedAt;
/// Pre-fills the login form; cleared by "Zmień użytkownika".
@override final  String? lastUserEmail;
/// Id of the user last signed in (plan §7.1): set after login and every
/// `GET /auth/me`, cleared by "Zmień użytkownika". Scopes per-user
/// state such as the profile language restored on a cold start.
@override final  String? lastUserId;
/// Whether the one-time "not encrypted" notice (plan §9.4) was shown
/// when an `http://` address of this profile was confirmed. A new
/// profile (a replaced appliance) starts without it.
@override@JsonKey() final  bool cleartextNoticeShown;

/// Create a copy of ApplianceProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplianceProfileCopyWith<_ApplianceProfile> get copyWith => __$ApplianceProfileCopyWithImpl<_ApplianceProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplianceProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplianceProfile&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.label, label) || other.label == label)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&const DeepCollectionEquality().equals(other.hosts, _hosts)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.initializedAt, initializedAt) || other.initializedAt == initializedAt)&&(identical(other.lastUserEmail, lastUserEmail) || other.lastUserEmail == lastUserEmail)&&(identical(other.lastUserId, lastUserId) || other.lastUserId == lastUserId)&&(identical(other.cleartextNoticeShown, cleartextNoticeShown) || other.cleartextNoticeShown == cleartextNoticeShown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profileId,label,baseUrl,const DeepCollectionEquality().hash(_hosts),deviceName,initializedAt,lastUserEmail,lastUserId,cleartextNoticeShown);
}

@override
String toString() {
    return 'ApplianceProfile(profileId: $profileId, label: $label, baseUrl: $baseUrl, hosts: $hosts, deviceName: $deviceName, initializedAt: $initializedAt, lastUserEmail: $lastUserEmail, lastUserId: $lastUserId, cleartextNoticeShown: $cleartextNoticeShown)';
}


}

/// @nodoc
abstract mixin class _$ApplianceProfileCopyWith<$Res> implements $ApplianceProfileCopyWith<$Res> {
  factory _$ApplianceProfileCopyWith(_ApplianceProfile value, $Res Function(_ApplianceProfile) _then) = __$ApplianceProfileCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String label, String baseUrl, List<String> hosts, String? deviceName, DateTime? initializedAt, String? lastUserEmail, String? lastUserId, bool cleartextNoticeShown
});




}
/// @nodoc
class __$ApplianceProfileCopyWithImpl<$Res>
    implements _$ApplianceProfileCopyWith<$Res> {
  __$ApplianceProfileCopyWithImpl(this._self, this._then);

  final _ApplianceProfile _self;
  final $Res Function(_ApplianceProfile) _then;

/// Create a copy of ApplianceProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? label = null,Object? baseUrl = null,Object? hosts = null,Object? deviceName = freezed,Object? initializedAt = freezed,Object? lastUserEmail = freezed,Object? lastUserId = freezed,Object? cleartextNoticeShown = null,}) {
  return _then(_ApplianceProfile(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<String>,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUserEmail: freezed == lastUserEmail ? _self.lastUserEmail : lastUserEmail // ignore: cast_nullable_to_non_nullable
as String?,lastUserId: freezed == lastUserId ? _self.lastUserId : lastUserId // ignore: cast_nullable_to_non_nullable
as String?,cleartextNoticeShown: null == cleartextNoticeShown ? _self.cleartextNoticeShown : cleartextNoticeShown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
