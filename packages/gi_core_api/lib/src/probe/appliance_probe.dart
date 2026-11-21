import 'package:dio/dio.dart';

import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/catalog/endpoints.dart';
import 'package:gi_core_api/src/converters/json_converters.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:gi_core_api/src/failures/failure_mapping.dart';
import 'package:gi_core_api/src/failures/failure_observer.dart';
import 'package:gi_core_api/src/http/client_info.dart';
import 'package:gi_core_api/src/http/dio_factory.dart';
import 'package:gi_core_api/src/http/response_decoding.dart';
import 'package:gi_core_api/src/http/transport_policy.dart';
import 'package:gi_core_api/src/models/system_models.dart';
import 'package:gi_core_api/src/probe/appliance_address.dart';

/// A confirmed GI Home candidate: `/health/live` answered and
/// `/setup/status` parsed (plan §9.2).
final class ProbeResult {
  const new({required this.address, required this.health, required this.setup});

  final ApplianceAddress address;
  final HealthLive health;
  final SetupStatus setup;
}

/// Checks an address typed on the connect screen with short LAN timeouts
/// (1.5 s connect, 2 s receive) before any credentials are sent.
/// An `onFailure` observer sees every [ApiFailure] [probe] throws.
final class ApplianceProbe {
  new({
    required this._clientInfo,
    this._acceptLanguage,
    this._httpClientAdapter,
    this._onFailure,
  });

  final ClientInfo _clientInfo;
  final String Function()? _acceptLanguage;
  final HttpClientAdapter? _httpClientAdapter;
  final ApiFailureObserver? _onFailure;

  /// Normalises [rawAddress] and probes it. Throws [FormatException] for an
  /// address that cannot be parsed and [ApiFailure] when the appliance does
  /// not answer as GI Core.
  Future<ProbeResult> probe(String rawAddress) async {
    final address = ApplianceAddress.parse(rawAddress);
    return await probeAddress(address);
  }

  /// Probes an already normalised [address] (the connection ladder,
  /// plan §9.2). With [healthTimeout], `GET /health/live` must answer
  /// within it as a whole, or the probe fails with [TimeoutFailure]: the
  /// ladder gives a remembered host 1.5 s.
  Future<ProbeResult> probeAddress(
    ApplianceAddress address, {
    Duration? healthTimeout,
  }) => observeFailures(
    _onFailure,
    () => _probe(address, healthTimeout: healthTimeout),
  );

  Future<ProbeResult> _probe(
    ApplianceAddress address, {
    Duration? healthTimeout,
  }) async {
    if (!TransportPolicy.allows(address.origin)) {
      throw ApiFailure.insecureTransport(host: address.origin.host);
    }
    final dio = createCoreDio(
      apiBaseUrl: address.apiBaseUrl,
      clientInfo: _clientInfo,
      acceptLanguage: _acceptLanguage,
      httpClientAdapter: _httpClientAdapter,
    );
    try {
      var healthRequest = _get(
        dio,
        GiEndpoints.healthLive,
        (json) => HealthLive.fromJson(asJsonObject(json)),
      );
      if (healthTimeout != null) {
        healthRequest = healthRequest.timeout(
          healthTimeout,
          onTimeout: () => throw const ApiFailure.timeout(
            reason: 'health/live did not answer in time',
          ),
        );
      }
      final health = await healthRequest;
      final setup = await _get(
        dio,
        GiEndpoints.setupStatus,
        (json) => SetupStatus.fromJson(asJsonObject(json)),
      );
      return ProbeResult(address: address, health: health, setup: setup);
    } finally {
      // Forced: a request abandoned by [healthTimeout] is aborted.
      dio.close(force: true);
    }
  }

  static Future<T> _get<T>(
    Dio dio,
    Endpoint endpoint,
    T Function(Object? json) decode,
  ) async {
    try {
      final response = await sendEndpoint(
        dio,
        endpoint,
        timeout: TimeoutClass.probe,
      );
      return decodeResponse<T>(endpoint, response, decode);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
