// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entity_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntityValue {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntityValue()';
}


}

/// @nodoc
class $EntityValueCopyWith<$Res>  {
$EntityValueCopyWith(EntityValue _, $Res Function(EntityValue) __);
}


/// Adds pattern-matching-related methods to [EntityValue].
extension EntityValuePatterns on EntityValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EntityValueNone value)?  none,TResult Function( EntityValueBoolean value)?  boolean,TResult Function( EntityValueNumber value)?  number,TResult Function( EntityValueText value)?  text,TResult Function( EntityValueStructured value)?  structured,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EntityValueNone() when none != null:
return none(_that);case EntityValueBoolean() when boolean != null:
return boolean(_that);case EntityValueNumber() when number != null:
return number(_that);case EntityValueText() when text != null:
return text(_that);case EntityValueStructured() when structured != null:
return structured(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EntityValueNone value)  none,required TResult Function( EntityValueBoolean value)  boolean,required TResult Function( EntityValueNumber value)  number,required TResult Function( EntityValueText value)  text,required TResult Function( EntityValueStructured value)  structured,}){
final _that = this;
switch (_that) {
case EntityValueNone():
return none(_that);case EntityValueBoolean():
return boolean(_that);case EntityValueNumber():
return number(_that);case EntityValueText():
return text(_that);case EntityValueStructured():
return structured(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EntityValueNone value)?  none,TResult? Function( EntityValueBoolean value)?  boolean,TResult? Function( EntityValueNumber value)?  number,TResult? Function( EntityValueText value)?  text,TResult? Function( EntityValueStructured value)?  structured,}){
final _that = this;
switch (_that) {
case EntityValueNone() when none != null:
return none(_that);case EntityValueBoolean() when boolean != null:
return boolean(_that);case EntityValueNumber() when number != null:
return number(_that);case EntityValueText() when text != null:
return text(_that);case EntityValueStructured() when structured != null:
return structured(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( bool value)?  boolean,TResult Function( num value)?  number,TResult Function( String value)?  text,TResult Function( Object value)?  structured,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EntityValueNone() when none != null:
return none();case EntityValueBoolean() when boolean != null:
return boolean(_that.value);case EntityValueNumber() when number != null:
return number(_that.value);case EntityValueText() when text != null:
return text(_that.value);case EntityValueStructured() when structured != null:
return structured(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( bool value)  boolean,required TResult Function( num value)  number,required TResult Function( String value)  text,required TResult Function( Object value)  structured,}) {final _that = this;
switch (_that) {
case EntityValueNone():
return none();case EntityValueBoolean():
return boolean(_that.value);case EntityValueNumber():
return number(_that.value);case EntityValueText():
return text(_that.value);case EntityValueStructured():
return structured(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( bool value)?  boolean,TResult? Function( num value)?  number,TResult? Function( String value)?  text,TResult? Function( Object value)?  structured,}) {final _that = this;
switch (_that) {
case EntityValueNone() when none != null:
return none();case EntityValueBoolean() when boolean != null:
return boolean(_that.value);case EntityValueNumber() when number != null:
return number(_that.value);case EntityValueText() when text != null:
return text(_that.value);case EntityValueStructured() when structured != null:
return structured(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class EntityValueNone extends EntityValue {
  const EntityValueNone(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValueNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntityValue.none()';
}


}




/// @nodoc


class EntityValueBoolean extends EntityValue {
  const EntityValueBoolean(this.value): super._();
  

 final  bool value;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityValueBooleanCopyWith<EntityValueBoolean> get copyWith => _$EntityValueBooleanCopyWithImpl<EntityValueBoolean>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValueBoolean&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value);
}

@override
String toString() {
    return 'EntityValue.boolean(value: $value)';
}


}

/// @nodoc
abstract mixin class $EntityValueBooleanCopyWith<$Res> implements $EntityValueCopyWith<$Res> {
  factory $EntityValueBooleanCopyWith(EntityValueBoolean value, $Res Function(EntityValueBoolean) _then) = _$EntityValueBooleanCopyWithImpl;
@useResult
$Res call({
 bool value
});




}
/// @nodoc
class _$EntityValueBooleanCopyWithImpl<$Res>
    implements $EntityValueBooleanCopyWith<$Res> {
  _$EntityValueBooleanCopyWithImpl(this._self, this._then);

  final EntityValueBoolean _self;
  final $Res Function(EntityValueBoolean) _then;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(EntityValueBoolean(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class EntityValueNumber extends EntityValue {
  const EntityValueNumber(this.value): super._();
  

 final  num value;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityValueNumberCopyWith<EntityValueNumber> get copyWith => _$EntityValueNumberCopyWithImpl<EntityValueNumber>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValueNumber&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value);
}

@override
String toString() {
    return 'EntityValue.number(value: $value)';
}


}

/// @nodoc
abstract mixin class $EntityValueNumberCopyWith<$Res> implements $EntityValueCopyWith<$Res> {
  factory $EntityValueNumberCopyWith(EntityValueNumber value, $Res Function(EntityValueNumber) _then) = _$EntityValueNumberCopyWithImpl;
@useResult
$Res call({
 num value
});




}
/// @nodoc
class _$EntityValueNumberCopyWithImpl<$Res>
    implements $EntityValueNumberCopyWith<$Res> {
  _$EntityValueNumberCopyWithImpl(this._self, this._then);

  final EntityValueNumber _self;
  final $Res Function(EntityValueNumber) _then;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(EntityValueNumber(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

/// @nodoc


class EntityValueText extends EntityValue {
  const EntityValueText(this.value): super._();
  

 final  String value;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityValueTextCopyWith<EntityValueText> get copyWith => _$EntityValueTextCopyWithImpl<EntityValueText>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValueText&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value);
}

@override
String toString() {
    return 'EntityValue.text(value: $value)';
}


}

/// @nodoc
abstract mixin class $EntityValueTextCopyWith<$Res> implements $EntityValueCopyWith<$Res> {
  factory $EntityValueTextCopyWith(EntityValueText value, $Res Function(EntityValueText) _then) = _$EntityValueTextCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$EntityValueTextCopyWithImpl<$Res>
    implements $EntityValueTextCopyWith<$Res> {
  _$EntityValueTextCopyWithImpl(this._self, this._then);

  final EntityValueText _self;
  final $Res Function(EntityValueText) _then;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(EntityValueText(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class EntityValueStructured extends EntityValue {
  const EntityValueStructured(this.value): super._();
  

 final  Object value;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityValueStructuredCopyWith<EntityValueStructured> get copyWith => _$EntityValueStructuredCopyWithImpl<EntityValueStructured>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityValueStructured&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(value));
}

@override
String toString() {
    return 'EntityValue.structured(value: $value)';
}


}

/// @nodoc
abstract mixin class $EntityValueStructuredCopyWith<$Res> implements $EntityValueCopyWith<$Res> {
  factory $EntityValueStructuredCopyWith(EntityValueStructured value, $Res Function(EntityValueStructured) _then) = _$EntityValueStructuredCopyWithImpl;
@useResult
$Res call({
 Object value
});




}
/// @nodoc
class _$EntityValueStructuredCopyWithImpl<$Res>
    implements $EntityValueStructuredCopyWith<$Res> {
  _$EntityValueStructuredCopyWithImpl(this._self, this._then);

  final EntityValueStructured _self;
  final $Res Function(EntityValueStructured) _then;

/// Create a copy of EntityValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(EntityValueStructured(
null == value ? _self.value : value ,
  ));
}


}

// dart format on
