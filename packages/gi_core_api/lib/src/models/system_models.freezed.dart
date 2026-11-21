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


/// @nodoc
mixin _$SystemSettings {

 String get locale; String get timezone; String? get deviceName;
/// Create a copy of SystemSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemSettingsCopyWith<SystemSettings> get copyWith => _$SystemSettingsCopyWithImpl<SystemSettings>(this as SystemSettings, _$identity);

  /// Serializes this SystemSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SystemSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemSettings&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SystemSettings;
  return Object.hash(runtimeType,_this.locale,_this.timezone,_this.deviceName);
}

@override
String toString() {
  final _this = this as SystemSettings;
  return 'SystemSettings(locale: ${_this.locale}, timezone: ${_this.timezone}, deviceName: ${_this.deviceName})';
}


}

/// @nodoc
abstract mixin class $SystemSettingsCopyWith<$Res>  {
  factory $SystemSettingsCopyWith(SystemSettings value, $Res Function(SystemSettings) _then) = _$SystemSettingsCopyWithImpl;
@useResult
$Res call({
 String locale, String timezone, String? deviceName
});




}
/// @nodoc
class _$SystemSettingsCopyWithImpl<$Res>
    implements $SystemSettingsCopyWith<$Res> {
  _$SystemSettingsCopyWithImpl(this._self, this._then);

  final SystemSettings _self;
  final $Res Function(SystemSettings) _then;

/// Create a copy of SystemSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? timezone = null,Object? deviceName = freezed,}) {
  return _then(SystemSettings(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemSettings].
extension SystemSettingsPatterns on SystemSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemSettings value)  $default,){
final _that = this;
switch (_that) {
case _SystemSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SystemSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String locale,  String timezone,  String? deviceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemSettings() when $default != null:
return $default(_that.locale,_that.timezone,_that.deviceName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String locale,  String timezone,  String? deviceName)  $default,) {final _that = this;
switch (_that) {
case _SystemSettings():
return $default(_that.locale,_that.timezone,_that.deviceName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String locale,  String timezone,  String? deviceName)?  $default,) {final _that = this;
switch (_that) {
case _SystemSettings() when $default != null:
return $default(_that.locale,_that.timezone,_that.deviceName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SystemSettings implements SystemSettings {
  const _SystemSettings({required this.locale, required this.timezone, this.deviceName});
  factory _SystemSettings.fromJson(Map<String, dynamic> json) => _$SystemSettingsFromJson(json);

@override final  String locale;
@override final  String timezone;
@override final  String? deviceName;

/// Create a copy of SystemSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemSettingsCopyWith<_SystemSettings> get copyWith => __$SystemSettingsCopyWithImpl<_SystemSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SystemSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemSettings&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locale,timezone,deviceName);
}

@override
String toString() {
    return 'SystemSettings(locale: $locale, timezone: $timezone, deviceName: $deviceName)';
}


}

/// @nodoc
abstract mixin class _$SystemSettingsCopyWith<$Res> implements $SystemSettingsCopyWith<$Res> {
  factory _$SystemSettingsCopyWith(_SystemSettings value, $Res Function(_SystemSettings) _then) = __$SystemSettingsCopyWithImpl;
@override @useResult
$Res call({
 String locale, String timezone, String? deviceName
});




}
/// @nodoc
class __$SystemSettingsCopyWithImpl<$Res>
    implements _$SystemSettingsCopyWith<$Res> {
  __$SystemSettingsCopyWithImpl(this._self, this._then);

  final _SystemSettings _self;
  final $Res Function(_SystemSettings) _then;

/// Create a copy of SystemSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? timezone = null,Object? deviceName = freezed,}) {
  return _then(_SystemSettings(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ApplianceUpdateStatus {

 bool get configured; UpdateCheckResult? get lastCheck; UpdateInstallResult? get lastInstall; String? get lastError;
/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplianceUpdateStatusCopyWith<ApplianceUpdateStatus> get copyWith => _$ApplianceUpdateStatusCopyWithImpl<ApplianceUpdateStatus>(this as ApplianceUpdateStatus, _$identity);

  /// Serializes this ApplianceUpdateStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApplianceUpdateStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplianceUpdateStatus&&(identical(other.configured, _this.configured) || other.configured == _this.configured)&&(identical(other.lastCheck, _this.lastCheck) || other.lastCheck == _this.lastCheck)&&(identical(other.lastInstall, _this.lastInstall) || other.lastInstall == _this.lastInstall)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApplianceUpdateStatus;
  return Object.hash(runtimeType,_this.configured,_this.lastCheck,_this.lastInstall,_this.lastError);
}

@override
String toString() {
  final _this = this as ApplianceUpdateStatus;
  return 'ApplianceUpdateStatus(configured: ${_this.configured}, lastCheck: ${_this.lastCheck}, lastInstall: ${_this.lastInstall}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $ApplianceUpdateStatusCopyWith<$Res>  {
  factory $ApplianceUpdateStatusCopyWith(ApplianceUpdateStatus value, $Res Function(ApplianceUpdateStatus) _then) = _$ApplianceUpdateStatusCopyWithImpl;
@useResult
$Res call({
 bool configured, UpdateCheckResult? lastCheck, UpdateInstallResult? lastInstall, String? lastError
});


$UpdateCheckResultCopyWith<$Res>? get lastCheck;$UpdateInstallResultCopyWith<$Res>? get lastInstall;

}
/// @nodoc
class _$ApplianceUpdateStatusCopyWithImpl<$Res>
    implements $ApplianceUpdateStatusCopyWith<$Res> {
  _$ApplianceUpdateStatusCopyWithImpl(this._self, this._then);

  final ApplianceUpdateStatus _self;
  final $Res Function(ApplianceUpdateStatus) _then;

/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configured = null,Object? lastCheck = freezed,Object? lastInstall = freezed,Object? lastError = freezed,}) {
  return _then(ApplianceUpdateStatus(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,lastCheck: freezed == lastCheck ? _self.lastCheck : lastCheck // ignore: cast_nullable_to_non_nullable
as UpdateCheckResult?,lastInstall: freezed == lastInstall ? _self.lastInstall : lastInstall // ignore: cast_nullable_to_non_nullable
as UpdateInstallResult?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateCheckResultCopyWith<$Res>? get lastCheck {
    if (_self.lastCheck == null) {
    return null;
  }

  return $UpdateCheckResultCopyWith<$Res>(_self.lastCheck!, (value) {
    return _then(_self.copyWith(lastCheck: value));
  });
}/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateInstallResultCopyWith<$Res>? get lastInstall {
    if (_self.lastInstall == null) {
    return null;
  }

  return $UpdateInstallResultCopyWith<$Res>(_self.lastInstall!, (value) {
    return _then(_self.copyWith(lastInstall: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApplianceUpdateStatus].
extension ApplianceUpdateStatusPatterns on ApplianceUpdateStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplianceUpdateStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplianceUpdateStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplianceUpdateStatus value)  $default,){
final _that = this;
switch (_that) {
case _ApplianceUpdateStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplianceUpdateStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ApplianceUpdateStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool configured,  UpdateCheckResult? lastCheck,  UpdateInstallResult? lastInstall,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplianceUpdateStatus() when $default != null:
return $default(_that.configured,_that.lastCheck,_that.lastInstall,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool configured,  UpdateCheckResult? lastCheck,  UpdateInstallResult? lastInstall,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _ApplianceUpdateStatus():
return $default(_that.configured,_that.lastCheck,_that.lastInstall,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool configured,  UpdateCheckResult? lastCheck,  UpdateInstallResult? lastInstall,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _ApplianceUpdateStatus() when $default != null:
return $default(_that.configured,_that.lastCheck,_that.lastInstall,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplianceUpdateStatus extends ApplianceUpdateStatus {
  const _ApplianceUpdateStatus({required this.configured, this.lastCheck, this.lastInstall, this.lastError}): super._();
  factory _ApplianceUpdateStatus.fromJson(Map<String, dynamic> json) => _$ApplianceUpdateStatusFromJson(json);

@override final  bool configured;
@override final  UpdateCheckResult? lastCheck;
@override final  UpdateInstallResult? lastInstall;
@override final  String? lastError;

/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplianceUpdateStatusCopyWith<_ApplianceUpdateStatus> get copyWith => __$ApplianceUpdateStatusCopyWithImpl<_ApplianceUpdateStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplianceUpdateStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplianceUpdateStatus&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.lastCheck, lastCheck) || other.lastCheck == lastCheck)&&(identical(other.lastInstall, lastInstall) || other.lastInstall == lastInstall)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,configured,lastCheck,lastInstall,lastError);
}

@override
String toString() {
    return 'ApplianceUpdateStatus(configured: $configured, lastCheck: $lastCheck, lastInstall: $lastInstall, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$ApplianceUpdateStatusCopyWith<$Res> implements $ApplianceUpdateStatusCopyWith<$Res> {
  factory _$ApplianceUpdateStatusCopyWith(_ApplianceUpdateStatus value, $Res Function(_ApplianceUpdateStatus) _then) = __$ApplianceUpdateStatusCopyWithImpl;
@override @useResult
$Res call({
 bool configured, UpdateCheckResult? lastCheck, UpdateInstallResult? lastInstall, String? lastError
});


@override $UpdateCheckResultCopyWith<$Res>? get lastCheck;@override $UpdateInstallResultCopyWith<$Res>? get lastInstall;

}
/// @nodoc
class __$ApplianceUpdateStatusCopyWithImpl<$Res>
    implements _$ApplianceUpdateStatusCopyWith<$Res> {
  __$ApplianceUpdateStatusCopyWithImpl(this._self, this._then);

  final _ApplianceUpdateStatus _self;
  final $Res Function(_ApplianceUpdateStatus) _then;

/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configured = null,Object? lastCheck = freezed,Object? lastInstall = freezed,Object? lastError = freezed,}) {
  return _then(_ApplianceUpdateStatus(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,lastCheck: freezed == lastCheck ? _self.lastCheck : lastCheck // ignore: cast_nullable_to_non_nullable
as UpdateCheckResult?,lastInstall: freezed == lastInstall ? _self.lastInstall : lastInstall // ignore: cast_nullable_to_non_nullable
as UpdateInstallResult?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateCheckResultCopyWith<$Res>? get lastCheck {
    if (_self.lastCheck == null) {
    return null;
  }

  return $UpdateCheckResultCopyWith<$Res>(_self.lastCheck!, (value) {
    return _then(_self.copyWith(lastCheck: value));
  });
}/// Create a copy of ApplianceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpdateInstallResultCopyWith<$Res>? get lastInstall {
    if (_self.lastInstall == null) {
    return null;
  }

  return $UpdateInstallResultCopyWith<$Res>(_self.lastInstall!, (value) {
    return _then(_self.copyWith(lastInstall: value));
  });
}
}


/// @nodoc
mixin _$UpdateCheckResult {

 DateTime get checkedAt; String get channel; bool get updateAvailable; List<ServiceUpdateStatus> get services;
/// Create a copy of UpdateCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCheckResultCopyWith<UpdateCheckResult> get copyWith => _$UpdateCheckResultCopyWithImpl<UpdateCheckResult>(this as UpdateCheckResult, _$identity);

  /// Serializes this UpdateCheckResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateCheckResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCheckResult&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.updateAvailable, _this.updateAvailable) || other.updateAvailable == _this.updateAvailable)&&const DeepCollectionEquality().equals(other.services, _this.services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateCheckResult;
  return Object.hash(runtimeType,_this.checkedAt,_this.channel,_this.updateAvailable,const DeepCollectionEquality().hash(_this.services));
}

@override
String toString() {
  final _this = this as UpdateCheckResult;
  return 'UpdateCheckResult(checkedAt: ${_this.checkedAt}, channel: ${_this.channel}, updateAvailable: ${_this.updateAvailable}, services: ${_this.services})';
}


}

/// @nodoc
abstract mixin class $UpdateCheckResultCopyWith<$Res>  {
  factory $UpdateCheckResultCopyWith(UpdateCheckResult value, $Res Function(UpdateCheckResult) _then) = _$UpdateCheckResultCopyWithImpl;
@useResult
$Res call({
 DateTime checkedAt, String channel, bool updateAvailable, List<ServiceUpdateStatus> services
});




}
/// @nodoc
class _$UpdateCheckResultCopyWithImpl<$Res>
    implements $UpdateCheckResultCopyWith<$Res> {
  _$UpdateCheckResultCopyWithImpl(this._self, this._then);

  final UpdateCheckResult _self;
  final $Res Function(UpdateCheckResult) _then;

/// Create a copy of UpdateCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkedAt = null,Object? channel = null,Object? updateAvailable = null,Object? services = null,}) {
  return _then(UpdateCheckResult(
checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceUpdateStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCheckResult].
extension UpdateCheckResultPatterns on UpdateCheckResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCheckResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCheckResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCheckResult value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCheckResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCheckResult value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCheckResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime checkedAt,  String channel,  bool updateAvailable,  List<ServiceUpdateStatus> services)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCheckResult() when $default != null:
return $default(_that.checkedAt,_that.channel,_that.updateAvailable,_that.services);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime checkedAt,  String channel,  bool updateAvailable,  List<ServiceUpdateStatus> services)  $default,) {final _that = this;
switch (_that) {
case _UpdateCheckResult():
return $default(_that.checkedAt,_that.channel,_that.updateAvailable,_that.services);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime checkedAt,  String channel,  bool updateAvailable,  List<ServiceUpdateStatus> services)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCheckResult() when $default != null:
return $default(_that.checkedAt,_that.channel,_that.updateAvailable,_that.services);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCheckResult implements UpdateCheckResult {
  const _UpdateCheckResult({required this.checkedAt, required this.channel, required this.updateAvailable,  List<ServiceUpdateStatus> services = const <ServiceUpdateStatus>[]}): _services = services;
  factory _UpdateCheckResult.fromJson(Map<String, dynamic> json) => _$UpdateCheckResultFromJson(json);

@override final  DateTime checkedAt;
@override final  String channel;
@override final  bool updateAvailable;
 final  List<ServiceUpdateStatus> _services;
@override@JsonKey() List<ServiceUpdateStatus> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}


/// Create a copy of UpdateCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCheckResultCopyWith<_UpdateCheckResult> get copyWith => __$UpdateCheckResultCopyWithImpl<_UpdateCheckResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCheckResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCheckResult&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.updateAvailable, updateAvailable) || other.updateAvailable == updateAvailable)&&const DeepCollectionEquality().equals(other.services, _services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,checkedAt,channel,updateAvailable,const DeepCollectionEquality().hash(_services));
}

@override
String toString() {
    return 'UpdateCheckResult(checkedAt: $checkedAt, channel: $channel, updateAvailable: $updateAvailable, services: $services)';
}


}

/// @nodoc
abstract mixin class _$UpdateCheckResultCopyWith<$Res> implements $UpdateCheckResultCopyWith<$Res> {
  factory _$UpdateCheckResultCopyWith(_UpdateCheckResult value, $Res Function(_UpdateCheckResult) _then) = __$UpdateCheckResultCopyWithImpl;
@override @useResult
$Res call({
 DateTime checkedAt, String channel, bool updateAvailable, List<ServiceUpdateStatus> services
});




}
/// @nodoc
class __$UpdateCheckResultCopyWithImpl<$Res>
    implements _$UpdateCheckResultCopyWith<$Res> {
  __$UpdateCheckResultCopyWithImpl(this._self, this._then);

  final _UpdateCheckResult _self;
  final $Res Function(_UpdateCheckResult) _then;

/// Create a copy of UpdateCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkedAt = null,Object? channel = null,Object? updateAvailable = null,Object? services = null,}) {
  return _then(_UpdateCheckResult(
checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceUpdateStatus>,
  ));
}


}


/// @nodoc
mixin _$ServiceUpdateStatus {

 String get service; String get channel; bool get updateAvailable; String? get runningImageId; String? get availableImageId; String? get runningVersion; String? get availableVersion;
/// Create a copy of ServiceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceUpdateStatusCopyWith<ServiceUpdateStatus> get copyWith => _$ServiceUpdateStatusCopyWithImpl<ServiceUpdateStatus>(this as ServiceUpdateStatus, _$identity);

  /// Serializes this ServiceUpdateStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceUpdateStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceUpdateStatus&&(identical(other.service, _this.service) || other.service == _this.service)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.updateAvailable, _this.updateAvailable) || other.updateAvailable == _this.updateAvailable)&&(identical(other.runningImageId, _this.runningImageId) || other.runningImageId == _this.runningImageId)&&(identical(other.availableImageId, _this.availableImageId) || other.availableImageId == _this.availableImageId)&&(identical(other.runningVersion, _this.runningVersion) || other.runningVersion == _this.runningVersion)&&(identical(other.availableVersion, _this.availableVersion) || other.availableVersion == _this.availableVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceUpdateStatus;
  return Object.hash(runtimeType,_this.service,_this.channel,_this.updateAvailable,_this.runningImageId,_this.availableImageId,_this.runningVersion,_this.availableVersion);
}

@override
String toString() {
  final _this = this as ServiceUpdateStatus;
  return 'ServiceUpdateStatus(service: ${_this.service}, channel: ${_this.channel}, updateAvailable: ${_this.updateAvailable}, runningImageId: ${_this.runningImageId}, availableImageId: ${_this.availableImageId}, runningVersion: ${_this.runningVersion}, availableVersion: ${_this.availableVersion})';
}


}

/// @nodoc
abstract mixin class $ServiceUpdateStatusCopyWith<$Res>  {
  factory $ServiceUpdateStatusCopyWith(ServiceUpdateStatus value, $Res Function(ServiceUpdateStatus) _then) = _$ServiceUpdateStatusCopyWithImpl;
@useResult
$Res call({
 String service, String channel, bool updateAvailable, String? runningImageId, String? availableImageId, String? runningVersion, String? availableVersion
});




}
/// @nodoc
class _$ServiceUpdateStatusCopyWithImpl<$Res>
    implements $ServiceUpdateStatusCopyWith<$Res> {
  _$ServiceUpdateStatusCopyWithImpl(this._self, this._then);

  final ServiceUpdateStatus _self;
  final $Res Function(ServiceUpdateStatus) _then;

/// Create a copy of ServiceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? service = null,Object? channel = null,Object? updateAvailable = null,Object? runningImageId = freezed,Object? availableImageId = freezed,Object? runningVersion = freezed,Object? availableVersion = freezed,}) {
  return _then(ServiceUpdateStatus(
service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,runningImageId: freezed == runningImageId ? _self.runningImageId : runningImageId // ignore: cast_nullable_to_non_nullable
as String?,availableImageId: freezed == availableImageId ? _self.availableImageId : availableImageId // ignore: cast_nullable_to_non_nullable
as String?,runningVersion: freezed == runningVersion ? _self.runningVersion : runningVersion // ignore: cast_nullable_to_non_nullable
as String?,availableVersion: freezed == availableVersion ? _self.availableVersion : availableVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceUpdateStatus].
extension ServiceUpdateStatusPatterns on ServiceUpdateStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceUpdateStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceUpdateStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceUpdateStatus value)  $default,){
final _that = this;
switch (_that) {
case _ServiceUpdateStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceUpdateStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceUpdateStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String service,  String channel,  bool updateAvailable,  String? runningImageId,  String? availableImageId,  String? runningVersion,  String? availableVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceUpdateStatus() when $default != null:
return $default(_that.service,_that.channel,_that.updateAvailable,_that.runningImageId,_that.availableImageId,_that.runningVersion,_that.availableVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String service,  String channel,  bool updateAvailable,  String? runningImageId,  String? availableImageId,  String? runningVersion,  String? availableVersion)  $default,) {final _that = this;
switch (_that) {
case _ServiceUpdateStatus():
return $default(_that.service,_that.channel,_that.updateAvailable,_that.runningImageId,_that.availableImageId,_that.runningVersion,_that.availableVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String service,  String channel,  bool updateAvailable,  String? runningImageId,  String? availableImageId,  String? runningVersion,  String? availableVersion)?  $default,) {final _that = this;
switch (_that) {
case _ServiceUpdateStatus() when $default != null:
return $default(_that.service,_that.channel,_that.updateAvailable,_that.runningImageId,_that.availableImageId,_that.runningVersion,_that.availableVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceUpdateStatus implements ServiceUpdateStatus {
  const _ServiceUpdateStatus({required this.service, required this.channel, required this.updateAvailable, this.runningImageId, this.availableImageId, this.runningVersion, this.availableVersion});
  factory _ServiceUpdateStatus.fromJson(Map<String, dynamic> json) => _$ServiceUpdateStatusFromJson(json);

@override final  String service;
@override final  String channel;
@override final  bool updateAvailable;
@override final  String? runningImageId;
@override final  String? availableImageId;
@override final  String? runningVersion;
@override final  String? availableVersion;

/// Create a copy of ServiceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceUpdateStatusCopyWith<_ServiceUpdateStatus> get copyWith => __$ServiceUpdateStatusCopyWithImpl<_ServiceUpdateStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceUpdateStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceUpdateStatus&&(identical(other.service, service) || other.service == service)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.updateAvailable, updateAvailable) || other.updateAvailable == updateAvailable)&&(identical(other.runningImageId, runningImageId) || other.runningImageId == runningImageId)&&(identical(other.availableImageId, availableImageId) || other.availableImageId == availableImageId)&&(identical(other.runningVersion, runningVersion) || other.runningVersion == runningVersion)&&(identical(other.availableVersion, availableVersion) || other.availableVersion == availableVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,service,channel,updateAvailable,runningImageId,availableImageId,runningVersion,availableVersion);
}

@override
String toString() {
    return 'ServiceUpdateStatus(service: $service, channel: $channel, updateAvailable: $updateAvailable, runningImageId: $runningImageId, availableImageId: $availableImageId, runningVersion: $runningVersion, availableVersion: $availableVersion)';
}


}

/// @nodoc
abstract mixin class _$ServiceUpdateStatusCopyWith<$Res> implements $ServiceUpdateStatusCopyWith<$Res> {
  factory _$ServiceUpdateStatusCopyWith(_ServiceUpdateStatus value, $Res Function(_ServiceUpdateStatus) _then) = __$ServiceUpdateStatusCopyWithImpl;
@override @useResult
$Res call({
 String service, String channel, bool updateAvailable, String? runningImageId, String? availableImageId, String? runningVersion, String? availableVersion
});




}
/// @nodoc
class __$ServiceUpdateStatusCopyWithImpl<$Res>
    implements _$ServiceUpdateStatusCopyWith<$Res> {
  __$ServiceUpdateStatusCopyWithImpl(this._self, this._then);

  final _ServiceUpdateStatus _self;
  final $Res Function(_ServiceUpdateStatus) _then;

/// Create a copy of ServiceUpdateStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? service = null,Object? channel = null,Object? updateAvailable = null,Object? runningImageId = freezed,Object? availableImageId = freezed,Object? runningVersion = freezed,Object? availableVersion = freezed,}) {
  return _then(_ServiceUpdateStatus(
service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,updateAvailable: null == updateAvailable ? _self.updateAvailable : updateAvailable // ignore: cast_nullable_to_non_nullable
as bool,runningImageId: freezed == runningImageId ? _self.runningImageId : runningImageId // ignore: cast_nullable_to_non_nullable
as String?,availableImageId: freezed == availableImageId ? _self.availableImageId : availableImageId // ignore: cast_nullable_to_non_nullable
as String?,runningVersion: freezed == runningVersion ? _self.runningVersion : runningVersion // ignore: cast_nullable_to_non_nullable
as String?,availableVersion: freezed == availableVersion ? _self.availableVersion : availableVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateInstallResult {

 DateTime get startedAt; DateTime get finishedAt; String get channel; List<String> get services;
/// Create a copy of UpdateInstallResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInstallResultCopyWith<UpdateInstallResult> get copyWith => _$UpdateInstallResultCopyWithImpl<UpdateInstallResult>(this as UpdateInstallResult, _$identity);

  /// Serializes this UpdateInstallResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateInstallResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInstallResult&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&const DeepCollectionEquality().equals(other.services, _this.services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateInstallResult;
  return Object.hash(runtimeType,_this.startedAt,_this.finishedAt,_this.channel,const DeepCollectionEquality().hash(_this.services));
}

@override
String toString() {
  final _this = this as UpdateInstallResult;
  return 'UpdateInstallResult(startedAt: ${_this.startedAt}, finishedAt: ${_this.finishedAt}, channel: ${_this.channel}, services: ${_this.services})';
}


}

/// @nodoc
abstract mixin class $UpdateInstallResultCopyWith<$Res>  {
  factory $UpdateInstallResultCopyWith(UpdateInstallResult value, $Res Function(UpdateInstallResult) _then) = _$UpdateInstallResultCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt, DateTime finishedAt, String channel, List<String> services
});




}
/// @nodoc
class _$UpdateInstallResultCopyWithImpl<$Res>
    implements $UpdateInstallResultCopyWith<$Res> {
  _$UpdateInstallResultCopyWithImpl(this._self, this._then);

  final UpdateInstallResult _self;
  final $Res Function(UpdateInstallResult) _then;

/// Create a copy of UpdateInstallResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startedAt = null,Object? finishedAt = null,Object? channel = null,Object? services = null,}) {
  return _then(UpdateInstallResult(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateInstallResult].
extension UpdateInstallResultPatterns on UpdateInstallResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateInstallResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateInstallResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateInstallResult value)  $default,){
final _that = this;
switch (_that) {
case _UpdateInstallResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateInstallResult value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateInstallResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startedAt,  DateTime finishedAt,  String channel,  List<String> services)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateInstallResult() when $default != null:
return $default(_that.startedAt,_that.finishedAt,_that.channel,_that.services);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startedAt,  DateTime finishedAt,  String channel,  List<String> services)  $default,) {final _that = this;
switch (_that) {
case _UpdateInstallResult():
return $default(_that.startedAt,_that.finishedAt,_that.channel,_that.services);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startedAt,  DateTime finishedAt,  String channel,  List<String> services)?  $default,) {final _that = this;
switch (_that) {
case _UpdateInstallResult() when $default != null:
return $default(_that.startedAt,_that.finishedAt,_that.channel,_that.services);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateInstallResult implements UpdateInstallResult {
  const _UpdateInstallResult({required this.startedAt, required this.finishedAt, required this.channel,  List<String> services = const <String>[]}): _services = services;
  factory _UpdateInstallResult.fromJson(Map<String, dynamic> json) => _$UpdateInstallResultFromJson(json);

@override final  DateTime startedAt;
@override final  DateTime finishedAt;
@override final  String channel;
 final  List<String> _services;
@override@JsonKey() List<String> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}


/// Create a copy of UpdateInstallResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateInstallResultCopyWith<_UpdateInstallResult> get copyWith => __$UpdateInstallResultCopyWithImpl<_UpdateInstallResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateInstallResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateInstallResult&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.channel, channel) || other.channel == channel)&&const DeepCollectionEquality().equals(other.services, _services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,startedAt,finishedAt,channel,const DeepCollectionEquality().hash(_services));
}

@override
String toString() {
    return 'UpdateInstallResult(startedAt: $startedAt, finishedAt: $finishedAt, channel: $channel, services: $services)';
}


}

/// @nodoc
abstract mixin class _$UpdateInstallResultCopyWith<$Res> implements $UpdateInstallResultCopyWith<$Res> {
  factory _$UpdateInstallResultCopyWith(_UpdateInstallResult value, $Res Function(_UpdateInstallResult) _then) = __$UpdateInstallResultCopyWithImpl;
@override @useResult
$Res call({
 DateTime startedAt, DateTime finishedAt, String channel, List<String> services
});




}
/// @nodoc
class __$UpdateInstallResultCopyWithImpl<$Res>
    implements _$UpdateInstallResultCopyWith<$Res> {
  __$UpdateInstallResultCopyWithImpl(this._self, this._then);

  final _UpdateInstallResult _self;
  final $Res Function(_UpdateInstallResult) _then;

/// Create a copy of UpdateInstallResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startedAt = null,Object? finishedAt = null,Object? channel = null,Object? services = null,}) {
  return _then(_UpdateInstallResult(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
