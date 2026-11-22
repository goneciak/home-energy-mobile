// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherEnvelope<T> {

 T get data; DateTime get fetchedAt; bool get stale; String? get lastError;
/// Create a copy of WeatherEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherEnvelopeCopyWith<T, WeatherEnvelope<T>> get copyWith => _$WeatherEnvelopeCopyWithImpl<T, WeatherEnvelope<T>>(this as WeatherEnvelope<T>, _$identity);

  /// Serializes this WeatherEnvelope to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  final _this = this as WeatherEnvelope<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherEnvelope<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WeatherEnvelope<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.fetchedAt,_this.stale,_this.lastError);
}

@override
String toString() {
  final _this = this as WeatherEnvelope<T>;
  return 'WeatherEnvelope<$T>(data: ${_this.data}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $WeatherEnvelopeCopyWith<T,$Res>  {
  factory $WeatherEnvelopeCopyWith(WeatherEnvelope<T> value, $Res Function(WeatherEnvelope<T>) _then) = _$WeatherEnvelopeCopyWithImpl;
@useResult
$Res call({
 T data, DateTime fetchedAt, bool stale, String? lastError
});




}
/// @nodoc
class _$WeatherEnvelopeCopyWithImpl<T,$Res>
    implements $WeatherEnvelopeCopyWith<T, $Res> {
  _$WeatherEnvelopeCopyWithImpl(this._self, this._then);

  final WeatherEnvelope<T> _self;
  final $Res Function(WeatherEnvelope<T>) _then;

/// Create a copy of WeatherEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? fetchedAt = null,Object? stale = null,Object? lastError = freezed,}) {
  return _then(WeatherEnvelope(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherEnvelope].
extension WeatherEnvelopePatterns<T> on WeatherEnvelope<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherEnvelope<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherEnvelope<T> value)  $default,){
final _that = this;
switch (_that) {
case _WeatherEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherEnvelope<T> value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T data,  DateTime fetchedAt,  bool stale,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherEnvelope() when $default != null:
return $default(_that.data,_that.fetchedAt,_that.stale,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T data,  DateTime fetchedAt,  bool stale,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _WeatherEnvelope():
return $default(_that.data,_that.fetchedAt,_that.stale,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T data,  DateTime fetchedAt,  bool stale,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _WeatherEnvelope() when $default != null:
return $default(_that.data,_that.fetchedAt,_that.stale,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _WeatherEnvelope<T> implements WeatherEnvelope<T> {
  const _WeatherEnvelope({required this.data, required this.fetchedAt, this.stale = false, this.lastError});
  factory _WeatherEnvelope.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$WeatherEnvelopeFromJson(json,fromJsonT);

@override final  T data;
@override final  DateTime fetchedAt;
@override@JsonKey() final  bool stale;
@override final  String? lastError;

/// Create a copy of WeatherEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherEnvelopeCopyWith<T, _WeatherEnvelope<T>> get copyWith => __$WeatherEnvelopeCopyWithImpl<T, _WeatherEnvelope<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$WeatherEnvelopeToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherEnvelope<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),fetchedAt,stale,lastError);
}

@override
String toString() {
    return 'WeatherEnvelope<$T>(data: $data, fetchedAt: $fetchedAt, stale: $stale, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$WeatherEnvelopeCopyWith<T,$Res> implements $WeatherEnvelopeCopyWith<T, $Res> {
  factory _$WeatherEnvelopeCopyWith(_WeatherEnvelope<T> value, $Res Function(_WeatherEnvelope<T>) _then) = __$WeatherEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 T data, DateTime fetchedAt, bool stale, String? lastError
});




}
/// @nodoc
class __$WeatherEnvelopeCopyWithImpl<T,$Res>
    implements _$WeatherEnvelopeCopyWith<T, $Res> {
  __$WeatherEnvelopeCopyWithImpl(this._self, this._then);

  final _WeatherEnvelope<T> _self;
  final $Res Function(_WeatherEnvelope<T>) _then;

/// Create a copy of WeatherEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? fetchedAt = null,Object? stale = null,Object? lastError = freezed,}) {
  return _then(_WeatherEnvelope<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CurrentWeather {

 DateTime? get observedAt; double? get temperatureC; double? get apparentTemperatureC; double? get relativeHumidityPercent; double? get pressureHpa; double? get windSpeedMps; double? get windDirectionDegrees; double? get windGustMps; double? get cloudCoveragePercent; String? get symbolCode; double? get precipitationMm;
/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentWeatherCopyWith<CurrentWeather> get copyWith => _$CurrentWeatherCopyWithImpl<CurrentWeather>(this as CurrentWeather, _$identity);

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrentWeather;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentWeather&&(identical(other.observedAt, _this.observedAt) || other.observedAt == _this.observedAt)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.apparentTemperatureC, _this.apparentTemperatureC) || other.apparentTemperatureC == _this.apparentTemperatureC)&&(identical(other.relativeHumidityPercent, _this.relativeHumidityPercent) || other.relativeHumidityPercent == _this.relativeHumidityPercent)&&(identical(other.pressureHpa, _this.pressureHpa) || other.pressureHpa == _this.pressureHpa)&&(identical(other.windSpeedMps, _this.windSpeedMps) || other.windSpeedMps == _this.windSpeedMps)&&(identical(other.windDirectionDegrees, _this.windDirectionDegrees) || other.windDirectionDegrees == _this.windDirectionDegrees)&&(identical(other.windGustMps, _this.windGustMps) || other.windGustMps == _this.windGustMps)&&(identical(other.cloudCoveragePercent, _this.cloudCoveragePercent) || other.cloudCoveragePercent == _this.cloudCoveragePercent)&&(identical(other.symbolCode, _this.symbolCode) || other.symbolCode == _this.symbolCode)&&(identical(other.precipitationMm, _this.precipitationMm) || other.precipitationMm == _this.precipitationMm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrentWeather;
  return Object.hash(runtimeType,_this.observedAt,_this.temperatureC,_this.apparentTemperatureC,_this.relativeHumidityPercent,_this.pressureHpa,_this.windSpeedMps,_this.windDirectionDegrees,_this.windGustMps,_this.cloudCoveragePercent,_this.symbolCode,_this.precipitationMm);
}

@override
String toString() {
  final _this = this as CurrentWeather;
  return 'CurrentWeather(observedAt: ${_this.observedAt}, temperatureC: ${_this.temperatureC}, apparentTemperatureC: ${_this.apparentTemperatureC}, relativeHumidityPercent: ${_this.relativeHumidityPercent}, pressureHpa: ${_this.pressureHpa}, windSpeedMps: ${_this.windSpeedMps}, windDirectionDegrees: ${_this.windDirectionDegrees}, windGustMps: ${_this.windGustMps}, cloudCoveragePercent: ${_this.cloudCoveragePercent}, symbolCode: ${_this.symbolCode}, precipitationMm: ${_this.precipitationMm})';
}


}

/// @nodoc
abstract mixin class $CurrentWeatherCopyWith<$Res>  {
  factory $CurrentWeatherCopyWith(CurrentWeather value, $Res Function(CurrentWeather) _then) = _$CurrentWeatherCopyWithImpl;
@useResult
$Res call({
 DateTime? observedAt, double? temperatureC, double? apparentTemperatureC, double? relativeHumidityPercent, double? pressureHpa, double? windSpeedMps, double? windDirectionDegrees, double? windGustMps, double? cloudCoveragePercent, String? symbolCode, double? precipitationMm
});




}
/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._self, this._then);

  final CurrentWeather _self;
  final $Res Function(CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? observedAt = freezed,Object? temperatureC = freezed,Object? apparentTemperatureC = freezed,Object? relativeHumidityPercent = freezed,Object? pressureHpa = freezed,Object? windSpeedMps = freezed,Object? windDirectionDegrees = freezed,Object? windGustMps = freezed,Object? cloudCoveragePercent = freezed,Object? symbolCode = freezed,Object? precipitationMm = freezed,}) {
  return _then(CurrentWeather(
observedAt: freezed == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,apparentTemperatureC: freezed == apparentTemperatureC ? _self.apparentTemperatureC : apparentTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,relativeHumidityPercent: freezed == relativeHumidityPercent ? _self.relativeHumidityPercent : relativeHumidityPercent // ignore: cast_nullable_to_non_nullable
as double?,pressureHpa: freezed == pressureHpa ? _self.pressureHpa : pressureHpa // ignore: cast_nullable_to_non_nullable
as double?,windSpeedMps: freezed == windSpeedMps ? _self.windSpeedMps : windSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,windDirectionDegrees: freezed == windDirectionDegrees ? _self.windDirectionDegrees : windDirectionDegrees // ignore: cast_nullable_to_non_nullable
as double?,windGustMps: freezed == windGustMps ? _self.windGustMps : windGustMps // ignore: cast_nullable_to_non_nullable
as double?,cloudCoveragePercent: freezed == cloudCoveragePercent ? _self.cloudCoveragePercent : cloudCoveragePercent // ignore: cast_nullable_to_non_nullable
as double?,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentWeather].
extension CurrentWeatherPatterns on CurrentWeather {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentWeather value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentWeather value)  $default,){
final _that = this;
switch (_that) {
case _CurrentWeather():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentWeather value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? observedAt,  double? temperatureC,  double? apparentTemperatureC,  double? relativeHumidityPercent,  double? pressureHpa,  double? windSpeedMps,  double? windDirectionDegrees,  double? windGustMps,  double? cloudCoveragePercent,  String? symbolCode,  double? precipitationMm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
return $default(_that.observedAt,_that.temperatureC,_that.apparentTemperatureC,_that.relativeHumidityPercent,_that.pressureHpa,_that.windSpeedMps,_that.windDirectionDegrees,_that.windGustMps,_that.cloudCoveragePercent,_that.symbolCode,_that.precipitationMm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? observedAt,  double? temperatureC,  double? apparentTemperatureC,  double? relativeHumidityPercent,  double? pressureHpa,  double? windSpeedMps,  double? windDirectionDegrees,  double? windGustMps,  double? cloudCoveragePercent,  String? symbolCode,  double? precipitationMm)  $default,) {final _that = this;
switch (_that) {
case _CurrentWeather():
return $default(_that.observedAt,_that.temperatureC,_that.apparentTemperatureC,_that.relativeHumidityPercent,_that.pressureHpa,_that.windSpeedMps,_that.windDirectionDegrees,_that.windGustMps,_that.cloudCoveragePercent,_that.symbolCode,_that.precipitationMm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? observedAt,  double? temperatureC,  double? apparentTemperatureC,  double? relativeHumidityPercent,  double? pressureHpa,  double? windSpeedMps,  double? windDirectionDegrees,  double? windGustMps,  double? cloudCoveragePercent,  String? symbolCode,  double? precipitationMm)?  $default,) {final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
return $default(_that.observedAt,_that.temperatureC,_that.apparentTemperatureC,_that.relativeHumidityPercent,_that.pressureHpa,_that.windSpeedMps,_that.windDirectionDegrees,_that.windGustMps,_that.cloudCoveragePercent,_that.symbolCode,_that.precipitationMm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentWeather implements CurrentWeather {
  const _CurrentWeather({this.observedAt, this.temperatureC, this.apparentTemperatureC, this.relativeHumidityPercent, this.pressureHpa, this.windSpeedMps, this.windDirectionDegrees, this.windGustMps, this.cloudCoveragePercent, this.symbolCode, this.precipitationMm});
  factory _CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);

@override final  DateTime? observedAt;
@override final  double? temperatureC;
@override final  double? apparentTemperatureC;
@override final  double? relativeHumidityPercent;
@override final  double? pressureHpa;
@override final  double? windSpeedMps;
@override final  double? windDirectionDegrees;
@override final  double? windGustMps;
@override final  double? cloudCoveragePercent;
@override final  String? symbolCode;
@override final  double? precipitationMm;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentWeatherCopyWith<_CurrentWeather> get copyWith => __$CurrentWeatherCopyWithImpl<_CurrentWeather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentWeatherToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentWeather&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.apparentTemperatureC, apparentTemperatureC) || other.apparentTemperatureC == apparentTemperatureC)&&(identical(other.relativeHumidityPercent, relativeHumidityPercent) || other.relativeHumidityPercent == relativeHumidityPercent)&&(identical(other.pressureHpa, pressureHpa) || other.pressureHpa == pressureHpa)&&(identical(other.windSpeedMps, windSpeedMps) || other.windSpeedMps == windSpeedMps)&&(identical(other.windDirectionDegrees, windDirectionDegrees) || other.windDirectionDegrees == windDirectionDegrees)&&(identical(other.windGustMps, windGustMps) || other.windGustMps == windGustMps)&&(identical(other.cloudCoveragePercent, cloudCoveragePercent) || other.cloudCoveragePercent == cloudCoveragePercent)&&(identical(other.symbolCode, symbolCode) || other.symbolCode == symbolCode)&&(identical(other.precipitationMm, precipitationMm) || other.precipitationMm == precipitationMm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,observedAt,temperatureC,apparentTemperatureC,relativeHumidityPercent,pressureHpa,windSpeedMps,windDirectionDegrees,windGustMps,cloudCoveragePercent,symbolCode,precipitationMm);
}

@override
String toString() {
    return 'CurrentWeather(observedAt: $observedAt, temperatureC: $temperatureC, apparentTemperatureC: $apparentTemperatureC, relativeHumidityPercent: $relativeHumidityPercent, pressureHpa: $pressureHpa, windSpeedMps: $windSpeedMps, windDirectionDegrees: $windDirectionDegrees, windGustMps: $windGustMps, cloudCoveragePercent: $cloudCoveragePercent, symbolCode: $symbolCode, precipitationMm: $precipitationMm)';
}


}

/// @nodoc
abstract mixin class _$CurrentWeatherCopyWith<$Res> implements $CurrentWeatherCopyWith<$Res> {
  factory _$CurrentWeatherCopyWith(_CurrentWeather value, $Res Function(_CurrentWeather) _then) = __$CurrentWeatherCopyWithImpl;
@override @useResult
$Res call({
 DateTime? observedAt, double? temperatureC, double? apparentTemperatureC, double? relativeHumidityPercent, double? pressureHpa, double? windSpeedMps, double? windDirectionDegrees, double? windGustMps, double? cloudCoveragePercent, String? symbolCode, double? precipitationMm
});




}
/// @nodoc
class __$CurrentWeatherCopyWithImpl<$Res>
    implements _$CurrentWeatherCopyWith<$Res> {
  __$CurrentWeatherCopyWithImpl(this._self, this._then);

  final _CurrentWeather _self;
  final $Res Function(_CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? observedAt = freezed,Object? temperatureC = freezed,Object? apparentTemperatureC = freezed,Object? relativeHumidityPercent = freezed,Object? pressureHpa = freezed,Object? windSpeedMps = freezed,Object? windDirectionDegrees = freezed,Object? windGustMps = freezed,Object? cloudCoveragePercent = freezed,Object? symbolCode = freezed,Object? precipitationMm = freezed,}) {
  return _then(_CurrentWeather(
observedAt: freezed == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,apparentTemperatureC: freezed == apparentTemperatureC ? _self.apparentTemperatureC : apparentTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,relativeHumidityPercent: freezed == relativeHumidityPercent ? _self.relativeHumidityPercent : relativeHumidityPercent // ignore: cast_nullable_to_non_nullable
as double?,pressureHpa: freezed == pressureHpa ? _self.pressureHpa : pressureHpa // ignore: cast_nullable_to_non_nullable
as double?,windSpeedMps: freezed == windSpeedMps ? _self.windSpeedMps : windSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,windDirectionDegrees: freezed == windDirectionDegrees ? _self.windDirectionDegrees : windDirectionDegrees // ignore: cast_nullable_to_non_nullable
as double?,windGustMps: freezed == windGustMps ? _self.windGustMps : windGustMps // ignore: cast_nullable_to_non_nullable
as double?,cloudCoveragePercent: freezed == cloudCoveragePercent ? _self.cloudCoveragePercent : cloudCoveragePercent // ignore: cast_nullable_to_non_nullable
as double?,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HourlyWeather {

 DateTime get time; double? get temperatureC; double? get precipitationMm; double? get precipitationProbabilityPercent; double? get windSpeedMps; double? get cloudCoveragePercent; String? get symbolCode;
/// Create a copy of HourlyWeather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HourlyWeatherCopyWith<HourlyWeather> get copyWith => _$HourlyWeatherCopyWithImpl<HourlyWeather>(this as HourlyWeather, _$identity);

  /// Serializes this HourlyWeather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HourlyWeather;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HourlyWeather&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.precipitationMm, _this.precipitationMm) || other.precipitationMm == _this.precipitationMm)&&(identical(other.precipitationProbabilityPercent, _this.precipitationProbabilityPercent) || other.precipitationProbabilityPercent == _this.precipitationProbabilityPercent)&&(identical(other.windSpeedMps, _this.windSpeedMps) || other.windSpeedMps == _this.windSpeedMps)&&(identical(other.cloudCoveragePercent, _this.cloudCoveragePercent) || other.cloudCoveragePercent == _this.cloudCoveragePercent)&&(identical(other.symbolCode, _this.symbolCode) || other.symbolCode == _this.symbolCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HourlyWeather;
  return Object.hash(runtimeType,_this.time,_this.temperatureC,_this.precipitationMm,_this.precipitationProbabilityPercent,_this.windSpeedMps,_this.cloudCoveragePercent,_this.symbolCode);
}

@override
String toString() {
  final _this = this as HourlyWeather;
  return 'HourlyWeather(time: ${_this.time}, temperatureC: ${_this.temperatureC}, precipitationMm: ${_this.precipitationMm}, precipitationProbabilityPercent: ${_this.precipitationProbabilityPercent}, windSpeedMps: ${_this.windSpeedMps}, cloudCoveragePercent: ${_this.cloudCoveragePercent}, symbolCode: ${_this.symbolCode})';
}


}

/// @nodoc
abstract mixin class $HourlyWeatherCopyWith<$Res>  {
  factory $HourlyWeatherCopyWith(HourlyWeather value, $Res Function(HourlyWeather) _then) = _$HourlyWeatherCopyWithImpl;
@useResult
$Res call({
 DateTime time, double? temperatureC, double? precipitationMm, double? precipitationProbabilityPercent, double? windSpeedMps, double? cloudCoveragePercent, String? symbolCode
});




}
/// @nodoc
class _$HourlyWeatherCopyWithImpl<$Res>
    implements $HourlyWeatherCopyWith<$Res> {
  _$HourlyWeatherCopyWithImpl(this._self, this._then);

  final HourlyWeather _self;
  final $Res Function(HourlyWeather) _then;

/// Create a copy of HourlyWeather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? temperatureC = freezed,Object? precipitationMm = freezed,Object? precipitationProbabilityPercent = freezed,Object? windSpeedMps = freezed,Object? cloudCoveragePercent = freezed,Object? symbolCode = freezed,}) {
  return _then(HourlyWeather(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,precipitationProbabilityPercent: freezed == precipitationProbabilityPercent ? _self.precipitationProbabilityPercent : precipitationProbabilityPercent // ignore: cast_nullable_to_non_nullable
as double?,windSpeedMps: freezed == windSpeedMps ? _self.windSpeedMps : windSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,cloudCoveragePercent: freezed == cloudCoveragePercent ? _self.cloudCoveragePercent : cloudCoveragePercent // ignore: cast_nullable_to_non_nullable
as double?,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HourlyWeather].
extension HourlyWeatherPatterns on HourlyWeather {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HourlyWeather value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HourlyWeather() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HourlyWeather value)  $default,){
final _that = this;
switch (_that) {
case _HourlyWeather():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HourlyWeather value)?  $default,){
final _that = this;
switch (_that) {
case _HourlyWeather() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime time,  double? temperatureC,  double? precipitationMm,  double? precipitationProbabilityPercent,  double? windSpeedMps,  double? cloudCoveragePercent,  String? symbolCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HourlyWeather() when $default != null:
return $default(_that.time,_that.temperatureC,_that.precipitationMm,_that.precipitationProbabilityPercent,_that.windSpeedMps,_that.cloudCoveragePercent,_that.symbolCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime time,  double? temperatureC,  double? precipitationMm,  double? precipitationProbabilityPercent,  double? windSpeedMps,  double? cloudCoveragePercent,  String? symbolCode)  $default,) {final _that = this;
switch (_that) {
case _HourlyWeather():
return $default(_that.time,_that.temperatureC,_that.precipitationMm,_that.precipitationProbabilityPercent,_that.windSpeedMps,_that.cloudCoveragePercent,_that.symbolCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime time,  double? temperatureC,  double? precipitationMm,  double? precipitationProbabilityPercent,  double? windSpeedMps,  double? cloudCoveragePercent,  String? symbolCode)?  $default,) {final _that = this;
switch (_that) {
case _HourlyWeather() when $default != null:
return $default(_that.time,_that.temperatureC,_that.precipitationMm,_that.precipitationProbabilityPercent,_that.windSpeedMps,_that.cloudCoveragePercent,_that.symbolCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HourlyWeather implements HourlyWeather {
  const _HourlyWeather({required this.time, this.temperatureC, this.precipitationMm, this.precipitationProbabilityPercent, this.windSpeedMps, this.cloudCoveragePercent, this.symbolCode});
  factory _HourlyWeather.fromJson(Map<String, dynamic> json) => _$HourlyWeatherFromJson(json);

@override final  DateTime time;
@override final  double? temperatureC;
@override final  double? precipitationMm;
@override final  double? precipitationProbabilityPercent;
@override final  double? windSpeedMps;
@override final  double? cloudCoveragePercent;
@override final  String? symbolCode;

/// Create a copy of HourlyWeather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HourlyWeatherCopyWith<_HourlyWeather> get copyWith => __$HourlyWeatherCopyWithImpl<_HourlyWeather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HourlyWeatherToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HourlyWeather&&(identical(other.time, time) || other.time == time)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.precipitationMm, precipitationMm) || other.precipitationMm == precipitationMm)&&(identical(other.precipitationProbabilityPercent, precipitationProbabilityPercent) || other.precipitationProbabilityPercent == precipitationProbabilityPercent)&&(identical(other.windSpeedMps, windSpeedMps) || other.windSpeedMps == windSpeedMps)&&(identical(other.cloudCoveragePercent, cloudCoveragePercent) || other.cloudCoveragePercent == cloudCoveragePercent)&&(identical(other.symbolCode, symbolCode) || other.symbolCode == symbolCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,temperatureC,precipitationMm,precipitationProbabilityPercent,windSpeedMps,cloudCoveragePercent,symbolCode);
}

@override
String toString() {
    return 'HourlyWeather(time: $time, temperatureC: $temperatureC, precipitationMm: $precipitationMm, precipitationProbabilityPercent: $precipitationProbabilityPercent, windSpeedMps: $windSpeedMps, cloudCoveragePercent: $cloudCoveragePercent, symbolCode: $symbolCode)';
}


}

/// @nodoc
abstract mixin class _$HourlyWeatherCopyWith<$Res> implements $HourlyWeatherCopyWith<$Res> {
  factory _$HourlyWeatherCopyWith(_HourlyWeather value, $Res Function(_HourlyWeather) _then) = __$HourlyWeatherCopyWithImpl;
@override @useResult
$Res call({
 DateTime time, double? temperatureC, double? precipitationMm, double? precipitationProbabilityPercent, double? windSpeedMps, double? cloudCoveragePercent, String? symbolCode
});




}
/// @nodoc
class __$HourlyWeatherCopyWithImpl<$Res>
    implements _$HourlyWeatherCopyWith<$Res> {
  __$HourlyWeatherCopyWithImpl(this._self, this._then);

  final _HourlyWeather _self;
  final $Res Function(_HourlyWeather) _then;

/// Create a copy of HourlyWeather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? temperatureC = freezed,Object? precipitationMm = freezed,Object? precipitationProbabilityPercent = freezed,Object? windSpeedMps = freezed,Object? cloudCoveragePercent = freezed,Object? symbolCode = freezed,}) {
  return _then(_HourlyWeather(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,precipitationProbabilityPercent: freezed == precipitationProbabilityPercent ? _self.precipitationProbabilityPercent : precipitationProbabilityPercent // ignore: cast_nullable_to_non_nullable
as double?,windSpeedMps: freezed == windSpeedMps ? _self.windSpeedMps : windSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,cloudCoveragePercent: freezed == cloudCoveragePercent ? _self.cloudCoveragePercent : cloudCoveragePercent // ignore: cast_nullable_to_non_nullable
as double?,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DailyWeather {

@LocalDateConverter() LocalWallTime get date; double? get minimumTemperatureC; double? get maximumTemperatureC; double get precipitationMm; String? get symbolCode;
/// Create a copy of DailyWeather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyWeatherCopyWith<DailyWeather> get copyWith => _$DailyWeatherCopyWithImpl<DailyWeather>(this as DailyWeather, _$identity);

  /// Serializes this DailyWeather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DailyWeather;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyWeather&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.minimumTemperatureC, _this.minimumTemperatureC) || other.minimumTemperatureC == _this.minimumTemperatureC)&&(identical(other.maximumTemperatureC, _this.maximumTemperatureC) || other.maximumTemperatureC == _this.maximumTemperatureC)&&(identical(other.precipitationMm, _this.precipitationMm) || other.precipitationMm == _this.precipitationMm)&&(identical(other.symbolCode, _this.symbolCode) || other.symbolCode == _this.symbolCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DailyWeather;
  return Object.hash(runtimeType,_this.date,_this.minimumTemperatureC,_this.maximumTemperatureC,_this.precipitationMm,_this.symbolCode);
}

@override
String toString() {
  final _this = this as DailyWeather;
  return 'DailyWeather(date: ${_this.date}, minimumTemperatureC: ${_this.minimumTemperatureC}, maximumTemperatureC: ${_this.maximumTemperatureC}, precipitationMm: ${_this.precipitationMm}, symbolCode: ${_this.symbolCode})';
}


}

/// @nodoc
abstract mixin class $DailyWeatherCopyWith<$Res>  {
  factory $DailyWeatherCopyWith(DailyWeather value, $Res Function(DailyWeather) _then) = _$DailyWeatherCopyWithImpl;
@useResult
$Res call({
@LocalDateConverter() LocalWallTime date, double? minimumTemperatureC, double? maximumTemperatureC, double precipitationMm, String? symbolCode
});




}
/// @nodoc
class _$DailyWeatherCopyWithImpl<$Res>
    implements $DailyWeatherCopyWith<$Res> {
  _$DailyWeatherCopyWithImpl(this._self, this._then);

  final DailyWeather _self;
  final $Res Function(DailyWeather) _then;

/// Create a copy of DailyWeather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? minimumTemperatureC = freezed,Object? maximumTemperatureC = freezed,Object? precipitationMm = null,Object? symbolCode = freezed,}) {
  return _then(DailyWeather(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalWallTime,minimumTemperatureC: freezed == minimumTemperatureC ? _self.minimumTemperatureC : minimumTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,maximumTemperatureC: freezed == maximumTemperatureC ? _self.maximumTemperatureC : maximumTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: null == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyWeather].
extension DailyWeatherPatterns on DailyWeather {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyWeather value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyWeather() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyWeather value)  $default,){
final _that = this;
switch (_that) {
case _DailyWeather():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyWeather value)?  $default,){
final _that = this;
switch (_that) {
case _DailyWeather() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalWallTime date,  double? minimumTemperatureC,  double? maximumTemperatureC,  double precipitationMm,  String? symbolCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyWeather() when $default != null:
return $default(_that.date,_that.minimumTemperatureC,_that.maximumTemperatureC,_that.precipitationMm,_that.symbolCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalWallTime date,  double? minimumTemperatureC,  double? maximumTemperatureC,  double precipitationMm,  String? symbolCode)  $default,) {final _that = this;
switch (_that) {
case _DailyWeather():
return $default(_that.date,_that.minimumTemperatureC,_that.maximumTemperatureC,_that.precipitationMm,_that.symbolCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LocalDateConverter()  LocalWallTime date,  double? minimumTemperatureC,  double? maximumTemperatureC,  double precipitationMm,  String? symbolCode)?  $default,) {final _that = this;
switch (_that) {
case _DailyWeather() when $default != null:
return $default(_that.date,_that.minimumTemperatureC,_that.maximumTemperatureC,_that.precipitationMm,_that.symbolCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyWeather implements DailyWeather {
  const _DailyWeather({@LocalDateConverter() required this.date, this.minimumTemperatureC, this.maximumTemperatureC, this.precipitationMm = 0, this.symbolCode});
  factory _DailyWeather.fromJson(Map<String, dynamic> json) => _$DailyWeatherFromJson(json);

@override@LocalDateConverter() final  LocalWallTime date;
@override final  double? minimumTemperatureC;
@override final  double? maximumTemperatureC;
@override@JsonKey() final  double precipitationMm;
@override final  String? symbolCode;

/// Create a copy of DailyWeather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyWeatherCopyWith<_DailyWeather> get copyWith => __$DailyWeatherCopyWithImpl<_DailyWeather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyWeatherToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyWeather&&(identical(other.date, date) || other.date == date)&&(identical(other.minimumTemperatureC, minimumTemperatureC) || other.minimumTemperatureC == minimumTemperatureC)&&(identical(other.maximumTemperatureC, maximumTemperatureC) || other.maximumTemperatureC == maximumTemperatureC)&&(identical(other.precipitationMm, precipitationMm) || other.precipitationMm == precipitationMm)&&(identical(other.symbolCode, symbolCode) || other.symbolCode == symbolCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,minimumTemperatureC,maximumTemperatureC,precipitationMm,symbolCode);
}

@override
String toString() {
    return 'DailyWeather(date: $date, minimumTemperatureC: $minimumTemperatureC, maximumTemperatureC: $maximumTemperatureC, precipitationMm: $precipitationMm, symbolCode: $symbolCode)';
}


}

/// @nodoc
abstract mixin class _$DailyWeatherCopyWith<$Res> implements $DailyWeatherCopyWith<$Res> {
  factory _$DailyWeatherCopyWith(_DailyWeather value, $Res Function(_DailyWeather) _then) = __$DailyWeatherCopyWithImpl;
@override @useResult
$Res call({
@LocalDateConverter() LocalWallTime date, double? minimumTemperatureC, double? maximumTemperatureC, double precipitationMm, String? symbolCode
});




}
/// @nodoc
class __$DailyWeatherCopyWithImpl<$Res>
    implements _$DailyWeatherCopyWith<$Res> {
  __$DailyWeatherCopyWithImpl(this._self, this._then);

  final _DailyWeather _self;
  final $Res Function(_DailyWeather) _then;

/// Create a copy of DailyWeather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? minimumTemperatureC = freezed,Object? maximumTemperatureC = freezed,Object? precipitationMm = null,Object? symbolCode = freezed,}) {
  return _then(_DailyWeather(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalWallTime,minimumTemperatureC: freezed == minimumTemperatureC ? _self.minimumTemperatureC : minimumTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,maximumTemperatureC: freezed == maximumTemperatureC ? _self.maximumTemperatureC : maximumTemperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: null == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double,symbolCode: freezed == symbolCode ? _self.symbolCode : symbolCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SolarStatus {

 double get currentElevationDegrees; double get currentAzimuthDegrees; bool get aboveHorizon; DateTime? get sunrise; DateTime? get sunset; DateTime? get dawn; DateTime? get dusk; DateTime? get solarNoon; DateTime? get solarMidnight; DateTime? get nextSunrise; DateTime? get nextSunset; int? get dayLengthSeconds;
/// Create a copy of SolarStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SolarStatusCopyWith<SolarStatus> get copyWith => _$SolarStatusCopyWithImpl<SolarStatus>(this as SolarStatus, _$identity);

  /// Serializes this SolarStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SolarStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SolarStatus&&(identical(other.currentElevationDegrees, _this.currentElevationDegrees) || other.currentElevationDegrees == _this.currentElevationDegrees)&&(identical(other.currentAzimuthDegrees, _this.currentAzimuthDegrees) || other.currentAzimuthDegrees == _this.currentAzimuthDegrees)&&(identical(other.aboveHorizon, _this.aboveHorizon) || other.aboveHorizon == _this.aboveHorizon)&&(identical(other.sunrise, _this.sunrise) || other.sunrise == _this.sunrise)&&(identical(other.sunset, _this.sunset) || other.sunset == _this.sunset)&&(identical(other.dawn, _this.dawn) || other.dawn == _this.dawn)&&(identical(other.dusk, _this.dusk) || other.dusk == _this.dusk)&&(identical(other.solarNoon, _this.solarNoon) || other.solarNoon == _this.solarNoon)&&(identical(other.solarMidnight, _this.solarMidnight) || other.solarMidnight == _this.solarMidnight)&&(identical(other.nextSunrise, _this.nextSunrise) || other.nextSunrise == _this.nextSunrise)&&(identical(other.nextSunset, _this.nextSunset) || other.nextSunset == _this.nextSunset)&&(identical(other.dayLengthSeconds, _this.dayLengthSeconds) || other.dayLengthSeconds == _this.dayLengthSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SolarStatus;
  return Object.hash(runtimeType,_this.currentElevationDegrees,_this.currentAzimuthDegrees,_this.aboveHorizon,_this.sunrise,_this.sunset,_this.dawn,_this.dusk,_this.solarNoon,_this.solarMidnight,_this.nextSunrise,_this.nextSunset,_this.dayLengthSeconds);
}

@override
String toString() {
  final _this = this as SolarStatus;
  return 'SolarStatus(currentElevationDegrees: ${_this.currentElevationDegrees}, currentAzimuthDegrees: ${_this.currentAzimuthDegrees}, aboveHorizon: ${_this.aboveHorizon}, sunrise: ${_this.sunrise}, sunset: ${_this.sunset}, dawn: ${_this.dawn}, dusk: ${_this.dusk}, solarNoon: ${_this.solarNoon}, solarMidnight: ${_this.solarMidnight}, nextSunrise: ${_this.nextSunrise}, nextSunset: ${_this.nextSunset}, dayLengthSeconds: ${_this.dayLengthSeconds})';
}


}

/// @nodoc
abstract mixin class $SolarStatusCopyWith<$Res>  {
  factory $SolarStatusCopyWith(SolarStatus value, $Res Function(SolarStatus) _then) = _$SolarStatusCopyWithImpl;
@useResult
$Res call({
 double currentElevationDegrees, double currentAzimuthDegrees, bool aboveHorizon, DateTime? sunrise, DateTime? sunset, DateTime? dawn, DateTime? dusk, DateTime? solarNoon, DateTime? solarMidnight, DateTime? nextSunrise, DateTime? nextSunset, int? dayLengthSeconds
});




}
/// @nodoc
class _$SolarStatusCopyWithImpl<$Res>
    implements $SolarStatusCopyWith<$Res> {
  _$SolarStatusCopyWithImpl(this._self, this._then);

  final SolarStatus _self;
  final $Res Function(SolarStatus) _then;

/// Create a copy of SolarStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentElevationDegrees = null,Object? currentAzimuthDegrees = null,Object? aboveHorizon = null,Object? sunrise = freezed,Object? sunset = freezed,Object? dawn = freezed,Object? dusk = freezed,Object? solarNoon = freezed,Object? solarMidnight = freezed,Object? nextSunrise = freezed,Object? nextSunset = freezed,Object? dayLengthSeconds = freezed,}) {
  return _then(SolarStatus(
currentElevationDegrees: null == currentElevationDegrees ? _self.currentElevationDegrees : currentElevationDegrees // ignore: cast_nullable_to_non_nullable
as double,currentAzimuthDegrees: null == currentAzimuthDegrees ? _self.currentAzimuthDegrees : currentAzimuthDegrees // ignore: cast_nullable_to_non_nullable
as double,aboveHorizon: null == aboveHorizon ? _self.aboveHorizon : aboveHorizon // ignore: cast_nullable_to_non_nullable
as bool,sunrise: freezed == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime?,sunset: freezed == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime?,dawn: freezed == dawn ? _self.dawn : dawn // ignore: cast_nullable_to_non_nullable
as DateTime?,dusk: freezed == dusk ? _self.dusk : dusk // ignore: cast_nullable_to_non_nullable
as DateTime?,solarNoon: freezed == solarNoon ? _self.solarNoon : solarNoon // ignore: cast_nullable_to_non_nullable
as DateTime?,solarMidnight: freezed == solarMidnight ? _self.solarMidnight : solarMidnight // ignore: cast_nullable_to_non_nullable
as DateTime?,nextSunrise: freezed == nextSunrise ? _self.nextSunrise : nextSunrise // ignore: cast_nullable_to_non_nullable
as DateTime?,nextSunset: freezed == nextSunset ? _self.nextSunset : nextSunset // ignore: cast_nullable_to_non_nullable
as DateTime?,dayLengthSeconds: freezed == dayLengthSeconds ? _self.dayLengthSeconds : dayLengthSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SolarStatus].
extension SolarStatusPatterns on SolarStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SolarStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SolarStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SolarStatus value)  $default,){
final _that = this;
switch (_that) {
case _SolarStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SolarStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SolarStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentElevationDegrees,  double currentAzimuthDegrees,  bool aboveHorizon,  DateTime? sunrise,  DateTime? sunset,  DateTime? dawn,  DateTime? dusk,  DateTime? solarNoon,  DateTime? solarMidnight,  DateTime? nextSunrise,  DateTime? nextSunset,  int? dayLengthSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SolarStatus() when $default != null:
return $default(_that.currentElevationDegrees,_that.currentAzimuthDegrees,_that.aboveHorizon,_that.sunrise,_that.sunset,_that.dawn,_that.dusk,_that.solarNoon,_that.solarMidnight,_that.nextSunrise,_that.nextSunset,_that.dayLengthSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentElevationDegrees,  double currentAzimuthDegrees,  bool aboveHorizon,  DateTime? sunrise,  DateTime? sunset,  DateTime? dawn,  DateTime? dusk,  DateTime? solarNoon,  DateTime? solarMidnight,  DateTime? nextSunrise,  DateTime? nextSunset,  int? dayLengthSeconds)  $default,) {final _that = this;
switch (_that) {
case _SolarStatus():
return $default(_that.currentElevationDegrees,_that.currentAzimuthDegrees,_that.aboveHorizon,_that.sunrise,_that.sunset,_that.dawn,_that.dusk,_that.solarNoon,_that.solarMidnight,_that.nextSunrise,_that.nextSunset,_that.dayLengthSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentElevationDegrees,  double currentAzimuthDegrees,  bool aboveHorizon,  DateTime? sunrise,  DateTime? sunset,  DateTime? dawn,  DateTime? dusk,  DateTime? solarNoon,  DateTime? solarMidnight,  DateTime? nextSunrise,  DateTime? nextSunset,  int? dayLengthSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SolarStatus() when $default != null:
return $default(_that.currentElevationDegrees,_that.currentAzimuthDegrees,_that.aboveHorizon,_that.sunrise,_that.sunset,_that.dawn,_that.dusk,_that.solarNoon,_that.solarMidnight,_that.nextSunrise,_that.nextSunset,_that.dayLengthSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SolarStatus implements SolarStatus {
  const _SolarStatus({required this.currentElevationDegrees, required this.currentAzimuthDegrees, required this.aboveHorizon, this.sunrise, this.sunset, this.dawn, this.dusk, this.solarNoon, this.solarMidnight, this.nextSunrise, this.nextSunset, this.dayLengthSeconds});
  factory _SolarStatus.fromJson(Map<String, dynamic> json) => _$SolarStatusFromJson(json);

@override final  double currentElevationDegrees;
@override final  double currentAzimuthDegrees;
@override final  bool aboveHorizon;
@override final  DateTime? sunrise;
@override final  DateTime? sunset;
@override final  DateTime? dawn;
@override final  DateTime? dusk;
@override final  DateTime? solarNoon;
@override final  DateTime? solarMidnight;
@override final  DateTime? nextSunrise;
@override final  DateTime? nextSunset;
@override final  int? dayLengthSeconds;

/// Create a copy of SolarStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SolarStatusCopyWith<_SolarStatus> get copyWith => __$SolarStatusCopyWithImpl<_SolarStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SolarStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SolarStatus&&(identical(other.currentElevationDegrees, currentElevationDegrees) || other.currentElevationDegrees == currentElevationDegrees)&&(identical(other.currentAzimuthDegrees, currentAzimuthDegrees) || other.currentAzimuthDegrees == currentAzimuthDegrees)&&(identical(other.aboveHorizon, aboveHorizon) || other.aboveHorizon == aboveHorizon)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.dawn, dawn) || other.dawn == dawn)&&(identical(other.dusk, dusk) || other.dusk == dusk)&&(identical(other.solarNoon, solarNoon) || other.solarNoon == solarNoon)&&(identical(other.solarMidnight, solarMidnight) || other.solarMidnight == solarMidnight)&&(identical(other.nextSunrise, nextSunrise) || other.nextSunrise == nextSunrise)&&(identical(other.nextSunset, nextSunset) || other.nextSunset == nextSunset)&&(identical(other.dayLengthSeconds, dayLengthSeconds) || other.dayLengthSeconds == dayLengthSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentElevationDegrees,currentAzimuthDegrees,aboveHorizon,sunrise,sunset,dawn,dusk,solarNoon,solarMidnight,nextSunrise,nextSunset,dayLengthSeconds);
}

@override
String toString() {
    return 'SolarStatus(currentElevationDegrees: $currentElevationDegrees, currentAzimuthDegrees: $currentAzimuthDegrees, aboveHorizon: $aboveHorizon, sunrise: $sunrise, sunset: $sunset, dawn: $dawn, dusk: $dusk, solarNoon: $solarNoon, solarMidnight: $solarMidnight, nextSunrise: $nextSunrise, nextSunset: $nextSunset, dayLengthSeconds: $dayLengthSeconds)';
}


}

/// @nodoc
abstract mixin class _$SolarStatusCopyWith<$Res> implements $SolarStatusCopyWith<$Res> {
  factory _$SolarStatusCopyWith(_SolarStatus value, $Res Function(_SolarStatus) _then) = __$SolarStatusCopyWithImpl;
@override @useResult
$Res call({
 double currentElevationDegrees, double currentAzimuthDegrees, bool aboveHorizon, DateTime? sunrise, DateTime? sunset, DateTime? dawn, DateTime? dusk, DateTime? solarNoon, DateTime? solarMidnight, DateTime? nextSunrise, DateTime? nextSunset, int? dayLengthSeconds
});




}
/// @nodoc
class __$SolarStatusCopyWithImpl<$Res>
    implements _$SolarStatusCopyWith<$Res> {
  __$SolarStatusCopyWithImpl(this._self, this._then);

  final _SolarStatus _self;
  final $Res Function(_SolarStatus) _then;

/// Create a copy of SolarStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentElevationDegrees = null,Object? currentAzimuthDegrees = null,Object? aboveHorizon = null,Object? sunrise = freezed,Object? sunset = freezed,Object? dawn = freezed,Object? dusk = freezed,Object? solarNoon = freezed,Object? solarMidnight = freezed,Object? nextSunrise = freezed,Object? nextSunset = freezed,Object? dayLengthSeconds = freezed,}) {
  return _then(_SolarStatus(
currentElevationDegrees: null == currentElevationDegrees ? _self.currentElevationDegrees : currentElevationDegrees // ignore: cast_nullable_to_non_nullable
as double,currentAzimuthDegrees: null == currentAzimuthDegrees ? _self.currentAzimuthDegrees : currentAzimuthDegrees // ignore: cast_nullable_to_non_nullable
as double,aboveHorizon: null == aboveHorizon ? _self.aboveHorizon : aboveHorizon // ignore: cast_nullable_to_non_nullable
as bool,sunrise: freezed == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as DateTime?,sunset: freezed == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as DateTime?,dawn: freezed == dawn ? _self.dawn : dawn // ignore: cast_nullable_to_non_nullable
as DateTime?,dusk: freezed == dusk ? _self.dusk : dusk // ignore: cast_nullable_to_non_nullable
as DateTime?,solarNoon: freezed == solarNoon ? _self.solarNoon : solarNoon // ignore: cast_nullable_to_non_nullable
as DateTime?,solarMidnight: freezed == solarMidnight ? _self.solarMidnight : solarMidnight // ignore: cast_nullable_to_non_nullable
as DateTime?,nextSunrise: freezed == nextSunrise ? _self.nextSunrise : nextSunrise // ignore: cast_nullable_to_non_nullable
as DateTime?,nextSunset: freezed == nextSunset ? _self.nextSunset : nextSunset // ignore: cast_nullable_to_non_nullable
as DateTime?,dayLengthSeconds: freezed == dayLengthSeconds ? _self.dayLengthSeconds : dayLengthSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PvForecast {

 double get peakPowerKw; List<PvForecastHour> get hourly; List<PvForecastDay> get daily;
/// Create a copy of PvForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvForecastCopyWith<PvForecast> get copyWith => _$PvForecastCopyWithImpl<PvForecast>(this as PvForecast, _$identity);

  /// Serializes this PvForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvForecast;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvForecast&&(identical(other.peakPowerKw, _this.peakPowerKw) || other.peakPowerKw == _this.peakPowerKw)&&const DeepCollectionEquality().equals(other.hourly, _this.hourly)&&const DeepCollectionEquality().equals(other.daily, _this.daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvForecast;
  return Object.hash(runtimeType,_this.peakPowerKw,const DeepCollectionEquality().hash(_this.hourly),const DeepCollectionEquality().hash(_this.daily));
}

@override
String toString() {
  final _this = this as PvForecast;
  return 'PvForecast(peakPowerKw: ${_this.peakPowerKw}, hourly: ${_this.hourly}, daily: ${_this.daily})';
}


}

/// @nodoc
abstract mixin class $PvForecastCopyWith<$Res>  {
  factory $PvForecastCopyWith(PvForecast value, $Res Function(PvForecast) _then) = _$PvForecastCopyWithImpl;
@useResult
$Res call({
 double peakPowerKw, List<PvForecastHour> hourly, List<PvForecastDay> daily
});




}
/// @nodoc
class _$PvForecastCopyWithImpl<$Res>
    implements $PvForecastCopyWith<$Res> {
  _$PvForecastCopyWithImpl(this._self, this._then);

  final PvForecast _self;
  final $Res Function(PvForecast) _then;

/// Create a copy of PvForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? peakPowerKw = null,Object? hourly = null,Object? daily = null,}) {
  return _then(PvForecast(
peakPowerKw: null == peakPowerKw ? _self.peakPowerKw : peakPowerKw // ignore: cast_nullable_to_non_nullable
as double,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<PvForecastHour>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as List<PvForecastDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [PvForecast].
extension PvForecastPatterns on PvForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvForecast value)  $default,){
final _that = this;
switch (_that) {
case _PvForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvForecast value)?  $default,){
final _that = this;
switch (_that) {
case _PvForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double peakPowerKw,  List<PvForecastHour> hourly,  List<PvForecastDay> daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvForecast() when $default != null:
return $default(_that.peakPowerKw,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double peakPowerKw,  List<PvForecastHour> hourly,  List<PvForecastDay> daily)  $default,) {final _that = this;
switch (_that) {
case _PvForecast():
return $default(_that.peakPowerKw,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double peakPowerKw,  List<PvForecastHour> hourly,  List<PvForecastDay> daily)?  $default,) {final _that = this;
switch (_that) {
case _PvForecast() when $default != null:
return $default(_that.peakPowerKw,_that.hourly,_that.daily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvForecast implements PvForecast {
  const _PvForecast({required this.peakPowerKw,  List<PvForecastHour> hourly = const <PvForecastHour>[],  List<PvForecastDay> daily = const <PvForecastDay>[]}): _hourly = hourly,_daily = daily;
  factory _PvForecast.fromJson(Map<String, dynamic> json) => _$PvForecastFromJson(json);

@override final  double peakPowerKw;
 final  List<PvForecastHour> _hourly;
@override@JsonKey() List<PvForecastHour> get hourly {
  if (_hourly is EqualUnmodifiableListView) return _hourly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hourly);
}

 final  List<PvForecastDay> _daily;
@override@JsonKey() List<PvForecastDay> get daily {
  if (_daily is EqualUnmodifiableListView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daily);
}


/// Create a copy of PvForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvForecastCopyWith<_PvForecast> get copyWith => __$PvForecastCopyWithImpl<_PvForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvForecastToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvForecast&&(identical(other.peakPowerKw, peakPowerKw) || other.peakPowerKw == peakPowerKw)&&const DeepCollectionEquality().equals(other.hourly, _hourly)&&const DeepCollectionEquality().equals(other.daily, _daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,peakPowerKw,const DeepCollectionEquality().hash(_hourly),const DeepCollectionEquality().hash(_daily));
}

@override
String toString() {
    return 'PvForecast(peakPowerKw: $peakPowerKw, hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$PvForecastCopyWith<$Res> implements $PvForecastCopyWith<$Res> {
  factory _$PvForecastCopyWith(_PvForecast value, $Res Function(_PvForecast) _then) = __$PvForecastCopyWithImpl;
@override @useResult
$Res call({
 double peakPowerKw, List<PvForecastHour> hourly, List<PvForecastDay> daily
});




}
/// @nodoc
class __$PvForecastCopyWithImpl<$Res>
    implements _$PvForecastCopyWith<$Res> {
  __$PvForecastCopyWithImpl(this._self, this._then);

  final _PvForecast _self;
  final $Res Function(_PvForecast) _then;

/// Create a copy of PvForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? peakPowerKw = null,Object? hourly = null,Object? daily = null,}) {
  return _then(_PvForecast(
peakPowerKw: null == peakPowerKw ? _self.peakPowerKw : peakPowerKw // ignore: cast_nullable_to_non_nullable
as double,hourly: null == hourly ? _self._hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<PvForecastHour>,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as List<PvForecastDay>,
  ));
}


}


/// @nodoc
mixin _$PvForecastHour {

@LocalWallTimeConverter() LocalWallTime get time; double? get shortwaveRadiationWm2; double? get estimatedProductionKw;
/// Create a copy of PvForecastHour
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvForecastHourCopyWith<PvForecastHour> get copyWith => _$PvForecastHourCopyWithImpl<PvForecastHour>(this as PvForecastHour, _$identity);

  /// Serializes this PvForecastHour to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvForecastHour;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvForecastHour&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.shortwaveRadiationWm2, _this.shortwaveRadiationWm2) || other.shortwaveRadiationWm2 == _this.shortwaveRadiationWm2)&&(identical(other.estimatedProductionKw, _this.estimatedProductionKw) || other.estimatedProductionKw == _this.estimatedProductionKw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvForecastHour;
  return Object.hash(runtimeType,_this.time,_this.shortwaveRadiationWm2,_this.estimatedProductionKw);
}

@override
String toString() {
  final _this = this as PvForecastHour;
  return 'PvForecastHour(time: ${_this.time}, shortwaveRadiationWm2: ${_this.shortwaveRadiationWm2}, estimatedProductionKw: ${_this.estimatedProductionKw})';
}


}

/// @nodoc
abstract mixin class $PvForecastHourCopyWith<$Res>  {
  factory $PvForecastHourCopyWith(PvForecastHour value, $Res Function(PvForecastHour) _then) = _$PvForecastHourCopyWithImpl;
@useResult
$Res call({
@LocalWallTimeConverter() LocalWallTime time, double? shortwaveRadiationWm2, double? estimatedProductionKw
});




}
/// @nodoc
class _$PvForecastHourCopyWithImpl<$Res>
    implements $PvForecastHourCopyWith<$Res> {
  _$PvForecastHourCopyWithImpl(this._self, this._then);

  final PvForecastHour _self;
  final $Res Function(PvForecastHour) _then;

/// Create a copy of PvForecastHour
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? shortwaveRadiationWm2 = freezed,Object? estimatedProductionKw = freezed,}) {
  return _then(PvForecastHour(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalWallTime,shortwaveRadiationWm2: freezed == shortwaveRadiationWm2 ? _self.shortwaveRadiationWm2 : shortwaveRadiationWm2 // ignore: cast_nullable_to_non_nullable
as double?,estimatedProductionKw: freezed == estimatedProductionKw ? _self.estimatedProductionKw : estimatedProductionKw // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PvForecastHour].
extension PvForecastHourPatterns on PvForecastHour {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvForecastHour value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvForecastHour() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvForecastHour value)  $default,){
final _that = this;
switch (_that) {
case _PvForecastHour():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvForecastHour value)?  $default,){
final _that = this;
switch (_that) {
case _PvForecastHour() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LocalWallTimeConverter()  LocalWallTime time,  double? shortwaveRadiationWm2,  double? estimatedProductionKw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvForecastHour() when $default != null:
return $default(_that.time,_that.shortwaveRadiationWm2,_that.estimatedProductionKw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LocalWallTimeConverter()  LocalWallTime time,  double? shortwaveRadiationWm2,  double? estimatedProductionKw)  $default,) {final _that = this;
switch (_that) {
case _PvForecastHour():
return $default(_that.time,_that.shortwaveRadiationWm2,_that.estimatedProductionKw);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LocalWallTimeConverter()  LocalWallTime time,  double? shortwaveRadiationWm2,  double? estimatedProductionKw)?  $default,) {final _that = this;
switch (_that) {
case _PvForecastHour() when $default != null:
return $default(_that.time,_that.shortwaveRadiationWm2,_that.estimatedProductionKw);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvForecastHour implements PvForecastHour {
  const _PvForecastHour({@LocalWallTimeConverter() required this.time, this.shortwaveRadiationWm2, this.estimatedProductionKw});
  factory _PvForecastHour.fromJson(Map<String, dynamic> json) => _$PvForecastHourFromJson(json);

@override@LocalWallTimeConverter() final  LocalWallTime time;
@override final  double? shortwaveRadiationWm2;
@override final  double? estimatedProductionKw;

/// Create a copy of PvForecastHour
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvForecastHourCopyWith<_PvForecastHour> get copyWith => __$PvForecastHourCopyWithImpl<_PvForecastHour>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvForecastHourToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvForecastHour&&(identical(other.time, time) || other.time == time)&&(identical(other.shortwaveRadiationWm2, shortwaveRadiationWm2) || other.shortwaveRadiationWm2 == shortwaveRadiationWm2)&&(identical(other.estimatedProductionKw, estimatedProductionKw) || other.estimatedProductionKw == estimatedProductionKw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,shortwaveRadiationWm2,estimatedProductionKw);
}

@override
String toString() {
    return 'PvForecastHour(time: $time, shortwaveRadiationWm2: $shortwaveRadiationWm2, estimatedProductionKw: $estimatedProductionKw)';
}


}

/// @nodoc
abstract mixin class _$PvForecastHourCopyWith<$Res> implements $PvForecastHourCopyWith<$Res> {
  factory _$PvForecastHourCopyWith(_PvForecastHour value, $Res Function(_PvForecastHour) _then) = __$PvForecastHourCopyWithImpl;
@override @useResult
$Res call({
@LocalWallTimeConverter() LocalWallTime time, double? shortwaveRadiationWm2, double? estimatedProductionKw
});




}
/// @nodoc
class __$PvForecastHourCopyWithImpl<$Res>
    implements _$PvForecastHourCopyWith<$Res> {
  __$PvForecastHourCopyWithImpl(this._self, this._then);

  final _PvForecastHour _self;
  final $Res Function(_PvForecastHour) _then;

/// Create a copy of PvForecastHour
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? shortwaveRadiationWm2 = freezed,Object? estimatedProductionKw = freezed,}) {
  return _then(_PvForecastHour(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalWallTime,shortwaveRadiationWm2: freezed == shortwaveRadiationWm2 ? _self.shortwaveRadiationWm2 : shortwaveRadiationWm2 // ignore: cast_nullable_to_non_nullable
as double?,estimatedProductionKw: freezed == estimatedProductionKw ? _self.estimatedProductionKw : estimatedProductionKw // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$PvForecastDay {

@LocalDateConverter() LocalWallTime get date; double get estimatedProductionKwh;
/// Create a copy of PvForecastDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvForecastDayCopyWith<PvForecastDay> get copyWith => _$PvForecastDayCopyWithImpl<PvForecastDay>(this as PvForecastDay, _$identity);

  /// Serializes this PvForecastDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvForecastDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvForecastDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.estimatedProductionKwh, _this.estimatedProductionKwh) || other.estimatedProductionKwh == _this.estimatedProductionKwh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvForecastDay;
  return Object.hash(runtimeType,_this.date,_this.estimatedProductionKwh);
}

@override
String toString() {
  final _this = this as PvForecastDay;
  return 'PvForecastDay(date: ${_this.date}, estimatedProductionKwh: ${_this.estimatedProductionKwh})';
}


}

/// @nodoc
abstract mixin class $PvForecastDayCopyWith<$Res>  {
  factory $PvForecastDayCopyWith(PvForecastDay value, $Res Function(PvForecastDay) _then) = _$PvForecastDayCopyWithImpl;
@useResult
$Res call({
@LocalDateConverter() LocalWallTime date, double estimatedProductionKwh
});




}
/// @nodoc
class _$PvForecastDayCopyWithImpl<$Res>
    implements $PvForecastDayCopyWith<$Res> {
  _$PvForecastDayCopyWithImpl(this._self, this._then);

  final PvForecastDay _self;
  final $Res Function(PvForecastDay) _then;

/// Create a copy of PvForecastDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? estimatedProductionKwh = null,}) {
  return _then(PvForecastDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalWallTime,estimatedProductionKwh: null == estimatedProductionKwh ? _self.estimatedProductionKwh : estimatedProductionKwh // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PvForecastDay].
extension PvForecastDayPatterns on PvForecastDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvForecastDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvForecastDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvForecastDay value)  $default,){
final _that = this;
switch (_that) {
case _PvForecastDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvForecastDay value)?  $default,){
final _that = this;
switch (_that) {
case _PvForecastDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalWallTime date,  double estimatedProductionKwh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvForecastDay() when $default != null:
return $default(_that.date,_that.estimatedProductionKwh);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalWallTime date,  double estimatedProductionKwh)  $default,) {final _that = this;
switch (_that) {
case _PvForecastDay():
return $default(_that.date,_that.estimatedProductionKwh);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LocalDateConverter()  LocalWallTime date,  double estimatedProductionKwh)?  $default,) {final _that = this;
switch (_that) {
case _PvForecastDay() when $default != null:
return $default(_that.date,_that.estimatedProductionKwh);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvForecastDay implements PvForecastDay {
  const _PvForecastDay({@LocalDateConverter() required this.date, required this.estimatedProductionKwh});
  factory _PvForecastDay.fromJson(Map<String, dynamic> json) => _$PvForecastDayFromJson(json);

@override@LocalDateConverter() final  LocalWallTime date;
@override final  double estimatedProductionKwh;

/// Create a copy of PvForecastDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvForecastDayCopyWith<_PvForecastDay> get copyWith => __$PvForecastDayCopyWithImpl<_PvForecastDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvForecastDayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvForecastDay&&(identical(other.date, date) || other.date == date)&&(identical(other.estimatedProductionKwh, estimatedProductionKwh) || other.estimatedProductionKwh == estimatedProductionKwh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,estimatedProductionKwh);
}

@override
String toString() {
    return 'PvForecastDay(date: $date, estimatedProductionKwh: $estimatedProductionKwh)';
}


}

/// @nodoc
abstract mixin class _$PvForecastDayCopyWith<$Res> implements $PvForecastDayCopyWith<$Res> {
  factory _$PvForecastDayCopyWith(_PvForecastDay value, $Res Function(_PvForecastDay) _then) = __$PvForecastDayCopyWithImpl;
@override @useResult
$Res call({
@LocalDateConverter() LocalWallTime date, double estimatedProductionKwh
});




}
/// @nodoc
class __$PvForecastDayCopyWithImpl<$Res>
    implements _$PvForecastDayCopyWith<$Res> {
  __$PvForecastDayCopyWithImpl(this._self, this._then);

  final _PvForecastDay _self;
  final $Res Function(_PvForecastDay) _then;

/// Create a copy of PvForecastDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? estimatedProductionKwh = null,}) {
  return _then(_PvForecastDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalWallTime,estimatedProductionKwh: null == estimatedProductionKwh ? _self.estimatedProductionKwh : estimatedProductionKwh // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PvHeatingPlan {

 String get deviceId; DateTime get generatedAt; double get safeMaxTemperatureCelsius; double get baseTargetCelsius;@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode get mode; List<PvHeatingPlanHour> get hours;
/// Create a copy of PvHeatingPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvHeatingPlanCopyWith<PvHeatingPlan> get copyWith => _$PvHeatingPlanCopyWithImpl<PvHeatingPlan>(this as PvHeatingPlan, _$identity);

  /// Serializes this PvHeatingPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvHeatingPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvHeatingPlan&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.safeMaxTemperatureCelsius, _this.safeMaxTemperatureCelsius) || other.safeMaxTemperatureCelsius == _this.safeMaxTemperatureCelsius)&&(identical(other.baseTargetCelsius, _this.baseTargetCelsius) || other.baseTargetCelsius == _this.baseTargetCelsius)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.hours, _this.hours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvHeatingPlan;
  return Object.hash(runtimeType,_this.deviceId,_this.generatedAt,_this.safeMaxTemperatureCelsius,_this.baseTargetCelsius,_this.mode,const DeepCollectionEquality().hash(_this.hours));
}

@override
String toString() {
  final _this = this as PvHeatingPlan;
  return 'PvHeatingPlan(deviceId: ${_this.deviceId}, generatedAt: ${_this.generatedAt}, safeMaxTemperatureCelsius: ${_this.safeMaxTemperatureCelsius}, baseTargetCelsius: ${_this.baseTargetCelsius}, mode: ${_this.mode}, hours: ${_this.hours})';
}


}

/// @nodoc
abstract mixin class $PvHeatingPlanCopyWith<$Res>  {
  factory $PvHeatingPlanCopyWith(PvHeatingPlan value, $Res Function(PvHeatingPlan) _then) = _$PvHeatingPlanCopyWithImpl;
@useResult
$Res call({
 String deviceId, DateTime generatedAt, double safeMaxTemperatureCelsius, double baseTargetCelsius,@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode mode, List<PvHeatingPlanHour> hours
});




}
/// @nodoc
class _$PvHeatingPlanCopyWithImpl<$Res>
    implements $PvHeatingPlanCopyWith<$Res> {
  _$PvHeatingPlanCopyWithImpl(this._self, this._then);

  final PvHeatingPlan _self;
  final $Res Function(PvHeatingPlan) _then;

/// Create a copy of PvHeatingPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? generatedAt = null,Object? safeMaxTemperatureCelsius = null,Object? baseTargetCelsius = null,Object? mode = null,Object? hours = null,}) {
  return _then(PvHeatingPlan(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,safeMaxTemperatureCelsius: null == safeMaxTemperatureCelsius ? _self.safeMaxTemperatureCelsius : safeMaxTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,baseTargetCelsius: null == baseTargetCelsius ? _self.baseTargetCelsius : baseTargetCelsius // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PvControlMode,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as List<PvHeatingPlanHour>,
  ));
}

}


/// Adds pattern-matching-related methods to [PvHeatingPlan].
extension PvHeatingPlanPatterns on PvHeatingPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvHeatingPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvHeatingPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvHeatingPlan value)  $default,){
final _that = this;
switch (_that) {
case _PvHeatingPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvHeatingPlan value)?  $default,){
final _that = this;
switch (_that) {
case _PvHeatingPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceId,  DateTime generatedAt,  double safeMaxTemperatureCelsius,  double baseTargetCelsius, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode,  List<PvHeatingPlanHour> hours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvHeatingPlan() when $default != null:
return $default(_that.deviceId,_that.generatedAt,_that.safeMaxTemperatureCelsius,_that.baseTargetCelsius,_that.mode,_that.hours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceId,  DateTime generatedAt,  double safeMaxTemperatureCelsius,  double baseTargetCelsius, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode,  List<PvHeatingPlanHour> hours)  $default,) {final _that = this;
switch (_that) {
case _PvHeatingPlan():
return $default(_that.deviceId,_that.generatedAt,_that.safeMaxTemperatureCelsius,_that.baseTargetCelsius,_that.mode,_that.hours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceId,  DateTime generatedAt,  double safeMaxTemperatureCelsius,  double baseTargetCelsius, @JsonKey(unknownEnumValue: PvControlMode.unknown)  PvControlMode mode,  List<PvHeatingPlanHour> hours)?  $default,) {final _that = this;
switch (_that) {
case _PvHeatingPlan() when $default != null:
return $default(_that.deviceId,_that.generatedAt,_that.safeMaxTemperatureCelsius,_that.baseTargetCelsius,_that.mode,_that.hours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvHeatingPlan implements PvHeatingPlan {
  const _PvHeatingPlan({required this.deviceId, required this.generatedAt, required this.safeMaxTemperatureCelsius, required this.baseTargetCelsius, @JsonKey(unknownEnumValue: PvControlMode.unknown) this.mode = PvControlMode.unknown,  List<PvHeatingPlanHour> hours = const <PvHeatingPlanHour>[]}): _hours = hours;
  factory _PvHeatingPlan.fromJson(Map<String, dynamic> json) => _$PvHeatingPlanFromJson(json);

@override final  String deviceId;
@override final  DateTime generatedAt;
@override final  double safeMaxTemperatureCelsius;
@override final  double baseTargetCelsius;
@override@JsonKey(unknownEnumValue: PvControlMode.unknown) final  PvControlMode mode;
 final  List<PvHeatingPlanHour> _hours;
@override@JsonKey() List<PvHeatingPlanHour> get hours {
  if (_hours is EqualUnmodifiableListView) return _hours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hours);
}


/// Create a copy of PvHeatingPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvHeatingPlanCopyWith<_PvHeatingPlan> get copyWith => __$PvHeatingPlanCopyWithImpl<_PvHeatingPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvHeatingPlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvHeatingPlan&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.safeMaxTemperatureCelsius, safeMaxTemperatureCelsius) || other.safeMaxTemperatureCelsius == safeMaxTemperatureCelsius)&&(identical(other.baseTargetCelsius, baseTargetCelsius) || other.baseTargetCelsius == baseTargetCelsius)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.hours, _hours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,deviceId,generatedAt,safeMaxTemperatureCelsius,baseTargetCelsius,mode,const DeepCollectionEquality().hash(_hours));
}

@override
String toString() {
    return 'PvHeatingPlan(deviceId: $deviceId, generatedAt: $generatedAt, safeMaxTemperatureCelsius: $safeMaxTemperatureCelsius, baseTargetCelsius: $baseTargetCelsius, mode: $mode, hours: $hours)';
}


}

/// @nodoc
abstract mixin class _$PvHeatingPlanCopyWith<$Res> implements $PvHeatingPlanCopyWith<$Res> {
  factory _$PvHeatingPlanCopyWith(_PvHeatingPlan value, $Res Function(_PvHeatingPlan) _then) = __$PvHeatingPlanCopyWithImpl;
@override @useResult
$Res call({
 String deviceId, DateTime generatedAt, double safeMaxTemperatureCelsius, double baseTargetCelsius,@JsonKey(unknownEnumValue: PvControlMode.unknown) PvControlMode mode, List<PvHeatingPlanHour> hours
});




}
/// @nodoc
class __$PvHeatingPlanCopyWithImpl<$Res>
    implements _$PvHeatingPlanCopyWith<$Res> {
  __$PvHeatingPlanCopyWithImpl(this._self, this._then);

  final _PvHeatingPlan _self;
  final $Res Function(_PvHeatingPlan) _then;

/// Create a copy of PvHeatingPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? generatedAt = null,Object? safeMaxTemperatureCelsius = null,Object? baseTargetCelsius = null,Object? mode = null,Object? hours = null,}) {
  return _then(_PvHeatingPlan(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,safeMaxTemperatureCelsius: null == safeMaxTemperatureCelsius ? _self.safeMaxTemperatureCelsius : safeMaxTemperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,baseTargetCelsius: null == baseTargetCelsius ? _self.baseTargetCelsius : baseTargetCelsius // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PvControlMode,hours: null == hours ? _self._hours : hours // ignore: cast_nullable_to_non_nullable
as List<PvHeatingPlanHour>,
  ));
}


}


/// @nodoc
mixin _$PvHeatingPlanHour {

@LocalWallTimeConverter() LocalWallTime get time; bool get forecastFavorable; bool get predictedBoostActive; double get predictedTargetCelsius; double? get estimatedProductionKw;
/// Create a copy of PvHeatingPlanHour
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PvHeatingPlanHourCopyWith<PvHeatingPlanHour> get copyWith => _$PvHeatingPlanHourCopyWithImpl<PvHeatingPlanHour>(this as PvHeatingPlanHour, _$identity);

  /// Serializes this PvHeatingPlanHour to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PvHeatingPlanHour;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PvHeatingPlanHour&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.forecastFavorable, _this.forecastFavorable) || other.forecastFavorable == _this.forecastFavorable)&&(identical(other.predictedBoostActive, _this.predictedBoostActive) || other.predictedBoostActive == _this.predictedBoostActive)&&(identical(other.predictedTargetCelsius, _this.predictedTargetCelsius) || other.predictedTargetCelsius == _this.predictedTargetCelsius)&&(identical(other.estimatedProductionKw, _this.estimatedProductionKw) || other.estimatedProductionKw == _this.estimatedProductionKw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PvHeatingPlanHour;
  return Object.hash(runtimeType,_this.time,_this.forecastFavorable,_this.predictedBoostActive,_this.predictedTargetCelsius,_this.estimatedProductionKw);
}

@override
String toString() {
  final _this = this as PvHeatingPlanHour;
  return 'PvHeatingPlanHour(time: ${_this.time}, forecastFavorable: ${_this.forecastFavorable}, predictedBoostActive: ${_this.predictedBoostActive}, predictedTargetCelsius: ${_this.predictedTargetCelsius}, estimatedProductionKw: ${_this.estimatedProductionKw})';
}


}

/// @nodoc
abstract mixin class $PvHeatingPlanHourCopyWith<$Res>  {
  factory $PvHeatingPlanHourCopyWith(PvHeatingPlanHour value, $Res Function(PvHeatingPlanHour) _then) = _$PvHeatingPlanHourCopyWithImpl;
@useResult
$Res call({
@LocalWallTimeConverter() LocalWallTime time, bool forecastFavorable, bool predictedBoostActive, double predictedTargetCelsius, double? estimatedProductionKw
});




}
/// @nodoc
class _$PvHeatingPlanHourCopyWithImpl<$Res>
    implements $PvHeatingPlanHourCopyWith<$Res> {
  _$PvHeatingPlanHourCopyWithImpl(this._self, this._then);

  final PvHeatingPlanHour _self;
  final $Res Function(PvHeatingPlanHour) _then;

/// Create a copy of PvHeatingPlanHour
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? forecastFavorable = null,Object? predictedBoostActive = null,Object? predictedTargetCelsius = null,Object? estimatedProductionKw = freezed,}) {
  return _then(PvHeatingPlanHour(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalWallTime,forecastFavorable: null == forecastFavorable ? _self.forecastFavorable : forecastFavorable // ignore: cast_nullable_to_non_nullable
as bool,predictedBoostActive: null == predictedBoostActive ? _self.predictedBoostActive : predictedBoostActive // ignore: cast_nullable_to_non_nullable
as bool,predictedTargetCelsius: null == predictedTargetCelsius ? _self.predictedTargetCelsius : predictedTargetCelsius // ignore: cast_nullable_to_non_nullable
as double,estimatedProductionKw: freezed == estimatedProductionKw ? _self.estimatedProductionKw : estimatedProductionKw // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PvHeatingPlanHour].
extension PvHeatingPlanHourPatterns on PvHeatingPlanHour {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PvHeatingPlanHour value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PvHeatingPlanHour() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PvHeatingPlanHour value)  $default,){
final _that = this;
switch (_that) {
case _PvHeatingPlanHour():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PvHeatingPlanHour value)?  $default,){
final _that = this;
switch (_that) {
case _PvHeatingPlanHour() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LocalWallTimeConverter()  LocalWallTime time,  bool forecastFavorable,  bool predictedBoostActive,  double predictedTargetCelsius,  double? estimatedProductionKw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PvHeatingPlanHour() when $default != null:
return $default(_that.time,_that.forecastFavorable,_that.predictedBoostActive,_that.predictedTargetCelsius,_that.estimatedProductionKw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LocalWallTimeConverter()  LocalWallTime time,  bool forecastFavorable,  bool predictedBoostActive,  double predictedTargetCelsius,  double? estimatedProductionKw)  $default,) {final _that = this;
switch (_that) {
case _PvHeatingPlanHour():
return $default(_that.time,_that.forecastFavorable,_that.predictedBoostActive,_that.predictedTargetCelsius,_that.estimatedProductionKw);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LocalWallTimeConverter()  LocalWallTime time,  bool forecastFavorable,  bool predictedBoostActive,  double predictedTargetCelsius,  double? estimatedProductionKw)?  $default,) {final _that = this;
switch (_that) {
case _PvHeatingPlanHour() when $default != null:
return $default(_that.time,_that.forecastFavorable,_that.predictedBoostActive,_that.predictedTargetCelsius,_that.estimatedProductionKw);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PvHeatingPlanHour implements PvHeatingPlanHour {
  const _PvHeatingPlanHour({@LocalWallTimeConverter() required this.time, required this.forecastFavorable, required this.predictedBoostActive, required this.predictedTargetCelsius, this.estimatedProductionKw});
  factory _PvHeatingPlanHour.fromJson(Map<String, dynamic> json) => _$PvHeatingPlanHourFromJson(json);

@override@LocalWallTimeConverter() final  LocalWallTime time;
@override final  bool forecastFavorable;
@override final  bool predictedBoostActive;
@override final  double predictedTargetCelsius;
@override final  double? estimatedProductionKw;

/// Create a copy of PvHeatingPlanHour
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PvHeatingPlanHourCopyWith<_PvHeatingPlanHour> get copyWith => __$PvHeatingPlanHourCopyWithImpl<_PvHeatingPlanHour>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PvHeatingPlanHourToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PvHeatingPlanHour&&(identical(other.time, time) || other.time == time)&&(identical(other.forecastFavorable, forecastFavorable) || other.forecastFavorable == forecastFavorable)&&(identical(other.predictedBoostActive, predictedBoostActive) || other.predictedBoostActive == predictedBoostActive)&&(identical(other.predictedTargetCelsius, predictedTargetCelsius) || other.predictedTargetCelsius == predictedTargetCelsius)&&(identical(other.estimatedProductionKw, estimatedProductionKw) || other.estimatedProductionKw == estimatedProductionKw));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,time,forecastFavorable,predictedBoostActive,predictedTargetCelsius,estimatedProductionKw);
}

@override
String toString() {
    return 'PvHeatingPlanHour(time: $time, forecastFavorable: $forecastFavorable, predictedBoostActive: $predictedBoostActive, predictedTargetCelsius: $predictedTargetCelsius, estimatedProductionKw: $estimatedProductionKw)';
}


}

/// @nodoc
abstract mixin class _$PvHeatingPlanHourCopyWith<$Res> implements $PvHeatingPlanHourCopyWith<$Res> {
  factory _$PvHeatingPlanHourCopyWith(_PvHeatingPlanHour value, $Res Function(_PvHeatingPlanHour) _then) = __$PvHeatingPlanHourCopyWithImpl;
@override @useResult
$Res call({
@LocalWallTimeConverter() LocalWallTime time, bool forecastFavorable, bool predictedBoostActive, double predictedTargetCelsius, double? estimatedProductionKw
});




}
/// @nodoc
class __$PvHeatingPlanHourCopyWithImpl<$Res>
    implements _$PvHeatingPlanHourCopyWith<$Res> {
  __$PvHeatingPlanHourCopyWithImpl(this._self, this._then);

  final _PvHeatingPlanHour _self;
  final $Res Function(_PvHeatingPlanHour) _then;

/// Create a copy of PvHeatingPlanHour
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? forecastFavorable = null,Object? predictedBoostActive = null,Object? predictedTargetCelsius = null,Object? estimatedProductionKw = freezed,}) {
  return _then(_PvHeatingPlanHour(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as LocalWallTime,forecastFavorable: null == forecastFavorable ? _self.forecastFavorable : forecastFavorable // ignore: cast_nullable_to_non_nullable
as bool,predictedBoostActive: null == predictedBoostActive ? _self.predictedBoostActive : predictedBoostActive // ignore: cast_nullable_to_non_nullable
as bool,predictedTargetCelsius: null == predictedTargetCelsius ? _self.predictedTargetCelsius : predictedTargetCelsius // ignore: cast_nullable_to_non_nullable
as double,estimatedProductionKw: freezed == estimatedProductionKw ? _self.estimatedProductionKw : estimatedProductionKw // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
