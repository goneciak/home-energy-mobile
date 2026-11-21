import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';

import 'fixtures.dart';

export 'fixtures.dart';

const _sessionId = '11111111-1111-4111-8111-111111111111';
final testCookieValue1 = '$_sessionId.${'A' * 43}';
final testCookieValue2 = '$_sessionId.${'B' * 43}';
final testCookieValue3 = '$_sessionId.${'C' * 43}';

String setCookieFor(String value) =>
    'gi_refresh_token=$value; Max-Age=2592000; Path=/api/v1/auth/refresh; '
    'Expires=Thu, 17 Dec 2026 22:06:20 GMT; HttpOnly; SameSite=Lax';

/// A request seen by [FakeCore].
final class FakeRequest {
  new(this.options, this.body);

  final RequestOptions options;
  final String? body;

  String get method => options.method;
  String get path => options.uri.path;
  String get route => '$method $path';

  String? header(String name) {
    final lower = name.toLowerCase();
    for (final MapEntry(:key, :value) in options.headers.entries) {
      if (key.toLowerCase() == lower) return value?.toString();
    }
    return null;
  }

  Map<String, dynamic>? get json => body == null || body!.isEmpty
      ? null
      : jsonDecode(body!) as Map<String, dynamic>;
}

/// Canned response for [FakeCore].
final class FakeResponse {
  new json(
    Object? body, {
    this.status = 200,
    Map<String, List<String>> headers = const {},
  }) : body = jsonEncode(body),
       headers = {
         'content-type': ['application/json; charset=utf-8'],
         'x-request-id': ['srv-req-1'],
         ...headers,
       };

  new html(this.body, {this.status = 200})
    : headers = {
        'content-type': ['text/html; charset=utf-8'],
      };

  new empty({this.status = 204}) : body = '', headers = const {};

  /// GI Core error envelope.
  factory error(
    int status,
    String code, {
    Map<String, List<String>> headers = const {},
  }) => FakeResponse.json(
    {
      'statusCode': status,
      'code': code,
      'message': code,
      'path': '/api/v1',
      'requestId': 'srv-req-err',
      'timestamp': '2026-11-17T22:06:20.000Z',
    },
    status: status,
    headers: headers,
  );

  final int status;
  final String body;
  final Map<String, List<String>> headers;
}

typedef FakeHandler = FutureOr<FakeResponse> Function(FakeRequest request);

/// In-process GI Core: an [HttpClientAdapter] that routes by `METHOD path`.
/// A handler may throw a [DioException] to simulate network failures.
final class FakeCore implements HttpClientAdapter {
  final Map<String, FakeHandler> _routes = {};
  final List<FakeRequest> requests = [];

  /// Shared event log; tests may add their own entries to check ordering.
  final List<String> events = [];

  void on(String method, String path, FakeHandler handler) =>
      _routes['$method /api/v1$path'] = handler;

  List<FakeRequest> requestsTo(String method, String path) => [
    for (final r in requests)
      if (r.route == '$method /api/v1$path') r,
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = requestStream == null
        ? null
        : utf8.decode(await requestStream.expand((chunk) => chunk).toList());
    final request = FakeRequest(options, body);
    requests.add(request);
    events.add(
      '${request.route} ${request.header('authorization') ?? ''}'.trim(),
    );
    final handler = _routes[request.route];
    final response = handler == null
        ? FakeResponse.error(404, 'HTTP_404')
        : await handler(request);
    return ResponseBody.fromString(
      response.body,
      response.status,
      headers: response.headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Simulated "connection refused": nothing was sent.
DioException refused(FakeRequest request) => DioException.connectionError(
  requestOptions: request.options,
  reason: 'refused',
  error: const SocketException('Connection refused'),
);

/// Simulated receive timeout: the request was sent, no answer arrived.
DioException receiveTimeout(FakeRequest request) => DioException.receiveTimeout(
  timeout: const Duration(seconds: 30),
  requestOptions: request.options,
);

final class FakeClock implements MonotonicClock {
  @override
  Duration elapsed = Duration.zero;

  void advance(Duration duration) => elapsed += duration;
}

/// [InMemoryTokenVault] that also records its operations in [events].
final class RecordingVault extends InMemoryTokenVault {
  new(this.events, [super._cookie, super._accessToken]);

  final List<String> events;

  @override
  Future<void> write(RefreshCookie cookie) async {
    await super.write(cookie);
    events.add('vault.write ${cookie.generation}');
  }

  @override
  Future<void> clear() async {
    await super.clear();
    events.add('vault.clear');
  }

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) async {
    await super.writeAccessToken(token);
    events.add('vault.writeAccess');
  }

  @override
  Future<void> clearAccessToken() async {
    await super.clearAccessToken();
    events.add('vault.clearAccess');
  }
}

RefreshCookie storedCookie({
  String? value,
  int generation = 0,
  DateTime? absoluteExpiry,
}) => RefreshCookie(
  name: 'gi_refresh_token',
  value: value ?? testCookieValue1,
  path: '/api/v1/auth/refresh',
  obtainedAt: DateTime.utc(2026, 11, 17),
  absoluteExpiry: absoluteExpiry ?? DateTime.utc(2026, 12, 17),
  generation: generation,
);

const testClientInfo = ClientInfo(appVersion: '0.1.0', platform: 'Test; Dart');

final testAddress = ApplianceAddress.parse('http://192.168.1.10:3000');

Map<String, Object?> loginBody({
  String token = 'access-1',
  int expiresIn = 900,
}) => {
  ...fixtureObject('AuthController_login/ok.json'),
  'accessToken': token,
  'expiresIn': expiresIn,
};

Map<String, Object?> refreshBody(String token, {int expiresIn = 900}) => {
  'accessToken': token,
  'expiresIn': expiresIn,
};

/// Builds a [GiCoreClient] on [core] with zero retry backoff and a fake
/// clock; the wall clock is fixed at 2026-11-17 unless [now] is given.
GiCoreClient testClient(
  FakeCore core, {
  TokenVault? vault,
  FakeClock? clock,
  DateTime Function()? now,
  DateTime? expectedInitializedAt,
  String? expectedDeviceName,
  ApplianceRenamed? onApplianceRenamed,
  Future<void> Function()? waitUntilForeground,
  HttpLogSink? log,
  ApiFailureObserver? onFailure,
  ConcurrencyLimiter? requestLimiter,
  LocalNetworkDeniedDetector localNetworkDenied =
      defaultLocalNetworkDeniedDetector,
  DecodeMode decodeMode = DecodeMode.tolerant,
  ApplianceAddress? address,
  HttpClientAdapter? adapter,
}) => GiCoreClient.create(
  address: address ?? testAddress,
  vault: vault ?? InMemoryTokenVault(),
  clientInfo: testClientInfo,
  httpClientAdapter: adapter ?? core,
  clock: clock ?? FakeClock(),
  now: now ?? () => DateTime.utc(2026, 11, 17, 12),
  expectedInitializedAt: expectedInitializedAt,
  expectedDeviceName: expectedDeviceName,
  onApplianceRenamed: onApplianceRenamed,
  waitUntilForeground: waitUntilForeground,
  retryBackoff: (_) => Duration.zero,
  log: log,
  onFailure: onFailure,
  requestLimiter: requestLimiter,
  localNetworkDenied: localNetworkDenied,
  decodeMode: decodeMode,
);
