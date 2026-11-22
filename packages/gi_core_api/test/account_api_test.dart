import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

const _sessionId = '0b8f9a2e-6c4d-4e1f-9a3b-7c2d1e0f4a5b';
const _code = '3F9A-0C1D-77B2-E4A8-19CD-5B60-A2F3-8E4D';
const _newPassword = 'Nowe-Haslo-2026';

FakeResponse _fixtureJson(String path, {int status = 200}) =>
    FakeResponse.json(fixtureJson(path), status: status);

void main() {
  late FakeCore core;
  late GiCoreClient client;
  late List<String> log;

  setUp(() async {
    core = FakeCore();
    log = [];
    client = testClient(core, decodeMode: DecodeMode.strict, log: log.add);
    core
      ..on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.json(
          loginBody(),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue1)],
          },
        ),
      )
      ..on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.json(
          refreshBody('access-2'),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue2)],
          },
        ),
      );
    await client.login(email: 'a@b.c', password: 'pw');
  });

  tearDown(() => client.close());

  group('catalog', () {
    test('account endpoints: roles, retries and milestone', () {
      for (final endpoint in [
        GiEndpoints.authSessionsList,
        GiEndpoints.authSessionRevoke,
        GiEndpoints.authLogoutAll,
        GiEndpoints.authRecoveryRegenerate,
        GiEndpoints.usersMeProfileUpdate,
      ]) {
        for (final role in UserRole.values.where(
          (r) => r != UserRole.unknown,
        )) {
          expect(endpoint.allows(role), isTrue, reason: endpoint.id);
        }
        expect(endpoint.requiresAuth, isTrue);
        expect(endpoint.milestone, Milestone.m3);
      }
      expect(GiEndpoints.authRecoveryReset.requiresAuth, isFalse);
      expect(GiEndpoints.authSessionsList.isIdempotent, isTrue);
      for (final write in [
        GiEndpoints.authSessionRevoke,
        GiEndpoints.authLogoutAll,
        GiEndpoints.authRecoveryRegenerate,
        GiEndpoints.authRecoveryReset,
        GiEndpoints.usersMeProfileUpdate,
      ]) {
        expect(write.maxRetries, 0, reason: write.id);
      }
    });
  });

  group('sessions', () {
    test('list decodes the recorded sessions', () async {
      core.on(
        'GET',
        '/auth/sessions',
        (_) => _fixtureJson('AuthController_listSessions/owner.json'),
      );

      final sessions = await client.authSessions();

      expect(sessions, hasLength(1));
      expect(sessions.single.current, isTrue);
      expect(sessions.single.userAgent, startsWith('GIHome-Mobile-Seed'));
      expect(sessions.single.expiresAt.isUtc, isTrue);
    });

    test('nullable fields decode as null', () {
      final session = AuthSessionInfo.fromJson({
        'id': _sessionId,
        'createdAt': '2026-11-20T10:00:00.000Z',
        'lastUsedAt': null,
        'expiresAt': '2026-12-20T10:00:00.000Z',
        'userAgent': null,
        'ipAddress': null,
        'current': false,
      });

      expect(session.lastUsedAt, isNull);
      expect(session.userAgent, isNull);
      expect(session.current, isFalse);
    });

    test('revoking another session keeps this one', () async {
      core.on(
        'DELETE',
        '/auth/sessions/$_sessionId',
        (_) => FakeResponse.empty(),
      );

      await client.revokeSession(_sessionId);

      expect(client.session.state, isA<AuthAuthenticated>());
    });

    test('revoking the current session ends it locally', () async {
      core.on(
        'DELETE',
        '/auth/sessions/$_sessionId',
        (_) => FakeResponse.empty(),
      );

      await client.revokeSession(_sessionId, current: true);

      expect(client.session.state, const AuthState.unauthenticated());
    });

    test('revoke maps 404 and 403 to typed failures', () async {
      core
        ..on(
          'DELETE',
          '/auth/sessions/$_sessionId',
          (_) => _fixtureJson(
            'AuthController_revokeSession/error_not_found_handwritten.json',
            status: 404,
          ),
        )
        ..on(
          'DELETE',
          '/auth/sessions/other',
          (_) => _fixtureJson(
            'AuthController_revokeSession/error_forbidden_handwritten.json',
            status: 403,
          ),
        );

      await expectLater(
        client.revokeSession(_sessionId),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.code,
            'code',
            GiErrorCodes.authSessionNotFound,
          ),
        ),
      );
      await expectLater(
        client.revokeSession('other'),
        throwsA(
          isA<ForbiddenFailure>().having(
            (f) => f.code,
            'code',
            GiErrorCodes.authSessionForbidden,
          ),
        ),
      );
      expect(
        core.requestsTo('DELETE', '/auth/sessions/$_sessionId'),
        hasLength(1),
      );
      expect(client.session.state, isA<AuthAuthenticated>());
    });

    test('logout-all ends the session locally', () async {
      core.on('POST', '/auth/logout-all', (_) => FakeResponse.empty());

      await client.logoutAll();

      expect(client.session.state, const AuthState.unauthenticated());
    });

    test('a logout-all failure leaves the session alone', () async {
      core.on(
        'POST',
        '/auth/logout-all',
        (_) => FakeResponse.error(500, 'INTERNAL_SERVER_ERROR'),
      );

      await expectLater(client.logoutAll(), throwsA(isA<ServerFailure>()));
      expect(core.requestsTo('POST', '/auth/logout-all'), hasLength(1));
      expect(client.session.state, isA<AuthAuthenticated>());
    });

    test('a revoked session on logout-all is reported as lost', () async {
      core.on(
        'POST',
        '/auth/logout-all',
        (_) => _fixtureJson(
          'AuthController_logoutAll/error_session_revoked_handwritten.json',
          status: 401,
        ),
      );

      await expectLater(
        client.logoutAll(),
        throwsA(
          isA<SessionLostFailure>().having(
            (f) => f.reason,
            'reason',
            SessionLostReason.sessionRevoked,
          ),
        ),
      );
      expect(client.session.state, isNot(isA<AuthAuthenticated>()));
    });
  });

  group('recovery', () {
    test('regenerate decodes the code and hides it in toString', () async {
      core.on(
        'POST',
        '/auth/recovery/regenerate',
        (_) => _fixtureJson(
          'AuthController_regenerateRecoveryCode/ok_handwritten.json',
        ),
      );

      final result = await client.regenerateRecoveryCode();

      expect(result.recoveryCode, _code);
      expect(RecoveryCodeFormat.check(result.recoveryCode), isNull);
      expect(result.toString(), isNot(contains('3F9A')));
    });

    test('reset sends exactly the DTO keys, without a token', () async {
      core.on('POST', '/auth/recovery/reset', (_) => FakeResponse.empty());

      await client.resetPasswordWithRecoveryCode(
        const RecoveryResetRequest(
          email: ' owner@gihome.test ',
          recoveryCode: '3f9a 0c1d 77b2 e4a8 19cd 5b60 a2f3 8e4d',
          newPassword: _newPassword,
        ),
      );

      final request = core.requestsTo('POST', '/auth/recovery/reset').single;
      expect(request.json, {
        'email': 'owner@gihome.test',
        'recoveryCode': _code,
        'newPassword': _newPassword,
      });
      expect(request.header('authorization'), isNull);
    });

    test('reset maps AUTH_RECOVERY_INVALID and the throttle', () async {
      var calls = 0;
      core.on(
        'POST',
        '/auth/recovery/reset',
        (_) => calls++ == 0
            ? _fixtureJson(
                'AuthController_recoveryReset/error_invalid_handwritten.json',
                status: 400,
              )
            : _fixtureJson(
                'AuthController_recoveryReset/'
                'error_rate_limited_handwritten.json',
                status: 429,
              ),
      );
      const request = RecoveryResetRequest(
        email: 'owner@gihome.test',
        recoveryCode: _code,
        newPassword: _newPassword,
      );

      await expectLater(
        client.resetPasswordWithRecoveryCode(request),
        throwsA(
          isA<DomainFailure>()
              .having((f) => f.statusCode, 'statusCode', 400)
              .having((f) => f.code, 'code', GiErrorCodes.authRecoveryInvalid),
        ),
      );
      await expectLater(
        client.resetPasswordWithRecoveryCode(request),
        throwsA(
          isA<RateLimitedFailure>().having(
            (f) => f.code,
            'code',
            GiErrorCodes.rateLimited,
          ),
        ),
      );
      expect(calls, 2);
    });

    test('an invalid reset request is rejected before sending', () {
      expect(
        () => client.resetPasswordWithRecoveryCode(
          const RecoveryResetRequest(
            email: 'not-an-email',
            recoveryCode: '',
            newPassword: 'weak',
          ),
        ),
        throwsArgumentError,
      );
      expect(core.requestsTo('POST', '/auth/recovery/reset'), isEmpty);
      expect(
        const RecoveryResetRequest(
          email: 'not-an-email',
          recoveryCode: '',
          newPassword: 'weak',
        ).validate(),
        RecoveryResetProblem.values.toSet(),
      );
    });

    test('request toString hides every field', () {
      const request = RecoveryResetRequest(
        email: 'owner@gihome.test',
        recoveryCode: _code,
        newPassword: _newPassword,
      );

      expect(request.toString(), isNot(contains('owner')));
      expect(request.toString(), isNot(contains('3F9A')));
      expect(request.toString(), isNot(contains(_newPassword)));
    });
  });

  group('RecoveryCodeFormat', () {
    test('normalize mirrors the server: trim, uppercase, no whitespace', () {
      expect(RecoveryCodeFormat.normalize('  3f9a-0c1d \t'), '3F9A-0C1D');
      expect(RecoveryCodeFormat.normalize('3f9a 0c1d'), '3F9A0C1D');
    });

    test('canonical restores dashes from spaces, none or lowercase', () {
      for (final input in [
        _code,
        _code.toLowerCase(),
        ' ${_code.replaceAll('-', ' ')} ',
        _code.replaceAll('-', ''),
        '3F9A-0C1D 77B2-E4A8 19CD-5B60 A2F3-8E4D',
      ]) {
        expect(RecoveryCodeFormat.canonical(input), _code, reason: input);
      }
      expect(RecoveryCodeFormat.canonical('3F9A-0C1D'), isNull);
      expect(RecoveryCodeFormat.canonical('${_code}0'), isNull);
      expect(RecoveryCodeFormat.canonical(_code.replaceAll('F', 'G')), isNull);
    });

    test('check flags what the server would reject', () {
      expect(RecoveryCodeFormat.check(_code), isNull);
      expect(RecoveryCodeFormat.check(' ${_code.toLowerCase()} '), isNull);
      expect(RecoveryCodeFormat.check('   '), RecoveryCodeProblem.empty);
      expect(
        RecoveryCodeFormat.check(_code.replaceAll('-', '')),
        RecoveryCodeProblem.missingDashes,
      );
      expect(
        RecoveryCodeFormat.check(_code.replaceAll('-', ' ')),
        RecoveryCodeProblem.missingDashes,
      );
      expect(
        RecoveryCodeFormat.check('ABCD-EFGH'),
        RecoveryCodeProblem.malformed,
      );
      expect(RecoveryCodeFormat.check('A' * 65), RecoveryCodeProblem.tooLong);
    });
  });

  group('PasswordPolicy', () {
    test('reports the first broken rule', () {
      expect(PasswordPolicy.check(''), PasswordProblem.empty);
      expect(PasswordPolicy.check('Ab1'), PasswordProblem.tooShort);
      expect(PasswordPolicy.check('Ab1${'x' * 254}'), PasswordProblem.tooLong);
      expect(PasswordPolicy.check('ABCDEFG1'), PasswordProblem.noLowercase);
      expect(PasswordPolicy.check('abcdefg1'), PasswordProblem.noUppercase);
      expect(PasswordPolicy.check('Abcdefgh'), PasswordProblem.noDigit);
      expect(PasswordPolicy.check('Abcdefg1'), isNull);
      expect(PasswordPolicy.check('Ab1${'x' * 253}'), isNull);
    });
  });

  group('profile update', () {
    test('sends only the set fields, trimmed, and updates the user', () async {
      core.on(
        'PATCH',
        '/users/me/profile',
        (_) =>
            _fixtureJson('UsersController_updateProfile/ok_handwritten.json'),
      );
      final before = (client.session.state as AuthAuthenticated).user;

      final profile = await client.updateProfile(
        const ProfileUpdate(firstName: ' Anna ', lastName: '', locale: 'en-US'),
      );

      expect(core.requestsTo('PATCH', '/users/me/profile').single.json, {
        'firstName': 'Anna',
        'lastName': '',
        'locale': 'en-US',
      });
      expect(profile.locale, 'en-US');
      expect(profile.lastName, isNull);
      final after = (client.session.state as AuthAuthenticated).user;
      expect(after.id, before.id);
      expect(after.firstName, 'Anna');
      expect(after.lastName, isNull);
      expect(after.role, before.role);
    });

    test('only the locale goes when only it is set', () {
      expect(const ProfileUpdate(locale: 'pl-PL').toJson(), {
        'locale': 'pl-PL',
      });
      expect(const ProfileUpdate().isEmpty, isTrue);
    });

    test('rejects DTO violations before sending', () {
      expect(
        ProfileUpdate(
          firstName: ' ',
          lastName: 'x' * 101,
          locale: 'polski',
        ).validate(),
        ProfileUpdateProblem.values.toSet(),
      );
      expect(const ProfileUpdate(locale: 'en').validate(), isEmpty);
      expect(
        () => client.updateProfile(const ProfileUpdate(firstName: '')),
        throwsArgumentError,
      );
      expect(core.requestsTo('PATCH', '/users/me/profile'), isEmpty);
    });
  });

  test('recovery codes and new passwords never reach the HTTP log', () async {
    core
      ..on(
        'POST',
        '/auth/recovery/regenerate',
        (_) => _fixtureJson(
          'AuthController_regenerateRecoveryCode/ok_handwritten.json',
        ),
      )
      ..on(
        'POST',
        '/auth/recovery/reset',
        (_) => _fixtureJson(
          'AuthController_recoveryReset/error_invalid_handwritten.json',
          status: 400,
        ),
      )
      ..on(
        'POST',
        '/users/me/change-password',
        (_) => _fixtureJson('UsersController_changePassword/ok.json'),
      );

    final code = (await client.regenerateRecoveryCode()).recoveryCode;
    await expectLater(
      client.resetPasswordWithRecoveryCode(
        RecoveryResetRequest(
          email: 'owner@gihome.test',
          recoveryCode: code,
          newPassword: _newPassword,
        ),
      ),
      throwsA(isA<DomainFailure>()),
    );
    await client.changePassword(
      const ChangePasswordRequest(
        currentPassword: 'Stare-Haslo-1',
        newPassword: _newPassword,
      ),
    );

    expect(log, isNotEmpty);
    final text = log.join('\n');
    for (final secret in [
      code,
      code.replaceAll('-', ''),
      _newPassword,
      'Stare-Haslo-1',
    ]) {
      expect(text, isNot(contains(secret)));
    }
  });
}
