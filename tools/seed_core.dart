// Seeder for a local, dockerized GI Core: the dev stack (tools/dev-up.*) or a
// contract stack (contract/compose.contract.yml). Never point it at a real
// appliance.
//
// Uses ONLY the existing public GI Core API; the backend is never modified.
//
//   dart run tools/seed_core.dart [--base-url http://localhost:3000] [--init [--yes]]
//       [--allow-initialized] [--fake-device fake-esphome|none]
//       [--fixtures [--overwrite-fixtures]]
//
// Steps (plan §17.3), each idempotent:
//   1. POST /setup/initialize        only with --init and only on initialized:false;
//                                     asks y/N first unless --yes
//   2. POST /auth/login               owner from tools/backend/dev.env
//   3. POST /users                    ADMIN, USER, SERVICE from tools/seed_accounts.json
//                                     (else tools/seed_accounts.example.json)
//   4. POST /rooms, POST /devices     demo rooms and devices (by name)
//   5. discover/claim/complete        the fake-esphome device (contract stack only:
//                                     the dev Core cannot reach it, plan D20)
//   6. PATCH /devices/:id             heating relay + control temperature entity
//      PUT .../entities/:id/role       boiler / CO supply roles (else the detail
//                                     says needs_configuration, not online)
//   7. PATCH .../control-strategy     55 °C, 4 °C hysteresis, MANUAL
//
// Guard: anything that writes to a Core that is ALREADY initialized (--init
// steps 3-7, --fixtures) is refused without --allow-initialized.
//
// --fixtures records real responses into
// packages/gi_core_api/test/fixtures/core/<shortSha of contract/backend.lock>/
// <endpointId>/<case>.json. Existing files are kept (tests pin their values)
// unless --overwrite-fixtures is given; requests for kept files are skipped.
//
// Owner credentials live in tools/backend/dev.env (gitignored, generated on the
// first run). They are local test values only.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

final String _root = File.fromUri(Platform.script).parent.parent.path;
final _envFile = File('$_root/tools/backend/dev.env');
final _accountsFile = File('$_root/tools/seed_accounts.json');
final _accountsExample = File('$_root/tools/seed_accounts.example.json');
final _backendLock = File('$_root/contract/backend.lock');

/// What the fake device's manifest reports (tools/fake_esphome).
const _fakeManufacturer = 'GI Contract Fakes';
const _fakeModel = 'fake-esphome';
const _fakeExternalId = 'gi-fake-esphome-01';

/// The manifest's name: every sync overwrites the device name with it
/// (esphome-integration.service.ts sync), so another name would not stick.
const _fakeDeviceName = 'Fake kotłownia';

/// What the GI Edge simulator's manifest reports (tools/gi_edge_sim).
const _edgeSimManufacturer = 'GI Industries';
const _edgeSimModel = 'GI Boiler Room Controller';
const _edgeSimExternalId = 'gi-edge-sim-01';
const _edgeSimDeviceName = 'GI Boiler Room Controller (simulator)';

/// MANUAL: GI Core's live hysteresis loop only acts in AUTO
/// (gi-edge-live-heating-control.service.ts), so the relay moves only when a
/// test or a person switches it.
const Map<String, Object> _controlStrategy = {
  'targetTemperatureCelsius': 55,
  'hysteresisCelsius': 4,
  'mode': 'MANUAL',
};

const _usage = '''
Usage: dart run tools/seed_core.dart [options]

  --base-url URL          GI Core base URL (default http://localhost:3000; --base is an alias)
  --init                  initialize the Core if needed, then seed steps 3-7
  --yes                   do not ask before initializing (CI)
  --allow-initialized     allow writes to a Core that is already initialized
  --fake-device HOST      fake-esphome host as GI Core resolves it (default fake-esphome;
                          "none" skips steps 5-7)
  --edge-sim HOST         also provision the GI Edge simulator (host as GI Core
                          resolves it, normally gi-edge-sim) and wait for its
                          activation (communicationMode GI_EDGE_V1)
  --fixtures              record missing fixtures (see packages/gi_core_api/test/fixtures)
  --overwrite-fixtures    with --fixtures: re-record existing files too
  -h, --help              this text
''';

Future<void> main(List<String> args) async {
  final Options options;
  try {
    options = Options.parse(args);
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..write(_usage);
    exit(64);
  }
  if (options.help) {
    stdout.write(_usage);
    return;
  }

  final api = _Api('${options.baseUrl}/api/v1');
  final creds = _loadOrCreateCreds();
  final recorder = _Recorder(
    '$_root/packages/gi_core_api/test/fixtures/core/${_backendRef()}',
    enabled: options.fixtures,
    overwrite: options.overwriteFixtures,
  );

  // Step 1: status, guard, initialize.
  final status = await api.get('/setup/status');
  _expect(status, 200);
  stdout.writeln('setup/status: ${status.body}');
  final statusJson = jsonDecode(status.body) as Map<String, dynamic>;
  final initialized = statusJson['initialized'] == true;
  final writes = options.init || options.fixtures;

  if (initialized && writes && !options.allowInitialized) {
    stderr.writeln(
      'GI Core at ${options.baseUrl} is already initialized '
      '(initializedAt ${statusJson['initializedAt']}). Seeding and recording '
      'fixtures write to it. Re-run with --allow-initialized if this is your '
      'dev or contract Core.',
    );
    exit(3);
  }
  if (!initialized) {
    if (!options.init) {
      stderr.writeln('GI Core is not initialized. Re-run with --init.');
      exit(2);
    }
    recorder.save('SetupController_getStatus/uninitialized.json', status.body);
    if (!options.yes &&
        !_confirm(
          'Initialize GI Core at ${options.baseUrl}? The first caller becomes '
          'its OWNER (${creds['GI_DEV_EMAIL']}).',
        )) {
      stderr.writeln('Not initialized.');
      exit(1);
    }
    await _initialize(api, creds, recorder);
  }

  // Step 2: owner login. Captures the refresh cookie as a native client sees
  // it.
  final login = await api.post('/auth/login', {
    'email': creds['GI_DEV_EMAIL'],
    'password': creds['GI_DEV_PASSWORD'],
  });
  _expect(login, 200);
  stdout.writeln('login ok; Set-Cookie: ${_redactCookies(login.setCookie)}');
  recorder
    ..save('AuthController_login/ok.json', _redactTokens(login.body))
    ..saveText(
      'AuthController_login/ok.set-cookie.txt',
      _redactCookies(login.setCookie).join('\n'),
    );
  api.bearer = (jsonDecode(login.body) as Map)['accessToken'] as String;

  final accounts = _loadAccounts();
  if (options.init) {
    // Step 3: ADMIN and USER accounts.
    await _ensureUsers(api, accounts);

    // Step 4: demo rooms and devices.
    final rooms = await _ensureRooms(api, ['Salon', 'Kotłownia']);
    await _ensureDevice(api, {
      'name': 'Lampa w salonie',
      'type': 'VIRTUAL',
      'manufacturer': 'GI Dev',
      'roomId': rooms['Salon'],
    });
    await _ensureDevice(api, {
      'name': 'Sterownik kotłowni',
      'type': 'ESP32',
      'manufacturer': 'GI Industries',
      'model': 'kotlownia',
      'roomId': rooms['Kotłownia'],
    });
    await _ensureDevice(api, {'name': 'Czujnik bez pokoju', 'type': 'GENERIC'});

    // Steps 5-7: the fake device.
    if (options.fakeDevice case final host?) {
      final deviceId = await _ensureFakeDevice(api, host, rooms['Kotłownia']);
      if (deviceId != null) await _configureHeating(api, deviceId);
    }

    // The GI Edge simulator (opt-in: an extra device in the lists).
    if (options.edgeSim case final host?) {
      final deviceId = await _ensureEdgeSim(api, host, rooms['Kotłownia']);
      if (deviceId != null) {
        await _configureHeating(
          api,
          deviceId,
          relayName: 'relay_2',
          temperatureName: 'Temperature 1',
        );
      }
    }
  }

  if (options.fixtures) {
    await _recordFixtures(api, recorder, accounts);
    stdout.writeln(
      'fixtures: ${recorder.written} written, ${recorder.kept} kept '
      '(${recorder.dir})',
    );
  }
}

/// Parsed command line.
final class Options {
  new _({
    required this.baseUrl,
    required this.init,
    required this.yes,
    required this.allowInitialized,
    required this.fakeDevice,
    required this.edgeSim,
    required this.fixtures,
    required this.overwriteFixtures,
    required this.help,
  });

  factory parse(List<String> args) {
    var baseUrl = 'http://localhost:3000';
    String? fakeDevice = 'fake-esphome';
    String? edgeSim;
    final flags = <String>{};
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String value() {
        if (i + 1 >= args.length) throw FormatException('$arg needs a value');
        return args[++i];
      }

      switch (arg) {
        case '--base-url' || '--base':
          baseUrl = value();
        case '--fake-device':
          final host = value();
          fakeDevice = host == 'none' ? null : host;
        case '--edge-sim':
          edgeSim = value();
        case '--init' ||
            '--yes' ||
            '--allow-initialized' ||
            '--fixtures' ||
            '--overwrite-fixtures':
          flags.add(arg);
        case '-h' || '--help':
          flags.add('--help');
        default:
          throw FormatException('Unknown option: $arg');
      }
    }
    while (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return Options._(
      baseUrl: baseUrl,
      init: flags.contains('--init'),
      yes: flags.contains('--yes'),
      allowInitialized: flags.contains('--allow-initialized'),
      fakeDevice: fakeDevice,
      edgeSim: edgeSim,
      fixtures: flags.contains('--fixtures'),
      overwriteFixtures: flags.contains('--overwrite-fixtures'),
      help: flags.contains('--help'),
    );
  }

  final String baseUrl;
  final bool init;
  final bool yes;
  final bool allowInitialized;
  final String? fakeDevice;
  final String? edgeSim;
  final bool fixtures;
  final bool overwriteFixtures;
  final bool help;
}

Future<void> _initialize(
  _Api api,
  Map<String, String> creds,
  _Recorder recorder,
) async {
  final r = await api.post('/setup/initialize', {
    'firstName': 'Dev',
    'lastName': 'Owner',
    'email': creds['GI_DEV_EMAIL'],
    'password': creds['GI_DEV_PASSWORD'],
    'deviceName': 'GI Home Dev',
  });
  stdout.writeln('setup/initialize -> ${r.status}');
  if (r.status >= 300) {
    stderr.writeln(r.body);
    exit(1);
  }
  final init = jsonDecode(r.body) as Map<String, dynamic>;
  final code = init['recoveryCode'];
  if (code is String) {
    // dev.env keeps the first Core's code (the dev stack); a contract stack is
    // thrown away, so its code is not kept anywhere.
    if (!_envFile.readAsStringSync().contains('GI_DEV_RECOVERY_CODE=')) {
      _envFile.writeAsStringSync(
        'GI_DEV_RECOVERY_CODE=$code\n',
        mode: FileMode.append,
      );
      stdout.writeln('recovery code stored in ${_envFile.path}');
    } else {
      stdout.writeln(
        'recovery code not stored: ${_envFile.path} already holds one',
      );
    }
    init['recoveryCode'] = 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX';
  }
  recorder.save('SetupController_initialize/ok.json', jsonEncode(init));
}

/// A test-only account from the accounts file.
final class _Account {
  new(Map<String, dynamic> json)
    : role = json['role'] as String,
      firstName = json['firstName'] as String,
      lastName = json['lastName'] as String?,
      email = (json['email'] as String).toLowerCase(),
      password = json['password'] as String;

  final String role;
  final String firstName;
  final String? lastName;
  final String email;
  final String password;
}

List<_Account> _loadAccounts() {
  final file = _accountsFile.existsSync() ? _accountsFile : _accountsExample;
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final a in json['accounts'] as List)
      _Account(a as Map<String, dynamic>),
  ];
}

Future<void> _ensureUsers(_Api api, List<_Account> accounts) async {
  final r = await api.get('/users?limit=100');
  _expect(r, 200);
  final existing = {
    for (final u in _items(r.body)) (u['email'] as String).toLowerCase(),
  };
  for (final a in accounts) {
    if (existing.contains(a.email)) continue;
    final c = await api.post('/users', {
      'firstName': a.firstName,
      'lastName': ?a.lastName,
      'email': a.email,
      'password': a.password,
      'role': a.role,
    });
    _expect(c, 201);
    stdout.writeln('user created: ${a.email} (${a.role})');
  }
}

Future<Map<String, String>> _ensureRooms(_Api api, List<String> names) async {
  final r = await api.get('/rooms');
  _expect(r, 200);
  final out = <String, String>{
    for (final m in _items(r.body)) m['name'] as String: m['id'] as String,
  };
  for (final n in names) {
    if (out.containsKey(n)) continue;
    final c = await api.post('/rooms', {'name': n});
    _expect(c, 201);
    out[n] = _field(c.body, 'id')! as String;
    stdout.writeln('room created: $n');
  }
  return out;
}

Future<List<Map<String, dynamic>>> _devices(_Api api) async {
  final r = await api.get('/devices?limit=100');
  _expect(r, 200);
  return _items(r.body);
}

Future<void> _ensureDevice(_Api api, Map<String, Object?> body) async {
  if ((await _devices(api)).any((d) => d['name'] == body['name'])) return;
  body.removeWhere((k, v) => v == null);
  final c = await api.post('/devices', body);
  stdout.writeln('device ${body['name']} -> ${c.status}');
  if (c.status >= 300) stderr.writeln(c.body);
}

/// Step 5: provisions the fake device through GI Core's ESPHome flow
/// (discover → claim → complete) and synchronizes it once so its entities
/// exist and it is ONLINE. Returns the device id, or null when GI Core cannot
/// reach the fake device (the dev stack).
///
/// mDNS discovery (`GET /integrations/esphome/discovered`) is not used: the
/// fake does not advertise `_esphomelib._tcp`. The manual host path is the
/// one GI Core falls back to in Docker anyway
/// (esphome-mdns-discovery.service.ts).
Future<String?> _ensureFakeDevice(_Api api, String host, String? roomId) =>
    _ensureEsphomeDevice(
      api,
      host,
      roomId,
      manufacturer: _fakeManufacturer,
      model: _fakeModel,
      externalId: _fakeExternalId,
      name: _fakeDeviceName,
    );

/// Step 5b: the GI Edge simulator. After the sync GI Core pushes
/// `/gi-provision` itself (GiEdgeAutoActivationService); when that did not
/// happen within a few seconds the owner endpoint `activate-now` is used. Then
/// it waits for `communicationMode` GI_EDGE_V1.
Future<String?> _ensureEdgeSim(_Api api, String host, String? roomId) async {
  final deviceId = await _ensureEsphomeDevice(
    api,
    host,
    roomId,
    manufacturer: _edgeSimManufacturer,
    model: _edgeSimModel,
    externalId: _edgeSimExternalId,
    name: _edgeSimDeviceName,
  );
  if (deviceId == null) return null;
  var pushed = false;
  for (var attempt = 0; attempt < 40; attempt++) {
    final r = await api.get('/devices/$deviceId');
    _expect(r, 200);
    final device = jsonDecode(r.body) as Map<String, dynamic>;
    if (device['communicationMode'] == 'GI_EDGE_V1') {
      stdout.writeln('GI Edge simulator $deviceId activated (GI_EDGE_V1)');
      // The first heartbeat creates the diagnostics; wait for it too.
      for (var i = 0; i < 20 && device['diagnostics'] == null; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final again = await api.get('/devices/$deviceId');
        if (again.status != 200) break;
        device['diagnostics'] = (jsonDecode(again.body) as Map)['diagnostics'];
      }
      return deviceId;
    }
    if (attempt == 5 && !pushed) {
      pushed = true;
      final a = await api.post(
        '/edge/devices/$deviceId/activate-now',
        const {},
      );
      stdout.writeln('activate-now -> ${a.status} ${a.body}');
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  stderr.writeln('WARNING: GI Edge simulator $deviceId was not activated.');
  return null;
}

Future<String?> _ensureEsphomeDevice(
  _Api api,
  String host,
  String? roomId, {
  required String manufacturer,
  required String model,
  required String externalId,
  required String name,
}) async {
  final existing = (await _devices(api))
      .where((d) => d['manufacturer'] == manufacturer && d['model'] == model);
  var deviceId = existing.isEmpty ? null : existing.first['id'] as String;

  if (deviceId == null) {
    // A session left open by an interrupted earlier run is resumed: discover
    // must not be repeated, GI Core answers a second discover of the same
    // identity with 500 INTERNAL_SERVER_ERROR (an unmapped
    // PROVISIONING_SESSION_ALREADY_ACTIVE).
    var sessionId = await _openEsphomeSession(api, externalId);
    if (sessionId == null) {
      final discover = await api.post('/integrations/esphome/discover', {
        'host': host,
      });
      if (discover.status != 201) {
        stderr.writeln(
          'WARNING: fake device not provisioned: discover($host) -> '
          '${discover.status} ${discover.body}\n'
          'Expected on the dev stack (GI Core cannot reach fake-esphome, plan '
          'D20); on a contract stack this is a failure (spike S6).',
        );
        return null;
      }
      // The discover body nests the domain snapshot, not the
      // ProvisioningSessionResponseDto: read the session back.
      sessionId = await _openEsphomeSession(api, externalId);
      stdout.writeln('fake device discovered at $host (session $sessionId)');
      if (sessionId == null) {
        stderr.writeln('WARNING: no open provisioning session for $host.');
        return null;
      }
    }

    var session = await api.get('/provisioning/$sessionId');
    _expect(session, 200);
    if (_field(session.body, 'status') == 'DISCOVERED') {
      session = await api.post('/provisioning/$sessionId/claim', const {});
      _expect(session, 201); // POST without @HttpCode: 201, Swagger says 200.
      stdout.writeln('provisioning claimed');
    }
    if (_field(session.body, 'status') == 'CLAIMED') {
      session = await api.post('/provisioning/$sessionId/complete', {
        'name': name,
        'type': 'ESP32',
        'roomId': ?roomId,
      });
      _expect(session, 201);
      stdout.writeln('provisioning completed');
    }
    deviceId = _field(session.body, 'deviceId') as String?;
    if (deviceId == null) {
      stderr.writeln('WARNING: provisioning ended without a device: $session');
      return null;
    }
  }

  // First sync now instead of waiting for the 30 s legacy poll: creates the
  // entities and marks the device ONLINE.
  final sync = await api.post('/devices/$deviceId/synchronize', const {});
  stdout.writeln('fake device $deviceId synchronize -> ${sync.status}');
  if (sync.status >= 300) stderr.writeln(sync.body);
  return deviceId;
}

Future<String?> _openEsphomeSession(_Api api, String externalId) async {
  final r = await api.get('/provisioning?source=ESPHOME&limit=100');
  _expect(r, 200);
  for (final s in _items(r.body)) {
    final identity = s['externalIdentity'] as Map;
    if (identity['externalId'] == externalId &&
        const {'DISCOVERED', 'CLAIMED'}.contains(s['status'])) {
      return s['id'] as String;
    }
  }
  return null;
}

/// Steps 6 and 7.
Future<void> _configureHeating(
  _Api api,
  String deviceId, {
  String? relayName,
  String? temperatureName,
}) async {
  final r = await api.get('/devices/$deviceId');
  _expect(r, 200);
  final device = jsonDecode(r.body) as Map<String, dynamic>;
  final entities = (device['entities'] as List).cast<Map<String, dynamic>>();
  final relay = entities
      .where(
        (e) =>
            e['domain'] == 'switch' &&
            e['writable'] == true &&
            (relayName == null || e['sourceName'] == relayName),
      )
      .firstOrNull;
  final temperature = entities
      .where(
        (e) =>
            e['deviceClass'] == 'temperature' &&
            (temperatureName == null || e['sourceName'] == temperatureName),
      )
      .firstOrNull;
  if (relay == null || temperature == null) {
    stderr.writeln(
      'WARNING: fake device has no relay/temperature entity yet: '
      '${entities.map((e) => e['sourceName']).toList()}',
    );
    return;
  }

  final wiring = {
    'heatingRelayEntityId': relay['id'],
    'controlTemperatureEntityId': temperature['id'],
  };
  if (wiring.entries.any((e) => device[e.key] != e.value)) {
    final p = await api.patch('/devices/$deviceId', wiring);
    _expect(p, 200);
    stdout.writeln('heating relay and control temperature set');
  }

  // Entity roles. Without a role or function on every enabled entity the
  // detail reports `needs_configuration` instead of `online`
  // (device-details-query.service.ts productStatus).
  for (final (entity, roleId) in [
    (relay, 'role-boiler'),
    (temperature, 'role-co-supply'),
  ]) {
    if (entity['assignedRole'] != null || entity['assignedFunction'] != null) {
      continue;
    }
    final p = await api.put(
      '/devices/$deviceId/entities/${entity['id']}/role',
      {'roleId': roleId},
    );
    _expect(p, 200);
    stdout.writeln('role $roleId assigned to ${entity['sourceName']}');
  }

  final base = device['baseControlStrategy'];
  if (base is! Map ||
      _controlStrategy.entries.any((e) => base[e.key] != e.value)) {
    final p = await api.patch(
      '/devices/$deviceId/control-strategy',
      _controlStrategy,
    );
    _expect(p, 200);
    stdout.writeln('control strategy set: ${p.body}');
  }
}

Future<void> _recordFixtures(
  _Api api,
  _Recorder recorder,
  List<_Account> accounts,
) async {
  for (final MapEntry(key: path, value: url) in {
    'AuthController_getMe/owner.json': '/auth/me',
    'UsersController_getProfile/owner.json': '/users/me/profile',
    'AuthController_listSessions/owner.json': '/auth/sessions',
    'RoomsController_list/seeded.json': '/rooms',
    'DevicesController_list/seeded.json': '/devices?limit=100',
    'SettingsController_getSystem/ok.json': '/settings/system',
    'HealthController_live/ok.json': '/health/live',
    'SetupController_getStatus/initialized.json': '/setup/status',
  }.entries) {
    await recorder.record(path, () async => (await api.get(url)).body);
  }

  final devices = await _devices(api);
  final roomless = devices
      .where((d) => d['name'] == 'Czujnik bez pokoju')
      .firstOrNull;
  if (roomless != null) {
    await recorder.record(
      'DevicesController_get/no_room_no_entities.json',
      () async => (await api.get('/devices/${roomless['id']}')).body,
    );
  }
  final fake = devices.where((d) => d['model'] == _fakeModel).firstOrNull;
  if (fake != null) {
    await recorder.record(
      'DevicesController_get/fake_esphome.json',
      () async => (await api.get('/devices/${fake['id']}')).body,
    );
    await _recordWriteFixtures(api, recorder, fake['id'] as String);
  }

  // Refresh, change password and logout, recorded on the seeded USER so the
  // owner's session and password are never touched. One login.
  final user = accounts.where((a) => a.role == 'USER').firstOrNull;
  const sessionFixtures = [
    'AuthController_refresh/ok.json',
    'UsersController_changePassword/ok.json',
    'AuthController_logout/ok.set-cookie.txt',
  ];
  if (user != null && sessionFixtures.any(recorder.wants)) {
    final session = _Api(api.base);
    final login = await session.post('/auth/login', {
      'email': user.email,
      'password': user.password,
    });
    _expect(login, 200);
    final refresh = await session.post(
      '/auth/refresh',
      null,
      headers: {'cookie': _cookiePair(login.setCookie)},
    );
    _expect(refresh, 200);
    recorder
      ..save('AuthController_refresh/ok.json', _redactTokens(refresh.body))
      ..saveText(
        'AuthController_refresh/ok.set-cookie.txt',
        _redactCookies(refresh.setCookie).join('\n'),
      );
    session.bearer = _field(refresh.body, 'accessToken')! as String;

    final temporary = '${user.password}-Tmp1';
    final changed = await session.post('/users/me/change-password', {
      'currentPassword': user.password,
      'newPassword': temporary,
    });
    _expect(changed, 200);
    recorder.save('UsersController_changePassword/ok.json', changed.body);
    final restored = await session.post('/users/me/change-password', {
      'currentPassword': temporary,
      'newPassword': user.password,
    });
    _expect(restored, 200);

    final logout = await session.post('/auth/logout', null);
    _expect(logout, 204);
    recorder.saveText(
      'AuthController_logout/ok.set-cookie.txt',
      logout.setCookie.join('\n'),
    );
  }

  // M3 environment: the contract stack has no house location or PV (and
  // the app may not write /settings/energy*), so only the "nothing to
  // show" answers are recordable; the 200 shapes are hand-written.
  for (final MapEntry(key: path, value: url) in {
    'EnvironmentController_current/error_no_data.json': '/weather/current',
    'EnvironmentController_hourly/error_no_data.json': '/weather/hourly',
    'EnvironmentController_daily/error_no_data.json': '/weather/daily',
    'EnvironmentController_solarCurrent/error_no_location.json':
        '/solar/current',
    'EnvironmentController_pvForecast/error_not_configured.json':
        '/pv/forecast',
  }.entries) {
    await recorder.record(path, () async => (await api.get(url)).body);
  }
  // M3 account. PATCH {} changes nothing; the revoke errors touch no
  // session. Regenerate, logout-all and the recovery reset are not recorded:
  // they would rotate the owner's code, end its sessions or spend the
  // 5-per-15-minutes reset budget (account_contract_test.dart covers them).
  await recorder.record(
    'UsersController_updateProfile/unchanged.json',
    () async => (await api.patch('/users/me/profile', <String, Object>{})).body,
  );
  await recorder.record(
    'AuthController_revokeSession/error_not_found.json',
    () async => (await api.delete(
      '/auth/sessions/00000000-0000-4000-8000-000000000000',
    )).body,
  );

  // Error envelopes. The two login attempts count against the login rate
  // limit (5/min per IP), so they are made only when needed.
  final anonymous = _Api(api.base);
  await recorder.record(
    'AuthController_getMe/error_unauthorized.json',
    () async => (await anonymous.get('/auth/me')).body,
  );
  await recorder.record(
    '_unrouted/error_route_not_found.json',
    () async => (await anonymous.get('/definitely-not-a-route')).body,
  );
  await recorder.record(
    'AuthController_login/error_validation.json',
    () async => (await anonymous.post('/auth/login', {
      'email': 'x@x.test',
      'password': 'wrong',
      'extra': 1,
    })).body,
  );
  await recorder.record(
    'AuthController_login/error_invalid_credentials.json',
    () async => (await anonymous.post('/auth/login', {
      'email': 'nobody@gihome.test',
      'password': 'WrongPass123',
    })).body,
  );
}

/// The M2 write endpoints on the fake device (LEGACY_ESPHOME, contract stack
/// only: the device exists nowhere else). Every write leaves the device as
/// the seeder configured it: relay OFF, not suspended, the seeded strategy.
Future<void> _recordWriteFixtures(
  _Api api,
  _Recorder recorder,
  String deviceId,
) async {
  final detail = jsonDecode((await api.get('/devices/$deviceId')).body);
  if (detail is! Map<String, dynamic>) return;
  final relayId = detail['heatingRelayEntityId'] as String?;
  final sensorId = detail['controlTemperatureEntityId'] as String?;
  if (relayId == null || sensorId == null) return;
  final state = '/devices/$deviceId/entities/$relayId/state';

  const put = 'DeviceEspHomeSyncController_setSwitchState';
  if (recorder.wants('$put/legacy_on.json') ||
      recorder.wants('$put/legacy_off.json')) {
    final on = await api.put(state, {'state': true});
    final off = await api.put(state, {'state': false});
    _expect(on, 200);
    _expect(off, 200);
    recorder
      ..save('$put/legacy_on.json', on.body)
      ..save('$put/legacy_off.json', off.body);
  }
  await recorder.record(
    '$put/error_entity_not_writable.json',
    () async => (await api.put('/devices/$deviceId/entities/$sensorId/state', {
      'state': false,
    })).body,
  );
  await recorder.record(
    '$put/error_entity_not_found.json',
    () async => (await api.put(
      '/devices/$deviceId/entities/no-such-entity/state',
      {'state': false},
    )).body,
  );
  await recorder.record(
    '$put/error_validation.json',
    () async => (await api.put(state, {'state': 'on'})).body,
  );

  // Not suspended after the seeder, so this PATCH changes nothing.
  await recorder.record(
    'DevicesController_update/resumed.json',
    () async => (await api.patch('/devices/$deviceId', {
      'heatingSuspended': false,
    })).body,
  );
  const strategy = 'DevicesController_updateControlStrategy';
  await recorder.record(
    '$strategy/seeded.json',
    () async => (await api.patch(
      '/devices/$deviceId/control-strategy',
      _controlStrategy,
    )).body,
  );
  await recorder.record(
    '$strategy/error_validation.json',
    () async => (await api.patch('/devices/$deviceId/control-strategy', {
      ..._controlStrategy,
      'hysteresisCelsius': 0,
    })).body,
  );

  await _recordM3DeviceFixtures(api, recorder, deviceId, relayId, sensorId);
}

/// The M3 device endpoints on the fake device: schedule CRUD (the created
/// schedule is disabled and deleted again, so the effective strategy stays
/// the seeded one), the PV heating plan (DISABLED without PV) and entity
/// history (the relay toggles of [_recordWriteFixtures] and earlier runs;
/// the fake temperature is constant, so its history is empty).
Future<void> _recordM3DeviceFixtures(
  _Api api,
  _Recorder recorder,
  String deviceId,
  String relayId,
  String sensorId,
) async {
  final base = '/devices/$deviceId/schedules';
  const body = {
    'name': 'Dni robocze',
    'daysOfWeek': [1, 2, 3, 4, 5],
    'startTime': '06:00',
    'endTime': '22:00',
    'targetTemperatureCelsius': 50,
    'hysteresisCelsius': 3,
    'enabled': false,
  };
  if (recorder.wants('HeatingScheduleController_create/created.json') ||
      recorder.wants('HeatingScheduleController_update/renamed.json') ||
      recorder.wants('HeatingScheduleController_list/one_row.json')) {
    final created = await api.post(base, body);
    _expect(created, 201);
    final id = _field(created.body, 'id')! as String;
    try {
      final list = await api.get(base);
      _expect(list, 200);
      final updated = await api.patch('$base/$id', {
        'name': 'Dni robocze (zmienione)',
      });
      _expect(updated, 200);
      recorder
        ..save('HeatingScheduleController_create/created.json', created.body)
        ..save('HeatingScheduleController_list/one_row.json', list.body)
        ..save('HeatingScheduleController_update/renamed.json', updated.body);
    } finally {
      _expect(await api.delete('$base/$id'), 204);
    }
  }
  await recorder.record(
    'HeatingScheduleController_list/empty.json',
    () async => (await api.get(base)).body,
  );
  await recorder.record(
    'HeatingScheduleController_create/error_validation.json',
    () async => (await api.post(base, {...body, 'startTime': '24:00'})).body,
  );
  await recorder.record(
    'HeatingScheduleController_update/error_not_found.json',
    () async => (await api.patch('$base/ckmissingschedule000000', {
      'enabled': false,
    })).body,
  );
  await recorder.record(
    'HeatingScheduleController_remove/error_not_found.json',
    () async => (await api.delete('$base/ckmissingschedule000000')).body,
  );

  await recorder.record(
    'PvHeatingController_getPlan/disabled.json',
    () async => (await api.get('/devices/$deviceId/pv-heating-plan')).body,
  );

  const history = 'HistoryController_getEntityHistory';
  String historyOf(String entityId) =>
      '/devices/$deviceId/entities/$entityId/history';
  await recorder.record(
    '$history/relay.json',
    () async => (await api.get(historyOf(relayId))).body,
  );
  await recorder.record(
    '$history/temperature_empty.json',
    () async => (await api.get(historyOf(sensorId))).body,
  );
  await recorder.record(
    '$history/error_range_invalid.json',
    () async => (await api.get(
      '${historyOf(relayId)}?from=2026-01-02T00:00:00Z&to=2026-01-01T00:00:00Z',
    )).body,
  );
  await recorder.record(
    '$history/error_validation.json',
    () async => (await api.get('${historyOf(relayId)}?limit=0')).body,
  );
  await recorder.record(
    '$history/error_entity_not_found.json',
    () async => (await api.get(historyOf('no-such-entity'))).body,
  );
}

/// Writes fixtures under [dir], keeping existing files unless [overwrite].
final class _Recorder {
  new(this.dir, {required this.enabled, required this.overwrite});

  final String dir;
  final bool enabled;
  final bool overwrite;
  int written = 0;
  int kept = 0;

  bool wants(String path) =>
      enabled && (overwrite || !File('$dir/$path').existsSync());

  Future<void> record(String path, Future<String> Function() fetch) async {
    if (!enabled) return;
    if (!wants(path)) {
      kept++;
      return;
    }
    save(path, await fetch());
  }

  /// Pretty-prints [body] when it is JSON.
  void save(String path, String body) {
    var out = body;
    try {
      out = const JsonEncoder.withIndent('  ').convert(jsonDecode(body));
    } on FormatException {
      // Not JSON: stored as is.
    }
    saveText(path, out);
  }

  void saveText(String path, String text) {
    if (!enabled) return;
    if (!wants(path)) {
      kept++;
      return;
    }
    File('$dir/$path')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('$text\n');
    written++;
    stdout.writeln('fixture: $path');
  }
}

String _backendRef() {
  for (final line in _backendLock.readAsLinesSync()) {
    if (line.trim().startsWith('shortSha=')) {
      return line.trim().substring('shortSha='.length).trim();
    }
  }
  throw StateError('${_backendLock.path} has no shortSha=');
}

Map<String, String> _loadOrCreateCreds() {
  if (_envFile.existsSync()) {
    return {
      for (final l in _envFile.readAsLinesSync())
        if (l.contains('=') && !l.startsWith('#'))
          l.substring(0, l.indexOf('=')): l.substring(l.indexOf('=') + 1),
    };
  }
  final rnd = Random.secure();
  const chars = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = List.generate(14, (_) => chars[rnd.nextInt(chars.length)]);
  final pw = 'Dev${random.join()}9a';
  final creds = {'GI_DEV_EMAIL': 'owner@gihome.test', 'GI_DEV_PASSWORD': pw};
  _envFile.parent.createSync(recursive: true);
  _envFile.writeAsStringSync(
    '# Local dev-only credentials for the dockerized GI Core. Gitignored.\n'
    '${creds.entries.map((e) => '${e.key}=${e.value}').join('\n')}\n',
  );
  stdout.writeln('generated dev credentials in ${_envFile.path}');
  return creds;
}

/// Asks [question] on stdin; anything but y/yes/t/tak is a no (EOF too).
bool _confirm(String question) {
  stdout.write('$question [y/N] ');
  final answer = stdin.readLineSync()?.trim().toLowerCase();
  return const {'y', 'yes', 't', 'tak'}.contains(answer);
}

List<Map<String, dynamic>> _items(String body) {
  final decoded = jsonDecode(body);
  final list =
      (decoded is Map ? (decoded['items'] ?? decoded['data']) : decoded)
          as List;
  return list.cast<Map<String, dynamic>>();
}

Object? _field(String body, String key) => (jsonDecode(body) as Map)[key];

String _redactTokens(String body) {
  final m = jsonDecode(body) as Map<String, dynamic>;
  if (m.containsKey('accessToken')) m['accessToken'] = '<redacted-jwt>';
  return jsonEncode(m);
}

/// `name=value` of the refresh cookie in [setCookie], for a `Cookie` header.
String _cookiePair(List<String> setCookie) =>
    setCookie.firstWhere((c) => c.contains('=')).split(';').first;

List<String> _redactCookies(List<String> cookies) => cookies
    .map(
      (c) => c.replaceFirstMapped(
        RegExp(r'^([^=]+)=([0-9a-f-]{36})\.([A-Za-z0-9_-]+)'),
        (m) {
          const session = '00000000-0000-0000-0000-000000000000';
          return '${m[1]}=$session.${'A' * m[3]!.length}';
        },
      ),
    )
    .toList();

void _expect(_Res r, int code) {
  if (r.status != code) {
    stderr.writeln('Expected $code, got ${r.status}: ${r.body}');
    exit(1);
  }
}

class _Res {
  new(this.status, this.body, this.setCookie);
  final int status;
  final String body;
  final List<String> setCookie;

  @override
  String toString() => '$status $body';
}

class _Api {
  new(this.base);
  final String base;
  String? bearer;
  final _client = HttpClient();

  Future<_Res> get(String path) => _send('GET', path, null);
  Future<_Res> post(
    String path,
    Object? body, {
    Map<String, String> headers = const {},
  }) => _send('POST', path, body, headers);
  Future<_Res> patch(String path, Object body) => _send('PATCH', path, body);
  Future<_Res> put(String path, Object body) => _send('PUT', path, body);
  Future<_Res> delete(String path) => _send('DELETE', path, null);

  Future<_Res> _send(
    String method,
    String path,
    Object? body, [
    Map<String, String> headers = const {},
  ]) async {
    final req = await _client.openUrl(method, Uri.parse('$base$path'));
    req.headers.set('Accept', 'application/json');
    req.headers.set('User-Agent', 'GIHome-Mobile-Seed/0.1 (dev)');
    if (bearer != null) req.headers.set('Authorization', 'Bearer $bearer');
    headers.forEach(req.headers.set);
    if (body != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(body));
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    return _Res(
      res.statusCode,
      text,
      res.headers[HttpHeaders.setCookieHeader] ?? const [],
    );
  }
}
