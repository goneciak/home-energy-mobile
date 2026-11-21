import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// The recorded responses of one backend ref
/// (`packages/gi_core_api/test/fixtures/core/<ref>/<endpointId>/<case>.*`).
final class MockCoreFixtures {
  const new(this.ref, this.json, this.text);

  /// Loads every `<endpointId>/<case>.json` (and the companion text files,
  /// e.g. `ok.set-cookie.txt`) under [dir].
  factory load(Directory dir) {
    if (!dir.existsSync()) {
      throw ArgumentError.value(dir.path, 'dir', 'no such fixtures folder');
    }
    final json = <String, Map<String, Object?>>{};
    final text = <String, Map<String, String>>{};
    final folders = dir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final folder in folders) {
      final id = folder.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      final files = folder.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final file in files) {
        final name = file.uri.pathSegments.last;
        if (name.endsWith('.json')) {
          (json[id] ??= {})[name.substring(0, name.length - 5)] = jsonDecode(
            file.readAsStringSync(),
          );
        } else {
          (text[id] ??= {})[name] = file.readAsStringSync().trim();
        }
      }
    }
    return MockCoreFixtures(
      dir.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
      json,
      text,
    );
  }

  /// The backend ref (folder name) the fixtures were recorded against.
  final String ref;

  /// Endpoint id -> case name -> decoded JSON body.
  final Map<String, Map<String, Object?>> json;

  /// Endpoint id -> file name -> text (non-JSON companions).
  final Map<String, Map<String, String>> text;

  static const _preferredCases = ['ok', 'seeded', 'owner', 'initialized'];

  /// The success case served for [endpointId]: the first of `ok`, `seeded`,
  /// `owner`, `initialized`, else the first case not named `error_*`.
  Object? success(String endpointId) {
    final cases = json[endpointId];
    if (cases == null) return null;
    for (final name in _preferredCases) {
      if (cases.containsKey(name)) return _copy(cases[name]);
    }
    for (final MapEntry(:key, :value) in cases.entries) {
      if (!key.startsWith('error_')) return _copy(value);
    }
    return null;
  }

  /// Every success case of [endpointId].
  Iterable<Object?> successCases(String endpointId) sync* {
    for (final MapEntry(:key, :value)
        in (json[endpointId] ?? const {}).entries) {
      if (!key.startsWith('error_')) yield _copy(value);
    }
  }

  static Object? _copy(Object? json) => jsonDecode(jsonEncode(json));
}

/// The fixtures folder for [ref], or (when that folder does not exist) the
/// most recently changed one under [root]: "the latest backendRef".
Directory resolveFixturesDir(Directory root, String? ref) {
  if (ref != null) {
    final dir = Directory('${root.path}/$ref');
    if (dir.existsSync()) return dir;
  }
  final dirs = root.listSync().whereType<Directory>().toList()
    ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  if (dirs.isEmpty) {
    throw StateError('No fixtures under ${root.path}');
  }
  return dirs.first;
}

final class _Session {
  new(this.id, this.user, this.password, this.refresh);

  final String id;
  final Map<String, Object?> user;
  final String password;
  String refresh;
  bool revoked = false;
}

final class _Access {
  const new(this.session, this.expiresAt);

  final _Session session;
  final DateTime expiresAt;
}

/// Dev-only GI Core (plan §17.1): serves the catalog endpoints
/// ([GiEndpoints.all]) from recorded fixtures with a minimal in-memory auth.
///
/// * `POST /auth/login` takes exactly `{email, password}` (anything else is
///   `VALIDATION_FAILED`, like Core); any e-mail signs in as the recorded
///   owner with that e-mail. With [password] set, only that password works
///   (`AUTH_INVALID_CREDENTIALS` otherwise). There is no rate limit.
/// * The refresh cookie (`gi_refresh_token`, `Path=/api/v1/auth/refresh`)
///   rotates on every `POST /auth/refresh`; replaying a rotated one answers
///   `AUTH_REFRESH_TOKEN_REUSED` and revokes the session, as Core does.
/// * Access tokens are opaque and live [accessTokenTtl]; then
///   `AUTH_ACCESS_TOKEN_EXPIRED`.
/// * `GET /auth/me` and `GET /users/me/profile` return the recorded owner
///   with the signed-in e-mail; `POST /users/me/change-password` checks the
///   body (and the current password when [password] is set) and revokes the
///   other sessions.
/// * `GET /devices/{id}` serves the recorded details by id; a listed device
///   without a recorded detail gets one built from the list item. With
///   [freshLastSeen], a device's non-null `lastSeenAt` is the request time,
///   so the app sees it online.
/// * The M2 writes act on an in-memory copy of the recorded details (plan
///   §12), checked in GI Core's order: `PUT .../entities/{entityId}/state`
///   (`{"state": bool}`; 404 `DEVICE_ENTITY_NOT_FOUND`, 409
///   `HEATING_SUSPENDED` for ON while suspended, 422 `ENTITY_NOT_WRITABLE`,
///   409 `ENTITY_DISABLED`, 503 `DEVICE_OFFLINE`, then [switchFailure] on a
///   legacy device). A legacy device is confirmed at once; a GI_EDGE_V1
///   device is written optimistically, or not at all in dry-run, where the
///   answer carries the OLD state. `PATCH /devices/{id}` takes
///   `heatingSuspended` and `dryRun` (suspending turns every switch OFF and
///   the effective mode to OFF); `PATCH .../control-strategy` takes all
///   three fields within Core's ranges.
/// * Anything else is Core's `404 HTTP_404` envelope.
final class MockCore {
  new({
    required this.fixtures,
    this.password,
    this.accessTokenTtl = const Duration(minutes: 15),
    this.freshLastSeen = true,
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random.secure();

  final MockCoreFixtures fixtures;

  /// The only accepted password; null accepts any non-empty one.
  String? password;
  final Duration accessTokenTtl;
  final bool freshLastSeen;
  final DateTime Function() _now;
  final Random _random;

  /// A failure the legacy switch commands answer with instead of switching:
  /// a key of [switchFailures]. Null switches normally.
  String? switchFailure;

  /// The legacy-path failures of `PUT .../state` and their HTTP status
  /// (`esphome-switch-command.service.ts`).
  static const switchFailures = <String, int>{
    'ESPHOME_DEVICE_UNREACHABLE': 503,
    'ESPHOME_COMMAND_REJECTED': 502,
    'ESPHOME_COMMAND_UNCONFIRMED': 502,
    'ESPHOME_COMMAND_TIMEOUT': 504,
  };

  /// Device details changed by the M2 writes, by device id.
  final Map<String, Map<String, Object?>> _changed = {};

  final Map<String, _Session> _sessionsByRefresh = {};
  final Map<String, _Access> _accessTokens = {};
  final List<_Session> _sessions = [];

  static const apiPrefix = '/api/v1';
  static const String cookieName = RefreshCookieCodec.defaultName;
  static const _cookiePath = '$apiPrefix/auth/refresh';

  /// Sessions that are not revoked.
  int get activeSessions => _sessions.where((s) => !s.revoked).length;

  Handler get handler => _handle;

  Future<Response> _handle(Request request) async {
    final requestId =
        request.headers['x-request-id'] ?? _uuid(); // Core echoes it.
    Response response;
    try {
      response = await _route(request, requestId);
    } on _Reply catch (reply) {
      response = reply.response;
    }
    return response.change(headers: {'x-request-id': requestId});
  }

  Future<Response> _route(Request request, String requestId) async {
    final path = '/${request.url.path}';
    final match = _match(request.method, path);
    if (match == null) {
      return _error(
        request,
        requestId,
        404,
        'HTTP_404',
        'Cannot ${request.method} $path',
      );
    }
    final (endpoint, params) = match;

    _Access? access;
    if (endpoint.requiresAuth) {
      access = _authenticate(request, requestId);
      final role = UserRole.values.firstWhere(
        (r) => r.name.toUpperCase() == access!.session.user['role'],
        orElse: () => UserRole.user,
      );
      if (!endpoint.allows(role)) {
        return _error(request, requestId, 403, 'HTTP_403', 'Forbidden');
      }
    }

    switch (endpoint.id) {
      case 'AuthController_login':
        return await _login(request, requestId);
      case 'AuthController_refresh':
        return _refresh(request, requestId);
      case 'AuthController_logout':
        access!.session.revoked = true;
        return Response(
          204,
          headers: {
            'set-cookie':
                fixtures.text['AuthController_logout']?['ok.set-cookie.txt'] ??
                '$cookieName=; Path=$_cookiePath; '
                    'Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; '
                    'SameSite=Lax',
          },
        );
      case 'AuthController_getMe' || 'UsersController_getProfile':
        return _json({
          ...?fixtures.success(endpoint.id) as Map<String, Object?>?,
          ..._identity(access!.session.user),
        });
      case 'UsersController_changePassword':
        return await _changePassword(request, requestId, access!.session);
      case 'DevicesController_get':
        return _device(request, requestId, params['id']!);
      case 'DeviceEspHomeSyncController_setSwitchState':
        return await _setSwitchState(
          request,
          requestId,
          params['id']!,
          params['entityId']!,
        );
      case 'DevicesController_update':
        return await _updateDevice(request, requestId, params['id']!);
      case 'DevicesController_updateControlStrategy':
        return await _updateControlStrategy(request, requestId, params['id']!);
    }

    if (endpoint.method != HttpMethod.get) {
      return _error(
        request,
        requestId,
        501,
        'HTTP_501',
        'mock_core does not implement ${endpoint.id}',
      );
    }
    final body = fixtures.success(endpoint.id);
    if (body == null) {
      return _error(
        request,
        requestId,
        404,
        'HTTP_404',
        'mock_core has no fixture for ${endpoint.id}',
      );
    }
    return _json(_freshen(body));
  }

  /// Every catalog endpoint with its path as a pattern and the placeholder
  /// names (`/devices/{id}` -> `^/api/v1/devices/([^/]+)/?$`, `[id]`).
  static final List<(Endpoint, RegExp, List<String>)> _routes = [
    for (final endpoint in GiEndpoints.all) _compileRoute(endpoint),
  ];

  static (Endpoint, RegExp, List<String>) _compileRoute(Endpoint endpoint) {
    final names = <String>[];
    final pattern = StringBuffer('^');
    var last = 0;
    final full = '$apiPrefix${endpoint.path}';
    for (final match in RegExp(r'\{(\w+)\}').allMatches(full)) {
      pattern
        ..write(RegExp.escape(full.substring(last, match.start)))
        ..write('([^/]+)');
      names.add(match[1]!);
      last = match.end;
    }
    pattern
      ..write(RegExp.escape(full.substring(last)))
      ..write(r'/?$');
    return (endpoint, RegExp(pattern.toString()), names);
  }

  (Endpoint, Map<String, String>)? _match(String method, String path) {
    for (final (endpoint, pattern, names) in _routes) {
      if (endpoint.method.verb != method) continue;
      final match = pattern.firstMatch(path);
      if (match == null) continue;
      return (
        endpoint,
        {
          for (var i = 0; i < names.length; i++)
            names[i]: Uri.decodeComponent(match[i + 1]!),
        },
      );
    }
    return null;
  }

  _Access _authenticate(Request request, String requestId) {
    final header = request.headers[HttpHeaders.authorizationHeader];
    if (header == null || !header.startsWith('Bearer ')) {
      throw _Reply(
        _error(
          request,
          requestId,
          401,
          'AUTH_UNAUTHORIZED',
          'Authentication required.',
        ),
      );
    }
    final access = _accessTokens[header.substring('Bearer '.length).trim()];
    if (access == null) {
      throw _Reply(
        _error(
          request,
          requestId,
          401,
          'AUTH_ACCESS_TOKEN_INVALID',
          'Access token is invalid.',
        ),
      );
    }
    if (!_now().isBefore(access.expiresAt)) {
      throw _Reply(
        _error(
          request,
          requestId,
          401,
          'AUTH_ACCESS_TOKEN_EXPIRED',
          'Access token has expired.',
        ),
      );
    }
    if (access.session.revoked) {
      throw _Reply(
        _error(
          request,
          requestId,
          401,
          'AUTH_SESSION_REVOKED',
          'Session is no longer active.',
        ),
      );
    }
    return access;
  }

  Future<Response> _login(Request request, String requestId) async {
    final body = await _body(
      request,
      requestId,
      required: const ['email', 'password'],
    );
    final email = body['email']! as String;
    final given = body['password']! as String;
    if (!email.contains('@') || (password != null && given != password)) {
      return _error(
        request,
        requestId,
        401,
        'AUTH_INVALID_CREDENTIALS',
        'Invalid email or password.',
      );
    }
    final login =
        fixtures.success('AuthController_login') as Map<String, Object?>? ??
        const {};
    final user = {...?login['user'] as Map<String, Object?>?, 'email': email};
    final session = _Session(_uuid(), user, given, _refreshValue());
    _sessions.add(session);
    _sessionsByRefresh[session.refresh] = session;
    return _json(
      {
        'accessToken': _issueAccess(session),
        'expiresIn': accessTokenTtl.inSeconds,
        'user': user,
      },
      headers: {'set-cookie': _setCookie(session.refresh)},
    );
  }

  Response _refresh(Request request, String requestId) {
    final value = _cookie(request.headers[HttpHeaders.cookieHeader]);
    final session = value == null ? null : _sessionsByRefresh[value];
    Response fail(String code, String message) =>
        _error(request, requestId, 401, code, message);
    if (session == null) {
      return fail('AUTH_REFRESH_TOKEN_INVALID', 'Refresh token is invalid.');
    }
    if (session.revoked) {
      return fail('AUTH_SESSION_REVOKED', 'Session is no longer active.');
    }
    if (session.refresh != value) {
      session.revoked = true; // Reuse revokes the whole family, as in Core.
      return fail(
        'AUTH_REFRESH_TOKEN_REUSED',
        'Refresh token has already been used.',
      );
    }
    session.refresh = _refreshValue();
    _sessionsByRefresh[session.refresh] = session;
    return _json(
      {
        'accessToken': _issueAccess(session),
        'expiresIn': accessTokenTtl.inSeconds,
      },
      headers: {'set-cookie': _setCookie(session.refresh)},
    );
  }

  Future<Response> _changePassword(
    Request request,
    String requestId,
    _Session session,
  ) async {
    final body = await _body(
      request,
      requestId,
      required: const ['currentPassword', 'newPassword'],
    );
    if (password != null && body['currentPassword'] != password) {
      return _error(
        request,
        requestId,
        401,
        'AUTH_INVALID_CREDENTIALS',
        'Invalid email or password.',
      );
    }
    if (password != null) password = body['newPassword']! as String;
    var revoked = 0;
    for (final other in _sessions) {
      if (identical(other, session) || other.revoked) continue;
      other.revoked = true;
      revoked++;
    }
    return _json({
      ...?fixtures.success('UsersController_changePassword')
          as Map<String, Object?>?,
      'revokedSessions': revoked,
    });
  }

  Response _device(Request request, String requestId, String id) {
    if (_changed[id] case final changed?) return _json(_freshen(changed));
    const detailId = 'DevicesController_get';
    for (final detail in fixtures.successCases(detailId)) {
      if (detail is Map<String, Object?> && detail['id'] == id) {
        return _json(_freshen(detail));
      }
    }
    final list = fixtures.success('DevicesController_list');
    final items = list is Map<String, Object?> ? list['items'] : null;
    // The plainest recorded detail; other details carry a device's own
    // strategy and diagnostics.
    final template =
        fixtures.json[detailId]?['no_room_no_entities'] ??
        fixtures.success(detailId);
    if (items is List && template is Map<String, Object?>) {
      for (final item in items) {
        if (item is Map<String, Object?> && item['id'] == id) {
          // Only the detail's own fields: the list has fields the detail
          // does not (strict decoding would reject them).
          return _json(
            _freshen({
              for (final MapEntry(:key, :value) in template.entries)
                key: item.containsKey(key) ? item[key] : value,
              'entities': <Object?>[],
            }),
          );
        }
      }
    }
    return _error(
      request,
      requestId,
      404,
      'DEVICE_NOT_FOUND',
      'Device not found.',
    );
  }

  /// The device's details as the writes see them, or a 404 reply.
  Future<Map<String, Object?>> _mutableDevice(
    Request request,
    String requestId,
    String id,
  ) async {
    if (_changed[id] case final changed?) return changed;
    final response = _device(request, requestId, id);
    final body = jsonDecode(await response.readAsString());
    if (response.statusCode != 200) {
      throw _Reply(_json(body, status: response.statusCode));
    }
    return _changed[id] = body as Map<String, Object?>;
  }

  /// Reads a JSON object body whose fields all pass [valid] (name -> check
  /// returning an error or null), with every [required] name present and
  /// no other.
  Future<Map<String, Object?>> _typedBody(
    Request request,
    String requestId, {
    required Map<String, String? Function(Object? value)> valid,
    List<String> required = const [],
  }) async {
    Object? json;
    try {
      json = jsonDecode(await request.readAsString());
    } on FormatException {
      json = null;
    }
    final details = <String, List<String>>{};
    if (json is! Map<String, Object?>) {
      details['body'] = ['body must be a JSON object'];
    } else {
      for (final name in required) {
        if (!json.containsKey(name)) details[name] = ['$name is required'];
      }
      for (final MapEntry(:key, :value) in json.entries) {
        final check = valid[key];
        final error = check == null
            ? 'property $key should not exist'
            : check(value);
        if (error != null) details[key] = [error];
      }
    }
    if (details.isNotEmpty) {
      throw _Reply(
        _error(
          request,
          requestId,
          400,
          'VALIDATION_FAILED',
          'Validation failed.',
          details: details,
        ),
      );
    }
    return json! as Map<String, Object?>;
  }

  static String? Function(Object?) _boolean(String name) =>
      (value) => value is bool ? null : '$name must be a boolean value';

  static String? Function(Object?) _number(String name, num min, num max) =>
      (value) => value is num && value >= min && value <= max
      ? null
      : '$name must be a number within $min and $max';

  Future<Response> _setSwitchState(
    Request request,
    String requestId,
    String deviceId,
    String entityId,
  ) async {
    final body = await _typedBody(
      request,
      requestId,
      valid: {'state': _boolean('state')},
      required: const ['state'],
    );
    final requested = body['state']! as bool;
    final device = await _mutableDevice(request, requestId, deviceId);
    Response fail(int status, String code, String message) =>
        _error(request, requestId, status, code, message);

    final entity = (device['entities'] as List? ?? const [])
        .whereType<Map<String, Object?>>()
        .where((e) => e['id'] == entityId)
        .firstOrNull;
    if (entity == null) {
      return fail(
        404,
        'DEVICE_ENTITY_NOT_FOUND',
        'Switch entity was not found on this device.',
      );
    }
    final isSwitch = entity['domain'] == 'switch';
    if (requested && device['heatingSuspended'] == true && isSwitch) {
      return fail(409, 'HEATING_SUSPENDED', 'Heating is suspended.');
    }
    if (!isSwitch || entity['writable'] != true) {
      return fail(
        422,
        'ENTITY_NOT_WRITABLE',
        'Entity is not a writable switch.',
      );
    }
    if (entity['enabled'] != true) {
      return fail(409, 'ENTITY_DISABLED', 'Entity is disabled.');
    }
    if (device['status'] != 'online' || entity['availability'] != true) {
      return fail(503, 'DEVICE_OFFLINE', 'Device is offline.');
    }

    final at = _now().toUtc().toIso8601String();
    if (device['communicationMode'] == 'GI_EDGE_V1') {
      // Fire and forget: a dry run writes nothing and answers the OLD
      // value; otherwise the entity is written before the controller acts.
      final dryRun = device['dryRun'] == true;
      final old = entity['value'];
      if (!dryRun) {
        entity
          ..['value'] = requested
          ..['lastSeenAt'] = at;
      }
      return _json({
        'entityId': entityId,
        'state': dryRun ? old : requested,
        'availability': entity['availability'],
        'confirmedAt': at,
      });
    }
    if (switchFailure case final code?) {
      return fail(switchFailures[code] ?? 502, code, 'Command failed: $code');
    }
    entity
      ..['value'] = requested
      ..['availability'] = true
      ..['lastSeenAt'] = at;
    return _json({
      'entityId': entityId,
      'state': requested,
      'availability': true,
      'confirmedAt': at,
    });
  }

  Future<Response> _updateDevice(
    Request request,
    String requestId,
    String deviceId,
  ) async {
    final body = await _typedBody(
      request,
      requestId,
      valid: {
        'heatingSuspended': _boolean('heatingSuspended'),
        'dryRun': _boolean('dryRun'),
      },
    );
    final device = await _mutableDevice(request, requestId, deviceId);
    device.addAll(body);
    _reconcile(device);
    if (device['heatingSuspended'] == true) {
      for (final entity in device['entities'] as List? ?? const []) {
        if (entity is Map<String, Object?> && entity['domain'] == 'switch') {
          entity['value'] = false;
        }
      }
    }

    // The list-item shape (DeviceResponseDto), not the details.
    final list = fixtures.success('DevicesController_list');
    final items = list is Map<String, Object?> ? list['items'] : null;
    final listed = (items is List ? items : const <Object?>[])
        .whereType<Map<String, Object?>>()
        .where((i) => i['id'] == deviceId)
        .firstOrNull;
    final item =
        listed ??
        fixtures.success('DevicesController_update')! as Map<String, Object?>;
    return _json(
      _freshen({
        ...item,
        'id': deviceId,
        'heatingSuspended': device['heatingSuspended'],
        'dryRun': device['dryRun'],
      }),
    );
  }

  Future<Response> _updateControlStrategy(
    Request request,
    String requestId,
    String deviceId,
  ) async {
    final body = await _typedBody(
      request,
      requestId,
      valid: {
        'targetTemperatureCelsius': _number('targetTemperatureCelsius', 0, 100),
        'hysteresisCelsius': _number('hysteresisCelsius', 1, 20),
        'mode': (value) => const ['AUTO', 'OFF', 'MANUAL'].contains(value)
            ? null
            : 'mode must be one of the following values: AUTO, OFF, MANUAL',
      },
      required: const ['targetTemperatureCelsius', 'hysteresisCelsius', 'mode'],
    );
    final device = await _mutableDevice(request, requestId, deviceId);
    device['baseControlStrategy'] = body;
    _reconcile(device);
    return _json({
      'controlStrategy': device['controlStrategy'],
      'baseControlStrategy': device['baseControlStrategy'],
      'configurationVersion': device['configurationVersion'],
    });
  }

  /// GI Core's reconcile without schedules: the effective strategy is the
  /// base, with mode OFF while suspended; every pass bumps the version.
  static void _reconcile(Map<String, Object?> device) {
    final base = device['baseControlStrategy'];
    if (base is Map<String, Object?>) {
      device['controlStrategy'] = {
        ...base,
        if (device['heatingSuspended'] == true) 'mode': 'OFF',
      };
    }
    final version = device['configurationVersion'];
    device['configurationVersion'] = (version is int ? version : 0) + 1;
  }

  /// Reads a JSON body with exactly the [required] string fields.
  Future<Map<String, Object?>> _body(
    Request request,
    String requestId, {
    required List<String> required,
  }) async {
    Object? json;
    try {
      json = jsonDecode(await request.readAsString());
    } on FormatException {
      json = null;
    }
    final details = <String, List<String>>{};
    if (json is! Map<String, Object?>) {
      details['body'] = ['body must be a JSON object'];
    } else {
      for (final name in required) {
        final value = json[name];
        if (value is! String || value.isEmpty) {
          details[name] = ['$name should not be empty'];
        }
      }
      for (final name in json.keys) {
        if (!required.contains(name)) {
          details[name] = ['property $name should not exist'];
        }
      }
    }
    if (details.isNotEmpty) {
      throw _Reply(
        _error(
          request,
          requestId,
          400,
          'VALIDATION_FAILED',
          'Validation failed.',
          details: details,
        ),
      );
    }
    return json! as Map<String, Object?>;
  }

  Map<String, Object?> _identity(Map<String, Object?> user) => {
    for (final key in const ['id', 'email', 'firstName', 'lastName', 'role'])
      if (user.containsKey(key)) key: user[key],
  };

  Object? _freshen(Object? body) {
    if (!freshLastSeen) return body;
    final now = _now().toUtc().toIso8601String();
    Object? walk(Object? node) => switch (node) {
      final Map<String, Object?> map => {
        for (final MapEntry(:key, :value) in map.entries)
          key: key == 'lastSeenAt' && value != null ? now : walk(value),
      },
      final List<Object?> list => [for (final item in list) walk(item)],
      _ => node,
    };
    return walk(body);
  }

  String _issueAccess(_Session session) {
    final token = 'mock.${_hex(24)}';
    _accessTokens[token] = _Access(session, _now().add(accessTokenTtl));
    return token;
  }

  String _setCookie(String value) {
    const maxAge = Duration(days: 30);
    final expires = HttpDate.format(_now().toUtc().add(maxAge));
    return '$cookieName=$value; Max-Age=${maxAge.inSeconds}; '
        'Path=$_cookiePath; Expires=$expires; HttpOnly; SameSite=Lax';
  }

  static String? _cookie(String? header) {
    if (header == null) return null;
    for (final part in header.split(';')) {
      final eq = part.indexOf('=');
      if (eq > 0 && part.substring(0, eq).trim() == cookieName) {
        return part.substring(eq + 1).trim();
      }
    }
    return null;
  }

  /// `<uuid>.<43 base64url chars>`, the shape of Core's refresh token
  /// ([RefreshCookieCodec.valuePattern]).
  String _refreshValue() {
    final secret = base64Url
        .encode(List.generate(32, (_) => _random.nextInt(256)))
        .replaceAll('=', '');
    return '${_uuid()}.$secret';
  }

  String _uuid() {
    final bytes = List.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  String _hex(int bytes) => [
    for (var i = 0; i < bytes; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  Response _error(
    Request request,
    String requestId,
    int status,
    String code,
    String message, {
    Map<String, Object?>? details,
  }) => _json({
    'statusCode': status,
    'code': code,
    'message': message,
    'path': '/${request.url.path}',
    'requestId': requestId,
    'timestamp': _now().toUtc().toIso8601String(),
    'details': ?details,
  }, status: status);

  static Response _json(
    Object? body, {
    int status = 200,
    Map<String, String> headers = const {},
  }) => Response(
    status,
    body: jsonEncode(body),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      ...headers,
    },
  );
}

/// An early reply thrown out of a helper.
final class _Reply implements Exception {
  const new(this.response);

  final Response response;
}

/// [MockCore] on a real HTTP port.
final class MockCoreServer {
  new _(this._server, this.core);

  static Future<MockCoreServer> start({
    required MockCore core,
    Object host = '127.0.0.1',
    int port = 3100,
    void Function(String line)? log,
  }) async {
    var handler = core.handler;
    if (log != null) {
      handler = const Pipeline()
          .addMiddleware(logRequests(logger: (message, _) => log(message)))
          .addHandler(handler);
    }
    final server = await shelf_io.serve(handler, host, port);
    return MockCoreServer._(server, core);
  }

  final HttpServer _server;
  final MockCore core;

  int get port => _server.port;
  InternetAddress get address => _server.address;

  /// `http://<address>:<port>`, the base URL the app takes.
  String get baseUrl {
    final host = address.type == InternetAddressType.IPv6
        ? '[${address.address}]'
        : address.address;
    return 'http://$host:$port';
  }

  Future<void> close() => _server.close(force: true);
}
