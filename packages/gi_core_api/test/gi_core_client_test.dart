import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  late FakeCore core;
  late InMemoryTokenVault vault;
  late GiCoreClient client;
  late List<String> log;
  late FakeClock clock;

  setUp(() async {
    core = FakeCore();
    vault = InMemoryTokenVault();
    log = [];
    clock = FakeClock();
    client = testClient(core, vault: vault, clock: clock, log: log.add);
    core.on(
      'POST',
      '/auth/login',
      (_) => FakeResponse.json(
        loginBody(),
        headers: {
          'set-cookie': [setCookieFor(testCookieValue1)],
        },
      ),
    );
    core.on('POST', '/auth/refresh', (_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return FakeResponse.json(
        refreshBody('access-2'),
        headers: {
          'set-cookie': [setCookieFor(testCookieValue2)],
        },
      );
    });
    core.on(
      'GET',
      '/devices',
      (_) =>
          FakeResponse.json(fixtureJson('DevicesController_list/seeded.json')),
    );
  });

  tearDown(() => client.close());

  Future<void> login() => client.login(email: 'a@b.c', password: 'pw');

  group('headers', () {
    test('every request carries the standard headers', () async {
      core.on(
        'GET',
        '/setup/status',
        (_) => FakeResponse.json(
          fixtureJson('SetupController_getStatus/initialized.json'),
        ),
      );

      await client.setupStatus();

      final request = core.requests.single;
      expect(request.header('accept'), 'application/json');
      expect(request.header('accept-language'), 'pl');
      expect(request.header('user-agent'), 'GIHome-Mobile/0.1.0 (Test; Dart)');
      expect(
        request.header('x-request-id'),
        matches(RegExp(r'^m-[0-9a-f]{32}$')),
      );
      expect(request.header('authorization'), isNull);
      expect(
        request.options.uri.toString(),
        'http://192.168.1.10:3000/api/v1/setup/status',
      );
    });

    test('authenticated endpoints get the Bearer token', () async {
      await login();

      final page = await client.devices();

      final request = core.requestsTo('GET', '/devices').single;
      expect(request.header('authorization'), 'Bearer access-1');
      expect(request.options.uri.query, 'page=1&limit=100');
      expect(page.items, hasLength(3));
    });

    test('the logger never prints secrets', () async {
      await login();
      await client.devices();

      final text = log.join('\n');
      expect(text, contains('GET /api/v1/devices'));
      expect(text, isNot(contains('access-1')));
      expect(text, isNot(contains(testCookieValue1)));
      expect(text, isNot(contains('pw')));
      expect(text, contains('<redacted>'));
    });

    test('a logged login carries no password, token or cookie value', () async {
      const password = 'S3cret-Passw0rd!';
      await client.login(email: 'owner@gihome.test', password: password);
      // A refresh sends the cookie in a request header.
      await client.session.ensureFresh(force: true);

      final login = log.where((line) => line.contains('/auth/login'));
      expect(login, hasLength(2), reason: 'request and response');
      final text = log.join('\n');
      expect(text, contains('POST /api/v1/auth/refresh'));
      for (final secret in [
        password,
        'owner@gihome.test',
        'access-1',
        'access-2',
        testCookieValue1,
        testCookieValue2,
        'gi_refresh_token=',
      ]) {
        expect(text, isNot(contains(secret)), reason: secret);
      }
      expect(text, contains('set-cookie: <redacted>'));
      expect(text, contains('cookie: <redacted>'));
    });
  });

  group('local network denied', () {
    DioException denied(FakeRequest request) => DioException.connectionError(
      requestOptions: request.options,
      reason: 'denied',
      error: const SocketException(
        'Connection failed',
        osError: OSError('Operation not permitted', 1),
      ),
    );

    test('is reported once, observed, and not retried', () async {
      final failures = <ApiFailure>[];
      final observed = testClient(core, onFailure: failures.add);
      addTearDown(observed.close);
      core.on('GET', '/setup/status', (request) => throw denied(request));

      await expectLater(
        observed.setupStatus(),
        throwsA(isA<LocalNetworkDeniedFailure>()),
      );
      expect(core.requestsTo('GET', '/setup/status'), hasLength(1));
      expect(failures.single.code, 'LOCAL_NETWORK_DENIED');
    });

    test('uses the injected detector', () async {
      final observed = testClient(
        core,
        localNetworkDenied: (error, _) =>
            error is SocketException && error.message == 'Connection refused',
      );
      addTearDown(observed.close);
      core.on('GET', '/health/live', (request) => throw refused(request));

      await expectLater(
        observed.healthLive(),
        throwsA(isA<LocalNetworkDeniedFailure>()),
      );
    });
  });

  group('401 handling', () {
    setUp(login);

    test('refreshes once and replays the request once', () async {
      var calls = 0;
      core.on('GET', '/devices', (request) {
        calls++;
        return request.header('authorization') == 'Bearer access-2'
            ? FakeResponse.json(
                fixtureJson('DevicesController_list/seeded.json'),
              )
            : FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED');
      });

      final page = await client.devices();

      expect(page.total, 3);
      expect(calls, 2);
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });

    test('parallel 401s trigger a single refresh', () async {
      core.on('GET', '/devices', (request) {
        return request.header('authorization') == 'Bearer access-2'
            ? FakeResponse.json(
                fixtureJson('DevicesController_list/seeded.json'),
              )
            : FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_INVALID');
      });

      await Future.wait([for (var i = 0; i < 10; i++) client.devices()]);

      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(core.requestsTo('GET', '/devices'), hasLength(20));
    });

    test('a second 401 after the replay is reported, not looped', () async {
      core.on(
        'GET',
        '/devices',
        (_) => FakeResponse.error(401, 'AUTH_UNAUTHORIZED'),
      );

      await expectLater(
        client.devices(),
        throwsA(
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'AUTH_UNAUTHORIZED',
          ),
        ),
      );
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(core.requestsTo('GET', '/devices'), hasLength(2));
    });

    test('a write is replayed once with the same body', () async {
      core.on('POST', '/users/me/change-password', (request) {
        return request.header('authorization') == 'Bearer access-2'
            ? FakeResponse.json({'revokedSessions': 2})
            : FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED');
      });

      final result = await client.changePassword(
        const ChangePasswordRequest(
          currentPassword: 'Old12345',
          newPassword: 'New12345',
        ),
      );

      expect(result.revokedSessions, 2);
      final bodies = core
          .requestsTo('POST', '/users/me/change-password')
          .map((r) => r.json);
      expect(bodies, [
        {'currentPassword': 'Old12345', 'newPassword': 'New12345'},
        {'currentPassword': 'Old12345', 'newPassword': 'New12345'},
      ]);
    });

    test('a revoked session ends locally without a refresh', () async {
      core.on(
        'GET',
        '/devices',
        (_) => FakeResponse.error(401, 'AUTH_SESSION_REVOKED'),
      );

      await expectLater(
        client.devices(),
        throwsA(
          const ApiFailure.sessionLost(
            reason: SessionLostReason.sessionRevoked,
          ),
        ),
      );
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
      expect(
        client.session.state,
        const AuthState.sessionLost(SessionLostReason.sessionRevoked),
      );
      expect(vault.cookie, isNull);
    });

    test('a disabled user ends the session; plain 403 does not', () async {
      core.on('GET', '/rooms', (_) => FakeResponse.error(403, 'HTTP_403'));
      await expectLater(client.rooms(), throwsA(isA<ForbiddenFailure>()));
      expect(client.session.state, isA<AuthAuthenticated>());

      core.on('GET', '/rooms', (_) => FakeResponse.error(403, 'USER_DISABLED'));
      await expectLater(
        client.rooms(),
        throwsA(
          const ApiFailure.sessionLost(reason: SessionLostReason.userDisabled),
        ),
      );
      expect(
        client.session.state,
        const AuthState.sessionLost(SessionLostReason.userDisabled),
      );
    });

    test(
      'an ambiguous refresh is never retried by the read retry policy',
      () async {
        core.on(
          'POST',
          '/auth/refresh',
          (request) => throw receiveTimeout(request),
        );
        clock.advance(const Duration(minutes: 15));

        await expectLater(client.devices(), throwsA(isA<TimeoutFailure>()));

        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
        expect(core.requestsTo('GET', '/health/live'), isEmpty);
        expect(core.requestsTo('GET', '/devices'), isEmpty);
      },
    );

    test('a failed refresh is reported instead of the 401', () async {
      core.on(
        'GET',
        '/devices',
        (_) => FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED'),
      );
      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.error(401, 'AUTH_REFRESH_TOKEN_REUSED'),
      );

      await expectLater(
        client.devices(),
        throwsA(
          const ApiFailure.sessionLost(
            reason: SessionLostReason.refreshTokenReused,
          ),
        ),
      );
    });
  });

  group('retries and decoding', () {
    test('idempotent reads retry transient failures', () async {
      var calls = 0;
      core.on('GET', '/setup/status', (request) {
        calls++;
        if (calls == 1) throw refused(request);
        if (calls == 2) return FakeResponse.html('<html/>', status: 503);
        return FakeResponse.json(
          fixtureJson('SetupController_getStatus/initialized.json'),
        );
      });

      final status = await client.setupStatus();

      expect(status.initialized, isTrue);
      expect(calls, 3);
    });

    test('writes are never retried', () async {
      await login();
      core.on(
        'POST',
        '/users/me/change-password',
        (_) => FakeResponse.html('<html/>', status: 503),
      );

      await expectLater(
        client.changePassword(
          const ChangePasswordRequest(currentPassword: 'a', newPassword: 'b'),
        ),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'status', 503),
        ),
      );
      expect(
        core.requestsTo('POST', '/users/me/change-password'),
        hasLength(1),
      );
    });

    test(
      'a wrong shape becomes unexpectedShape with endpoint and field',
      () async {
        await login();
        final broken = fixtureObject('DevicesController_list/seeded.json');
        ((broken['items'] as List<Object?>).first! as Map<String, dynamic>)
            .remove('dryRun');
        core.on('GET', '/devices', (_) => FakeResponse.json(broken));

        await expectLater(
          client.devices(),
          throwsA(
            isA<UnexpectedShapeFailure>()
                .having(
                  (f) => f.endpointId,
                  'endpointId',
                  'DevicesController_list',
                )
                .having((f) => f.fieldPath, 'fieldPath', contains('dryRun'))
                .having((f) => f.requestId, 'requestId', 'srv-req-1'),
          ),
        );
      },
    );

    test(
      'a JSON array where an object is expected is unexpectedShape',
      () async {
        core.on('GET', '/health/live', (_) => FakeResponse.json(['ok']));

        await expectLater(
          client.healthLive(),
          throwsA(isA<UnexpectedShapeFailure>()),
        );
      },
    );

    test('an HTML 200 is an unexpected response', () async {
      core.on(
        'GET',
        '/health/live',
        (_) => FakeResponse.html('<html>captive portal</html>'),
      );

      await expectLater(
        client.healthLive(),
        throwsA(
          isA<UnexpectedResponseFailure>().having(
            (f) => f.statusCode,
            'status',
            200,
          ),
        ),
      );
    });

    test('a missing route and a missing device are distinguished', () async {
      await login();
      core.on(
        'GET',
        '/devices/abc',
        (_) => FakeResponse.error(404, 'DEVICE_NOT_FOUND'),
      );

      await expectLater(client.device('abc'), throwsA(isA<NotFoundFailure>()));
      await expectLater(
        client.device('other'),
        throwsA(isA<RouteAbsentFailure>()),
      );
    });

    test('device detail and profile decode', () async {
      await login();
      core.on('GET', '/devices/341584fe-d238-44e5-b97b-191ff594bb09', (_) {
        return FakeResponse.json(
          fixtureJson('DevicesController_get/no_room_no_entities.json'),
        );
      });
      core.on(
        'GET',
        '/users/me/profile',
        (_) => FakeResponse.json(
          fixtureJson('UsersController_getProfile/owner.json'),
        ),
      );

      final detail = await client.device(
        '341584fe-d238-44e5-b97b-191ff594bb09',
      );
      final profile = await client.profile();

      expect(detail.name, 'Czujnik bez pokoju');
      expect(profile.email, 'owner@gihome.test');
    });

    test('an RBAC 403 reloads the user once', () async {
      await login();
      core
        ..on('GET', '/rooms', (_) => FakeResponse.error(403, 'HTTP_403'))
        ..on(
          'GET',
          '/auth/me',
          (_) => FakeResponse.json({
            ...fixtureObject('AuthController_getMe/owner.json'),
            'role': 'USER',
          }),
        );

      await Future.wait([
        for (var i = 0; i < 3; i++)
          expectLater(client.rooms(), throwsA(isA<ForbiddenFailure>())),
      ]);
      await pumpEventQueue();

      expect(core.requestsTo('GET', '/auth/me'), hasLength(1));
      expect(
        client.session.state,
        isA<AuthAuthenticated>().having(
          (s) => s.user.role,
          'role',
          UserRole.user,
        ),
      );
    });

    test('me() refreshes the user held by the session', () async {
      await login();
      core.on(
        'GET',
        '/auth/me',
        (_) => FakeResponse.json({
          ...fixtureObject('AuthController_getMe/owner.json'),
          'role': 'USER',
        }),
      );

      await client.me();

      expect(
        client.session.state,
        isA<AuthAuthenticated>().having(
          (s) => s.user.role,
          'role',
          UserRole.user,
        ),
      );
    });
  });

  test('cleartext to a public host is refused before sending', () async {
    final remote = GiCoreClient.create(
      address: ApplianceAddress.parse('http://example.com'),
      vault: vault,
      clientInfo: testClientInfo,
      httpClientAdapter: core,
    );
    addTearDown(remote.close);

    await expectLater(
      remote.login(email: 'a@b.c', password: 'pw'),
      throwsA(const ApiFailure.insecureTransport(host: 'example.com')),
    );
    expect(core.requests, isEmpty);
  });

  group('ApplianceProbe', () {
    ApplianceProbe probe() =>
        ApplianceProbe(clientInfo: testClientInfo, httpClientAdapter: core);

    test('confirms a GI Core with short timeouts', () async {
      core
        ..on(
          'GET',
          '/health/live',
          (_) =>
              FakeResponse.json(fixtureJson('HealthController_live/ok.json')),
        )
        ..on(
          'GET',
          '/setup/status',
          (_) => FakeResponse.json(
            fixtureJson('SetupController_getStatus/initialized.json'),
          ),
        );

      final result = await probe().probe('192.168.1.10:3000/api/v1/');

      expect(result.address.toString(), 'http://192.168.1.10:3000');
      expect(result.health.isLive, isTrue);
      expect(result.setup.deviceName, 'GI Home Dev');
      final health = core.requestsTo('GET', '/health/live').single;
      expect(health.options.connectTimeout, const Duration(milliseconds: 1500));
      expect(health.options.receiveTimeout, const Duration(seconds: 2));
    });

    test('reports an unreachable host', () async {
      core.on('GET', '/health/live', (request) => throw refused(request));

      await expectLater(
        probe().probe('gi-home.local'),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(core.requestsTo('GET', '/setup/status'), isEmpty);
    });

    test('gives up on health/live after the health timeout', () async {
      final never = Completer<FakeResponse>();
      core.on('GET', '/health/live', (_) => never.future);

      final stopwatch = Stopwatch()..start();
      await expectLater(
        probe().probeAddress(
          ApplianceAddress.parse('192.168.1.10'),
          healthTimeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutFailure>()),
      );
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
      expect(core.requestsTo('GET', '/setup/status'), isEmpty);
    });

    test(
      'rejects bad input and public cleartext hosts without a request',
      () async {
        await expectLater(probe().probe('ftp://x'), throwsFormatException);
        await expectLater(
          probe().probe('http://example.com'),
          throwsA(isA<InsecureTransportFailure>()),
        );
        expect(core.requests, isEmpty);
      },
    );
  });

  group('failure observer', () {
    test('sees each thrown failure once, after retries', () async {
      final seen = <ApiFailure>[];
      final observed = GiCoreClient.create(
        address: testAddress,
        vault: InMemoryTokenVault(),
        clientInfo: testClientInfo,
        httpClientAdapter: core,
        clock: FakeClock(),
        now: () => DateTime.utc(2026, 11, 17, 12),
        retryBackoff: (_) => Duration.zero,
        onFailure: seen.add,
      );
      addTearDown(observed.close);
      core.on('GET', '/health/live', (_) => FakeResponse.json(['ok']));
      core.on('GET', '/setup/status', (request) => throw refused(request));

      await expectLater(
        observed.healthLive(),
        throwsA(isA<UnexpectedShapeFailure>()),
      );
      await expectLater(
        observed.setupStatus(),
        throwsA(isA<UnreachableFailure>()),
      );

      expect(core.requestsTo('GET', '/setup/status').length, greaterThan(1));
      expect(seen, [
        isA<UnexpectedShapeFailure>().having(
          (f) => f.endpointId,
          'endpointId',
          GiEndpoints.healthLive.id,
        ),
        isA<UnreachableFailure>(),
      ]);
    });

    test('sees restore and login failures', () async {
      final seen = <ApiFailure>[];
      final observed = GiCoreClient.create(
        address: testAddress,
        vault: _ThrowingVault(),
        clientInfo: testClientInfo,
        httpClientAdapter: core,
        onFailure: seen.add,
      );
      addTearDown(observed.close);
      core.on('POST', '/auth/login', (_) => FakeResponse.json(loginBody()));

      await expectLater(
        observed.restoreSession(),
        throwsA(isA<VaultUnavailableFailure>()),
      );
      await expectLater(
        observed.login(email: 'a@b.c', password: 'pw'),
        throwsA(isA<RefreshCookieMissingFailure>()),
      );

      expect(seen, [
        isA<VaultUnavailableFailure>(),
        isA<RefreshCookieMissingFailure>(),
      ]);
    });

    test('an observer that throws does not change the failure', () async {
      final observed = GiCoreClient.create(
        address: testAddress,
        vault: InMemoryTokenVault(),
        clientInfo: testClientInfo,
        httpClientAdapter: core,
        onFailure: (_) => throw StateError('observer'),
      );
      addTearDown(observed.close);
      core.on('GET', '/health/live', (_) => FakeResponse.json(['ok']));

      await expectLater(
        observed.healthLive(),
        throwsA(isA<UnexpectedShapeFailure>()),
      );
    });

    test('the probe reports its failures', () async {
      final seen = <ApiFailure>[];
      core.on('GET', '/health/live', (request) => throw refused(request));

      await expectLater(
        ApplianceProbe(
          clientInfo: testClientInfo,
          httpClientAdapter: core,
          onFailure: seen.add,
        ).probe('gi-home.local'),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(seen, [isA<UnreachableFailure>()]);
    });
  });
}

final class _ThrowingVault implements TokenVault {
  @override
  Future<VaultResult> read() async => VaultUnavailable(StateError('locked'));

  @override
  Future<void> write(RefreshCookie cookie) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<PersistedAccessToken?> readAccessToken() async => null;

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) async {}

  @override
  Future<void> clearAccessToken() async {}
}
