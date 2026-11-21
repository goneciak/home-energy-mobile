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
}

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
