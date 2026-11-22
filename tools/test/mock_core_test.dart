import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_tools/mock_core.dart';
import 'package:test/test.dart';

/// mock_core on an ephemeral port, driven by the real client (strict
/// decoding, so the served fixtures must match the models exactly).
void main() {
  final root = findRepoRoot(from: Directory.current);
  final fixtures = MockCoreFixtures.load(
    resolveFixturesDir(fixturesRoot(root), readBackendRef(root)),
  );

  late DateTime now;
  late MockCore core;
  late MockCoreServer server;
  late List<String> requests;
  late GiCoreClient client;

  GiCoreClient newClient() => GiCoreClient.create(
    address: ApplianceAddress.parse(server.baseUrl),
    vault: InMemoryTokenVault(),
    clientInfo: const ClientInfo(appVersion: '0.0.0', platform: 'test'),
    decodeMode: DecodeMode.strict,
  );

  /// A raw Dio for wire-level checks; never throws on a status.
  Dio raw() => Dio(
    BaseOptions(
      baseUrl: '${server.baseUrl}/api/v1',
      validateStatus: (_) => true,
    ),
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 19, 12);
    requests = [];
    core = MockCore(fixtures: fixtures, now: () => now);
    server = await MockCoreServer.start(core: core, port: 0, log: requests.add);
    client = newClient();
  });

  tearDown(() async {
    await client.close();
    await server.close();
  });

  test('serves the fixtures of the pinned backend ref', () {
    expect(fixtures.ref, readBackendRef(root));
    for (final endpoint in GiEndpoints.all) {
      expect(
        fixtures.json.keys.followedBy(fixtures.text.keys),
        contains(endpoint.id),
      );
    }
  });

  test('connect, login, devices, rooms, me and profile', () async {
    expect((await client.healthLive()).status, 'ok');
    expect((await client.setupStatus()).initialized, isTrue);

    final user = await client.login(
      email: 'dev@gihome.test',
      password: 'anything',
    );
    expect(user.email, 'dev@gihome.test');
    expect(user.role, UserRole.owner);

    final devices = await client.devices();
    expect(devices.items, hasLength(3));
    for (final item in devices.items) {
      final detail = await client.device(item.id);
      expect(detail.id, item.id);
      expect(detail.lastSeenAt, item.lastSeenAt == null ? isNull : now);
    }
    expect(await client.rooms(), hasLength(2));
    expect((await client.me()).email, 'dev@gihome.test');
    expect((await client.profile()).email, 'dev@gihome.test');
    expect(core.activeSessions, 1);
  });

  test('refresh rotates the cookie; an expired token is refreshed', () async {
    await client.login(email: 'dev@gihome.test', password: 'x');
    final first = await client.session.accessToken();

    final second = await client.session.ensureFresh(force: true);
    expect(second, isNot(first));

    // Server-side expiry: the client gets AUTH_ACCESS_TOKEN_EXPIRED, refreshes
    // once and replays the call.
    now = now.add(const Duration(minutes: 16));
    final refreshesBefore = requests.where(_isRefresh).length;
    expect(await client.rooms(), hasLength(2));
    expect(requests.where(_isRefresh).length, refreshesBefore + 1);
  });

  test('a replayed refresh cookie is REUSED and revokes the session', () async {
    final dio = raw();
    final login = await dio.post<Object?>(
      '/auth/login',
      data: {'email': 'dev@gihome.test', 'password': 'x'},
    );
    expect(login.statusCode, 200);
    final cookie = _cookie(login);
    expect(
      RefreshCookieCodec.valuePattern.hasMatch(cookie.split('=').last),
      isTrue,
    );

    final rotated = await _refresh(dio, cookie);
    expect(rotated.statusCode, 200);
    expect(_cookie(rotated), isNot(cookie));

    final replay = await _refresh(dio, cookie);
    expect(replay.statusCode, 401);
    expect(_code(replay), 'AUTH_REFRESH_TOKEN_REUSED');
    expect(
      _code(await _refresh(dio, _cookie(rotated))),
      'AUTH_SESSION_REVOKED',
    );
    expect(core.activeSessions, 0);
  });

  test('auth errors use the Core envelope', () async {
    final dio = raw();

    final anonymous = await dio.get<Object?>(
      '/devices',
      options: Options(headers: {'x-request-id': 'req-1'}),
    );
    expect(anonymous.statusCode, 401);
    expect(_code(anonymous), 'AUTH_UNAUTHORIZED');
    expect((anonymous.data! as Map)['requestId'], 'req-1');
    expect(anonymous.headers.value('x-request-id'), 'req-1');

    final badToken = await dio.get<Object?>(
      '/devices',
      options: Options(headers: {'authorization': 'Bearer nope'}),
    );
    expect(_code(badToken), 'AUTH_ACCESS_TOKEN_INVALID');

    final extra = await dio.post<Object?>(
      '/auth/login',
      data: {'email': 'a@b.c', 'password': 'x', 'extra': 1},
    );
    expect(extra.statusCode, 400);
    expect(_code(extra), 'VALIDATION_FAILED');
    expect((extra.data! as Map)['details'], {
      'extra': ['property extra should not exist'],
    });

    final unrouted = await dio.get<Object?>('/definitely-not-a-route');
    expect(unrouted.statusCode, 404);
    expect(_code(unrouted), 'HTTP_404');

    final missing = await _signedIn(dio, '/devices/nope');
    expect(_code(missing), 'DEVICE_NOT_FOUND');
  });

  test('--password is enforced and change-password updates it', () async {
    core.password = 'old-password';
    await expectLater(
      client.login(email: 'dev@gihome.test', password: 'wrong'),
      throwsA(isA<ApiFailure>()),
    );
    await client.login(email: 'dev@gihome.test', password: 'old-password');
    final other = newClient();
    addTearDown(other.close);
    await other.login(email: 'dev@gihome.test', password: 'old-password');

    final result = await client.changePassword(
      const ChangePasswordRequest(
        currentPassword: 'old-password',
        newPassword: 'new-password',
      ),
    );

    expect(result.revokedSessions, 1);
    expect(core.password, 'new-password');
    expect(core.activeSessions, 1);
  });

  test('logout ends the session and clears the cookie', () async {
    await client.login(email: 'dev@gihome.test', password: 'x');

    final result = await client.logout();

    expect(result.serverSessionEnded, isTrue);
    expect(core.activeSessions, 0);
  });

  group('M2 writes (plan §12)', () {
    final fake =
        fixtures.json['DevicesController_get']!['fake_esphome']!
            as Map<String, Object?>;
    final deviceId = fake['id']! as String;
    final relayId = fake['heatingRelayEntityId']! as String;
    final sensorId = fake['controlTemperatureEntityId']! as String;
    final statePath = '/devices/$deviceId/entities/$relayId/state';

    setUp(() => client.login(email: 'dev@gihome.test', password: 'x'));

    Future<Response<Object?>> write(String method, String path, Object data) =>
        _authorized(client, raw(), method, path, data);

    /// Restarts the server on [detail] as the only recorded details.
    Future<void> serveOnly(Map<String, Object?> detail) async {
      await client.close();
      await server.close();
      core = MockCore(
        fixtures: MockCoreFixtures(fixtures.ref, {
          ...fixtures.json,
          'DevicesController_get': {'fake_esphome': detail},
        }, fixtures.text),
        now: () => now,
      );
      server = await MockCoreServer.start(core: core, port: 0);
      client = newClient();
      await client.login(email: 'dev@gihome.test', password: 'x');
    }

    test('a legacy switch is confirmed and shows in the details', () async {
      final on = await client.setSwitchState(deviceId, relayId, state: true);

      expect(on.state, isTrue);
      expect(on.confirmedAt, now);
      final relay = (await client.device(deviceId)).entities
          .firstWhere((e) => e.id == relayId);
      expect(relay.value, const EntityValue.boolean(true));
    });

    test('guards and validation answer Core codes', () async {
      final cases = <(String, Object, String)>[
        (
          '/devices/$deviceId/entities/nope/state',
          {'state': true},
          'DEVICE_ENTITY_NOT_FOUND',
        ),
        (
          '/devices/$deviceId/entities/$sensorId/state',
          {'state': true},
          'ENTITY_NOT_WRITABLE',
        ),
        (statePath, {'state': 'on'}, 'VALIDATION_FAILED'),
        (statePath, {'state': true, 'x': 1}, 'VALIDATION_FAILED'),
        (statePath, <String, Object>{}, 'VALIDATION_FAILED'),
        (
          '/devices/00000000-0000-4000-8000-000000000000/entities/a/state',
          {'state': true},
          'DEVICE_NOT_FOUND',
        ),
      ];
      for (final (path, data, code) in cases) {
        expect(_code(await write('PUT', path, data)), code, reason: path);
      }
    });

    test('suspend: ON refused, OFF allowed, effective mode OFF; resume '
        'restores the base mode', () async {
      final suspended = await client.setHeatingSuspended(
        deviceId,
        suspended: true,
      );
      expect(suspended.heatingSuspended, isTrue);
      final refused = await write('PUT', statePath, {'state': true});
      expect(refused.statusCode, 409);
      expect(_code(refused), 'HEATING_SUSPENDED');
      expect(
        (await client.setSwitchState(deviceId, relayId, state: false)).state,
        isFalse,
      );
      final whileSuspended = await client.device(deviceId);
      expect(whileSuspended.controlStrategy?.mode, ControlStrategyMode.off);
      expect(
        whileSuspended.baseControlStrategy?.mode,
        ControlStrategyMode.manual,
      );

      await client.setHeatingSuspended(deviceId, suspended: false);
      final resumed = await client.device(deviceId);
      expect(resumed.heatingSuspended, isFalse);
      expect(resumed.controlStrategy, resumed.baseControlStrategy);
    });

    test('control strategy: validated, effective follows base, version '
        'increases', () async {
      final before = (await client.device(deviceId)).configurationVersion;
      final result = await client.updateControlStrategy(
        deviceId,
        targetTemperatureCelsius: 60,
        hysteresisCelsius: 5,
        mode: ControlStrategyMode.auto,
      );

      expect(result.controlStrategy, result.baseControlStrategy);
      expect(result.baseControlStrategy?.targetTemperatureCelsius, 60);
      expect(result.configurationVersion, before + 1);
      final invalid = await write(
        'PATCH',
        '/devices/$deviceId/control-strategy',
        {'targetTemperatureCelsius': 60, 'hysteresisCelsius': 0, 'mode': 'X'},
      );
      expect(invalid.statusCode, 400);
      expect((invalid.data! as Map)['details'], hasLength(2));
    });

    test('an injected legacy failure answers with its status', () async {
      for (final MapEntry(key: code, value: status)
          in MockCore.switchFailures.entries) {
        core.switchFailure = code;
        final response = await write('PUT', statePath, {'state': true});
        expect(response.statusCode, status);
        expect(_code(response), code);
      }
    });

    test('GI Edge: a dry run answers the OLD state and writes nothing; '
        'otherwise the write is optimistic', () async {
      await serveOnly({
        ...fake,
        'communicationMode': 'GI_EDGE_V1',
        'dryRun': true,
      });

      final dry = await client.setSwitchState(deviceId, relayId, state: true);
      expect(dry.state, isFalse);
      final relay = (await client.device(deviceId)).entities
          .firstWhere((e) => e.id == relayId);
      expect(relay.value, const EntityValue.boolean(false));

      final live = await write('PATCH', '/devices/$deviceId', {
        'dryRun': false,
      });
      expect(live.statusCode, 200);
      expect(
        (await client.setSwitchState(deviceId, relayId, state: true)).state,
        isTrue,
      );
    });

    test('an offline device answers 503 DEVICE_OFFLINE', () async {
      await serveOnly({...fake, 'status': 'offline'});

      final response = await write('PUT', statePath, {'state': false});
      expect(response.statusCode, 503);
      expect(_code(response), 'DEVICE_OFFLINE');
    });
  });
  group('M3', () {
    final fake =
        fixtures.json['DevicesController_get']!['fake_esphome']!
            as Map<String, Object?>;
    final deviceId = fake['id']! as String;

    setUp(() => client.login(email: 'dev@gihome.test', password: 'x'));

    test('schedules: CRUD with Core statuses, reconciled on UTC', () async {
      // 2026-11-19 is a Thursday (day 4); now is 12:00 UTC.
      final before = await client.schedules(deviceId);
      final created = await client.createSchedule(
        deviceId,
        const HeatingScheduleInput(
          name: 'Noon',
          daysOfWeek: [4],
          startTime: '11:00',
          endTime: '13:00',
          targetTemperatureCelsius: 61.5,
          hysteresisCelsius: 2,
        ),
      );
      expect(created.enabled, isTrue);
      expect(await client.schedules(deviceId), hasLength(before.length + 1));
      var strategy = (await client.device(deviceId)).controlStrategy!;
      expect(strategy.targetTemperatureCelsius, 61.5);
      expect(strategy.mode, ControlStrategyMode.manual);

      final disabled = await client.updateSchedule(
        deviceId,
        created.id,
        const HeatingSchedulePatch(enabled: false),
      );
      expect(disabled.enabled, isFalse);
      strategy = (await client.device(deviceId)).controlStrategy!;
      expect(strategy.targetTemperatureCelsius, 55);

      final dio = raw();
      final path = '/devices/$deviceId/schedules';
      final bad = await _authorized(client, dio, 'POST', path, {
        'name': 'x',
        'daysOfWeek': [7],
        'startTime': '24:00',
        'endTime': '06:00',
        'targetTemperatureCelsius': 50,
        'hysteresisCelsius': 2,
      });
      expect(bad.statusCode, 400);
      expect(_code(bad), 'VALIDATION_FAILED');

      await client.deleteSchedule(deviceId, created.id);
      expect(await client.schedules(deviceId), hasLength(before.length));
      final gone = await _authorized(
        client,
        dio,
        'DELETE',
        '$path/${created.id}',
        const <String, Object?>{},
      );
      expect(gone.statusCode, 404);
      expect(_code(gone), 'HEATING_SCHEDULE_NOT_FOUND');
    });

    test('sessions: list marks this one, revoke, logout-all', () async {
      final other = newClient();
      addTearDown(other.close);
      await other.login(email: 'dev@gihome.test', password: 'x');
      final sessions = await client.authSessions();
      expect(sessions, hasLength(2));
      expect(sessions.where((s) => s.current), hasLength(1));
      final foreign = sessions.firstWhere((s) => !s.current);
      await client.revokeSession(foreign.id);
      expect(core.activeSessions, 1);
      await client.logoutAll();
      expect(core.activeSessions, 0);
    });

    test('recovery code: regenerate, reset revokes every session', () async {
      final code = (await client.regenerateRecoveryCode()).recoveryCode;
      expect(RecoveryCodeFormat.check(code), isNull);
      await client.resetPasswordWithRecoveryCode(
        RecoveryResetRequest(
          email: 'dev@gihome.test',
          recoveryCode: code,
          newPassword: 'Recovered1',
        ),
      );
      expect(core.activeSessions, 0);
    });

    test('profile update is served back', () async {
      final updated = await client.updateProfile(
        const ProfileUpdate(locale: 'en-US', firstName: 'Ada'),
      );
      expect(updated.locale, 'en-US');
      expect((await client.profile()).firstName, 'Ada');
      expect((await client.me()).firstName, 'Ada');
    });

    test('M3 reads are served from fixtures', () async {
      expect(await client.pvHeatingPlan(deviceId), isA<PvHeatingPlan>());
      expect(
        await client.weatherCurrent(),
        isA<EnvironmentAvailable<Object?>>(),
      );
      expect(await client.solarCurrent(), isA<EnvironmentAvailable<Object?>>());
      expect(await client.pvForecast(), isA<EnvironmentAvailable<Object?>>());
    });
  });
}

Future<Response<Object?>> _authorized(
  GiCoreClient client,
  Dio dio,
  String method,
  String path,
  Object data,
) async => await dio.request<Object?>(
  path,
  data: data,
  options: Options(
    method: method,
    headers: {'authorization': 'Bearer ${await client.session.accessToken()}'},
  ),
);

bool _isRefresh(String line) => line.contains('/api/v1/auth/refresh');

String _cookie(Response<Object?> response) =>
    response.headers['set-cookie']!.single.split(';').first;

Future<Response<Object?>> _refresh(Dio dio, String cookie) => dio.post<Object?>(
  '/auth/refresh',
  options: Options(headers: {'cookie': cookie}),
);

Future<Response<Object?>> _signedIn(Dio dio, String path) async {
  final login = await dio.post<Object?>(
    '/auth/login',
    data: {'email': 'dev@gihome.test', 'password': 'x'},
  );
  final token = (login.data! as Map)['accessToken'];
  return await dio.get<Object?>(
    path,
    options: Options(headers: {'authorization': 'Bearer $token'}),
  );
}

String? _code(Response<Object?> response) =>
    (response.data! as Map)['code'] as String?;
