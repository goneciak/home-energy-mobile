import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef MockHandler = FutureOr<ResponseBody> Function(RequestOptions request);

/// In-process GI Core, plugged in through `coreHttpClientAdapterProvider`:
/// the dev flavor's mock (feature flag `mockCore`) and the widget tests'
/// fake. Nothing goes to the network.
///
/// Routes are keyed `'<METHOD> <path>'`, e.g. `'GET /api/v1/health/live'`;
/// unknown routes answer like Core does (404 `HTTP_404`). A handler may
/// throw a [DioException] to simulate a transport failure, or answer
/// asynchronously to hold a request in flight.
class MockCoreAdapter implements HttpClientAdapter {
  new([Map<String, MockHandler>? routes]) : routes = {...?routes};

  final Map<String, MockHandler> routes;
  final List<RequestOptions> requests = [];

  List<String> get requestedRoutes => [
    for (final r in requests) '${r.method} ${r.uri.path}',
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = '${options.method} ${options.uri.path}';
    final handler = routes[route];
    if (handler == null) {
      return jsonReply(
        errorEnvelope(404, 'HTTP_404', path: options.uri.path),
        status: 404,
      );
    }
    return await handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonReply(
  Object? body, {
  int status = 200,
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    ...headers,
  },
);

ResponseBody htmlReply(String html, {int status = 200}) =>
    ResponseBody.fromString(
      html,
      status,
      headers: {
        Headers.contentTypeHeader: ['text/html; charset=utf-8'],
      },
    );

Map<String, Object?> errorEnvelope(
  int status,
  String code, {
  String path = '/api/v1',
  String message = 'error',
}) => {
  'statusCode': status,
  'code': code,
  'message': message,
  'path': path,
  'requestId': 'srv-req-1',
  'timestamp': '2026-11-17T22:06:20.919Z',
};

Never refuseConnection(RequestOptions request) =>
    throw DioException.connectionError(
      requestOptions: request,
      reason: 'Connection refused',
    );

/// Recorded `/setup/status` of the seeded dev appliance.
const Map<String, Object> initializedSetup = {
  'initialized': true,
  'initializedAt': '2026-11-17T22:06:20.184Z',
  'deviceName': 'GI Home Dev',
  'locale': 'pl-PL',
  'timezone': 'Europe/Warsaw',
};

const Map<String, Object?> uninitializedSetup = {
  'initialized': false,
  'initializedAt': null,
  'deviceName': null,
  'locale': 'pl-PL',
  'timezone': 'Europe/Warsaw',
};

const Map<String, Object> ownerUser = {
  'id': 'cmwl8s1se000680n2ryr54481',
  'email': 'owner@gihome.test',
  'firstName': 'Dev',
  'lastName': 'Owner',
  'role': 'OWNER',
  'mustChangePassword': false,
};

/// A syntactically valid refresh cookie (a mock value, not a real token).
final mockSetCookie =
    'gi_refresh_token=11111111-1111-4111-8111-111111111111.${'A' * 43}; '
    'Max-Age=2592000; Path=/api/v1/auth/refresh; HttpOnly; SameSite=Lax';

/// Routes of an appliance that is up and set up.
Map<String, MockHandler> healthyApplianceRoutes() => {
  'GET /api/v1/health/live': (_) => jsonReply({'status': 'ok'}),
  'GET /api/v1/setup/status': (_) => jsonReply(initializedSetup),
};

/// The dev flavor's mock GI Core: a set-up appliance that signs in any
/// email and password as an owner and lists two rooms and two devices,
/// last seen at the time of the request. Writes are not mocked (the app
/// has none beyond the password change, which succeeds).
Map<String, MockHandler> mockCoreRoutes() {
  Map<String, Object?> device(Map<String, Object?> fields) => {
    'description': null,
    'serialNumber': null,
    'firmwareVersion': null,
    'status': 'online',
    'createdAt': '2026-11-17T22:06:20.578Z',
    'updatedAt': '2026-11-17T22:06:20.578Z',
    'lastSeenAt': DateTime.now().toUtc().toIso8601String(),
    'enabled': true,
    'communicationMode': 'GI_EDGE_V1',
    'lastConnectionError': null,
    'lastConnectionAttemptAt': null,
    'lastKnownIp': null,
    'heatingRelayEntityId': null,
    'controlTemperatureEntityId': null,
    'pumpRelayEntityId': null,
    'pumpComparisonEntityId': null,
    'inverterIntegrationMode': 'DISABLED',
    'inverterVendorProfileId': null,
    'heatingSuspended': false,
    'fallbackThresholdMs': 120000,
    'boilerEstimateWindowMinutes': 10,
    'localControlTemperatureSource': 'SUPPLY',
    'dryRun': false,
    'activeFaultCount': 0,
    'currentState': null,
    'capabilities': <Object?>[],
    'connectivityState': 'ONLINE',
    ...fields,
  };
  List<Map<String, Object?>> devices() => [
    device({
      'id': _boilerRoomControllerId,
      'name': 'Sterownik kotłowni',
      'manufacturer': 'GI Industries',
      'model': 'kotlownia',
      'type': 'ESP32',
      'roomId': _boilerRoomId,
    }),
    device({
      'id': _livingRoomLampId,
      'name': 'Lampa w salonie',
      'manufacturer': 'GI Dev',
      'model': null,
      'type': 'VIRTUAL',
      'roomId': _livingRoomId,
    }),
  ];
  ResponseBody signedIn(Map<String, Object?> body) => jsonReply(
    body,
    headers: {
      'set-cookie': [mockSetCookie],
    },
  );

  return {
    ...healthyApplianceRoutes(),
    'POST /api/v1/auth/login': (_) => signedIn({
      'accessToken': 'mock-access',
      'expiresIn': 900,
      'user': ownerUser,
    }),
    'POST /api/v1/auth/refresh': (_) =>
        signedIn({'accessToken': 'mock-access', 'expiresIn': 900}),
    'POST /api/v1/auth/logout': (_) => jsonReply(null, status: 204),
    'GET /api/v1/auth/me': (_) => jsonReply(ownerUser),
    'GET /api/v1/users/me/profile': (_) => jsonReply({
      ...ownerUser,
      'locale': 'pl-PL',
      'enabled': true,
      'lastLoginAt': null,
      'createdAt': '2026-11-17T22:06:20.174Z',
      'updatedAt': '2026-11-17T22:06:20.174Z',
    }),
    'POST /api/v1/users/me/change-password': (_) =>
        jsonReply(null, status: 204),
    'GET /api/v1/rooms': (_) => jsonReply([
      for (final (id, name) in [
        (_boilerRoomId, 'Kotłownia'),
        (_livingRoomId, 'Salon'),
      ])
        {
          'id': id,
          'name': name,
          'description': null,
          'sortOrder': 0,
          'createdAt': '2026-11-17T22:06:20.443Z',
          'updatedAt': '2026-11-17T22:06:20.443Z',
        },
    ]),
    'GET /api/v1/devices': (_) {
      final items = devices();
      return jsonReply({
        'items': items,
        'page': 1,
        'limit': 100,
        'total': items.length,
        'totalPages': 1,
      });
    },
    for (final item in devices())
      'GET /api/v1/devices/${item['id']}': (_) => jsonReply({
        ...devices().firstWhere((d) => d['id'] == item['id']),
        'entities': <Object?>[],
        'hostname': null,
        'mac': null,
        'diagnostics': null,
        'controlStrategy': null,
        'baseControlStrategy': null,
        'configurationVersion': 1,
        'pvHeatingConfig': null,
        'pvProductionEntityId': null,
        'pvConsumptionEntityId': null,
        'pvBoostActive': false,
      }),
  };
}

const _boilerRoomId = '15a6de6e-f36c-4741-9775-53cd03413ccb';
const _livingRoomId = '875e2b40-bc93-4257-bee2-fa1c1e0b84fc';
const _boilerRoomControllerId = '60d5a6b9-e974-45b0-b3ee-43e264d1ec85';
const _livingRoomLampId = 'fbc51583-9b91-420e-bd94-694c691dcf63';
