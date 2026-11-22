import 'package:dio/dio.dart';

import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart';
import 'package:gi_core_api/src/http/client_info.dart';
import 'package:gi_core_api/src/http/concurrency_limiter.dart';
import 'package:gi_core_api/src/http/conditional_get.dart';
import 'package:gi_core_api/src/http/interceptors.dart';

/// Builds a [Dio] for `<origin>/api/v1` with the standard interceptor chain:
/// transport policy → headers → [auth] (optional) → [conditionalGet]
/// (optional) → error mapping → logger.
///
/// Redirects are never followed: a redirect is either a proxy or a captive
/// portal and must not receive credentials.
///
/// With [limiter], the network exchange of every request takes one of its
/// slots (see [ConcurrencyLimitedAdapter]); pass the same limiter to every
/// [Dio] that talks to one appliance. [localNetworkDenied] classifies
/// connection errors as `ApiFailure.localNetworkDenied`.
Dio createCoreDio({
  required Uri apiBaseUrl,
  required ClientInfo clientInfo,
  String Function()? acceptLanguage,
  AuthInterceptor? auth,
  ConditionalGetInterceptor? conditionalGet,
  HttpLogSink? log,
  HttpClientAdapter? httpClientAdapter,
  ConcurrencyLimiter? limiter,
  LocalNetworkDeniedDetector localNetworkDenied =
      defaultLocalNetworkDeniedDetector,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl.toString(),
      connectTimeout: TimeoutClass.read.connect,
      receiveTimeout: TimeoutClass.read.receive,
      followRedirects: false,
      maxRedirects: 0,
    ),
  );
  final adapter = httpClientAdapter ?? dio.httpClientAdapter;
  dio.httpClientAdapter = limiter == null
      ? adapter
      : ConcurrencyLimitedAdapter(adapter, limiter);
  dio.interceptors.addAll([
    TransportPolicyInterceptor(),
    HeadersInterceptor(
      clientInfo: clientInfo,
      acceptLanguage: acceptLanguage ?? () => 'pl',
    ),
    ?auth,
    ?conditionalGet,
    ErrorMappingInterceptor(localNetworkDenied: localNetworkDenied),
    if (log != null) RedactingLogInterceptor(log),
  ]);
  auth?.attach(dio);
  return dio;
}

/// Sends [endpoint] with its method, timeouts and catalog metadata. Throws
/// [DioException] carrying an `ApiFailure` on failure.
Future<Response<Object?>> sendEndpoint(
  Dio dio,
  Endpoint endpoint, {
  Map<String, String> pathParams = const {},
  Map<String, Object?>? query,
  Object? data,
  Map<String, Object?>? headers,
  TimeoutClass? timeout,
}) {
  final timeouts = timeout ?? endpoint.timeout;
  return dio.request<Object?>(
    endpoint.resolvePath(pathParams),
    data: data,
    queryParameters: query,
    options: Options(
      method: endpoint.method.verb,
      headers: headers,
      connectTimeout: timeouts.connect,
      receiveTimeout: timeouts.receive,
      extra: {endpointExtraKey: endpoint},
    ),
  );
}
