/// Spike S1 (plan M0, §7.4): the refresh cookie under load and in the
/// failure modes the session manager is built for, against the Core at
/// `GI_CORE_URL` with strict decoding. Results: `docs/spikes/s1-auth-cookie.md`.
///
/// * 50 forced refreshes in sequence: every one succeeds and rotates.
/// * The same cookie sent twice: `AUTH_REFRESH_TOKEN_REUSED`, and the whole
///   session is revoked.
/// * A cookie older than the previous one: `AUTH_REFRESH_TOKEN_INVALID`.
/// * The process dies after the refresh response and before the vault write
///   (simulated with a vault write that never returns): after a restart the
///   stale cookie is reported as reuse and one login is needed.
///
/// Each group logs in once as the seeded USER (two logins in this file): the
/// owner's sessions are revoked by the password change in
/// `auth_flow_contract_test.dart`, which may run at the same time. Only the
/// sessions created here are revoked, so it is safe on a dev Core too.
/// The measured values are printed, prefixed with `S1`.
@Tags(['contract'])
library;

// The spike's measurements are part of its output.
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.setupStatus,
  GiEndpoints.authLogin,
  GiEndpoints.authRefresh,
  GiEndpoints.authMe,
];

const _rotations = 50;

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('S1 refresh cookie', skip: skip, () {
    late ApplianceAddress address;
    late Dio raw;

    GiCoreClient newClient(TokenVault vault) => strictClient(
      address: address,
      vault: vault,
      expectedInitializedAt: probe!.setup.initializedAt,
    );

    final account = ContractEnv.seededAccount('USER');

    Future<void> login(GiCoreClient client) => respectingLoginLimit(
      () => client.login(email: account.email, password: account.password),
    );

    Future<Response<Object?>> rawRefresh(RefreshCookie cookie) =>
        raw.post<Object?>(
          '/auth/refresh',
          options: Options(headers: {'cookie': cookie.cookieHeader}),
        );

    Future<Response<Object?>> rawMe(String token) => raw.get<Object?>(
      '/auth/me',
      options: Options(headers: {'authorization': 'Bearer $token'}),
    );

    setUpAll(() {
      address = probe!.address;
      raw = rawDio(address);
    });

    tearDownAll(() => raw.close());

    group('rotation and reuse (login 1 of 2)', () {
      final vault = InMemoryTokenVault();
      late GiCoreClient client;

      setUpAll(() async {
        client = newClient(vault);
        await login(client);
      });

      tearDownAll(() => client.close());

      test(
        '$_rotations refreshes in sequence all succeed and rotate',
        () async {
          final first = vault.cookie!;
          final values = <String>{first.value};
          final tokens = <String>{await client.session.accessToken()};
          final millis = <int>[];

          for (var i = 1; i <= _rotations; i++) {
            final watch = Stopwatch()..start();
            tokens.add(await client.session.ensureFresh(force: true));
            millis.add(watch.elapsedMilliseconds);
            final cookie = vault.cookie!;
            expect(cookie.generation, first.generation + i);
            expect(cookie.path, '/api/v1/auth/refresh');
            expect(cookie.value, matches(RefreshCookieCodec.valuePattern));
            // The 30-day limit counts from login, not from each refresh.
            expect(
              cookie.absoluteExpiry!
                  .difference(first.absoluteExpiry!)
                  .inSeconds
                  .abs(),
              lessThanOrEqualTo(_rotations),
            );
            values.add(cookie.value);
          }

          expect(values, hasLength(_rotations + 1), reason: 'every value new');
          expect((await client.me()).email, account.email);
          millis.sort();
          print(
            'S1 rotations=$_rotations distinctCookies=${values.length} '
            'distinctTokens=${tokens.length} refreshMs min=${millis.first} '
            'median=${millis[millis.length ~/ 2]} max=${millis.last}',
          );
        },
      );

      test('a cookie older than the previous one is INVALID and the session '
          'survives', () async {
        // Generation 0, the login cookie, is $_rotations rotations old.
        final ancient = vault.writes.first;
        final response = await rawRefresh(ancient);

        expect(response.statusCode, 401);
        expect(
          ApiErrorEnvelope.tryParse(response.data)?.code,
          'AUTH_REFRESH_TOKEN_INVALID',
        );
        print('S1 ancient cookie -> ${response.statusCode} ${response.data}');
        // Only the previous cookie counts as reuse; this one is not revoked.
        await client.session.ensureFresh(force: true);
        expect((await client.me()).email, account.email);
      });

      test('the same cookie twice: REUSED revokes the whole session', () async {
        final cookie = vault.cookie!;
        final token = await client.session.accessToken();

        final first = await rawRefresh(cookie);
        expect(first.statusCode, 200);
        final rotated = RefreshCookieCodec.select(
          first.headers['set-cookie'] ?? const [],
          now: DateTime.now().toUtc(),
        );
        expect(rotated, isA<RefreshCookieFound>());

        final second = await rawRefresh(cookie);
        expect(second.statusCode, 401);
        final envelope = ApiErrorEnvelope.tryParse(second.data)!;
        expect(envelope.code, 'AUTH_REFRESH_TOKEN_REUSED');
        expect(envelope.statusCode, 401);
        expect(envelope.path, '/api/v1/auth/refresh');
        expect(envelope.requestId, isNotEmpty);
        expect((second.data! as Map).keys.toSet(), {
          'statusCode',
          'code',
          'message',
          'path',
          'requestId',
          'timestamp',
        });
        print('S1 reuse -> ${second.statusCode} ${second.data}');
        print('S1 reuse set-cookie: ${second.headers['set-cookie'] ?? 'none'}');

        // The rotation that won is revoked too, and so is the access token.
        final next = await rawRefresh((rotated as RefreshCookieFound).cookie);
        expect(next.statusCode, 401);
        expect(
          ApiErrorEnvelope.tryParse(next.data)?.code,
          'AUTH_SESSION_REVOKED',
        );
        final me = await rawMe(token);
        expect(me.statusCode, 401);
        expect(
          ApiErrorEnvelope.tryParse(me.data)?.code,
          'AUTH_SESSION_REVOKED',
        );
        print(
          'S1 after reuse: rotated cookie -> ${next.statusCode} '
          '${ApiErrorEnvelope.tryParse(next.data)?.code}, access token -> '
          '${me.statusCode} ${ApiErrorEnvelope.tryParse(me.data)?.code}',
        );
      });
    });

    group('process killed between the refresh response and the vault write '
        '(login 2 of 2)', () {
      test('after a restart the stale cookie is reuse: one login is needed, '
          'never a silent recovery', () async {
        final vault = _DyingVault();
        final client = newClient(vault);
        await login(client);
        final persisted = vault.cookie!;
        final firstToken = await client.session.accessToken();

        vault.dieOnNextWrite = true;
        var tokenReleased = false;
        unawaited(
          client.session
              .ensureFresh(force: true)
              .then((_) => tokenReleased = true),
        );
        // The server answered (a rotated cookie reached the vault write)...
        final lost = await vault.dying.future.timeout(
          const Duration(seconds: 30),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
        // ...but the new access token was never handed out (write-ahead).
        expect(tokenReleased, isFalse);
        expect(lost.value, isNot(persisted.value));
        expect(vault.cookie, persisted, reason: 'the disk keeps the old one');
        // The "dead" process is abandoned here; its write never completes.

        // Restart: a new process reads what was on disk.
        final restartVault = InMemoryTokenVault(persisted);
        final restarted = newClient(restartVault);
        addTearDown(restarted.close);
        final state = await restarted.session.restore();

        expect(
          state,
          const AuthState.sessionLost(SessionLostReason.refreshTokenReused),
        );
        expect(restartVault.cookie, isNull);
        print('S1 restart with the stale cookie -> $state');

        // The server revoked the session: the cookie that died with the
        // process and the last access token are dead as well.
        final orphan = await rawRefresh(lost);
        expect(
          ApiErrorEnvelope.tryParse(orphan.data)?.code,
          'AUTH_SESSION_REVOKED',
        );
        final me = await rawMe(firstToken);
        expect(
          ApiErrorEnvelope.tryParse(me.data)?.code,
          'AUTH_SESSION_REVOKED',
        );
        print(
          'S1 after the restart: lost cookie -> ${orphan.statusCode} '
          '${ApiErrorEnvelope.tryParse(orphan.data)?.code}, old access '
          'token -> ${me.statusCode} '
          '${ApiErrorEnvelope.tryParse(me.data)?.code}',
        );
      });
    });
  });
}

/// A vault whose next cookie write never returns, like a process killed
/// while writing: [dying] completes with the cookie that was being written.
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
