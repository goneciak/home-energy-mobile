import 'dart:convert';
import 'dart:math' as math;

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/demo/data/demo_series.dart';

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
/// M3:
///
/// * Heating schedules are kept per device (CRUD with Core's 201/200/204)
///   and reconciled into `controlStrategy` like GI Core: the first enabled
///   schedule (by `createdAt`) whose window matches the UTC clock sets
///   target and hysteresis, the mode stays the base one, and a suspended
///   device is `OFF`. The reconcile also runs lazily on every request, like
///   the server's minute cron.
/// * Weather, sun, PV forecast and the PV heating plan are synthetic series
///   of [DemoSeries]; entity history is a deterministic 7-day change log.
/// * Sessions (three, one current), revoke, logout-all, recovery code
///   regeneration and reset, and the profile update act on memory.
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
    _historyEnd = start;
    for (final device in _devices) {
      _lastHeartbeat[device['id']! as String] = start;
      _stampHeartbeat(device, start);
    }
    for (final row in _list('schedules')) {
      (_schedules[row['deviceId']! as String] ??= []).add(row);
    }
    _sessions.addAll(_list('sessions'));
    _reconcileAll();
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

  /// Device id → its heating schedules, oldest first.
  final Map<String, List<Map<String, Object?>>> _schedules = {};

  /// The demo user's live sessions, newest first.
  final List<Map<String, Object?>> _sessions = [];

  /// Entity id → its synthetic history (built on first use).
  final Map<String, List<Map<String, Object?>>> _history = {};
  late final DateTime _historyEnd;

  final math.Random _random = math.Random(19);
  int _nextId = 100;
  String? _recoveryCode;

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
    _reconcileAll();
    final device = _device(id);
    return device == null ? null : _detailOf(device);
  }

  /// Answers [method] on [path] (with the `/api/v1` prefix) with the
  /// decoded JSON [body].
  ///
  /// [query] holds the decoded query parameters.
  DemoReply handle(
    String method,
    String path,
    Object? body, {
    Map<String, String> query = const {},
  }) {
    if (!path.startsWith(_apiPrefix)) return _notFound(path);
    _applyHeartbeats();
    _reconcileAll();
    final segments = path
        .substring(_apiPrefix.length)
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    return switch ((method, segments)) {
      ('GET', ['health', 'live']) => _ok({'status': 'ok'}),
      ('GET', ['setup', 'status']) => _ok(setup),
      ('POST', ['auth', 'login']) => _login(),
      ('POST', ['auth', 'refresh']) => _ok(_session(withUser: false)),
      ('POST', ['auth', 'logout']) => (status: 204, body: null),
      ('GET', ['auth', 'me']) => _ok(user),
      ('GET', ['users', 'me', 'profile']) => _ok(_profile()),
      ('PATCH', ['users', 'me', 'profile']) => _updateProfile(body, path),
      ('POST', ['users', 'me', 'change-password']) => _changePassword(
        body,
        path,
      ),
      ('GET', ['auth', 'sessions']) => _ok(_sessions),
      ('DELETE', ['auth', 'sessions', final id]) => _revokeSession(id, path),
      ('POST', ['auth', 'logout-all']) => _logoutAll(),
      ('POST', ['auth', 'recovery', 'regenerate']) => _regenerate(),
      ('POST', ['auth', 'recovery', 'reset']) => _recoveryReset(body, path),
      ('GET', ['weather', 'current']) => _ok(
        DemoSeries.weatherCurrent(_now().toUtc()),
      ),
      ('GET', ['weather', 'hourly']) => _ok(
        DemoSeries.weatherHourly(_now().toUtc()),
      ),
      ('GET', ['weather', 'daily']) => _ok(
        DemoSeries.weatherDaily(_now().toUtc()),
      ),
      ('GET', ['solar', 'current']) => _ok(
        DemoSeries.solarCurrent(_now().toUtc()),
      ),
      ('GET', ['pv', 'forecast']) => _ok(
        DemoSeries.pvForecast(_now().toUtc(), _peakPowerKw),
      ),
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
      ('GET', ['devices', final id, 'entities', final entityId, 'history']) =>
        _withDevice(id, path, (d) => _entityHistory(d, entityId, query, path)),
      ('GET', ['devices', final id, 'pv-heating-plan']) => _withDevice(
        id,
        path,
        (d) => _ok(_pvPlan(d)),
      ),
      ('GET', ['devices', final id, 'schedules']) => _withDevice(
        id,
        path,
        (d) => _ok(_schedulesOf(d)),
      ),
      ('POST', ['devices', final id, 'schedules']) => _withDevice(
        id,
        path,
        (d) => _createSchedule(d, body, path),
      ),
      ('PATCH', ['devices', final id, 'schedules', final scheduleId]) =>
        _withDevice(
          id,
          path,
          (d) => _updateSchedule(d, scheduleId, body, path),
        ),
      ('DELETE', ['devices', final id, 'schedules', final scheduleId]) =>
        _withDevice(id, path, (d) => _removeSchedule(d, scheduleId, path)),
      _ => _notFound(path),
    };
  }

  /// A login opens this phone's session again when logout-all ended it.
  DemoReply _login() {
    if (!_sessions.any((s) => s['current'] == true)) {
      final now = _now().toUtc();
      _sessions.insert(0, {
        'id': _uuid(),
        'createdAt': _iso(now),
        'lastUsedAt': _iso(now),
        'expiresAt': _iso(now.add(const Duration(days: 30))),
        'userAgent': 'GI Home (demo)',
        'ipAddress': null,
        'current': true,
      });
    }
    return _ok(_session(withUser: true));
  }

  String _uuid() {
    String hex(int n) =>
        [for (var i = 0; i < n; i++) _random.nextInt(16).toRadixString(16)]
            .join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-8${hex(3)}-${hex(12)}';
  }

  /// The demo user's profile language tag (changed by `PATCH
  /// /users/me/profile`), `null` when none is set.
  String? get profileLocale => _profile()['locale'] as String?;

  Map<String, Object?> _profile() => {
    ...user,
    ...?_fixtures['profile'] as Map<String, Object?>?,
  };

  static final _localePattern = RegExp(r'^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8})*$');

  /// `PATCH /users/me/profile`: trimmed fields; an empty last name clears
  /// it.
  DemoReply _updateProfile(Object? body, String path) {
    if (body is! Map<String, Object?>) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    final update = <String, Object?>{};
    for (final MapEntry(:key, :value) in body.entries) {
      if (value is! String) return _error(400, 'VALIDATION_FAILED', path);
      final text = value.trim();
      final valid = switch (key) {
        'firstName' => text.isNotEmpty && text.length <= 100,
        'lastName' => text.length <= 100,
        'locale' => _localePattern.hasMatch(text),
        _ => false,
      };
      if (!valid) return _error(400, 'VALIDATION_FAILED', path);
      update[key] = key == 'lastName' && text.isEmpty ? null : text;
    }
    final profile =
        (_fixtures['profile'] ??= <String, Object?>{}) as Map<String, Object?>;
    for (final MapEntry(:key, :value) in update.entries) {
      if (key == 'locale') {
        profile[key] = value;
      } else {
        user[key] = value;
      }
    }
    profile['updatedAt'] = _iso(_now().toUtc());
    return _ok(_profile());
  }

  /// `POST /users/me/change-password`: 200 `{revokedSessions}` like Core;
  /// the other sessions end, this one stays.
  DemoReply _changePassword(Object? body, String path) {
    if (body
        case {
          'currentPassword': final String current,
          'newPassword': final String next,
        }
        when body.length == 2 && current.isNotEmpty) {
      if (PasswordPolicy.check(next) != null) {
        return _error(400, 'VALIDATION_FAILED', path);
      }
      if (next == current) {
        return _error(400, 'USER_NEW_PASSWORD_SAME_AS_CURRENT', path);
      }
      final before = _sessions.length;
      _sessions.removeWhere((s) => s['current'] != true);
      return _ok({'revokedSessions': before - _sessions.length});
    }
    return _error(400, 'VALIDATION_FAILED', path);
  }

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  DemoReply _revokeSession(String id, String path) {
    if (!_uuidPattern.hasMatch(id)) return _error(400, 'HTTP_400', path);
    final session = _sessions.where((s) => s['id'] == id).firstOrNull;
    if (session == null) return _error(404, 'AUTH_SESSION_NOT_FOUND', path);
    _sessions.remove(session);
    return (status: 204, body: null);
  }

  DemoReply _logoutAll() {
    _sessions.clear();
    return (status: 204, body: null);
  }

  DemoReply _regenerate() {
    _recoveryCode = DemoSeries.recoveryCode(_random);
    return _ok({'recoveryCode': _recoveryCode});
  }

  /// `POST /auth/recovery/reset`: only the last regenerated code of the
  /// demo user works; success ends every session.
  DemoReply _recoveryReset(Object? body, String path) {
    if (body
        case {
          'email': final String email,
          'recoveryCode': final String code,
          'newPassword': final String password,
        }
        when body.length == 3 &&
            email.contains('@') &&
            code.isNotEmpty &&
            code.length <= RecoveryCodeFormat.maxLength &&
            PasswordPolicy.check(password) == null) {
      if (email.trim().toLowerCase() != '${user['email']}'.toLowerCase() ||
          _recoveryCode == null ||
          RecoveryCodeFormat.normalize(code) != _recoveryCode) {
        return _error(400, 'AUTH_RECOVERY_INVALID', path);
      }
      _sessions.clear();
      return (status: 204, body: null);
    }
    return _error(400, 'VALIDATION_FAILED', path);
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

  /// GI Core's reconcile (`heating-schedule-reconciliation.service.ts`):
  /// mode `OFF` while heating is suspended; otherwise the first enabled
  /// schedule (by `createdAt`) whose window matches now sets target and
  /// hysteresis over the base, else the base verbatim. A write bumps the
  /// version; with [onlyIfChanged] (the lazy "cron" pass) nothing is
  /// written when the strategy would not change.
  void _reconcile(Map<String, Object?> device, {bool onlyIfChanged = false}) {
    final base = device['baseControlStrategy'] as Map<String, Object?>?;
    if (base == null) return;
    final suspended = device['heatingSuspended'] == true;
    final active = suspended
        ? null
        : _schedulesOf(device)
              .where((s) => s['enabled'] == true && _matches(s))
              .firstOrNull;
    final next = <String, Object?>{
      ...base,
      if (suspended) 'mode': 'OFF',
      if (active != null) ...{
        'targetTemperatureCelsius': active['targetTemperatureCelsius'],
        'hysteresisCelsius': active['hysteresisCelsius'],
      },
    };
    final current = device['controlStrategy'] as Map<String, Object?>?;
    if (onlyIfChanged &&
        current != null &&
        next.length == current.length &&
        next.entries.every((e) => current[e.key] == e.value)) {
      return;
    }
    device
      ..['controlStrategy'] = next
      ..['configurationVersion'] = (device['configurationVersion']! as int) + 1;
  }

  void _reconcileAll() {
    for (final device in _devices) {
      _reconcile(device, onlyIfChanged: true);
    }
  }

  /// `windowMatches` of GI Core on its UTC process clock: start inclusive,
  /// end exclusive, `start == end` is the whole day, `start > end` wraps
  /// past midnight anchored on the start day. 0 = Sunday … 6 = Saturday.
  bool _matches(Map<String, Object?> schedule) {
    final now = _now().toUtc();
    final minutes = now.hour * 60 + now.minute;
    final start = HeatingScheduleRules.minutesOf('${schedule['startTime']}');
    final end = HeatingScheduleRules.minutesOf('${schedule['endTime']}');
    if (start == null || end == null) return false;
    final days = (schedule['daysOfWeek']! as List<Object?>).cast<int>();
    final today = now.weekday % 7;
    final yesterday = (today + 6) % 7;
    if (start == end) return days.contains(today);
    if (start < end) {
      return days.contains(today) && minutes >= start && minutes < end;
    }
    return (days.contains(today) && minutes >= start) ||
        (days.contains(yesterday) && minutes < end);
  }

  List<Map<String, Object?>> _list(String key) =>
      ((_fixtures[key] as List<Object?>?) ?? const [])
          .cast<Map<String, Object?>>();

  List<Map<String, Object?>> _schedulesOf(Map<String, Object?> device) =>
      _schedules[device['id']! as String] ?? const [];

  static const _scheduleKeys = {
    'name',
    'daysOfWeek',
    'startTime',
    'endTime',
    'targetTemperatureCelsius',
    'hysteresisCelsius',
    'enabled',
  };

  /// Checks a schedule body as `heating-schedule.dto.ts` does. With
  /// [create], every field but `enabled` is required.
  static bool _validSchedule(Object? body, {required bool create}) {
    if (body is! Map<String, Object?>) return false;
    if (create &&
        !_scheduleKeys.where((k) => k != 'enabled').every(body.containsKey)) {
      return false;
    }
    for (final MapEntry(:key, :value) in body.entries) {
      final ok = switch (key) {
        'name' => value is String && HeatingScheduleRules.validName(value),
        'daysOfWeek' =>
          value is List<Object?> &&
              value.every((d) => d is int) &&
              HeatingScheduleRules.validDays(value.cast<int>()),
        'startTime' ||
        'endTime' => value is String && HeatingScheduleRules.validTime(value),
        'targetTemperatureCelsius' =>
          value is num && HeatingScheduleRules.validTarget(value.toDouble()),
        'hysteresisCelsius' =>
          value is num &&
              HeatingScheduleRules.validHysteresis(value.toDouble()),
        'enabled' => value is bool,
        _ => false,
      };
      if (!ok) return false;
    }
    return true;
  }

  /// A cuid-like id (25 lowercase characters starting with `c`).
  String _cuid() => 'cdemo${(_nextId++).toRadixString(36).padLeft(20, '0')}';

  DemoReply _createSchedule(
    Map<String, Object?> device,
    Object? body,
    String path,
  ) {
    if (!_validSchedule(body, create: true)) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    final fields = _copy(body)! as Map<String, Object?>;
    final now = _iso(_now().toUtc());
    final row = <String, Object?>{
      'id': _cuid(),
      'deviceId': device['id'],
      'name': fields['name'],
      'daysOfWeek': fields['daysOfWeek'],
      'startTime': fields['startTime'],
      'endTime': fields['endTime'],
      'targetTemperatureCelsius': fields['targetTemperatureCelsius'],
      'hysteresisCelsius': fields['hysteresisCelsius'],
      'enabled': fields['enabled'] ?? true,
      'createdAt': now,
      'updatedAt': now,
    };
    (_schedules[device['id']! as String] ??= []).add(row);
    _reconcile(device);
    return (status: 201, body: _copy(row));
  }

  Map<String, Object?>? _schedule(Map<String, Object?> device, String id) =>
      _schedulesOf(device).where((s) => s['id'] == id).firstOrNull;

  DemoReply _updateSchedule(
    Map<String, Object?> device,
    String scheduleId,
    Object? body,
    String path,
  ) {
    if (!_validSchedule(body, create: false)) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    final row = _schedule(device, scheduleId);
    if (row == null) return _error(404, 'HEATING_SCHEDULE_NOT_FOUND', path);
    row
      ..addAll(_copy(body)! as Map<String, Object?>)
      ..['updatedAt'] = _iso(_now().toUtc());
    _reconcile(device);
    return _ok(row);
  }

  DemoReply _removeSchedule(
    Map<String, Object?> device,
    String scheduleId,
    String path,
  ) {
    final row = _schedule(device, scheduleId);
    if (row == null) return _error(404, 'HEATING_SCHEDULE_NOT_FOUND', path);
    _schedules[device['id']! as String]!.remove(row);
    _reconcile(device);
    return (status: 204, body: null);
  }

  double get _peakPowerKw =>
      ((_fixtures['pv'] as Map<String, Object?>?)?['peakPowerKw'] as num? ??
              6.5)
          .toDouble();

  /// `GET /devices/:id/pv-heating-plan`: FORECAST_ONLY for a device with a
  /// PV heating config, otherwise Core's defaults (DISABLED, no hours).
  Map<String, Object?> _pvPlan(Map<String, Object?> device) {
    final config = device['pvHeatingConfig'] as Map<String, Object?>?;
    final strategy =
        (device['baseControlStrategy'] ?? device['controlStrategy'])
            as Map<String, Object?>?;
    final baseTarget = strategy?['targetTemperatureCelsius'] as num? ?? 60;
    final safeMax = config?['safeMaxTemperatureCelsius'] as num? ?? 60;
    final now = _now().toUtc();
    return {
      'deviceId': device['id'],
      'generatedAt': _iso(now),
      'mode': config == null ? 'DISABLED' : 'FORECAST_ONLY',
      'safeMaxTemperatureCelsius': safeMax,
      'baseTargetCelsius': baseTarget,
      'hours': config == null
          ? const <Object?>[]
          : DemoSeries.pvPlanHours(
              now,
              peakPowerKw: _peakPowerKw,
              ratio: (config['forecastFavorableProductionRatio'] as num? ?? 0.4)
                  .toDouble(),
              baseTarget: baseTarget,
              safeMax: safeMax,
            ),
    };
  }

  static const _historyKeys = {'from', 'to', 'limit'};

  /// `GET .../entities/:entityId/history`: ascending, `from`/`to`
  /// inclusive, the OLDEST `limit` samples when truncated.
  DemoReply _entityHistory(
    Map<String, Object?> device,
    String entityId,
    Map<String, String> query,
    String path,
  ) {
    if (!query.keys.every(_historyKeys.contains)) {
      return _error(400, 'VALIDATION_FAILED', path);
    }
    var limit = 1000;
    if (query['limit'] case final text?) {
      final parsed = int.tryParse(text);
      if (parsed == null || parsed < 1 || parsed > 5000) {
        return _error(400, 'VALIDATION_FAILED', path);
      }
      limit = parsed;
    }
    final to = query.containsKey('to')
        ? DateTime.tryParse(query['to']!)
        : _now().toUtc();
    final from = query.containsKey('from')
        ? DateTime.tryParse(query['from']!)
        : to?.subtract(const Duration(hours: 24));
    if (from == null || to == null || !from.isBefore(to)) {
      return _error(400, 'HISTORY_RANGE_INVALID', path);
    }
    final entity = _entities(device)
        .where((e) => e['id'] == entityId)
        .firstOrNull;
    if (entity == null) return _error(404, 'DEVICE_ENTITY_NOT_FOUND', path);
    final all = _history[entityId] ??= DemoSeries.history(entity, _historyEnd);
    final samples = <Map<String, Object?>>[];
    for (final sample in all) {
      final at = DateTime.parse(sample['at']! as String);
      if (at.isBefore(from)) continue;
      if (at.isAfter(to) || samples.length >= limit) break;
      samples.add(sample);
    }
    return _ok({
      'entityId': entityId,
      'from': _iso(from),
      'to': _iso(to),
      'samples': samples,
    });
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
