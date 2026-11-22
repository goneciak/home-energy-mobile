/// Live contract of the M3 account endpoints (plan §20 M3 item 5, §13.2):
/// the session list, revoking a session (another one, this one, someone
/// else's), logout-all, regenerating the recovery code, the password reset
/// with a recovery code and the profile update. Strict decoding throughout.
///
/// Everything destructive runs on the seeded USER: its sessions are revoked
/// several times and its password is changed (and always restored, also when
/// a test fails). The profile update runs on the seeded ADMIN and restores
/// its first name and locale.
///
/// Throttles: login is limited to 5 per minute (this file logs in seven
/// times; `respectingLoginLimit` waits once when needed) and
/// `POST /auth/recovery/reset` to 5 per 15 minutes per IP. This file sends
/// exactly two resets per run; a run that hits 429 anyway skips the reset
/// test instead of failing.
///
/// Runs only on a Core seeded for contract use (the fake device is
/// provisioned), never on a dev Core.
@Tags(['contract'])
library;

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.authSessionsList,
  GiEndpoints.authSessionRevoke,
  GiEndpoints.authLogoutAll,
  GiEndpoints.authRecoveryRegenerate,
  GiEndpoints.authRecoveryReset,
  GiEndpoints.usersMeProfileUpdate,
];

/// Recovery codes: 32 uppercase hex digits in 8 dashed groups of 4.
final _recoveryCode = RegExp(r'^[0-9A-F]{4}(-[0-9A-F]{4}){7}$');

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('account endpoints', skip: skip, () {
    late Dio raw;
    late ({String email, String password}) user;
    String? notSeeded;
    final clients = <GiCoreClient>[];

    GiCoreClient newClient() {
      final client = strictClient(
        address: probe!.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      clients.add(client);
      return client;
    }

    Future<GiCoreClient> signIn(
      ({String email, String password}) account, {
      String? password,
    }) async {
      final client = newClient();
      await respectingLoginLimit(
        () => client.login(
          email: account.email,
          password: password ?? account.password,
        ),
      );
      return client;
    }

    Future<Response<Object?>> withToken(
      String token,
      String method,
      String path, {
      Object? data,
    }) => raw.request<Object?>(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {'authorization': 'Bearer $token'},
      ),
    );

    void expectError(Response<Object?> response, int status, String code) {
      expect(response.statusCode, status, reason: '${response.data}');
      expect(
        ApiErrorEnvelope.tryParse(response.data)?.code,
        code,
        reason: '${response.data}',
      );
    }

    Future<void> expectRevoked(String token) async => expectError(
      await withToken(token, 'GET', '/auth/me'),
      401,
      'AUTH_SESSION_REVOKED',
    );

    Future<String> currentSessionId(GiCoreClient client) async =>
        (await client.authSessions()).singleWhere((s) => s.current).id;

    setUpAll(() async {
      raw = rawDio(probe!.address);
      user = ContractEnv.seededAccount('USER');
      final admin = newClient();
      final account = ContractEnv.seededAccount('ADMIN');
      try {
        await respectingLoginLimit(
          () => admin.login(email: account.email, password: account.password),
        );
      } on UnauthorizedFailure {
        notSeeded = 'no seeded ADMIN at $base: not a contract Core';
        return;
      }
      if (!isContractSeeded((await admin.devices()).items)) {
        notSeeded = 'no fake device at $base: not a contract Core';
        if (ContractEnv.fakeEsphomeUrl != null) {
          fail('$notSeeded, but FAKE_ESPHOME_URL is set');
        }
      }
    });

    tearDownAll(() async {
      for (final client in clients) {
        await client.close();
      }
      raw.close();
    });

    void seededTest(String description, Future<void> Function() body) =>
        test(description, () async {
          if (notSeeded case final reason?) {
            markTestSkipped(reason);
            return;
          }
          await body();
        }, timeout: const Timeout(Duration(minutes: 4)));

    seededTest('sessions: list marks this phone, revoking another one ends it '
        'at once, idempotently; unknown, malformed and foreign ids '
        'fail', () async {
      final phone = await signIn(user);
      final other = await signIn(user);
      final otherId = await currentSessionId(other);
      final otherToken = await other.session.accessToken();

      final sessions = await phone.authSessions();
      expect(sessions.where((s) => s.current), hasLength(1));
      final mine = sessions.singleWhere((s) => s.current);
      expect(mine.id, isNot(otherId));
      final listed = sessions.singleWhere((s) => s.id == otherId);
      expect(listed.current, isFalse);
      expect(listed.expiresAt.isAfter(listed.createdAt), isTrue);
      // Newest first.
      for (var i = 1; i < sessions.length; i++) {
        expect(
          sessions[i - 1].createdAt.isBefore(sessions[i].createdAt),
          isFalse,
        );
      }

      await phone.revokeSession(otherId);
      await expectRevoked(otherToken);
      expect(
        (await phone.authSessions()).map((s) => s.id),
        isNot(contains(otherId)),
      );
      // Idempotent: revoking a revoked session is still 204.
      await phone.revokeSession(otherId);

      final token = await phone.session.accessToken();
      expectError(
        await withToken(
          token,
          'DELETE',
          '/auth/sessions/00000000-0000-4000-8000-000000000000',
        ),
        404,
        'AUTH_SESSION_NOT_FOUND',
      );
      expectError(
        await withToken(token, 'DELETE', '/auth/sessions/not-a-uuid'),
        400,
        'HTTP_400',
      );

      // Someone else's session: 403, and it stays valid.
      final admin = clients.first;
      expectError(
        await withToken(
          await admin.session.accessToken(),
          'DELETE',
          '/auth/sessions/${mine.id}',
        ),
        403,
        'AUTH_SESSION_FORBIDDEN',
      );
      expect((await phone.me()).email, user.email);

      // Revoking this phone's own session ends it locally and on the server.
      await phone.revokeSession(mine.id, current: true);
      expect(phone.session.state, isNot(isA<AuthAuthenticated>()));
      await expectRevoked(token);
    });

    seededTest('logout-all: 204, every session of the user is revoked at '
        'once, this one included', () async {
      final phone = await signIn(user);
      final tablet = await signIn(user);
      final phoneToken = await phone.session.accessToken();
      final tabletToken = await tablet.session.accessToken();

      await phone.logoutAll();

      expect(phone.session.state, isNot(isA<AuthAuthenticated>()));
      await expectRevoked(phoneToken);
      await expectRevoked(tabletToken);
    });

    seededTest('recovery: regenerate gives a fresh dashed code; a wrong code '
        'is AUTH_RECOVERY_INVALID; the right one resets the password and '
        'revokes every session', () async {
      final phone = await signIn(user);
      final first = await phone.regenerateRecoveryCode();
      expect(first.recoveryCode, matches(_recoveryCode));
      final code = (await phone.regenerateRecoveryCode()).recoveryCode;
      expect(code, matches(_recoveryCode));
      expect(code, isNot(first.recoveryCode));
      // Regenerating does not touch sessions.
      final token = await phone.session.accessToken();
      expect((await phone.me()).email, user.email);

      final temporary = '${user.password}-Rc1';
      var changed = false;
      addTearDown(() async {
        if (!changed) return;
        final again = await signIn(user, password: temporary);
        await again.changePassword(
          ChangePasswordRequest(
            currentPassword: temporary,
            newPassword: user.password,
          ),
        );
      });

      try {
        // The superseded code no longer works (reset 1 of 2).
        final wrong = await raw.post<Object?>(
          '/auth/recovery/reset',
          data: RecoveryResetRequest(
            email: user.email,
            recoveryCode: first.recoveryCode,
            newPassword: temporary,
          ).toJson(),
        );
        if (wrong.statusCode == 429) {
          markTestSkipped('recovery reset throttled (5 per 15 minutes)');
          return;
        }
        expectError(wrong, 400, 'AUTH_RECOVERY_INVALID');

        // Reset 2 of 2, from a signed-out client. The client trims the
        // e-mail and canonicalises the code; the server lowercases the
        // e-mail.
        await newClient().resetPasswordWithRecoveryCode(
          RecoveryResetRequest(
            email: ' ${user.email.toUpperCase()} ',
            recoveryCode: code.toLowerCase(),
            newPassword: temporary,
          ),
        );
        changed = true;
      } on RateLimitedFailure {
        markTestSkipped('recovery reset throttled (5 per 15 minutes)');
        return;
      }

      await expectRevoked(token);
      final after = await signIn(user, password: temporary);
      expect((await after.me()).email, user.email);
      await after.changePassword(
        ChangePasswordRequest(
          currentPassword: temporary,
          newPassword: user.password,
        ),
      );
      changed = false;
      expect((await after.me()).mustChangePassword, isFalse);
    });

    seededTest('PATCH profile: changes the locale and the first name, the '
        'answer and GET agree; an invalid body is VALIDATION_FAILED', () async {
      final admin = clients.first;
      final before = await admin.profile();
      addTearDown(
        () => admin.updateProfile(
          ProfileUpdate(firstName: before.firstName, locale: before.locale),
        ),
      );
      final locale = before.locale == 'en-US' ? 'pl-PL' : 'en-US';

      final updated = await admin.updateProfile(
        ProfileUpdate(firstName: '  Kontrakt  ', locale: locale),
      );

      expect(updated.locale, locale);
      expect(updated.firstName, 'Kontrakt');
      expect(updated.lastName, before.lastName);
      expect(await admin.profile(), updated);
      expect((await admin.me()).firstName, 'Kontrakt');

      // Nothing set: 200 with the profile unchanged.
      final token = await admin.session.accessToken();
      final empty = await withToken(
        token,
        'PATCH',
        '/users/me/profile',
        data: <String, Object>{},
      );
      expect(empty.statusCode, 200, reason: '${empty.data}');

      for (final body in <Map<String, Object?>>[
        {'firstName': ''},
        {'locale': 'not a locale'},
        {'email': 'other@gihome.test'},
        {'role': 'OWNER'},
      ]) {
        expectError(
          await withToken(token, 'PATCH', '/users/me/profile', data: body),
          400,
          'VALIDATION_FAILED',
        );
      }
      expect((await admin.profile()).role, before.role);
    });
  });
}
