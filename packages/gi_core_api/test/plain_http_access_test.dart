import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

import 'support/fake_core.dart';

/// What a tester on a home network meets: Core with `AUTH_COOKIE_SECURE=true`
/// reached over plain `http://host:3000`, a reverse proxy that redirects to
/// `https://`, and an address typed without a port.
void main() {
  group('Secure refresh cookie over plain http', () {
    late FakeCore core;
    late FakeClock clock;
    late GiCoreClient client;

    String secureSetCookie(String value) =>
        'gi_refresh_token=$value; Max-Age=2592000; '
        'Path=/api/v1/auth/refresh; Expires=Thu, 17 Dec 2026 22:06:20 GMT; '
        'HttpOnly; Secure; SameSite=Lax';

    setUp(() {
      core = FakeCore();
      clock = FakeClock();
      client = testClient(core, vault: InMemoryTokenVault(), clock: clock);
    });

    tearDown(() => client.close());

    test('is stored, replayed and rotated: the session survives a refresh '
        'on http', () async {
      expect(testAddress.isCleartext, isTrue);
      core
        ..on(
          'POST',
          '/auth/login',
          (_) => FakeResponse.json(
            loginBody(),
            headers: {
              'set-cookie': [secureSetCookie(testCookieValue1)],
            },
          ),
        )
        ..on('POST', '/auth/refresh', (request) {
          final replayed = request.header('cookie');
          if (replayed == 'gi_refresh_token=$testCookieValue1') {
            return FakeResponse.json(
              refreshBody('access-2'),
              headers: {
                'set-cookie': [secureSetCookie(testCookieValue2)],
              },
            );
          }
          if (replayed == 'gi_refresh_token=$testCookieValue2') {
            return FakeResponse.json(
              refreshBody('access-3'),
              headers: {
                'set-cookie': [secureSetCookie(testCookieValue3)],
              },
            );
          }
          return FakeResponse.error(401, 'AUTH_REFRESH_TOKEN_INVALID');
        });

      await client.login(email: 'owner@gihome.test', password: 'pw');
      clock.advance(const Duration(seconds: 850));
      expect(await client.session.ensureFresh(), 'access-2');
      clock.advance(const Duration(seconds: 850));
      expect(await client.session.ensureFresh(), 'access-3');

      expect(client.session.state, isA<AuthAuthenticated>());
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(2));
    });
  });

  group('over a real socket', () {
    final servers = <HttpServer>[];
    tearDown(() async {
      for (final server in servers) {
        await server.close(force: true);
      }
      servers.clear();
    });

    Future<HttpServer> serve(Handler handler) async {
      final server = await shelf_io.serve(
        handler,
        InternetAddress.loopbackIPv4,
        0,
      );
      servers.add(server);
      return server;
    }

    ApplianceProbe probe() => ApplianceProbe(clientInfo: testClientInfo);

    test(
      'a redirect to https is HttpsRequired and is never followed',
      () async {
        var targetHits = 0;
        final target = await serve((request) {
          targetHits++;
          return Response.ok('{}');
        });
        final proxy = await serve(
          (request) => Response.movedPermanently(
            'https://gi-home.local/api/v1/health/live',
            headers: {'x-target': '${target.port}'},
          ),
        );

        await expectLater(
          probe().probe('127.0.0.1:${proxy.port}'),
          throwsA(
            isA<HttpsRequiredFailure>()
                .having((f) => f.host, 'host', 'gi-home.local')
                .having((f) => f.code, 'code', 'HTTPS_REQUIRED'),
          ),
        );
        expect(targetHits, 0);
      },
    );

    test('a redirect elsewhere is still an unexpected response', () async {
      final server = await serve((request) => Response.found('/login'));

      await expectLater(
        probe().probe('127.0.0.1:${server.port}'),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });
  });

  group('address without a port', () {
    final core = FakeCore();

    ApplianceProbe probe() =>
        ApplianceProbe(clientInfo: testClientInfo, httpClientAdapter: core);

    test(
      'falls back from :80 to :3000 and reports the port that worked',
      () async {
        core
          ..on('GET', '/health/live', (request) {
            if (request.options.uri.port != 3000) {
              return FakeResponse.error(404, 'HTTP_404');
            }
            return FakeResponse.json({'status': 'ok'});
          })
          ..on(
            'GET',
            '/setup/status',
            (_) => FakeResponse.json(
              fixtureJson('SetupController_getStatus/initialized.json'),
            ),
          );

        final result = await probe().probe('192.168.1.20');

        expect(result.address.authority, '192.168.1.20:3000');
        expect(core.requests.map((r) => r.options.uri.port).toList(), [
          80,
          3000,
          3000,
        ]);
      },
    );

    test('an explicit port is probed exactly, without a fallback', () async {
      core.requests.clear();
      await expectLater(
        probe().probe('192.168.1.20:8080'),
        throwsA(isA<RouteAbsentFailure>()),
      );
      expect(core.requests.map((r) => r.options.uri.port).toSet(), {8080});
    });
  });
}
