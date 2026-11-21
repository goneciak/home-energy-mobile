/// Live auth contract (plan §17.3, spike S1, Exit M0) against the Core at
/// `GI_CORE_URL` (default http://localhost:3000), with strict decoding.
/// See `support/contract_env.dart` for the environment and credentials.
///
/// Tests run in declaration order and share state. Login is rate limited to
/// 5 attempts per minute per IP, so this file performs exactly two logins (as
/// the owner); the other contract files use the seeded ADMIN and USER.
///
/// Changing the owner's password (and back) only runs on a Core seeded for
/// contract use (the fake device is provisioned), never on a dev Core.
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
  GiEndpoints.healthLive,
  GiEndpoints.setupStatus,
  GiEndpoints.authLogin,
  GiEndpoints.authRefresh,
  GiEndpoints.authLogout,
  GiEndpoints.authMe,
  GiEndpoints.usersMeProfile,
  GiEndpoints.usersMeChangePassword,
  GiEndpoints.roomsList,
  GiEndpoints.devicesList,
  GiEndpoints.devicesDetail,
];

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final owner = ContractEnv.owner();
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('GI Core contract', skip: skip, () {
    late ApplianceAddress address;
    late Dio raw;
    late InMemoryTokenVault vault;
    late GiCoreClient client;
    var contractSeeded = false;

    GiCoreClient newClient() => strictClient(
      address: address,
      vault: vault,
      expectedInitializedAt: probe!.setup.initializedAt,
    );

    Future<CurrentUser> login() => respectingLoginLimit(
      () => client.login(email: owner!.email, password: owner.password),
    );

    Future<Response<Object?>> rawRequest(
      String method,
      String path, {
      Map<String, Object?> headers = const {},
      Object? data,
    }) => raw.request<Object?>(
      path,
      data: data,
      options: Options(method: method, headers: headers),
    );

    setUpAll(() {
      address = probe!.address;
      raw = rawDio(address);
      vault = InMemoryTokenVault();
      client = newClient();
    });

    tearDownAll(() async {
      await client.close();
      raw.close();
    });

    group('public endpoints', () {
      test('probe confirms GI Core and the appliance fingerprint', () {
        expect(probe!.health.isLive, isTrue);
        expect(probe.setup.initializedAt, isNotNull);
        expect(probe.setup.locale, isNotNull);
      });

      test('health/live and setup/status decode strictly', () async {
        expect((await client.healthLive()).isLive, isTrue);
        final status = await client.setupStatus();
        expect(status.initialized, isTrue);
        expect(
          status.initializedAt!.isAtSameMomentAs(probe!.setup.initializedAt!),
          isTrue,
        );
      });

      test('unknown route: HTTP_404 envelope echoing our request id', () async {
        const requestId = 'm-00112233445566778899aabbccddeeff';
        final response = await rawRequest(
          'GET',
          '/definitely-not-a-route',
          headers: {'x-request-id': requestId},
        );

        expect(response.headers.value('x-request-id'), requestId);
        final failure = failureFromResponse(
          statusCode: response.statusCode!,
          data: response.data,
          headers: response.headers,
        );
        expect(failure, isA<RouteAbsentFailure>());
        expect(failure.requestId, requestId);
      });

      test(
        'protected endpoint without a token: 401 AUTH_UNAUTHORIZED',
        () async {
          final response = await rawRequest('GET', '/auth/me');

          expect(response.statusCode, 401);
          expect(
            ApiErrorEnvelope.tryParse(response.data)?.code,
            'AUTH_UNAUTHORIZED',
          );
        },
      );
    });

    group('session 1: read, rotate, reuse', () {
      late RefreshCookie firstCookie;
      late String firstToken;

      test('login stores the refresh cookie (login 1 of 2)', () async {
        final user = await login();

        firstCookie = vault.cookie!;
        firstToken = await client.session.accessToken();
        expect(client.session.state, AuthState.authenticated(user));
        expect(firstCookie.name, 'gi_refresh_token');
        expect(firstCookie.path, '/api/v1/auth/refresh');
        expect(firstCookie.value, matches(RefreshCookieCodec.valuePattern));
        expect(
          firstCookie.absoluteExpiry!.difference(firstCookie.obtainedAt),
          const Duration(days: 30),
        );
        expect(user.role, UserRole.owner);
      });

      test('me and profile', () async {
        final me = await client.me();
        final profile = await client.profile();

        expect(profile.id, me.id);
        expect(profile.email, me.email);
        expect(profile.role, me.role);
      });

      test('rooms, devices (limit=100) and every device detail', () async {
        final rooms = await client.rooms();
        final page = await client.devices();

        expect(rooms, isNotEmpty);
        expect(page.limit, 100);
        expect(page.items, hasLength(page.total));
        for (final item in page.items) {
          final detail = await client.device(item.id);
          expect(detail.id, item.id);
          expect(detail.status, isNot(ProductStatus.unknown));
          if (item.roomId != null) {
            expect(rooms.map((r) => r.id), contains(item.roomId));
          }
        }
        contractSeeded = isContractSeeded(page.items);
      });

      test('a domain 404 differs from a missing route', () async {
        await expectLater(
          client.device('00000000-0000-4000-8000-000000000000'),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      test('an unknown body key is rejected with VALIDATION_FAILED', () async {
        final token = await client.session.accessToken();
        final response = await rawRequest(
          'POST',
          '/users/me/change-password',
          headers: {'authorization': 'Bearer $token'},
          data: {'currentPassword': 'x', 'newPassword': 'Abcdefg1', 'extra': 1},
        );

        final failure = failureFromResponse(
          statusCode: response.statusCode!,
          data: response.data,
        );
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).details.keys, contains('extra'));
      });

      test('refresh rotates the cookie and the token', () async {
        final token = await client.session.ensureFresh(force: true);

        expect(token, isNot(firstToken));
        expect(vault.cookie!.value, isNot(firstCookie.value));
        expect(vault.cookie!.generation, firstCookie.generation + 1);
        expect((await client.me()).id, isNotEmpty);
      });

      test(
        'replaying the old cookie is detected and revokes the session',
        () async {
          final response = await rawRequest(
            'POST',
            '/auth/refresh',
            headers: {'cookie': firstCookie.cookieHeader},
          );

          expect(response.statusCode, 401);
          expect(
            ApiErrorEnvelope.tryParse(response.data)?.code,
            'AUTH_REFRESH_TOKEN_REUSED',
          );

          await expectLater(
            client.me(),
            throwsA(
              const ApiFailure.sessionLost(
                reason: SessionLostReason.sessionRevoked,
              ),
            ),
          );
          expect(
            client.session.state,
            const AuthState.sessionLost(SessionLostReason.sessionRevoked),
          );
          expect(vault.cookie, isNull);
        },
      );
    });

    group('session 2: password, logout', () {
      late RefreshCookie cookie;
      late String token;

      test('login again (login 2 of 2)', () async {
        await client.close();
        client = newClient();
        await login();
        cookie = vault.cookie!;
        token = await client.session.accessToken();
      });

      test('change the password and back; the current session stays', () async {
        if (!contractSeeded) {
          markTestSkipped(
            'changes the owner password: only on a Core seeded for '
            'contract use (no fake device at $base)',
          );
          return;
        }
        final temporary = '${owner!.password}-Tmp1';
        var current = owner.password;
        addTearDown(() async {
          // Never leave the owner on the temporary password.
          if (current == owner.password) return;
          await client.changePassword(
            ChangePasswordRequest(
              currentPassword: current,
              newPassword: owner.password,
            ),
          );
        });

        final changed = await client.changePassword(
          ChangePasswordRequest(
            currentPassword: owner.password,
            newPassword: temporary,
          ),
        );
        current = temporary;
        expect(changed.revokedSessions, greaterThanOrEqualTo(0));

        // The old password is no longer the current one.
        await expectLater(
          client.changePassword(
            ChangePasswordRequest(
              currentPassword: owner.password,
              newPassword: 'Another-Pass-1',
            ),
          ),
          throwsA(
            isA<DomainFailure>()
                .having((f) => f.statusCode, 'status', 400)
                .having((f) => f.code, 'code', 'USER_CURRENT_PASSWORD_INVALID'),
          ),
        );

        final restored = await client.changePassword(
          ChangePasswordRequest(
            currentPassword: temporary,
            newPassword: owner.password,
          ),
        );
        current = owner.password;
        // Every other session went with the first change.
        expect(restored.revokedSessions, 0);
        expect((await client.me()).email, owner.email);
        expect(vault.cookie!.value, cookie.value);
      });

      test('logout ends the server session and wipes locally', () async {
        final result = await client.logout();

        expect(result.serverSessionEnded, isTrue);
        expect(client.session.state, const AuthState.unauthenticated());
        expect(vault.cookie, isNull);

        final me = await rawRequest(
          'GET',
          '/auth/me',
          headers: {'authorization': 'Bearer $token'},
        );
        expect(me.statusCode, 401);
        expect(
          ApiErrorEnvelope.tryParse(me.data)?.code,
          'AUTH_SESSION_REVOKED',
        );

        final refresh = await rawRequest(
          'POST',
          '/auth/refresh',
          headers: {'cookie': cookie.cookieHeader},
        );
        expect(refresh.statusCode, 401);
        expect(
          ApiErrorEnvelope.tryParse(refresh.data)?.code,
          'AUTH_SESSION_REVOKED',
        );
      });
    });
  });
}
