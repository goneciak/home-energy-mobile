import 'dart:io';

import 'package:dio/dio.dart';

import 'package:gi_core_api/src/failures/api_error_envelope.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/http/transport_policy.dart';

/// Decides whether [error], raised while connecting to [uri], means the
/// operating system denied GI Home access to the local network (plan §9.4).
/// Injected through `createCoreDio` / `GiCoreClient.create`, so the
/// platform signatures found by spike S2 can be plugged in without touching
/// the mapping.
typedef LocalNetworkDeniedDetector = bool Function(Object? error, Uri uri);

/// POSIX `EPERM`: the kernel or a sandbox refused the operation.
const _ePerm = 1;

/// POSIX `EACCES`: permission denied.
const _eAcces = 13;

/// The conservative default [LocalNetworkDeniedDetector]: a [SocketException]
/// whose OS error is `EPERM` (1) or `EACCES` (13) while connecting to a
/// home-network host (private, link-local or loopback address, or a `.local`
/// name; see [TransportPolicy.isHomeNetworkHost]). A refused, unreachable or
/// timed-out connection is never classified as denied.
///
/// These are the errors a permission check produces on Android and Linux.
/// iOS may report the Local Network denial differently (for example as a
/// generic "no route to host"); spike S2 records the real signatures on
/// devices and extends this detector, and until then such errors stay
/// [ApiFailure.unreachable].
bool defaultLocalNetworkDeniedDetector(Object? error, Uri uri) {
  if (error is! SocketException) return false;
  final code = error.osError?.errorCode;
  if (code != _ePerm && code != _eAcces) return false;
  final host = error.address?.host ?? uri.host;
  return TransportPolicy.isHomeNetworkHost(host) ||
      TransportPolicy.isHomeNetworkHost(uri.host);
}

/// Maps any [DioException] to an [ApiFailure]. Idempotent: an exception that
/// already carries an [ApiFailure] yields that failure. [isLocalNetworkDenied]
/// classifies connection errors as [ApiFailure.localNetworkDenied].
ApiFailure mapDioException(
  DioException exception, {
  LocalNetworkDeniedDetector isLocalNetworkDenied =
      defaultLocalNetworkDeniedDetector,
}) {
  final error = exception.error;
  if (error is ApiFailure) return error;
  final uri = exception.requestOptions.uri;
  final host = uri.host;
  if ((exception.type == DioExceptionType.connectionError ||
          exception.type == DioExceptionType.unknown) &&
      _detects(isLocalNetworkDenied, error, uri)) {
    return ApiFailure.localNetworkDenied(reason: '$error');
  }
  return switch (exception.type) {
    DioExceptionType.connectionTimeout => const ApiFailure.unreachable(
      reason: 'connect timeout',
    ),
    // Dio raises connectionError both when connecting fails (SocketException:
    // nothing was sent) and when the server closes the connection before the
    // response headers (HttpException: the request may have been processed).
    DioExceptionType.connectionError =>
      error is HttpException
          ? ApiFailure.timeout(reason: error.message)
          : ApiFailure.unreachable(reason: exception.message),
    DioExceptionType.sendTimeout => const ApiFailure.timeout(
      reason: 'send timeout',
    ),
    DioExceptionType.receiveTimeout => const ApiFailure.timeout(
      reason: 'receive timeout',
    ),
    // The body arrived but decoding it took too long.
    DioExceptionType.transformTimeout => ApiFailure.unexpectedResponse(
      statusCode: exception.response?.statusCode,
    ),
    DioExceptionType.badCertificate => ApiFailure.tlsUntrusted(
      host: host,
      reason: 'certificate rejected',
    ),
    DioExceptionType.cancel => const ApiFailure.cancelled(),
    DioExceptionType.badResponse => failureFromResponse(
      statusCode: exception.response?.statusCode ?? 0,
      data: exception.response?.data,
      headers: exception.response?.headers,
    ),
    DioExceptionType.unknown => switch (error) {
      TlsException(:final message) => ApiFailure.tlsUntrusted(
        host: host,
        reason: message,
      ),
      FormatException() => ApiFailure.unexpectedResponse(
        statusCode: exception.response?.statusCode,
        contentType: exception.response?.headers.value(
          Headers.contentTypeHeader,
        ),
      ),
      // A socket error after the connection was established: the request
      // may have reached the server.
      _ => ApiFailure.timeout(reason: exception.message ?? '$error'),
    },
  };
}

/// A detector that throws is treated as "not denied": diagnostics must not
/// change how a failure is reported.
bool _detects(LocalNetworkDeniedDetector detector, Object? error, Uri uri) {
  try {
    return detector(error, uri);
  } on Object {
    return false;
  }
}

/// Maps a non-2xx response to an [ApiFailure] using the error envelope when
/// the body is one (plan §8.1).
ApiFailure failureFromResponse({
  required int statusCode,
  Object? data,
  Headers? headers,
}) {
  final envelope = ApiErrorEnvelope.tryParse(data);
  if (envelope == null) {
    if (statusCode == 429) {
      return ApiFailure.rateLimited(retryAfter: parseRetryAfter(headers));
    }
    if (statusCode >= 500) return ApiFailure.server(statusCode: statusCode);
    return ApiFailure.unexpectedResponse(
      statusCode: statusCode,
      contentType: headers?.value(Headers.contentTypeHeader),
    );
  }
  final code = envelope.code;
  if (code == 'HTTP_404') return ApiFailure.routeAbsent(envelope: envelope);
  if (code == 'VALIDATION_FAILED') {
    return ApiFailure.validation(details: envelope.details, envelope: envelope);
  }
  if (statusCode == 429 || code == 'HTTP_429') {
    return ApiFailure.rateLimited(
      retryAfter: parseRetryAfter(headers),
      envelope: envelope,
    );
  }
  return switch (statusCode) {
    401 => ApiFailure.unauthorized(code: code, envelope: envelope),
    403 => ApiFailure.forbidden(code: code, envelope: envelope),
    404 => ApiFailure.notFound(code: code, envelope: envelope),
    >= 500 => ApiFailure.server(
      statusCode: statusCode,
      errorCode: code,
      envelope: envelope,
    ),
    _ => ApiFailure.domain(
      statusCode: statusCode,
      code: code,
      envelope: envelope,
    ),
  };
}

/// Parses `Retry-After` given as delta-seconds or an HTTP date.
Duration? parseRetryAfter(Headers? headers, {DateTime? now}) {
  final value = headers?.value('retry-after')?.trim();
  if (value == null || value.isEmpty) return null;
  final seconds = int.tryParse(value);
  if (seconds != null) return seconds >= 0 ? Duration(seconds: seconds) : null;
  try {
    final date = HttpDate.parse(value);
    final delta = date.difference(now ?? DateTime.now().toUtc());
    return delta.isNegative ? Duration.zero : delta;
  } on HttpException {
    return null;
  }
}
