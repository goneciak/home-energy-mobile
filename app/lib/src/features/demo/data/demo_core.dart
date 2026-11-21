import 'dart:convert';

/// A response of [DemoCore]: status and JSON body (`null` for 204).
typedef DemoReply = ({int status, Object? body});

/// The demo appliance (plan §19.5): bundled, sanitized fixtures
/// (`assets/demo_fixtures/demo_core.json`) answered from memory, with
/// writes applied to that memory only. Pure Dart and timer-free; time
/// comes from the `now` clock.
///
/// Every device behaves as a `GI_EDGE_V1` controller, so the app's command
/// confirmation (plan §12.2) can be shown without hardware:
///
/// * `PUT .../entities/:entityId/state` writes the entity optimistically and
///   answers at once, like GI Core; the device reports it in a simulated
///   heartbeat [heartbeatDelay] later (device `lastSeenAt` and
///   `diagnostics.relayN.{output, commanded}`).
/// * `PATCH /devices/:id {"heatingSuspended"}` reconciles the effective
///   strategy (mode `OFF` while suspended, the base strategy after resuming);
///   the next heartbeat reports every switch off while suspended.
/// * `PATCH /devices/:id/control-strategy` sets the base strategy.
///
/// Heartbeats are applied lazily when a request arrives, so nothing runs in
/// the background. Without a pending command the device still reports a
/// heartbeat every [heartbeatInterval], so it never turns stale.
final class DemoCore {
  /// [fixtures] is the decoded `demo_core.json`; it is deep-copied.
  new(
    Map<String, Object?> fixtures, {
    DateTime Function()? now,
    this.heartbeatDelay = const Duration(seconds: 3),
    this.heartbeatInterval = const Duration(seconds: 20),
  }) : _now = now ?? DateTime.now,
       _fixtures = _copy(fixtures)! as Map<String, Object?> {
    final start = _now().toUtc();
    for (final device in _devices) {
      _lastHeartbeat[device['id']! as String] = start;
      _stampHeartbeat(device, start);
    }
  }

  /// Decodes the JSON text of `demo_core.json`.
  factory fromJsonString(
    String json, {
    DateTime Function()? now,
    Duration heartbeatDelay = const Duration(seconds: 3),
  }) => DemoCore(
    jsonDecode(json) as Map<String, Object?>,
    now: now,
    heartbeatDelay: heartbeatDelay,
  );

  /// Access token handed out by the demo; it means nothing anywhere else.
  static const accessToken = 'demo-access-token';

  /// Refresh cookie of the demo session; a well-formed placeholder.
  static final setCookie =
      'gi_refresh_token=00000000-0000-4000-8000-000000000000.${'D' * 43}; '
      'Max-Age=2592000; Path=/api/v1/auth/refresh; HttpOnly; SameSite=Lax';

  final DateTime Function() _now;
  final Map<String, Object?> _fixtures;
  final Duration heartbeatDelay;
  final Duration heartbeatInterval;

  final Map<String, DateTime> _lastHeartbeat = {};

  /// Device id → when its next command heartbeat is due.
  final Map<String, DateTime> _pendingHeartbeat = {};

  static const _apiPrefix = '/api/v1';

  /// `setup/status` of the demo appliance.
  Map<String, Object?> get setup => _fixtures['setup']! as Map<String, Object?>;

  /// The demo user (an owner).
  Map<String, Object?> get user => _fixtures['user']! as Map<String, Object?>;

  List<Map<String, Object?>> get _devices =>
      (_fixtures['devices']! as List<Object?>).cast<Map<String, Object?>>();

  /// The current `GET /devices/:id` body of [id], or `null`.
  Map<String, Object?>? deviceDetail(String id) {
    _applyHeartbeats();
    final device = _device(id);
    return device == null ? null : _detailOf(device);
  }

  /// Answers [method] on [path] (with the `/api/v1` prefix) with the
  /// decoded JSON [body].
  DemoReply handle(String method, String path, Object? body) {
    if (!path.startsWith(_apiPrefix)) return _notFound(path);
    _applyHeartbeats();
    final segments = path
        .substring(_apiPrefix.length)
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    return switch ((method, segments)) {
      ('GET', ['health', 'live']) => _ok({'status': 'ok'}),
      ('GET', ['setup', 'status']) => _ok(setup),
      ('POST', ['auth', 'login']) => _ok(_session(withUser: true)),
      ('POST', ['auth', 'refresh']) => _ok(_session(withUser: false)),
      ('POST', ['auth', 'logout']) => (status: 204, body: null),
      ('GET', ['auth', 'me']) => _ok(user),
      ('GET', ['users', 'me', 'profile']) => _ok({
        ...user,
        ...?_fixtures['profile'] as Map<String, Object?>?,
      }),
      ('POST', ['users', 'me', 'change-password']) => (status: 204, body: null),
      ('GET', ['settings', 'system']) => _ok({
        'deviceName': setup['deviceName'],
        'locale': setup['locale'],
        'timezone': setup['timezone'],
      }),
      ('GET', ['appliance', 'updates', 'status']) => _ok(
        _fixtures['updatesStatus'],
      ),
      ('GET', ['rooms']) => _ok(_fixtures['rooms']),
      ('GET', ['devices']) => _ok({
        'items': [for (final d in _devices) _listItemOf(d)],
        'page': 1,
        'limit': 100,
        'total': _devices.length,
        'totalPages': 1,
      }),
      ('GET', ['devices', final id]) => _withDevice(
        id,
        path,
        (d) => _ok(_detailOf(d)),
      ),
      ('PATCH', ['devices', final id]) => _withDevice(
        id,
        path,
        (d) => _updateDevice(d, body, path),
      ),
      ('PATCH', ['devices', final id, 'control-strategy']) => _withDevice(
        id,
        path,
        (d) => _updateStrategy(d, body, path),
      ),
      ('PUT', ['devices', final id, 'entities', final entityId, 'state']) =>
        _withDevice(id, path, (d) => _setSwitch(d, entityId, body, path)),
      _ => _notFound(path),
    };
  }

  Map<String, Object?> _session({required bool withUser}) => {
    'accessToken': accessToken,
    'expiresIn': 900,
    if (withUser) 'user': user,
  };

  DemoReply _withDevice(
    String id,
    String path,
    DemoReply Function(Map<String, Object?> device) handler,
  ) {
    final device = _device(id);
    if (device == null) return _error(404, 'DEVICE_NOT_FOUND', path);
    return handler(device);
  }

  Map<String, Object?>? _device(String id) {
    for (final device in _devices) {
      if (device['id'] == id) return device;
    }
    return null;
  }

  DemoReply _updateDevice(
    Map<String, Object?> device,
    Object? body,
    String path,
  ) {
    if (body is! Map<String, Object?> ||
        body.length != 1 ||
        body['heatingSuspended'] is! bool) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    final now = _now().toUtc();
    device
      ..['heatingSuspended'] = body['heatingSuspended']
      ..['updatedAt'] = _iso(now);
    _reconcile(device);
    _scheduleHeartbeat(device, now);
    return _ok(_listItemOf(device));
  }

  DemoReply _updateStrategy(
    Map<String, Object?> device,
    Object? body,
    String path,
  ) {
    if (body
        case {
          'targetTemperatureCelsius': final num target,
          'hysteresisCelsius': final num hysteresis,
          'mode': final String mode,
        }
        when target >= 0 &&
            target <= 100 &&
            hysteresis >= 1 &&
            hysteresis <= 20 &&
            const {'AUTO', 'OFF', 'MANUAL'}.contains(mode)) {
      device['baseControlStrategy'] = {
        'targetTemperatureCelsius': target,
        'hysteresisCelsius': hysteresis,
        'mode': mode,
      };
      _reconcile(device);
      _scheduleHeartbeat(device, _now().toUtc());
      return _ok({
        'controlStrategy': device['controlStrategy'],
        'baseControlStrategy': device['baseControlStrategy'],
        'configurationVersion': device['configurationVersion'],
      });
    }
    return _error(400, 'VALIDATION_FAILED', path);
  }

  DemoReply _setSwitch(
    Map<String, Object?> device,
    String entityId,
    Object? body,
    String path,
  ) {
    if (body is! Map<String, Object?> || body['state'] is! bool) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    final requested = body['state']! as bool;
    final entity = _entities(device)
        .where((e) => e['id'] == entityId)
        .firstOrNull;
    if (entity == null) return _error(404, 'DEVICE_ENTITY_NOT_FOUND', path);
    final isSwitch = entity['domain'] == 'switch';
    if (requested && isSwitch && device['heatingSuspended'] == true) {
      return _error(409, 'HEATING_SUSPENDED', path);
    }
    if (!isSwitch || entity['writable'] != true) {
      return _error(422, 'ENTITY_NOT_WRITABLE', path);
    }
    if (entity['enabled'] != true) {
      return _error(409, 'ENTITY_DISABLED', path);
    }
    final now = _now().toUtc();
    // GI_EDGE_V1, not a dry run: written optimistically, confirmed only by
    // a later heartbeat.
    entity
      ..['value'] = requested
      ..['lastSeenAt'] = _iso(now);
    _scheduleHeartbeat(device, now);
    return _ok({
      'entityId': entityId,
      'state': requested,
      'availability': entity['availability'],
      'confirmedAt': _iso(now),
    });
  }

  /// GI Core's reconcile without schedules: the base strategy, mode `OFF`
  /// while heating is suspended. Every reconcile bumps the version.
  void _reconcile(Map<String, Object?> device) {
    final base = device['baseControlStrategy'] as Map<String, Object?>?;
    if (base == null) return;
    device
      ..['controlStrategy'] = {
        ...base,
        if (device['heatingSuspended'] == true) 'mode': 'OFF',
      }
      ..['configurationVersion'] = (device['configurationVersion']! as int) + 1;
  }

  void _scheduleHeartbeat(Map<String, Object?> device, DateTime from) {
    _pendingHeartbeat[device['id']! as String] = from.add(heartbeatDelay);
  }

  void _applyHeartbeats() {
    final now = _now().toUtc();
    for (final device in _devices) {
      final id = device['id']! as String;
      final due = _pendingHeartbeat[id];
      if (due != null && !now.isBefore(due)) {
        _pendingHeartbeat.remove(id);
        _heartbeat(device, due);
      } else if (due == null &&
          now.difference(_lastHeartbeat[id]!) >= heartbeatInterval) {
        _heartbeat(device, now);
      }
    }
  }

  /// What the controller reports [at]: while suspended every switch is off
  /// (GI Core sends TURN_OFF to each); the heating relay follows the
  /// thermostat on the control temperature.
  void _heartbeat(Map<String, Object?> device, DateTime at) {
    _lastHeartbeat[device['id']! as String] = at;
    final suspended = device['heatingSuspended'] == true;
    final strategy = device['controlStrategy'] as Map<String, Object?>?;
    for (final entity in _entities(device)) {
      if (entity['domain'] != 'switch') continue;
      if (suspended) {
        entity['value'] = false;
      } else if (entity['id'] == device['heatingRelayEntityId'] &&
          strategy != null) {
        entity['value'] = _thermostat(device, strategy, entity['value']);
      }
    }
    _stampHeartbeat(device, at);
  }

  bool _thermostat(
    Map<String, Object?> device,
    Map<String, Object?> strategy,
    Object? current,
  ) {
    if (strategy['mode'] == 'OFF') return false;
    final temperature = _entities(device)
        .where((e) => e['id'] == device['controlTemperatureEntityId'])
        .map((e) => e['value'])
        .whereType<num>()
        .firstOrNull;
    if (temperature == null) return false;
    final target = strategy['targetTemperatureCelsius']! as num;
    final hysteresis = strategy['hysteresisCelsius']! as num;
    if (temperature >= target) return false;
    if (temperature < target - hysteresis) return true;
    return current == true;
  }

  void _stampHeartbeat(Map<String, Object?> device, DateTime at) {
    device['lastSeenAt'] = _iso(at);
    final diagnostics = device['diagnostics'] as Map<String, Object?>?;
    if (diagnostics == null) return;
    var heating = false;
    for (final entity in _entities(device)) {
      final relay = RegExp(r'^relay_?(\d+)$')
          .firstMatch('${entity['sourceName']}');
      if (entity['domain'] != 'switch' || relay == null) continue;
      final on = entity['value'] == true;
      diagnostics['relay${relay.group(1)}'] = {'output': on, 'commanded': on};
      entity['lastSeenAt'] = _iso(at);
      if (entity['id'] == device['heatingRelayEntityId']) heating = on;
    }
    if (device['heatingRelayEntityId'] != null) {
      diagnostics['currentState'] = heating ? 'HEATING' : 'IDLE';
    }
  }

  static List<Map<String, Object?>> _entities(Map<String, Object?> device) =>
      (device['entities']! as List<Object?>).cast<Map<String, Object?>>();

  static const _detailOnly = {
    'baseControlStrategy',
    'configurationVersion',
    'controlStrategy',
    'diagnostics',
    'entities',
    'hostname',
    'mac',
    'pvBoostActive',
    'pvConsumptionEntityId',
    'pvHeatingConfig',
    'pvProductionEntityId',
  };

  static const _listOnly = {
    'capabilities',
    'createdAt',
    'serialNumber',
    'type',
    'updatedAt',
  };

  Map<String, Object?> _detailOf(Map<String, Object?> device) =>
      _copy({
            for (final MapEntry(:key, :value) in device.entries)
              if (!_listOnly.contains(key)) key: value,
          })!
          as Map<String, Object?>;

  /// The list-item shape (also the `PATCH /devices/:id` answer): status in
  /// upper case, with the fault count and state from the diagnostics.
  Map<String, Object?> _listItemOf(Map<String, Object?> device) {
    final diagnostics = device['diagnostics'] as Map<String, Object?>?;
    return _copy({
          for (final MapEntry(:key, :value) in device.entries)
            if (!_detailOnly.contains(key)) key: value,
          'status': '${device['status']}'.toUpperCase(),
          'activeFaultCount':
              (diagnostics?['activeFaults'] as List<Object?>?)?.length ?? 0,
          'currentState': diagnostics?['currentState'],
        })!
        as Map<String, Object?>;
  }

  static DemoReply _ok(Object? body) => (status: 200, body: _copy(body));

  DemoReply _error(int status, String code, String path) => (
    status: status,
    body: {
      'statusCode': status,
      'code': code,
      'message': code,
      'path': path,
      'requestId': 'demo',
      'timestamp': _iso(_now().toUtc()),
    },
  );

  DemoReply _notFound(String path) => _error(404, 'HTTP_404', path);

  static String _iso(DateTime time) => time.toUtc().toIso8601String();

  static Object? _copy(Object? value) => switch (value) {
    final Map<String, Object?> map => <String, Object?>{
      for (final MapEntry(:key, value: v) in map.entries) key: _copy(v),
    },
    final List<Object?> list => [for (final v in list) _copy(v)],
    _ => value,
  };
}
