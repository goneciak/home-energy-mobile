import 'dart:math';

import 'package:dio/dio.dart';

import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/failures/api_error_envelope.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart';
import 'package:gi_core_api/src/http/client_info.dart';
import 'package:gi_core_api/src/http/response_decoding.dart';
import 'package:gi_core_api/src/http/transport_policy.dart';

/// `RequestOptions.extra` key holding the catalog [Endpoint].
const endpointExtraKey = 'gi.endpoint';
const _usedTokenKey = 'gi.usedToken';

/// Set on requests that failed because the session could not provide a
/// token. Such failures must not be retried automatically: the refresh
/// policy (single attempt, health gate after an ambiguous outcome) decides.
const sessionFailureExtraKey = 'gi.sessionFailure';
const _replayedKey = 'gi.replayed';
const _stopwatchKey = 'gi.stopwatch';

/// Receives one redacted log line per request event.
typedef HttpLogSink = void Function(String line);

/// What [AuthInterceptor] needs from the session owner.
abstract interface class AccessTokenSource {
  /// A token valid for at least the refresh margin, refreshing if needed.
  Future<String> accessToken();

  /// Refreshes unless the current token differs from [rejectedToken]
  /// (someone else already refreshed).
  Future<String> ensureFresh({bool force = false, String? rejectedToken});

  /// Ends the session locally after the server declared it dead. Returns
  /// `false` when the session already moved on from [rejectedToken] (e.g. a
  /// new login) and was left alone.
  Future<bool> invalidate(SessionLostReason reason, {String? rejectedToken});
}

extension EndpointOptions on RequestOptions {
  Endpoint? get endpoint => switch (extra[endpointExtraKey]) {
    final Endpoint endpoint => endpoint,
    _ => null,
  };
}

/// Rejects cleartext requests to hosts outside the home network (§9.4).
final class TransportPolicyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (TransportPolicy.allows(options.uri)) {
      handler.next(options);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: options,
        error: ApiFailure.insecureTransport(host: options.uri.host),
      ),
    );
  }
}

/// Adds `Accept`, `Accept-Language`, `User-Agent` and `X-Request-Id`.
final class HeadersInterceptor extends Interceptor {
  new({
    required ClientInfo clientInfo,
    required this._acceptLanguage,
    Random? random,
  }) : _userAgent = clientInfo.userAgent,
       _random = random ?? Random.secure();

  final String _userAgent;
  final String Function() _acceptLanguage;
  final Random _random;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers
      ..[Headers.acceptHeader] = Headers.jsonContentType
      ..['accept-language'] = _acceptLanguage()
      ..['user-agent'] = _userAgent
      ..[requestIdHeader] = newRequestId(_random);
    handler.next(options);
  }

  /// `m-` followed by 32 hex digits; matches the server's accepted pattern.
  static String newRequestId(Random random) {
    final buffer = StringBuffer('m-');
    for (var i = 0; i < 16; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// Attaches the Bearer token to non-public endpoints and replays a request
/// once after a 401 and a single refresh (plan §6.5, §7.5).
final class AuthInterceptor extends Interceptor {
  new(this._tokens);

  final AccessTokenSource _tokens;
  late final Dio _dio;

  /// Binds the [Dio] used to replay requests; set once after construction.
  // A setter would read as a mutable property; this is one-time wiring.
  // ignore: use_setters_to_change_properties
  void attach(Dio dio) => _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!(options.endpoint?.requiresAuth ?? false)) {
      handler.next(options);
      return;
    }
    try {
      final token = await _tokens.accessToken();
      options
        ..headers['authorization'] = 'Bearer $token'
        ..extra[_usedTokenKey] = token;
      handler.next(options);
    } on ApiFailure catch (failure) {
      options.extra[sessionFailureExtraKey] = true;
      handler.reject(
        DioException(requestOptions: options, error: failure),
        true,
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    if (!(options.endpoint?.requiresAuth ?? false) ||
        (status != 401 && status != 403)) {
      handler.next(err);
      return;
    }
    final code = ApiErrorEnvelope.tryParse(err.response?.data)?.code;
    final lostReason = switch ((status, code)) {
      (401, 'AUTH_SESSION_REVOKED') => SessionLostReason.sessionRevoked,
      (403, 'USER_DISABLED') => SessionLostReason.userDisabled,
      _ => null,
    };
    if (lostReason != null) {
      final ended = await _tokens.invalidate(
        lostReason,
        rejectedToken: options.extra[_usedTokenKey] as String?,
      );
      handler.next(
        ended
            ? err.copyWith(error: ApiFailure.sessionLost(reason: lostReason))
            : err,
      );
      return;
    }
    if (status != 401 || options.extra[_replayedKey] == true) {
      handler.next(err);
      return;
    }
    try {
      await _tokens.ensureFresh(
        force: true,
        rejectedToken: options.extra[_usedTokenKey] as String?,
      );
    } on ApiFailure catch (failure) {
      options.extra[sessionFailureExtraKey] = true;
      handler.next(err.copyWith(error: failure));
      return;
    }
    // A write rejected by AuthGuard never reached its handler, so replaying
    // it once is safe.
    options.extra[_replayedKey] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (replayError) {
      handler.next(replayError);
    }
  }
}

/// Converts every [DioException] into one carrying an [ApiFailure].
final class ErrorMappingInterceptor extends Interceptor {
  new({this._localNetworkDenied = defaultLocalNetworkDeniedDetector});

  final LocalNetworkDeniedDetector _localNetworkDenied;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      err.error is ApiFailure
          ? err
          : err.copyWith(
              error: mapDioException(
                err,
                isLocalNetworkDenied: _localNetworkDenied,
              ),
            ),
    );
  }
}

/// Logs one line per request event without bodies, query strings or hosts;
/// `authorization`, `cookie` and `set-cookie` are redacted.
final class RedactingLogInterceptor extends Interceptor {
  new(this._sink);

  final HttpLogSink _sink;

  static const _sensitiveHeaders = {'authorization', 'cookie', 'set-cookie'};

  /// Copy of [headers] with sensitive values replaced by `<redacted>`.
  static Map<String, Object?> redactHeaders(Map<String, Object?> headers) => {
    for (final MapEntry(:key, :value) in headers.entries)
      key: _sensitiveHeaders.contains(key.toLowerCase()) ? '<redacted>' : value,
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_stopwatchKey] = Stopwatch()..start();
    _sink(
      '-> ${options.method} ${options.uri.path} '
      '${redactHeaders(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    _sink(
      '<- ${response.statusCode} ${options.method} ${options.uri.path} '
      '${_elapsed(options)} '
      '${redactHeaders(response.headers.map)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final error = err.error;
    final code = error is ApiFailure ? error.code : err.type.name;
    final requestId =
        err.response?.headers.value(requestIdHeader) ??
        options.headers[requestIdHeader];
    _sink(
      '<- ${err.response?.statusCode ?? '---'} ${options.method} '
      '${options.uri.path} ${_elapsed(options)} $code id=$requestId',
    );
    handler.next(err);
  }

  static String _elapsed(RequestOptions options) =>
      switch (options.extra[_stopwatchKey]) {
        final Stopwatch stopwatch => '${stopwatch.elapsedMilliseconds}ms',
        _ => '',
      };
}
