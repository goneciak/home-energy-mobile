import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_home/src/core/l10n/l10n.dart';

/// Generic user-facing text for any error thrown by the GI Core client
/// (plan §8.1). Screens handle their own specific codes first (for example
/// `AUTH_INVALID_CREDENTIALS` on the login form) and fall back to this.
String failureMessage(AppLocalizations l10n, Object error) =>
    (error is ApiFailure
        ? deviceCommandFailureMessage(l10n, error) ??
              _readFailureMessage(l10n, error)
        : null) ??
    _genericFailureMessage(l10n, error);

/// Text for error codes of read endpoints, or `null`.
String? _readFailureMessage(AppLocalizations l10n, ApiFailure failure) =>
    switch (failure.code) {
      GiErrorCodes.historyRangeInvalid => l10n.errorHistoryRangeInvalid,
      _ => null,
    };

/// Text for the device-control error codes (plan §8.2, §12), or `null` for
/// any other failure. None of them claims a relay switched: an unconfirmed
/// or timed-out command leaves the state unknown.
String? deviceCommandFailureMessage(
  AppLocalizations l10n,
  ApiFailure failure,
) => switch (failure.code) {
  GiErrorCodes.deviceEntityNotFound => l10n.errorDeviceEntityNotFound,
  GiErrorCodes.deviceNotFound => l10n.errorDeviceNotFound,
  GiErrorCodes.heatingSuspended => l10n.errorHeatingSuspended,
  GiErrorCodes.entityDisabled => l10n.errorEntityDisabled,
  GiErrorCodes.entityNotWritable => l10n.errorEntityNotWritable,
  GiErrorCodes.deviceOffline => l10n.errorDeviceOffline,
  GiErrorCodes.espHomeDeviceUnreachable => l10n.errorDeviceUnreachable,
  GiErrorCodes.espHomeCommandRejected ||
  GiErrorCodes.espHomeCommandUnconfirmed => l10n.errorCommandUnconfirmed,
  GiErrorCodes.espHomeCommandTimeout => l10n.errorCommandTimeout,
  GiErrorCodes.espHomeHostForbidden => l10n.errorDeviceHostForbidden,
  _ => null,
};

String _genericFailureMessage(AppLocalizations l10n, Object error) =>
    switch (error) {
      UnreachableFailure() => l10n.errorUnreachable,
      TimeoutFailure() => l10n.errorTimeout,
      LocalNetworkDeniedFailure() => l10n.errorLocalNetworkDenied,
      TlsUntrustedFailure() => l10n.errorTlsUntrusted,
      InsecureTransportFailure() => l10n.errorInsecureTransport,
      // A 401 that did not end the session (that is SessionLostFailure).
      UnauthorizedFailure() => l10n.errorUnauthorized,
      ForbiddenFailure() => l10n.errorForbidden,
      NotFoundFailure() => l10n.errorNotFound,
      RouteAbsentFailure() => l10n.errorRouteAbsent,
      ValidationFailure() => l10n.errorValidation,
      RateLimitedFailure() => l10n.errorRateLimited,
      DomainFailure() => l10n.errorGeneric,
      // 503: starting up or being updated; the same state as maintenance.
      ServerFailure(statusCode: 503) => l10n.errorMaintenance,
      ServerFailure() => l10n.errorServer,
      UnexpectedResponseFailure() => l10n.errorUnexpectedResponse,
      UnexpectedShapeFailure() => l10n.errorUnexpectedShape,
      SessionLostFailure(:final reason) => sessionLostMessage(l10n, reason),
      RefreshCookieMissingFailure() => l10n.errorRefreshCookieMissing,
      VaultUnavailableFailure() => l10n.errorVaultUnavailable,
      DifferentApplianceFailure() => l10n.errorDifferentAppliance,
      ApplianceResetFailure() => l10n.errorApplianceReset,
      CancelledFailure() => l10n.errorCancelled,
      _ => l10n.errorGeneric,
    };

/// Explanation shown on the login screen after the session ended without
/// the user's action (plan §7.5).
String sessionLostMessage(AppLocalizations l10n, SessionLostReason reason) =>
    switch (reason) {
      SessionLostReason.refreshTokenInvalid ||
      SessionLostReason.refreshTokenReused ||
      SessionLostReason.sessionRevoked ||
      SessionLostReason.refreshRejected => l10n.sessionLostRevoked,
      SessionLostReason.userDisabled => l10n.sessionLostUserDisabled,
      SessionLostReason.expired => l10n.sessionLostExpired,
      SessionLostReason.noToken ||
      SessionLostReason.protocol => l10n.sessionLostProtocol,
      SessionLostReason.vaultWiped => l10n.sessionLostVaultWiped,
    };

/// Support reference for generic errors: the server request id, if any.
String? failureRequestIdLine(AppLocalizations l10n, Object error) {
  final requestId = error is ApiFailure ? error.requestId : null;
  return requestId == null ? null : l10n.errorRequestId(requestId);
}
