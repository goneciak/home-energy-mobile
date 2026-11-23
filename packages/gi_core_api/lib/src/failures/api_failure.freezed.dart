// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure()';
}


}

/// @nodoc
class $ApiFailureCopyWith<$Res>  {
$ApiFailureCopyWith(ApiFailure _, $Res Function(ApiFailure) __);
}


/// Adds pattern-matching-related methods to [ApiFailure].
extension ApiFailurePatterns on ApiFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UnreachableFailure value)?  unreachable,TResult Function( TimeoutFailure value)?  timeout,TResult Function( LocalNetworkDeniedFailure value)?  localNetworkDenied,TResult Function( TlsUntrustedFailure value)?  tlsUntrusted,TResult Function( InsecureTransportFailure value)?  insecureTransport,TResult Function( HttpsRequiredFailure value)?  httpsRequired,TResult Function( UnauthorizedFailure value)?  unauthorized,TResult Function( ForbiddenFailure value)?  forbidden,TResult Function( NotFoundFailure value)?  notFound,TResult Function( RouteAbsentFailure value)?  routeAbsent,TResult Function( ValidationFailure value)?  validation,TResult Function( RateLimitedFailure value)?  rateLimited,TResult Function( DomainFailure value)?  domain,TResult Function( ServerFailure value)?  server,TResult Function( UnexpectedResponseFailure value)?  unexpectedResponse,TResult Function( UnexpectedShapeFailure value)?  unexpectedShape,TResult Function( SessionLostFailure value)?  sessionLost,TResult Function( RefreshCookieMissingFailure value)?  refreshCookieMissing,TResult Function( VaultUnavailableFailure value)?  vaultUnavailable,TResult Function( DifferentApplianceFailure value)?  differentAppliance,TResult Function( ApplianceResetFailure value)?  applianceReset,TResult Function( CancelledFailure value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UnreachableFailure() when unreachable != null:
return unreachable(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case LocalNetworkDeniedFailure() when localNetworkDenied != null:
return localNetworkDenied(_that);case TlsUntrustedFailure() when tlsUntrusted != null:
return tlsUntrusted(_that);case InsecureTransportFailure() when insecureTransport != null:
return insecureTransport(_that);case HttpsRequiredFailure() when httpsRequired != null:
return httpsRequired(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case RouteAbsentFailure() when routeAbsent != null:
return routeAbsent(_that);case ValidationFailure() when validation != null:
return validation(_that);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that);case DomainFailure() when domain != null:
return domain(_that);case ServerFailure() when server != null:
return server(_that);case UnexpectedResponseFailure() when unexpectedResponse != null:
return unexpectedResponse(_that);case UnexpectedShapeFailure() when unexpectedShape != null:
return unexpectedShape(_that);case SessionLostFailure() when sessionLost != null:
return sessionLost(_that);case RefreshCookieMissingFailure() when refreshCookieMissing != null:
return refreshCookieMissing(_that);case VaultUnavailableFailure() when vaultUnavailable != null:
return vaultUnavailable(_that);case DifferentApplianceFailure() when differentAppliance != null:
return differentAppliance(_that);case ApplianceResetFailure() when applianceReset != null:
return applianceReset(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UnreachableFailure value)  unreachable,required TResult Function( TimeoutFailure value)  timeout,required TResult Function( LocalNetworkDeniedFailure value)  localNetworkDenied,required TResult Function( TlsUntrustedFailure value)  tlsUntrusted,required TResult Function( InsecureTransportFailure value)  insecureTransport,required TResult Function( HttpsRequiredFailure value)  httpsRequired,required TResult Function( UnauthorizedFailure value)  unauthorized,required TResult Function( ForbiddenFailure value)  forbidden,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( RouteAbsentFailure value)  routeAbsent,required TResult Function( ValidationFailure value)  validation,required TResult Function( RateLimitedFailure value)  rateLimited,required TResult Function( DomainFailure value)  domain,required TResult Function( ServerFailure value)  server,required TResult Function( UnexpectedResponseFailure value)  unexpectedResponse,required TResult Function( UnexpectedShapeFailure value)  unexpectedShape,required TResult Function( SessionLostFailure value)  sessionLost,required TResult Function( RefreshCookieMissingFailure value)  refreshCookieMissing,required TResult Function( VaultUnavailableFailure value)  vaultUnavailable,required TResult Function( DifferentApplianceFailure value)  differentAppliance,required TResult Function( ApplianceResetFailure value)  applianceReset,required TResult Function( CancelledFailure value)  cancelled,}){
final _that = this;
switch (_that) {
case UnreachableFailure():
return unreachable(_that);case TimeoutFailure():
return timeout(_that);case LocalNetworkDeniedFailure():
return localNetworkDenied(_that);case TlsUntrustedFailure():
return tlsUntrusted(_that);case InsecureTransportFailure():
return insecureTransport(_that);case HttpsRequiredFailure():
return httpsRequired(_that);case UnauthorizedFailure():
return unauthorized(_that);case ForbiddenFailure():
return forbidden(_that);case NotFoundFailure():
return notFound(_that);case RouteAbsentFailure():
return routeAbsent(_that);case ValidationFailure():
return validation(_that);case RateLimitedFailure():
return rateLimited(_that);case DomainFailure():
return domain(_that);case ServerFailure():
return server(_that);case UnexpectedResponseFailure():
return unexpectedResponse(_that);case UnexpectedShapeFailure():
return unexpectedShape(_that);case SessionLostFailure():
return sessionLost(_that);case RefreshCookieMissingFailure():
return refreshCookieMissing(_that);case VaultUnavailableFailure():
return vaultUnavailable(_that);case DifferentApplianceFailure():
return differentAppliance(_that);case ApplianceResetFailure():
return applianceReset(_that);case CancelledFailure():
return cancelled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UnreachableFailure value)?  unreachable,TResult? Function( TimeoutFailure value)?  timeout,TResult? Function( LocalNetworkDeniedFailure value)?  localNetworkDenied,TResult? Function( TlsUntrustedFailure value)?  tlsUntrusted,TResult? Function( InsecureTransportFailure value)?  insecureTransport,TResult? Function( HttpsRequiredFailure value)?  httpsRequired,TResult? Function( UnauthorizedFailure value)?  unauthorized,TResult? Function( ForbiddenFailure value)?  forbidden,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( RouteAbsentFailure value)?  routeAbsent,TResult? Function( ValidationFailure value)?  validation,TResult? Function( RateLimitedFailure value)?  rateLimited,TResult? Function( DomainFailure value)?  domain,TResult? Function( ServerFailure value)?  server,TResult? Function( UnexpectedResponseFailure value)?  unexpectedResponse,TResult? Function( UnexpectedShapeFailure value)?  unexpectedShape,TResult? Function( SessionLostFailure value)?  sessionLost,TResult? Function( RefreshCookieMissingFailure value)?  refreshCookieMissing,TResult? Function( VaultUnavailableFailure value)?  vaultUnavailable,TResult? Function( DifferentApplianceFailure value)?  differentAppliance,TResult? Function( ApplianceResetFailure value)?  applianceReset,TResult? Function( CancelledFailure value)?  cancelled,}){
final _that = this;
switch (_that) {
case UnreachableFailure() when unreachable != null:
return unreachable(_that);case TimeoutFailure() when timeout != null:
return timeout(_that);case LocalNetworkDeniedFailure() when localNetworkDenied != null:
return localNetworkDenied(_that);case TlsUntrustedFailure() when tlsUntrusted != null:
return tlsUntrusted(_that);case InsecureTransportFailure() when insecureTransport != null:
return insecureTransport(_that);case HttpsRequiredFailure() when httpsRequired != null:
return httpsRequired(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case RouteAbsentFailure() when routeAbsent != null:
return routeAbsent(_that);case ValidationFailure() when validation != null:
return validation(_that);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that);case DomainFailure() when domain != null:
return domain(_that);case ServerFailure() when server != null:
return server(_that);case UnexpectedResponseFailure() when unexpectedResponse != null:
return unexpectedResponse(_that);case UnexpectedShapeFailure() when unexpectedShape != null:
return unexpectedShape(_that);case SessionLostFailure() when sessionLost != null:
return sessionLost(_that);case RefreshCookieMissingFailure() when refreshCookieMissing != null:
return refreshCookieMissing(_that);case VaultUnavailableFailure() when vaultUnavailable != null:
return vaultUnavailable(_that);case DifferentApplianceFailure() when differentAppliance != null:
return differentAppliance(_that);case ApplianceResetFailure() when applianceReset != null:
return applianceReset(_that);case CancelledFailure() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? reason)?  unreachable,TResult Function( String? reason)?  timeout,TResult Function( String? reason)?  localNetworkDenied,TResult Function( String host,  String? reason)?  tlsUntrusted,TResult Function( String host)?  insecureTransport,TResult Function( String host)?  httpsRequired,TResult Function( String code,  ApiErrorEnvelope? envelope)?  unauthorized,TResult Function( String code,  ApiErrorEnvelope? envelope)?  forbidden,TResult Function( String code,  ApiErrorEnvelope? envelope)?  notFound,TResult Function( ApiErrorEnvelope? envelope)?  routeAbsent,TResult Function( Map<String, List<String>> details,  ApiErrorEnvelope? envelope)?  validation,TResult Function( Duration? retryAfter,  ApiErrorEnvelope? envelope)?  rateLimited,TResult Function( int statusCode,  String code,  ApiErrorEnvelope? envelope)?  domain,TResult Function( int statusCode,  String? errorCode,  Duration? retryAfter,  ApiErrorEnvelope? envelope)?  server,TResult Function( int? statusCode,  String? contentType)?  unexpectedResponse,TResult Function( String endpointId,  String? requestId,  String? fieldPath,  String? message)?  unexpectedShape,TResult Function( SessionLostReason reason)?  sessionLost,TResult Function()?  refreshCookieMissing,TResult Function()?  vaultUnavailable,TResult Function()?  differentAppliance,TResult Function()?  applianceReset,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UnreachableFailure() when unreachable != null:
return unreachable(_that.reason);case TimeoutFailure() when timeout != null:
return timeout(_that.reason);case LocalNetworkDeniedFailure() when localNetworkDenied != null:
return localNetworkDenied(_that.reason);case TlsUntrustedFailure() when tlsUntrusted != null:
return tlsUntrusted(_that.host,_that.reason);case InsecureTransportFailure() when insecureTransport != null:
return insecureTransport(_that.host);case HttpsRequiredFailure() when httpsRequired != null:
return httpsRequired(_that.host);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.code,_that.envelope);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.code,_that.envelope);case NotFoundFailure() when notFound != null:
return notFound(_that.code,_that.envelope);case RouteAbsentFailure() when routeAbsent != null:
return routeAbsent(_that.envelope);case ValidationFailure() when validation != null:
return validation(_that.details,_that.envelope);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that.retryAfter,_that.envelope);case DomainFailure() when domain != null:
return domain(_that.statusCode,_that.code,_that.envelope);case ServerFailure() when server != null:
return server(_that.statusCode,_that.errorCode,_that.retryAfter,_that.envelope);case UnexpectedResponseFailure() when unexpectedResponse != null:
return unexpectedResponse(_that.statusCode,_that.contentType);case UnexpectedShapeFailure() when unexpectedShape != null:
return unexpectedShape(_that.endpointId,_that.requestId,_that.fieldPath,_that.message);case SessionLostFailure() when sessionLost != null:
return sessionLost(_that.reason);case RefreshCookieMissingFailure() when refreshCookieMissing != null:
return refreshCookieMissing();case VaultUnavailableFailure() when vaultUnavailable != null:
return vaultUnavailable();case DifferentApplianceFailure() when differentAppliance != null:
return differentAppliance();case ApplianceResetFailure() when applianceReset != null:
return applianceReset();case CancelledFailure() when cancelled != null:
return cancelled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? reason)  unreachable,required TResult Function( String? reason)  timeout,required TResult Function( String? reason)  localNetworkDenied,required TResult Function( String host,  String? reason)  tlsUntrusted,required TResult Function( String host)  insecureTransport,required TResult Function( String host)  httpsRequired,required TResult Function( String code,  ApiErrorEnvelope? envelope)  unauthorized,required TResult Function( String code,  ApiErrorEnvelope? envelope)  forbidden,required TResult Function( String code,  ApiErrorEnvelope? envelope)  notFound,required TResult Function( ApiErrorEnvelope? envelope)  routeAbsent,required TResult Function( Map<String, List<String>> details,  ApiErrorEnvelope? envelope)  validation,required TResult Function( Duration? retryAfter,  ApiErrorEnvelope? envelope)  rateLimited,required TResult Function( int statusCode,  String code,  ApiErrorEnvelope? envelope)  domain,required TResult Function( int statusCode,  String? errorCode,  Duration? retryAfter,  ApiErrorEnvelope? envelope)  server,required TResult Function( int? statusCode,  String? contentType)  unexpectedResponse,required TResult Function( String endpointId,  String? requestId,  String? fieldPath,  String? message)  unexpectedShape,required TResult Function( SessionLostReason reason)  sessionLost,required TResult Function()  refreshCookieMissing,required TResult Function()  vaultUnavailable,required TResult Function()  differentAppliance,required TResult Function()  applianceReset,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case UnreachableFailure():
return unreachable(_that.reason);case TimeoutFailure():
return timeout(_that.reason);case LocalNetworkDeniedFailure():
return localNetworkDenied(_that.reason);case TlsUntrustedFailure():
return tlsUntrusted(_that.host,_that.reason);case InsecureTransportFailure():
return insecureTransport(_that.host);case HttpsRequiredFailure():
return httpsRequired(_that.host);case UnauthorizedFailure():
return unauthorized(_that.code,_that.envelope);case ForbiddenFailure():
return forbidden(_that.code,_that.envelope);case NotFoundFailure():
return notFound(_that.code,_that.envelope);case RouteAbsentFailure():
return routeAbsent(_that.envelope);case ValidationFailure():
return validation(_that.details,_that.envelope);case RateLimitedFailure():
return rateLimited(_that.retryAfter,_that.envelope);case DomainFailure():
return domain(_that.statusCode,_that.code,_that.envelope);case ServerFailure():
return server(_that.statusCode,_that.errorCode,_that.retryAfter,_that.envelope);case UnexpectedResponseFailure():
return unexpectedResponse(_that.statusCode,_that.contentType);case UnexpectedShapeFailure():
return unexpectedShape(_that.endpointId,_that.requestId,_that.fieldPath,_that.message);case SessionLostFailure():
return sessionLost(_that.reason);case RefreshCookieMissingFailure():
return refreshCookieMissing();case VaultUnavailableFailure():
return vaultUnavailable();case DifferentApplianceFailure():
return differentAppliance();case ApplianceResetFailure():
return applianceReset();case CancelledFailure():
return cancelled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? reason)?  unreachable,TResult? Function( String? reason)?  timeout,TResult? Function( String? reason)?  localNetworkDenied,TResult? Function( String host,  String? reason)?  tlsUntrusted,TResult? Function( String host)?  insecureTransport,TResult? Function( String host)?  httpsRequired,TResult? Function( String code,  ApiErrorEnvelope? envelope)?  unauthorized,TResult? Function( String code,  ApiErrorEnvelope? envelope)?  forbidden,TResult? Function( String code,  ApiErrorEnvelope? envelope)?  notFound,TResult? Function( ApiErrorEnvelope? envelope)?  routeAbsent,TResult? Function( Map<String, List<String>> details,  ApiErrorEnvelope? envelope)?  validation,TResult? Function( Duration? retryAfter,  ApiErrorEnvelope? envelope)?  rateLimited,TResult? Function( int statusCode,  String code,  ApiErrorEnvelope? envelope)?  domain,TResult? Function( int statusCode,  String? errorCode,  Duration? retryAfter,  ApiErrorEnvelope? envelope)?  server,TResult? Function( int? statusCode,  String? contentType)?  unexpectedResponse,TResult? Function( String endpointId,  String? requestId,  String? fieldPath,  String? message)?  unexpectedShape,TResult? Function( SessionLostReason reason)?  sessionLost,TResult? Function()?  refreshCookieMissing,TResult? Function()?  vaultUnavailable,TResult? Function()?  differentAppliance,TResult? Function()?  applianceReset,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case UnreachableFailure() when unreachable != null:
return unreachable(_that.reason);case TimeoutFailure() when timeout != null:
return timeout(_that.reason);case LocalNetworkDeniedFailure() when localNetworkDenied != null:
return localNetworkDenied(_that.reason);case TlsUntrustedFailure() when tlsUntrusted != null:
return tlsUntrusted(_that.host,_that.reason);case InsecureTransportFailure() when insecureTransport != null:
return insecureTransport(_that.host);case HttpsRequiredFailure() when httpsRequired != null:
return httpsRequired(_that.host);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.code,_that.envelope);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.code,_that.envelope);case NotFoundFailure() when notFound != null:
return notFound(_that.code,_that.envelope);case RouteAbsentFailure() when routeAbsent != null:
return routeAbsent(_that.envelope);case ValidationFailure() when validation != null:
return validation(_that.details,_that.envelope);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that.retryAfter,_that.envelope);case DomainFailure() when domain != null:
return domain(_that.statusCode,_that.code,_that.envelope);case ServerFailure() when server != null:
return server(_that.statusCode,_that.errorCode,_that.retryAfter,_that.envelope);case UnexpectedResponseFailure() when unexpectedResponse != null:
return unexpectedResponse(_that.statusCode,_that.contentType);case UnexpectedShapeFailure() when unexpectedShape != null:
return unexpectedShape(_that.endpointId,_that.requestId,_that.fieldPath,_that.message);case SessionLostFailure() when sessionLost != null:
return sessionLost(_that.reason);case RefreshCookieMissingFailure() when refreshCookieMissing != null:
return refreshCookieMissing();case VaultUnavailableFailure() when vaultUnavailable != null:
return vaultUnavailable();case DifferentApplianceFailure() when differentAppliance != null:
return differentAppliance();case ApplianceResetFailure() when applianceReset != null:
return applianceReset();case CancelledFailure() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class UnreachableFailure extends ApiFailure {
  const UnreachableFailure({this.reason}): super._();
  

 final  String? reason;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreachableFailureCopyWith<UnreachableFailure> get copyWith => _$UnreachableFailureCopyWithImpl<UnreachableFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreachableFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ApiFailure.unreachable(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $UnreachableFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $UnreachableFailureCopyWith(UnreachableFailure value, $Res Function(UnreachableFailure) _then) = _$UnreachableFailureCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$UnreachableFailureCopyWithImpl<$Res>
    implements $UnreachableFailureCopyWith<$Res> {
  _$UnreachableFailureCopyWithImpl(this._self, this._then);

  final UnreachableFailure _self;
  final $Res Function(UnreachableFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(UnreachableFailure(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TimeoutFailure extends ApiFailure {
  const TimeoutFailure({this.reason}): super._();
  

 final  String? reason;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeoutFailureCopyWith<TimeoutFailure> get copyWith => _$TimeoutFailureCopyWithImpl<TimeoutFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ApiFailure.timeout(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TimeoutFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $TimeoutFailureCopyWith(TimeoutFailure value, $Res Function(TimeoutFailure) _then) = _$TimeoutFailureCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$TimeoutFailureCopyWithImpl<$Res>
    implements $TimeoutFailureCopyWith<$Res> {
  _$TimeoutFailureCopyWithImpl(this._self, this._then);

  final TimeoutFailure _self;
  final $Res Function(TimeoutFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(TimeoutFailure(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LocalNetworkDeniedFailure extends ApiFailure {
  const LocalNetworkDeniedFailure({this.reason}): super._();
  

 final  String? reason;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalNetworkDeniedFailureCopyWith<LocalNetworkDeniedFailure> get copyWith => _$LocalNetworkDeniedFailureCopyWithImpl<LocalNetworkDeniedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalNetworkDeniedFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ApiFailure.localNetworkDenied(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $LocalNetworkDeniedFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $LocalNetworkDeniedFailureCopyWith(LocalNetworkDeniedFailure value, $Res Function(LocalNetworkDeniedFailure) _then) = _$LocalNetworkDeniedFailureCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$LocalNetworkDeniedFailureCopyWithImpl<$Res>
    implements $LocalNetworkDeniedFailureCopyWith<$Res> {
  _$LocalNetworkDeniedFailureCopyWithImpl(this._self, this._then);

  final LocalNetworkDeniedFailure _self;
  final $Res Function(LocalNetworkDeniedFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(LocalNetworkDeniedFailure(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TlsUntrustedFailure extends ApiFailure {
  const TlsUntrustedFailure({required this.host, this.reason}): super._();
  

 final  String host;
 final  String? reason;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TlsUntrustedFailureCopyWith<TlsUntrustedFailure> get copyWith => _$TlsUntrustedFailureCopyWithImpl<TlsUntrustedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TlsUntrustedFailure&&(identical(other.host, host) || other.host == host)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,host,reason);
}

@override
String toString() {
    return 'ApiFailure.tlsUntrusted(host: $host, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TlsUntrustedFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $TlsUntrustedFailureCopyWith(TlsUntrustedFailure value, $Res Function(TlsUntrustedFailure) _then) = _$TlsUntrustedFailureCopyWithImpl;
@useResult
$Res call({
 String host, String? reason
});




}
/// @nodoc
class _$TlsUntrustedFailureCopyWithImpl<$Res>
    implements $TlsUntrustedFailureCopyWith<$Res> {
  _$TlsUntrustedFailureCopyWithImpl(this._self, this._then);

  final TlsUntrustedFailure _self;
  final $Res Function(TlsUntrustedFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? host = null,Object? reason = freezed,}) {
  return _then(TlsUntrustedFailure(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class InsecureTransportFailure extends ApiFailure {
  const InsecureTransportFailure({required this.host}): super._();
  

 final  String host;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsecureTransportFailureCopyWith<InsecureTransportFailure> get copyWith => _$InsecureTransportFailureCopyWithImpl<InsecureTransportFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InsecureTransportFailure&&(identical(other.host, host) || other.host == host));
}


@override
int get hashCode {
    return Object.hash(runtimeType,host);
}

@override
String toString() {
    return 'ApiFailure.insecureTransport(host: $host)';
}


}

/// @nodoc
abstract mixin class $InsecureTransportFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $InsecureTransportFailureCopyWith(InsecureTransportFailure value, $Res Function(InsecureTransportFailure) _then) = _$InsecureTransportFailureCopyWithImpl;
@useResult
$Res call({
 String host
});




}
/// @nodoc
class _$InsecureTransportFailureCopyWithImpl<$Res>
    implements $InsecureTransportFailureCopyWith<$Res> {
  _$InsecureTransportFailureCopyWithImpl(this._self, this._then);

  final InsecureTransportFailure _self;
  final $Res Function(InsecureTransportFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? host = null,}) {
  return _then(InsecureTransportFailure(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class HttpsRequiredFailure extends ApiFailure {
  const HttpsRequiredFailure({required this.host}): super._();
  

 final  String host;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpsRequiredFailureCopyWith<HttpsRequiredFailure> get copyWith => _$HttpsRequiredFailureCopyWithImpl<HttpsRequiredFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpsRequiredFailure&&(identical(other.host, host) || other.host == host));
}


@override
int get hashCode {
    return Object.hash(runtimeType,host);
}

@override
String toString() {
    return 'ApiFailure.httpsRequired(host: $host)';
}


}

/// @nodoc
abstract mixin class $HttpsRequiredFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $HttpsRequiredFailureCopyWith(HttpsRequiredFailure value, $Res Function(HttpsRequiredFailure) _then) = _$HttpsRequiredFailureCopyWithImpl;
@useResult
$Res call({
 String host
});




}
/// @nodoc
class _$HttpsRequiredFailureCopyWithImpl<$Res>
    implements $HttpsRequiredFailureCopyWith<$Res> {
  _$HttpsRequiredFailureCopyWithImpl(this._self, this._then);

  final HttpsRequiredFailure _self;
  final $Res Function(HttpsRequiredFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? host = null,}) {
  return _then(HttpsRequiredFailure(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure({required this.code, this.envelope}): super._();
  

 final  String code;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnauthorizedFailureCopyWith<UnauthorizedFailure> get copyWith => _$UnauthorizedFailureCopyWithImpl<UnauthorizedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthorizedFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,envelope);
}

@override
String toString() {
    return 'ApiFailure.unauthorized(code: $code, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $UnauthorizedFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $UnauthorizedFailureCopyWith(UnauthorizedFailure value, $Res Function(UnauthorizedFailure) _then) = _$UnauthorizedFailureCopyWithImpl;
@useResult
$Res call({
 String code, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$UnauthorizedFailureCopyWithImpl<$Res>
    implements $UnauthorizedFailureCopyWith<$Res> {
  _$UnauthorizedFailureCopyWithImpl(this._self, this._then);

  final UnauthorizedFailure _self;
  final $Res Function(UnauthorizedFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? envelope = freezed,}) {
  return _then(UnauthorizedFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure({required this.code, this.envelope}): super._();
  

 final  String code;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForbiddenFailureCopyWith<ForbiddenFailure> get copyWith => _$ForbiddenFailureCopyWithImpl<ForbiddenFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForbiddenFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,envelope);
}

@override
String toString() {
    return 'ApiFailure.forbidden(code: $code, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $ForbiddenFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $ForbiddenFailureCopyWith(ForbiddenFailure value, $Res Function(ForbiddenFailure) _then) = _$ForbiddenFailureCopyWithImpl;
@useResult
$Res call({
 String code, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$ForbiddenFailureCopyWithImpl<$Res>
    implements $ForbiddenFailureCopyWith<$Res> {
  _$ForbiddenFailureCopyWithImpl(this._self, this._then);

  final ForbiddenFailure _self;
  final $Res Function(ForbiddenFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? envelope = freezed,}) {
  return _then(ForbiddenFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class NotFoundFailure extends ApiFailure {
  const NotFoundFailure({required this.code, this.envelope}): super._();
  

 final  String code;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,envelope);
}

@override
String toString() {
    return 'ApiFailure.notFound(code: $code, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@useResult
$Res call({
 String code, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? envelope = freezed,}) {
  return _then(NotFoundFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class RouteAbsentFailure extends ApiFailure {
  const RouteAbsentFailure({this.envelope}): super._();
  

 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteAbsentFailureCopyWith<RouteAbsentFailure> get copyWith => _$RouteAbsentFailureCopyWithImpl<RouteAbsentFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteAbsentFailure&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,envelope);
}

@override
String toString() {
    return 'ApiFailure.routeAbsent(envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $RouteAbsentFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $RouteAbsentFailureCopyWith(RouteAbsentFailure value, $Res Function(RouteAbsentFailure) _then) = _$RouteAbsentFailureCopyWithImpl;
@useResult
$Res call({
 ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$RouteAbsentFailureCopyWithImpl<$Res>
    implements $RouteAbsentFailureCopyWith<$Res> {
  _$RouteAbsentFailureCopyWithImpl(this._self, this._then);

  final RouteAbsentFailure _self;
  final $Res Function(RouteAbsentFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? envelope = freezed,}) {
  return _then(RouteAbsentFailure(
envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class ValidationFailure extends ApiFailure {
  const ValidationFailure({required  Map<String, List<String>> details, this.envelope}): _details = details,super._();
  

 final  Map<String, List<String>> _details;
 Map<String, List<String>> get details {
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_details);
}

 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&const DeepCollectionEquality().equals(other.details, _details)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_details),envelope);
}

@override
String toString() {
    return 'ApiFailure.validation(details: $details, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $ValidationFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@useResult
$Res call({
 Map<String, List<String>> details, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? details = null,Object? envelope = freezed,}) {
  return _then(ValidationFailure(
details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class RateLimitedFailure extends ApiFailure {
  const RateLimitedFailure({this.retryAfter, this.envelope}): super._();
  

 final  Duration? retryAfter;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitedFailureCopyWith<RateLimitedFailure> get copyWith => _$RateLimitedFailureCopyWithImpl<RateLimitedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitedFailure&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,retryAfter,envelope);
}

@override
String toString() {
    return 'ApiFailure.rateLimited(retryAfter: $retryAfter, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $RateLimitedFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $RateLimitedFailureCopyWith(RateLimitedFailure value, $Res Function(RateLimitedFailure) _then) = _$RateLimitedFailureCopyWithImpl;
@useResult
$Res call({
 Duration? retryAfter, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$RateLimitedFailureCopyWithImpl<$Res>
    implements $RateLimitedFailureCopyWith<$Res> {
  _$RateLimitedFailureCopyWithImpl(this._self, this._then);

  final RateLimitedFailure _self;
  final $Res Function(RateLimitedFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? retryAfter = freezed,Object? envelope = freezed,}) {
  return _then(RateLimitedFailure(
retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class DomainFailure extends ApiFailure {
  const DomainFailure({required this.statusCode, required this.code, this.envelope}): super._();
  

 final  int statusCode;
 final  String code;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainFailureCopyWith<DomainFailure> get copyWith => _$DomainFailureCopyWithImpl<DomainFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.code, code) || other.code == code)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,code,envelope);
}

@override
String toString() {
    return 'ApiFailure.domain(statusCode: $statusCode, code: $code, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $DomainFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $DomainFailureCopyWith(DomainFailure value, $Res Function(DomainFailure) _then) = _$DomainFailureCopyWithImpl;
@useResult
$Res call({
 int statusCode, String code, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$DomainFailureCopyWithImpl<$Res>
    implements $DomainFailureCopyWith<$Res> {
  _$DomainFailureCopyWithImpl(this._self, this._then);

  final DomainFailure _self;
  final $Res Function(DomainFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? code = null,Object? envelope = freezed,}) {
  return _then(DomainFailure(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class ServerFailure extends ApiFailure {
  const ServerFailure({required this.statusCode, this.errorCode, this.retryAfter, this.envelope}): super._();
  

 final  int statusCode;
 final  String? errorCode;
 final  Duration? retryAfter;
 final  ApiErrorEnvelope? envelope;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter)&&(identical(other.envelope, envelope) || other.envelope == envelope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,errorCode,retryAfter,envelope);
}

@override
String toString() {
    return 'ApiFailure.server(statusCode: $statusCode, errorCode: $errorCode, retryAfter: $retryAfter, envelope: $envelope)';
}


}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@useResult
$Res call({
 int statusCode, String? errorCode, Duration? retryAfter, ApiErrorEnvelope? envelope
});


$ApiErrorEnvelopeCopyWith<$Res>? get envelope;

}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? errorCode = freezed,Object? retryAfter = freezed,Object? envelope = freezed,}) {
  return _then(ServerFailure(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,envelope: freezed == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as ApiErrorEnvelope?,
  ));
}

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<$Res>? get envelope {
    if (_self.envelope == null) {
    return null;
  }

  return $ApiErrorEnvelopeCopyWith<$Res>(_self.envelope!, (value) {
    return _then(_self.copyWith(envelope: value));
  });
}
}

/// @nodoc


class UnexpectedResponseFailure extends ApiFailure {
  const UnexpectedResponseFailure({this.statusCode, this.contentType}): super._();
  

 final  int? statusCode;
 final  String? contentType;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedResponseFailureCopyWith<UnexpectedResponseFailure> get copyWith => _$UnexpectedResponseFailureCopyWithImpl<UnexpectedResponseFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedResponseFailure&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,contentType);
}

@override
String toString() {
    return 'ApiFailure.unexpectedResponse(statusCode: $statusCode, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $UnexpectedResponseFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $UnexpectedResponseFailureCopyWith(UnexpectedResponseFailure value, $Res Function(UnexpectedResponseFailure) _then) = _$UnexpectedResponseFailureCopyWithImpl;
@useResult
$Res call({
 int? statusCode, String? contentType
});




}
/// @nodoc
class _$UnexpectedResponseFailureCopyWithImpl<$Res>
    implements $UnexpectedResponseFailureCopyWith<$Res> {
  _$UnexpectedResponseFailureCopyWithImpl(this._self, this._then);

  final UnexpectedResponseFailure _self;
  final $Res Function(UnexpectedResponseFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = freezed,Object? contentType = freezed,}) {
  return _then(UnexpectedResponseFailure(
statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class UnexpectedShapeFailure extends ApiFailure {
  const UnexpectedShapeFailure({required this.endpointId, this.requestId, this.fieldPath, this.message}): super._();
  

 final  String endpointId;
 final  String? requestId;
 final  String? fieldPath;
 final  String? message;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedShapeFailureCopyWith<UnexpectedShapeFailure> get copyWith => _$UnexpectedShapeFailureCopyWithImpl<UnexpectedShapeFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedShapeFailure&&(identical(other.endpointId, endpointId) || other.endpointId == endpointId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.fieldPath, fieldPath) || other.fieldPath == fieldPath)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,endpointId,requestId,fieldPath,message);
}

@override
String toString() {
    return 'ApiFailure.unexpectedShape(endpointId: $endpointId, requestId: $requestId, fieldPath: $fieldPath, message: $message)';
}


}

/// @nodoc
abstract mixin class $UnexpectedShapeFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $UnexpectedShapeFailureCopyWith(UnexpectedShapeFailure value, $Res Function(UnexpectedShapeFailure) _then) = _$UnexpectedShapeFailureCopyWithImpl;
@useResult
$Res call({
 String endpointId, String? requestId, String? fieldPath, String? message
});




}
/// @nodoc
class _$UnexpectedShapeFailureCopyWithImpl<$Res>
    implements $UnexpectedShapeFailureCopyWith<$Res> {
  _$UnexpectedShapeFailureCopyWithImpl(this._self, this._then);

  final UnexpectedShapeFailure _self;
  final $Res Function(UnexpectedShapeFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? endpointId = null,Object? requestId = freezed,Object? fieldPath = freezed,Object? message = freezed,}) {
  return _then(UnexpectedShapeFailure(
endpointId: null == endpointId ? _self.endpointId : endpointId // ignore: cast_nullable_to_non_nullable
as String,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,fieldPath: freezed == fieldPath ? _self.fieldPath : fieldPath // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SessionLostFailure extends ApiFailure {
  const SessionLostFailure({required this.reason}): super._();
  

 final  SessionLostReason reason;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionLostFailureCopyWith<SessionLostFailure> get copyWith => _$SessionLostFailureCopyWithImpl<SessionLostFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionLostFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ApiFailure.sessionLost(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SessionLostFailureCopyWith<$Res> implements $ApiFailureCopyWith<$Res> {
  factory $SessionLostFailureCopyWith(SessionLostFailure value, $Res Function(SessionLostFailure) _then) = _$SessionLostFailureCopyWithImpl;
@useResult
$Res call({
 SessionLostReason reason
});




}
/// @nodoc
class _$SessionLostFailureCopyWithImpl<$Res>
    implements $SessionLostFailureCopyWith<$Res> {
  _$SessionLostFailureCopyWithImpl(this._self, this._then);

  final SessionLostFailure _self;
  final $Res Function(SessionLostFailure) _then;

/// Create a copy of ApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SessionLostFailure(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SessionLostReason,
  ));
}


}

/// @nodoc


class RefreshCookieMissingFailure extends ApiFailure {
  const RefreshCookieMissingFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshCookieMissingFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure.refreshCookieMissing()';
}


}




/// @nodoc


class VaultUnavailableFailure extends ApiFailure {
  const VaultUnavailableFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultUnavailableFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure.vaultUnavailable()';
}


}




/// @nodoc


class DifferentApplianceFailure extends ApiFailure {
  const DifferentApplianceFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DifferentApplianceFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure.differentAppliance()';
}


}




/// @nodoc


class ApplianceResetFailure extends ApiFailure {
  const ApplianceResetFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplianceResetFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure.applianceReset()';
}


}




/// @nodoc


class CancelledFailure extends ApiFailure {
  const CancelledFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelledFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ApiFailure.cancelled()';
}


}




// dart format on
