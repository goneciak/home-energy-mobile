import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  late FakeCore core;
  late FakeClock clock;
  late RecordingVault vault;
  late GiCoreClient client;

  AuthSessionManager session() => client.session;

  void serveLogin({String token = 'access-1', String? cookie}) {
    core.on(
      'POST',
      '/auth/login',
      (_) => FakeResponse.json(
        loginBody(token: token),
        headers: {
          'set-cookie': [setCookieFor(cookie ?? testCookieValue1)],
        },
      ),
    );
  }

  /// Serves rotations testCookieValue2, testCookieValue3, ... with tokens
  /// access-2, access-3, ...
  void serveRotatingRefresh({Duration delay = Duration.zero}) {
    final values = [testCookieValue2, testCookieValue3];
    var issued = 0;
    core.on('POST', '/auth/refresh', (_) async {
      await Future<void>.delayed(delay);
      final value = values[issued % values.length];
      issued++;
      return FakeResponse.json(
        refreshBody('access-${issued + 1}'),
        headers: {
          'set-cookie': [setCookieFor(value)],
        },
      );
    });
  }

  setUp(() {
    core = FakeCore();
    clock = FakeClock();
    vault = RecordingVault(core.events);
    client = testClient(core, vault: vault, clock: clock);
    core.on('GET', '/health/live', (_) => FakeResponse.json({'status': 'ok'}));
    core.on(
      'GET',
      '/auth/me',
      (_) =>
          FakeResponse.json(fixtureObject('AuthController_getMe/owner.json')),
    );
  });

  tearDown(() => client.close());

  group('login', () {
    test(
      'sends exactly email and password and persists the cookie first',
      () async {
        serveLogin();
        final states = <AuthState>[];
        session().states.listen(states.add);

        final user = await client.login(
          email: 'owner@gihome.test',
          password: 'pw',
        );

        final request = core.requestsTo('POST', '/auth/login').single;
        expect(request.json!.keys, unorderedEquals(['email', 'password']));
        expect(request.header('authorization'), isNull);
        expect(user.role, UserRole.owner);
        expect(vault.cookie!.value, testCookieValue1);
        expect(vault.cookie!.absoluteExpiry, DateTime.utc(2026, 12, 17, 12));
        expect(session().state, AuthState.authenticated(user));
        expect(session().sessionExpiresAt, DateTime.utc(2026, 12, 17, 12));
        await pumpEventQueue();
        expect(states, [AuthState.authenticated(user)]);
      },
    );

    test('without a refresh cookie fails and stays logged out', () async {
      core.on('POST', '/auth/login', (_) => FakeResponse.json(loginBody()));

      await expectLater(
        client.login(email: 'a@b.c', password: 'pw'),
        throwsA(isA<RefreshCookieMissingFailure>()),
      );
      expect(vault.cookie, isNull);
      expect(session().state, const AuthState.unknown());
    });

    test('wrong credentials never trigger a refresh', () async {
      core.on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.error(401, 'AUTH_INVALID_CREDENTIALS'),
      );

      await expectLater(
        client.login(email: 'a@b.c', password: 'bad'),
        throwsA(
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'AUTH_INVALID_CREDENTIALS',
          ),
        ),
      );
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
    });
  });

  group('ensureFresh', () {
    setUp(() async {
      serveLogin();
      await client.login(email: 'a@b.c', password: 'pw');
    });

    test(
      'reuses the token until 60 s before expiry, measured monotonically',
      () async {
        serveRotatingRefresh();

        clock.advance(const Duration(seconds: 839));
        expect(await session().ensureFresh(), 'access-1');
        clock.advance(const Duration(seconds: 2));
        expect(await session().ensureFresh(), 'access-2');

        final refresh = core.requestsTo('POST', '/auth/refresh').single;
        expect(refresh.header('cookie'), 'gi_refresh_token=$testCookieValue1');
        expect(refresh.body, anyOf(isNull, isEmpty));
      },
    );

    test('concurrent callers share a single refresh', () async {
      serveRotatingRefresh(delay: const Duration(milliseconds: 20));

      final tokens = await Future.wait([
        for (var i = 0; i < 10; i++)
          session().ensureFresh(force: true, rejectedToken: 'access-1'),
      ]);

      expect(tokens.toSet(), {'access-2'});
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });

    test('a forced refresh for an already replaced token is skipped', () async {
      serveRotatingRefresh();

      await session().ensureFresh(force: true, rejectedToken: 'access-1');
      final token = await session().ensureFresh(
        force: true,
        rejectedToken: 'access-1',
      );

      expect(token, 'access-2');
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });

    test('a device sleep that stops the monotonic clock still expires the '
        'token by the wall clock', () async {
      var wall = DateTime.utc(2026, 11, 17, 12);
      await client.close();
      client = testClient(core, vault: vault, clock: clock, now: () => wall);
      await client.login(email: 'a@b.c', password: 'pw');
      serveRotatingRefresh();

      // Monotonic time stood still while the phone slept for an hour.
      wall = wall.add(const Duration(hours: 1));

      expect(await session().ensureFresh(), 'access-2');
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });

    test('a wall clock set back does not extend the token', () async {
      var wall = DateTime.utc(2026, 11, 17, 12);
      await client.close();
      client = testClient(core, vault: vault, clock: clock, now: () => wall);
      await client.login(email: 'a@b.c', password: 'pw');
      serveRotatingRefresh();

      wall = wall.subtract(const Duration(hours: 1));
      clock.advance(const Duration(seconds: 850));

      expect(await session().ensureFresh(), 'access-2');
    });

    test('never refreshes before the app is in the foreground', () async {
      final foreground = Completer<void>();
      await client.close();
      client = testClient(
        core,
        vault: vault,
        clock: clock,
        waitUntilForeground: () => foreground.future,
      );
      await client.login(email: 'a@b.c', password: 'pw');
      serveRotatingRefresh();

      final token = session().ensureFresh(force: true);
      await pumpEventQueue();
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);

      foreground.complete();
      expect(await token, 'access-2');
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });

    test(
      'rotates the cookie on every refresh and sends the newest one',
      () async {
        serveRotatingRefresh();

        await session().ensureFresh(force: true);
        await session().ensureFresh(force: true);

        final cookies = core
            .requestsTo('POST', '/auth/refresh')
            .map((r) => r.header('cookie'));
        expect(cookies, [
          'gi_refresh_token=$testCookieValue1',
          'gi_refresh_token=$testCookieValue2',
        ]);
        expect(vault.cookie!.value, testCookieValue3);
        expect(vault.cookie!.generation, 2);
      },
    );

    test('persists the rotated cookie before the new token is used', () async {
      serveRotatingRefresh();
      core.on(
        'GET',
        '/rooms',
        (_) =>
            FakeResponse.json(fixtureJson('RoomsController_list/seeded.json')),
      );
      clock.advance(const Duration(seconds: 850));

      await client.rooms();

      final write = core.events.indexOf('vault.write 1');
      final use = core.events.indexOf('GET /api/v1/rooms Bearer access-2');
      expect(write, isNonNegative);
      expect(use, greaterThan(write));
      expect(
        core.events.where(
          (e) => e.contains('Bearer access-1') && e.contains('rooms'),
        ),
        isEmpty,
      );
    });

    for (final (status, code, reason) in [
      (401, 'AUTH_REFRESH_TOKEN_REUSED', SessionLostReason.refreshTokenReused),
      (
        401,
        'AUTH_REFRESH_TOKEN_INVALID',
        SessionLostReason.refreshTokenInvalid,
      ),
      (401, 'AUTH_SESSION_REVOKED', SessionLostReason.sessionRevoked),
      (403, 'USER_DISABLED', SessionLostReason.userDisabled),
      (401, 'AUTH_SOMETHING_NEW', SessionLostReason.refreshRejected),
    ]) {
      test('$status $code wipes the session', () async {
        core.on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.error(status, code),
        );

        await expectLater(
          session().ensureFresh(force: true),
          throwsA(ApiFailure.sessionLost(reason: reason)),
        );
        expect(vault.cookie, isNull);
        expect(session().state, AuthState.sessionLost(reason));
        expect(session().sessionExpiresAt, isNull);
      });
    }

    test(
      'after a loss, later callers keep the reason and send nothing',
      () async {
        core.on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.error(403, 'USER_DISABLED'),
        );
        await expectLater(
          session().ensureFresh(force: true),
          throwsA(isA<SessionLostFailure>()),
        );
        final sent = core.requests.length;
        final states = <AuthState>[];
        session().states.listen(states.add);

        await expectLater(
          session().accessToken(),
          throwsA(
            const ApiFailure.sessionLost(
              reason: SessionLostReason.userDisabled,
            ),
          ),
        );
        expect(
          await session().invalidate(SessionLostReason.sessionRevoked),
          isFalse,
        );

        expect(core.requests, hasLength(sent));
        await pumpEventQueue();
        expect(states, isEmpty);
        expect(
          session().state,
          const AuthState.sessionLost(SessionLostReason.userDisabled),
        );
      },
    );

    test('a 200 without a rotated cookie is a protocol failure', () async {
      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.json(refreshBody('access-2')),
      );

      await expectLater(
        session().ensureFresh(force: true),
        throwsA(
          const ApiFailure.sessionLost(reason: SessionLostReason.protocol),
        ),
      );
      expect(vault.cookie, isNull);
    });

    test('not sent: keeps the cookie and retries directly next time', () async {
      core.on('POST', '/auth/refresh', (request) => throw refused(request));

      await expectLater(
        session().ensureFresh(force: true),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(vault.cookie!.value, testCookieValue1);
      expect(session().isRefreshAmbiguous, isFalse);

      serveRotatingRefresh();
      expect(await session().ensureFresh(force: true), 'access-2');
      expect(core.requestsTo('GET', '/health/live'), isEmpty);
    });

    test(
      'ambiguous: needs a healthy appliance before sending the cookie again',
      () async {
        core.on(
          'POST',
          '/auth/refresh',
          (request) => throw receiveTimeout(request),
        );

        await expectLater(
          session().ensureFresh(force: true),
          throwsA(isA<TimeoutFailure>()),
        );
        expect(session().isRefreshAmbiguous, isTrue);
        expect(vault.cookie!.value, testCookieValue1);
        expect(session().state, isA<AuthAuthenticated>());

        core.on('GET', '/health/live', (request) => throw refused(request));
        await expectLater(
          session().ensureFresh(force: true),
          throwsA(isA<UnreachableFailure>()),
        );
        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));

        core.on(
          'GET',
          '/health/live',
          (_) => FakeResponse.json({'status': 'ok'}),
        );
        serveRotatingRefresh();
        expect(await session().ensureFresh(force: true), 'access-2');
        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(2));
        expect(session().isRefreshAmbiguous, isFalse);
      },
    );

    test('5xx and HTML answers are ambiguous, never a session loss', () async {
      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.html('<html>gateway</html>', status: 502),
      );
      await expectLater(
        session().ensureFresh(force: true),
        throwsA(isA<ServerFailure>()),
      );
      expect(session().isRefreshAmbiguous, isTrue);

      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.html('<html>portal</html>'),
      );
      await expectLater(
        session().ensureFresh(force: true),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
      expect(session().isRefreshAmbiguous, isTrue);
      expect(vault.cookie!.value, testCookieValue1);
      expect(session().state, isA<AuthAuthenticated>());
    });

    test(
      'a vault write failure keeps the session and removes the stale cookie',
      () async {
        serveRotatingRefresh();
        vault.writeError = Exception('keystore');

        expect(await session().ensureFresh(force: true), 'access-2');
        // Memory still holds the rotated cookie for the next refresh.
        expect(await session().ensureFresh(force: true), 'access-3');
        expect(
          core.requestsTo('POST', '/auth/refresh').last.header('cookie'),
          'gi_refresh_token=$testCookieValue2',
        );
      },
    );

    test('a process killed between the refresh response and the vault write '
        'never releases the new token; after a restart the server reports '
        'the stale cookie as reuse (spike S1)', () async {
      final dying = _DyingVault();
      final first = testClient(core, vault: dying, clock: clock);
      addTearDown(first.close);
      await first.login(email: 'a@b.c', password: 'pw');
      serveRotatingRefresh();
      dying.dieOnNextWrite = true;

      var released = false;
      unawaited(
        first.session.ensureFresh(force: true).then((_) => released = true),
      );
      final lost = await dying.dying.future;
      await pumpEventQueue();

      expect(lost.value, testCookieValue2);
      expect(released, isFalse);
      expect(core.events.where((e) => e.contains('access-2')), isEmpty);
      expect(dying.cookie!.value, testCookieValue1);

      // The server rotated, so the cookie left on disk is the previous one.
      core.on(
        'POST',
        '/auth/refresh',
        (request) =>
            request.header('cookie') == 'gi_refresh_token=$testCookieValue1'
            ? FakeResponse.error(401, 'AUTH_REFRESH_TOKEN_REUSED')
            : FakeResponse.error(401, 'AUTH_SESSION_REVOKED'),
      );
      final disk = InMemoryTokenVault(dying.cookie);
      final restarted = testClient(core, vault: disk, clock: clock);
      addTearDown(restarted.close);

      expect(
        await restarted.session.restore(),
        const AuthState.sessionLost(SessionLostReason.refreshTokenReused),
      );
      expect(disk.cookie, isNull);
      expect(
        core.requestsTo('POST', '/auth/refresh').last.header('cookie'),
        'gi_refresh_token=$testCookieValue1',
      );
      expect(core.requestsTo('GET', '/auth/me'), isEmpty);
    });
  });

  group('vault wiped during a refresh', () {
    test('ends the session with the vaultWiped reason', () async {
      await client.close();
      client = testClient(core, vault: _WipedVault(), clock: clock);

      await expectLater(
        session().ensureFresh(),
        throwsA(
          isA<SessionLostFailure>().having(
            (f) => f.reason,
            'reason',
            SessionLostReason.vaultWiped,
          ),
        ),
      );
      expect(
        session().state,
        const AuthState.sessionLost(SessionLostReason.vaultWiped),
      );
      expect(core.requests, isEmpty);
    });
  });

  group('restore', () {
    test('absent cookie means unauthenticated without any request', () async {
      final state = await session().restore();

      expect(state, const AuthState.unauthenticated());
      expect(core.requests, isEmpty);
    });

    test('unavailable vault keeps credentials and the unknown state', () async {
      await vault.write(storedCookie());
      vault.readError = StateError('errSecInteractionNotAllowed');

      await expectLater(
        session().restore(),
        throwsA(isA<VaultUnavailableFailure>()),
      );
      expect(session().state, const AuthState.unknown());
      expect(vault.cookie, isNotNull);
      expect(core.requests, isEmpty);
    });

    test('a throwing vault is treated as unavailable', () async {
      await client.close();
      client = testClient(core, vault: _ThrowingVault(), clock: clock);

      await expectLater(
        session().restore(),
        throwsA(isA<VaultUnavailableFailure>()),
      );
      expect(session().state, const AuthState.unknown());
    });

    test('a cookie the vault wiped as unreadable ends the session with '
        'its own reason and no request', () async {
      await client.close();
      client = testClient(core, vault: _WipedVault(), clock: clock);
      final states = <AuthState>[];
      session().states.listen(states.add);

      final state = await session().restore();

      expect(state, const AuthState.sessionLost(SessionLostReason.vaultWiped));
      expect(core.requests, isEmpty);
      await pumpEventQueue();
      expect(states, [
        const AuthState.sessionLost(SessionLostReason.vaultWiped),
      ]);
    });

    test('recovers on the next restore once the vault reads again', () async {
      await vault.write(storedCookie());
      vault.readError = StateError('errSecInteractionNotAllowed');
      serveRotatingRefresh();

      await expectLater(
        session().restore(),
        throwsA(isA<VaultUnavailableFailure>()),
      );
      vault.readError = null;

      expect(await session().restore(), isA<AuthAuthenticated>());
    });

    test('refreshes and loads the user', () async {
      await vault.write(storedCookie());
      serveRotatingRefresh();

      final state = await session().restore();

      expect(state, isA<AuthAuthenticated>());
      expect(
        core.requestsTo('GET', '/auth/me').single.header('authorization'),
        'Bearer access-2',
      );
      expect(vault.cookie!.value, testCookieValue2);
    });

    test('offline keeps the cookie and the unknown state', () async {
      await vault.write(storedCookie());
      core.on('POST', '/auth/refresh', (request) => throw refused(request));

      await expectLater(
        session().restore(),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(session().state, const AuthState.unknown());
      expect(vault.cookie, isNotNull);
    });

    test('an expired cookie is not sent and ends the session', () async {
      await vault.write(storedCookie(absoluteExpiry: DateTime.utc(2026, 11)));

      final state = await session().restore();

      expect(state, const AuthState.sessionLost(SessionLostReason.expired));
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
      expect(vault.cookie, isNull);
    });

    test('a stored cookie the server rejects ends the session', () async {
      await vault.write(storedCookie());
      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.error(401, 'AUTH_SESSION_REVOKED'),
      );

      final state = await session().restore();

      expect(
        state,
        const AuthState.sessionLost(SessionLostReason.sessionRevoked),
      );
      expect(session().state, state);
      expect(vault.cookie, isNull);
      expect(core.requestsTo('GET', '/auth/me'), isEmpty);
    });

    test('a different appliance never receives the cookie', () async {
      await client.close();
      client = testClient(
        core,
        vault: vault,
        clock: clock,
        expectedInitializedAt: DateTime.utc(2025),
      );
      await vault.write(storedCookie());
      core.on(
        'GET',
        '/setup/status',
        (_) => FakeResponse.json(
          fixtureObject('SetupController_getStatus/initialized.json'),
        ),
      );

      await expectLater(
        session().restore(),
        throwsA(isA<DifferentApplianceFailure>()),
      );
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
      expect(vault.cookie, isNotNull);
    });

    test('the matching appliance is checked once per minute', () async {
      await client.close();
      client = testClient(
        core,
        vault: vault,
        clock: clock,
        expectedInitializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
      );
      await vault.write(storedCookie());
      core.on(
        'GET',
        '/setup/status',
        (_) => FakeResponse.json(
          fixtureObject('SetupController_getStatus/initialized.json'),
        ),
      );
      serveRotatingRefresh();

      await session().restore();
      await session().ensureFresh(force: true);

      expect(core.requestsTo('GET', '/setup/status'), hasLength(1));
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(2));
    });

    test(
      'a reset appliance is reported as reset and never gets the cookie',
      () async {
        await client.close();
        client = testClient(
          core,
          vault: vault,
          clock: clock,
          expectedInitializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
          expectedDeviceName: 'GI Home Dev',
        );
        await vault.write(storedCookie());
        core.on(
          'GET',
          '/setup/status',
          (_) => FakeResponse.json(
            fixtureObject('SetupController_getStatus/uninitialized.json'),
          ),
        );
        serveRotatingRefresh();

        await expectLater(
          session().restore(),
          throwsA(
            isA<ApplianceResetFailure>().having(
              (f) => f.code,
              'code',
              'APPLIANCE_RESET',
            ),
          ),
        );
        expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
        // Kept: the app decides what to do with a reset appliance.
        expect(vault.cookie, isNotNull);
        expect(session().state, const AuthState.unknown());
      },
    );

    test(
      'a renamed appliance is not blocked and reports its new name',
      () async {
        await client.close();
        final renamed = <String>[];
        client = testClient(
          core,
          vault: vault,
          clock: clock,
          expectedInitializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
          expectedDeviceName: 'Old name',
          onApplianceRenamed: renamed.add,
        );
        await vault.write(storedCookie());
        core.on(
          'GET',
          '/setup/status',
          (_) => FakeResponse.json(
            fixtureObject('SetupController_getStatus/initialized.json'),
          ),
        );
        serveRotatingRefresh();
        expect(session().applianceDeviceName, 'Old name');

        final state = await session().restore();
        clock.advance(const Duration(minutes: 2));
        await session().ensureFresh(force: true);

        expect(state, isA<AuthAuthenticated>());
        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(2));
        expect(core.requestsTo('GET', '/setup/status'), hasLength(2));
        // Reported once, not on every later check.
        expect(renamed, ['GI Home Dev']);
        expect(session().applianceDeviceName, 'GI Home Dev');
      },
    );

    test('a missing device name is not a rename', () async {
      await client.close();
      final renamed = <String>[];
      client = testClient(
        core,
        vault: vault,
        clock: clock,
        expectedInitializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
        expectedDeviceName: 'GI Home Dev',
        onApplianceRenamed: renamed.add,
      );
      await vault.write(storedCookie());
      core.on(
        'GET',
        '/setup/status',
        (_) => FakeResponse.json({
          ...fixtureObject('SetupController_getStatus/initialized.json'),
          'deviceName': null,
        }),
      );
      serveRotatingRefresh();

      expect(await session().restore(), isA<AuthAuthenticated>());
      expect(renamed, isEmpty);
      expect(session().applianceDeviceName, 'GI Home Dev');
    });
  });

  group('logout', () {
    setUp(() async {
      serveLogin();
      await client.login(email: 'a@b.c', password: 'pw');
    });

    test('revokes the server session and wipes local data', () async {
      core.on('POST', '/auth/logout', (_) => FakeResponse.empty());

      final result = await client.logout();

      expect(result.serverSessionEnded, isTrue);
      expect(
        core.requestsTo('POST', '/auth/logout').single.header('authorization'),
        'Bearer access-1',
      );
      expect(vault.cookie, isNull);
      expect(session().state, const AuthState.unauthenticated());
    });

    test('refreshes first when the token is about to expire', () async {
      serveRotatingRefresh();
      core.on('POST', '/auth/logout', (_) => FakeResponse.empty());
      clock.advance(const Duration(seconds: 870));

      await client.logout();

      expect(
        core.requestsTo('POST', '/auth/logout').single.header('authorization'),
        'Bearer access-2',
      );
    });

    test('an access token aged during sleep is refreshed once', () async {
      serveRotatingRefresh();
      var logouts = 0;
      core.on('POST', '/auth/logout', (_) {
        logouts++;
        return logouts == 1
            ? FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED')
            : FakeResponse.empty();
      });

      final result = await client.logout();

      expect(result.serverSessionEnded, isTrue);
      expect(
        core
            .requestsTo('POST', '/auth/logout')
            .map((r) => r.header('authorization')),
        ['Bearer access-1', 'Bearer access-2'],
      );
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(vault.cookie, isNull);
    });

    test('other 401 answers are not retried', () async {
      core.on(
        'POST',
        '/auth/logout',
        (_) => FakeResponse.error(401, 'AUTH_UNAUTHORIZED'),
      );

      final result = await client.logout();

      expect(result.serverSessionEnded, isFalse);
      expect(core.requestsTo('POST', '/auth/logout'), hasLength(1));
      expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
    });

    test(
      'a late 401 for the old token does not report a lost session',
      () async {
        core.on('POST', '/auth/logout', (_) => FakeResponse.empty());
        await client.logout();
        final states = <AuthState>[];
        session().states.listen(states.add);

        final ended = await session().invalidate(
          SessionLostReason.sessionRevoked,
          rejectedToken: 'access-1',
        );

        expect(ended, isFalse);
        await pumpEventQueue();
        expect(states, isEmpty);
        expect(session().state, const AuthState.unauthenticated());
      },
    );

    test('always wipes locally, even offline', () async {
      core.on('POST', '/auth/logout', (request) => throw refused(request));
      final states = <AuthState>[];
      session().states.listen(states.add);

      final result = await client.logout();

      expect(result.serverSessionEnded, isFalse);
      expect(vault.cookie, isNull);
      expect(session().state, const AuthState.unauthenticated());
      await pumpEventQueue();
      expect(states, [const AuthState.unauthenticated()]);
    });

    test('without a refreshable session still ends unauthenticated', () async {
      core.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.error(401, 'AUTH_REFRESH_TOKEN_REUSED'),
      );
      clock.advance(const Duration(hours: 1));
      final states = <AuthState>[];
      session().states.listen(states.add);

      final result = await client.logout();

      expect(result.serverSessionEnded, isFalse);
      expect(core.requestsTo('POST', '/auth/logout'), isEmpty);
      await pumpEventQueue();
      expect(states, [const AuthState.unauthenticated()]);
    });
  });

  group('persisted access token (D3)', () {
    final noon = DateTime.utc(2026, 11, 17, 12);
    PersistedAccessToken persisted({
      required DateTime expiresAt,
      String token = 'access-stored',
    }) => PersistedAccessToken(token: token, expiresAt: expiresAt);

    /// A cold start: a new client on [vault] holding a cookie and [token].
    Future<void> coldStart({
      PersistedAccessToken? token,
      TokenVault? using,
      DateTime Function()? now,
      DateTime? expectedInitializedAt,
      HttpLogSink? log,
    }) async {
      await client.close();
      vault = RecordingVault(core.events, storedCookie(), token);
      client = testClient(
        core,
        vault: using ?? vault,
        clock: clock,
        now: now,
        expectedInitializedAt: expectedInitializedAt,
        log: log,
      );
    }

    test('login and every refresh persist the token with its wall-clock '
        'expiry', () async {
      serveLogin();
      serveRotatingRefresh();

      await client.login(email: 'a@b.c', password: 'pw');
      expect(
        vault.accessToken,
        persisted(
          token: 'access-1',
          expiresAt: noon.add(const Duration(minutes: 15)),
        ),
      );

      await session().ensureFresh(force: true);
      expect(vault.accessToken!.token, 'access-2');
      expect(vault.accessToken!.expiresAt.isUtc, isTrue);
      expect(core.events.indexOf('vault.writeAccess'), isNonNegative);
    });

    test(
      'a valid persisted token restores the session without a refresh',
      () async {
        await coldStart(
          token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        );

        final state = await session().restore();

        expect(state, isA<AuthAuthenticated>());
        expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
        expect(
          core.requestsTo('GET', '/auth/me').single.header('authorization'),
          'Bearer access-stored',
        );
        expect(vault.cookie, storedCookie());
      },
    );

    test(
      'the persisted token is used only after the fingerprint matches',
      () async {
        core.on(
          'GET',
          '/setup/status',
          (_) => FakeResponse.json(
            fixtureObject('SetupController_getStatus/initialized.json'),
          ),
        );
        await coldStart(
          token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
          expectedInitializedAt: DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
        );

        expect(await session().restore(), isA<AuthAuthenticated>());

        expect(core.events.take(2), [
          'GET /api/v1/setup/status',
          'GET /api/v1/auth/me Bearer access-stored',
        ]);
        expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
      },
    );

    for (final (name, expiresAt) in [
      ('an expired token', noon.subtract(const Duration(minutes: 1))),
      (
        'a token valid for less than the safety margin',
        noon.add(const Duration(seconds: 20)),
      ),
    ]) {
      test('$name means a refresh on cold start', () async {
        serveRotatingRefresh();
        await coldStart(token: persisted(expiresAt: expiresAt));

        expect(await session().restore(), isA<AuthAuthenticated>());

        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
        expect(
          core.requestsTo('GET', '/auth/me').single.header('authorization'),
          'Bearer access-2',
        );
        expect(vault.accessToken!.token, 'access-2');
      });
    }

    test('a wall clock already past the expiry means a refresh', () async {
      serveRotatingRefresh();
      // Saved for 12:15; the phone's clock now reads 12:20.
      await coldStart(
        token: persisted(expiresAt: noon.add(const Duration(minutes: 15))),
        now: () => noon.add(const Duration(minutes: 20)),
      );

      await session().restore();

      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(core.events, isNot(contains(contains('Bearer access-stored'))));
    });

    test('while running, the restored token expires on both clocks', () async {
      var wall = noon;
      serveRotatingRefresh();
      await coldStart(
        token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        now: () => wall,
      );
      await session().restore();

      // Monotonic: 9.5 of the 10 minutes later the margin is reached.
      clock.advance(const Duration(seconds: 500));
      expect(await session().ensureFresh(), 'access-stored');
      clock.advance(const Duration(seconds: 70));
      expect(await session().ensureFresh(), 'access-2');

      // Wall clock: a sleep that stopped the monotonic clock.
      wall = wall.add(const Duration(hours: 1));
      expect(await session().ensureFresh(), 'access-3');
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(2));
    });

    test('a persisted token the server rejects is refreshed once', () async {
      serveRotatingRefresh();
      core.on(
        'GET',
        '/auth/me',
        (request) => request.header('authorization') == 'Bearer access-stored'
            ? FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_INVALID')
            : FakeResponse.json(
                fixtureObject('AuthController_getMe/owner.json'),
              ),
      );
      await coldStart(
        token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
      );

      expect(await session().restore(), isA<AuthAuthenticated>());

      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(core.requestsTo('GET', '/auth/me'), hasLength(2));
      expect(vault.accessToken!.token, 'access-2');
    });

    test(
      'concurrent 401s on a persisted token share a single refresh',
      () async {
        serveRotatingRefresh(delay: const Duration(milliseconds: 20));
        core.on(
          'GET',
          '/rooms',
          (request) => request.header('authorization') == 'Bearer access-stored'
              ? FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED')
              : FakeResponse.json(
                  fixtureJson('RoomsController_list/seeded.json'),
                ),
        );
        await coldStart(
          token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        );
        await session().restore();

        await Future.wait([for (var i = 0; i < 4; i++) client.rooms()]);

        expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      },
    );

    test(
      'a session ended on the server meanwhile is lost on restore',
      () async {
        core.on(
          'GET',
          '/auth/me',
          (_) => FakeResponse.error(401, 'AUTH_SESSION_REVOKED'),
        );
        await coldStart(
          token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        );

        final state = await session().restore();

        expect(
          state,
          const AuthState.sessionLost(SessionLostReason.sessionRevoked),
        );
        expect(core.requestsTo('POST', '/auth/refresh'), isEmpty);
        expect(vault.cookie, isNull);
        expect(vault.accessToken, isNull);
      },
    );

    test('an unreadable token falls back to a refresh and keeps the '
        'cookie', () async {
      serveRotatingRefresh();
      await coldStart(
        token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
      );
      vault.accessReadError = StateError('errSecInteractionNotAllowed');

      expect(await session().restore(), isA<AuthAuthenticated>());

      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(
        core.requestsTo('POST', '/auth/refresh').single.header('cookie'),
        'gi_refresh_token=$testCookieValue1',
      );
      expect(core.events, isNot(contains('vault.clear')));
      expect(vault.cookie!.value, testCookieValue2);
    });

    test('a vault that throws on the token read is treated the same', () async {
      serveRotatingRefresh();
      final throwing = _ThrowingAccessReadVault(
        storedCookie(),
        persisted(expiresAt: noon.add(const Duration(minutes: 10))),
      );
      await coldStart(using: throwing);

      expect(await session().restore(), isA<AuthAuthenticated>());
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
      expect(throwing.cookie!.value, testCookieValue2);
    });

    group('is removed', () {
      test('on logout', () async {
        core.on('POST', '/auth/logout', (_) => FakeResponse.empty());
        await coldStart(
          token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        );
        await session().restore();

        await client.logout();

        expect(
          core
              .requestsTo('POST', '/auth/logout')
              .single
              .header('authorization'),
          'Bearer access-stored',
        );
        expect(vault.accessToken, isNull);
        expect(vault.cookie, isNull);
      });

      test('when the session is lost', () async {
        serveLogin();
        await client.login(email: 'a@b.c', password: 'pw');
        expect(vault.accessToken, isNotNull);
        core.on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.error(401, 'AUTH_REFRESH_TOKEN_REUSED'),
        );

        await expectLater(
          session().ensureFresh(force: true),
          throwsA(isA<SessionLostFailure>()),
        );

        expect(vault.accessToken, isNull);
        expect(vault.cookie, isNull);
      });

      for (final (name, setup, failure) in [
        (
          'for a different appliance',
          'SetupController_getStatus/initialized.json',
          isA<DifferentApplianceFailure>(),
        ),
        (
          'for a reset appliance',
          'SetupController_getStatus/uninitialized.json',
          isA<ApplianceResetFailure>(),
        ),
      ]) {
        test('$name, which never receives it', () async {
          core.on(
            'GET',
            '/setup/status',
            (_) => FakeResponse.json(fixtureObject(setup)),
          );
          await coldStart(
            token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
            expectedInitializedAt: DateTime.utc(2025),
          );

          await expectLater(session().restore(), throwsA(failure));

          expect(core.requestsTo('GET', '/auth/me'), isEmpty);
          expect(core.events, isNot(contains(contains('access-stored'))));
          expect(vault.accessToken, isNull);
          // The cookie stays for the app to decide (plan §9.3).
          expect(vault.cookie, isNotNull);
        });
      }
    });

    test('is never logged', () async {
      final lines = <String>[];
      serveRotatingRefresh();
      await coldStart(
        token: persisted(expiresAt: noon.add(const Duration(minutes: 10))),
        log: lines.add,
      );
      await session().restore();
      await session().ensureFresh(force: true);

      expect(lines, isNotEmpty);
      for (final line in lines) {
        expect(line, isNot(contains('access-')));
      }
      expect(
        vault.accessToken.toString(),
        isNot(contains(vault.accessToken!.token)),
      );
    });

    test('round-trips through JSON and rejects malformed records', () {
      final token = persisted(
        expiresAt: DateTime.parse('2026-11-17T13:15:00+01:00'),
      );

      expect(token.expiresAt, DateTime.utc(2026, 11, 17, 12, 15));
      expect(PersistedAccessToken.tryFromJson(token.toJson()), token);
      for (final bad in <Object?>[
        null,
        'x',
        {'token': '', 'expiresAt': '2026-11-17T12:15:00Z'},
        {'token': 'a', 'expiresAt': 'soon'},
        {'token': 'a'},
      ]) {
        expect(PersistedAccessToken.tryFromJson(bad), isNull, reason: '$bad');
      }
    });
  });
}

final class _ThrowingVault implements TokenVault {
  @override
  Future<VaultResult> read() => throw StateError('keystore corrupted');

  @override
  Future<void> write(RefreshCookie cookie) =>
      throw StateError('keystore corrupted');

  @override
  Future<void> clear() => throw StateError('keystore corrupted');

  @override
  Future<PersistedAccessToken?> readAccessToken() =>
      throw StateError('keystore corrupted');

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) =>
      throw StateError('keystore corrupted');

  @override
  Future<void> clearAccessToken() => throw StateError('keystore corrupted');
}

/// A vault whose unusable entry was just removed (plan §7.1).
final class _WipedVault implements TokenVault {
  @override
  Future<VaultResult> read() async => const VaultAbsent(wiped: true);

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

/// A working cookie store whose access token entry breaks the contract and
/// throws on read.
final class _ThrowingAccessReadVault extends InMemoryTokenVault {
  new([super._cookie, super._accessToken]);

  @override
  Future<PersistedAccessToken?> readAccessToken() =>
      throw StateError('keystore corrupted');
}

/// A vault whose next cookie write never returns, like a process killed
/// while writing; [dying] completes with the cookie being written.
final class _DyingVault extends InMemoryTokenVault {
  bool dieOnNextWrite = false;
  final dying = Completer<RefreshCookie>();

  @override
  Future<void> write(RefreshCookie cookie) {
    if (!dieOnNextWrite) return super.write(cookie);
    dying.complete(cookie);
    return Completer<void>().future;
  }
}
