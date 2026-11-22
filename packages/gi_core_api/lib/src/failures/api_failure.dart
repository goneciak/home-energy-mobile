import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gi_core_api/src/failures/api_error_envelope.dart';

part 'api_failure.freezed.dart';

/// Why a session ended without the user logging out (plan §7.4). Each value
/// is a separate local diagnostic counter.
enum SessionLostReason {
  /// 401 `AUTH_REFRESH_TOKEN_INVALID`.
  refreshTokenInvalid,

  /// 401 `AUTH_REFRESH_TOKEN_REUSED`: an old cookie was presented, the server
  /// revoked the whole session.
  refreshTokenReused,

  /// 401 `AUTH_SESSION_REVOKED` (logout elsewhere, 10-session limit, expiry).
  sessionRevoked,

  /// 403 `USER_DISABLED`.
  userDisabled,

  /// Any other 401 from the refresh endpoint.
  refreshRejected,

  /// No refresh cookie stored.
  noToken,

  /// The stored cookie's absolute expiry (30 days) has passed.
  expired,

  /// 200 from refresh without a valid rotated cookie.
  protocol,

  /// The stored cookie could not be read (corrupt entry, or secure storage
  /// failing on several reads in a row) and was wiped (plan §7.1).
  vaultWiped,
}

/// Every failure the GI Core client reports. User-facing text is picked by
/// [code] from the app's ARB files; server codes pass through unchanged.
@freezed
sealed class ApiFailure with _$ApiFailure implements Exception {
  /// The request never left the phone or never reached the server (DNS,
  /// connection refused, connect timeout). Safe to retry.
  const factory unreachable({String? reason}) = UnreachableFailure;

  /// The request may have reached the server but no answer arrived (receive
  /// or send timeout, reset after sending). The outcome is unknown.
  const factory timeout({String? reason}) = TimeoutFailure;

  /// The operating system refused to open a connection to a home-network
  /// host because GI Home lacks the local-network permission (iOS Local
  /// Network privacy, Android local network protection; plan §9.4). Retrying
  /// cannot help until the user allows access in the system settings.
  ///
  /// Detected by the client's `LocalNetworkDeniedDetector`; the exact
  /// platform signatures are confirmed by spike S2.
  const factory localNetworkDenied({String? reason}) =
      LocalNetworkDeniedFailure;

  /// TLS handshake or certificate failure. Never downgraded to http.
  const factory tlsUntrusted({required String host, String? reason}) =
      TlsUntrustedFailure;

  /// Cleartext http to a host outside the home network (plan §9.4).
  const factory insecureTransport({required String host}) =
      InsecureTransportFailure;

  /// HTTP 401 that does not end the session (e.g. wrong credentials).
  const factory unauthorized({
    required String code,
    ApiErrorEnvelope? envelope,
  }) = UnauthorizedFailure;

  /// HTTP 403 (`HTTP_403` for RBAC).
  const factory forbidden({required String code, ApiErrorEnvelope? envelope}) =
      ForbiddenFailure;

  /// Domain 404 (e.g. `DEVICE_NOT_FOUND`, `RESOURCE_NOT_FOUND`).
  const factory notFound({required String code, ApiErrorEnvelope? envelope}) =
      NotFoundFailure;

  /// `HTTP_404`: the route does not exist in this GI Core version.
  const factory routeAbsent({ApiErrorEnvelope? envelope}) = RouteAbsentFailure;

  /// 400 `VALIDATION_FAILED` with messages keyed by dotted field path.
  const factory validation({
    required Map<String, List<String>> details,
    ApiErrorEnvelope? envelope,
  }) = ValidationFailure;

  /// 429 `HTTP_429`. [retryAfter] comes from `Retry-After` when present.
  const factory rateLimited({
    Duration? retryAfter,
    ApiErrorEnvelope? envelope,
  }) = RateLimitedFailure;

  /// Any other 4xx with an error envelope (409 `HEATING_SUSPENDED`, 400
  /// `USER_CURRENT_PASSWORD_INVALID`, ...).
  const factory domain({
    required int statusCode,
    required String code,
    ApiErrorEnvelope? envelope,
  }) = DomainFailure;

  /// 5xx. [errorCode] is `null` when the body was not an envelope.
  /// [retryAfter] comes from `Retry-After` (a 503 may send it).
  const factory server({
    required int statusCode,
    String? errorCode,
    Duration? retryAfter,
    ApiErrorEnvelope? envelope,
  }) = ServerFailure;

  /// A body that is not JSON where JSON was expected (proxy or captive
  /// portal HTML page, unexpected redirect).
  const factory unexpectedResponse({int? statusCode, String? contentType}) =
      UnexpectedResponseFailure;

  /// JSON that does not match the model. Counted per endpoint; never crashes
  /// the app.
  const factory unexpectedShape({
    required String endpointId,
    String? requestId,
    String? fieldPath,
    String? message,
  }) = UnexpectedShapeFailure;

  /// The session is over; the user has to log in again.
  const factory sessionLost({required SessionLostReason reason}) =
      SessionLostFailure;

  /// Login succeeded but the response carried no usable refresh cookie.
  const factory refreshCookieMissing() = RefreshCookieMissingFailure;

  /// Secure storage could not be read. Credentials are kept; retry later.
  const factory vaultUnavailable() = VaultUnavailableFailure;

  /// The appliance answering at this address is not the one the session
  /// belongs to (different `initializedAt`); the cookie was not sent.
  const factory differentAppliance() = DifferentApplianceFailure;

  /// The appliance the session belongs to answers at this address but
  /// reports `initialized: false`: it was reset and must be set up again
  /// (plan §9.3). The cookie was not sent; the old session cannot survive a
  /// reset.
  const factory applianceReset() = ApplianceResetFailure;

  const factory cancelled() = CancelledFailure;

  const new _();

  /// Stable code for UI text lookup: the server code when there is one,
  /// otherwise a client code (plan §8.1).
  String get code => switch (this) {
    UnreachableFailure() => 'BACKEND_UNREACHABLE',
    TimeoutFailure() => 'REQUEST_TIMEOUT',
    LocalNetworkDeniedFailure() => 'LOCAL_NETWORK_DENIED',
    TlsUntrustedFailure() => 'TLS_CERT_UNTRUSTED',
    InsecureTransportFailure() => 'INSECURE_TRANSPORT',
    UnauthorizedFailure(:final code) => code,
    ForbiddenFailure(:final code) => code,
    NotFoundFailure(:final code) => code,
    RouteAbsentFailure() => 'HTTP_404',
    ValidationFailure() => 'VALIDATION_FAILED',
    RateLimitedFailure() => 'HTTP_429',
    DomainFailure(:final code) => code,
    ServerFailure(:final errorCode) => errorCode ?? 'INTERNAL_SERVER_ERROR',
    UnexpectedResponseFailure() => 'UNEXPECTED_RESPONSE',
    UnexpectedShapeFailure() => 'UNEXPECTED_SHAPE',
    SessionLostFailure() => 'SESSION_LOST',
    RefreshCookieMissingFailure() => 'REFRESH_COOKIE_MISSING',
    VaultUnavailableFailure() => 'VAULT_UNAVAILABLE',
    DifferentApplianceFailure() => 'DIFFERENT_APPLIANCE',
    ApplianceResetFailure() => 'APPLIANCE_RESET',
    CancelledFailure() => 'CANCELLED',
  };

  /// Server request id, shown next to generic errors for support.
  String? get requestId => switch (this) {
    UnauthorizedFailure(:final envelope) ||
    ForbiddenFailure(:final envelope) ||
    NotFoundFailure(:final envelope) ||
    RouteAbsentFailure(:final envelope) ||
    ValidationFailure(:final envelope) ||
    RateLimitedFailure(:final envelope) ||
    DomainFailure(:final envelope) ||
    ServerFailure(:final envelope) => envelope?.requestId,
    UnexpectedShapeFailure(:final requestId) => requestId,
    _ => null,
  };

  /// Whether an idempotent request may be retried automatically.
  bool get isTransient => switch (this) {
    UnreachableFailure() || TimeoutFailure() => true,
    ServerFailure(:final statusCode) => const {
      502,
      503,
      504,
    }.contains(statusCode),
    _ => false,
  };
}
