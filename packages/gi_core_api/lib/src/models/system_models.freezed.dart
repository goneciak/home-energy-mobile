// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthLive {

 String get status;
/// Create a copy of HealthLive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthLiveCopyWith<HealthLive> get copyWith => _$HealthLiveCopyWithImpl<HealthLive>(this as HealthLive, _$identity);

  /// Serializes this HealthLive to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HealthLive;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthLive&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HealthLive;
  return Object.hash(runtimeType,_this.status);
}

@override
String toString() {
  final _this = this as HealthLive;
  return 'HealthLive(status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $HealthLiveCopyWith<$Res>  {
  factory $HealthLiveCopyWith(HealthLive value, $Res Function(HealthLive) _then) = _$HealthLiveCopyWithImpl;
@useResult
$Res call({
 String status
});




}
/// @nodoc
class _$HealthLiveCopyWithImpl<$Res>
    implements $HealthLiveCopyWith<$Res> {
  _$HealthLiveCopyWithImpl(this._self, this._then);

  final HealthLive _self;
  final $Res Function(HealthLive) _then;

/// Create a copy of HealthLive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(HealthLive(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthLive].
extension HealthLivePatterns on HealthLive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthLive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthLive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthLive value)  $default,){
final _that = this;
switch (_that) {
case _HealthLive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthLive value)?  $default,){
final _that = this;
switch (_that) {
case _HealthLive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthLive() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status)  $default,) {final _that = this;
switch (_that) {
case _HealthLive():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status)?  $default,) {final _that = this;
switch (_that) {
case _HealthLive() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthLive extends HealthLive {
  const _HealthLive({required this.status}): super._();
  factory _HealthLive.fromJson(Map<String, dynamic> json) => _$HealthLiveFromJson(json);

@override final  String status;

/// Create a copy of HealthLive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthLiveCopyWith<_HealthLive> get copyWith => __$HealthLiveCopyWithImpl<_HealthLive>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthLiveToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthLive&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status);
}

@override
String toString() {
    return 'HealthLive(status: $status)';
}


}

/// @nodoc
abstract mixin class _$HealthLiveCopyWith<$Res> implements $HealthLiveCopyWith<$Res> {
  factory _$HealthLiveCopyWith(_HealthLive value, $Res Function(_HealthLive) _then) = __$HealthLiveCopyWithImpl;
@override @useResult
$Res call({
 String status
});




}
/// @nodoc
class __$HealthLiveCopyWithImpl<$Res>
    implements _$HealthLiveCopyWith<$Res> {
  __$HealthLiveCopyWithImpl(this._self, this._then);

  final _HealthLive _self;
  final $Res Function(_HealthLive) _then;

/// Create a copy of HealthLive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_HealthLive(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SetupStatus {

 bool get initialized; DateTime? get initializedAt; String? get deviceName; String? get locale; String? get timezone;
/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupStatusCopyWith<SetupStatus> get copyWith => _$SetupStatusCopyWithImpl<SetupStatus>(this as SetupStatus, _$identity);

  /// Serializes this SetupStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetupStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupStatus&&(identical(other.initialized, _this.initialized) || other.initialized == _this.initialized)&&(identical(other.initializedAt, _this.initializedAt) || other.initializedAt == _this.initializedAt)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupStatus;
  return Object.hash(runtimeType,_this.initialized,_this.initializedAt,_this.deviceName,_this.locale,_this.timezone);
}

@override
String toString() {
  final _this = this as SetupStatus;
  return 'SetupStatus(initialized: ${_this.initialized}, initializedAt: ${_this.initializedAt}, deviceName: ${_this.deviceName}, locale: ${_this.locale}, timezone: ${_this.timezone})';
}


}

/// @nodoc
abstract mixin class $SetupStatusCopyWith<$Res>  {
  factory $SetupStatusCopyWith(SetupStatus value, $Res Function(SetupStatus) _then) = _$SetupStatusCopyWithImpl;
@useResult
$Res call({
 bool initialized, DateTime? initializedAt, String? deviceName, String? locale, String? timezone
});




}
/// @nodoc
class _$SetupStatusCopyWithImpl<$Res>
    implements $SetupStatusCopyWith<$Res> {
  _$SetupStatusCopyWithImpl(this._self, this._then);

  final SetupStatus _self;
  final $Res Function(SetupStatus) _then;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? initialized = null,Object? initializedAt = freezed,Object? deviceName = freezed,Object? locale = freezed,Object? timezone = freezed,}) {
  return _then(SetupStatus(
initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetupStatus].
extension SetupStatusPatterns on SetupStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupStatus value)  $default,){
final _that = this;
switch (_that) {
case _SetupStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool initialized,  DateTime? initializedAt,  String? deviceName,  String? locale,  String? timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
return $default(_that.initialized,_that.initializedAt,_that.deviceName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool initialized,  DateTime? initializedAt,  String? deviceName,  String? locale,  String? timezone)  $default,) {final _that = this;
switch (_that) {
case _SetupStatus():
return $default(_that.initialized,_that.initializedAt,_that.deviceName,_that.locale,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool initialized,  DateTime? initializedAt,  String? deviceName,  String? locale,  String? timezone)?  $default,) {final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
return $default(_that.initialized,_that.initializedAt,_that.deviceName,_that.locale,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupStatus implements SetupStatus {
  const _SetupStatus({required this.initialized, this.initializedAt, this.deviceName, this.locale, this.timezone});
  factory _SetupStatus.fromJson(Map<String, dynamic> json) => _$SetupStatusFromJson(json);

@override final  bool initialized;
@override final  DateTime? initializedAt;
@override final  String? deviceName;
@override final  String? locale;
@override final  String? timezone;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupStatusCopyWith<_SetupStatus> get copyWith => __$SetupStatusCopyWithImpl<_SetupStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupStatus&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.initializedAt, initializedAt) || other.initializedAt == initializedAt)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,initialized,initializedAt,deviceName,locale,timezone);
}

@override
String toString() {
    return 'SetupStatus(initialized: $initialized, initializedAt: $initializedAt, deviceName: $deviceName, locale: $locale, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$SetupStatusCopyWith<$Res> implements $SetupStatusCopyWith<$Res> {
  factory _$SetupStatusCopyWith(_SetupStatus value, $Res Function(_SetupStatus) _then) = __$SetupStatusCopyWithImpl;
@override @useResult
$Res call({
 bool initialized, DateTime? initializedAt, String? deviceName, String? locale, String? timezone
});




}
/// @nodoc
class __$SetupStatusCopyWithImpl<$Res>
    implements _$SetupStatusCopyWith<$Res> {
  __$SetupStatusCopyWithImpl(this._self, this._then);

  final _SetupStatus _self;
  final $Res Function(_SetupStatus) _then;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialized = null,Object? initializedAt = freezed,Object? deviceName = freezed,Object? locale = freezed,Object? timezone = freezed,}) {
  return _then(_SetupStatus(
initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListPage<T> {

 List<T> get items; int get page; int get limit; int get total; int get totalPages;
/// Create a copy of ListPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListPageCopyWith<T, ListPage<T>> get copyWith => _$ListPageCopyWithImpl<T, ListPage<T>>(this as ListPage<T>, _$identity);

  /// Serializes this ListPage to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as ListPage<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListPage<T>&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListPage<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.page,_this.limit,_this.total,_this.totalPages);
}

@override
String toString() {
  final _this = this as ListPage<T>;
  return 'ListPage<$T>(items: ${_this.items}, page: ${_this.page}, limit: ${_this.limit}, total: ${_this.total}, totalPages: ${_this.totalPages})';
}


}

/// @nodoc
abstract mixin class $ListPageCopyWith<T,$Res>  {
  factory $ListPageCopyWith(ListPage<T> value, $Res Function(ListPage<T>) _then) = _$ListPageCopyWithImpl;
@useResult
$Res call({
 List<T> items, int page, int limit, int total, int totalPages
});




}
/// @nodoc
class _$ListPageCopyWithImpl<T,$Res>
    implements $ListPageCopyWith<T, $Res> {
  _$ListPageCopyWithImpl(this._self, this._then);

  final ListPage<T> _self;
  final $Res Function(ListPage<T>) _then;

/// Create a copy of ListPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(ListPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListPage].
extension ListPagePatterns<T> on ListPage<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListPage<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListPage<T> value)  $default,){
final _that = this;
switch (_that) {
case _ListPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListPage<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ListPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  int page,  int limit,  int total,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListPage() when $default != null:
return $default(_that.items,_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  int page,  int limit,  int total,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _ListPage():
return $default(_that.items,_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  int page,  int limit,  int total,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _ListPage() when $default != null:
return $default(_that.items,_that.page,_that.limit,_that.total,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ListPage<T> extends ListPage<T> {
  const _ListPage({required  List<T> items, required this.page, required this.limit, required this.total, required this.totalPages}): _items = items,super._();
  factory _ListPage.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ListPageFromJson(json,fromJsonT);

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int limit;
@override final  int total;
@override final  int totalPages;

/// Create a copy of ListPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListPageCopyWith<T, _ListPage<T>> get copyWith => __$ListPageCopyWithImpl<T, _ListPage<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ListPageToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListPage<T>&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,limit,total,totalPages);
}

@override
String toString() {
    return 'ListPage<$T>(items: $items, page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$ListPageCopyWith<T,$Res> implements $ListPageCopyWith<T, $Res> {
  factory _$ListPageCopyWith(_ListPage<T> value, $Res Function(_ListPage<T>) _then) = __$ListPageCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, int page, int limit, int total, int totalPages
});




}
/// @nodoc
class __$ListPageCopyWithImpl<T,$Res>
    implements _$ListPageCopyWith<T, $Res> {
  __$ListPageCopyWithImpl(this._self, this._then);

  final _ListPage<T> _self;
  final $Res Function(_ListPage<T>) _then;

/// Create a copy of ListPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_ListPage<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
