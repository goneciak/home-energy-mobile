import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

import 'support/fake_core.dart';

/// Plan §9.4, §17.1: a real HTTPS server on a self-signed certificate
/// (test/support/tls, test only) must be reported as `TlsUntrusted` for its
/// host, never as unreachable and never retried over http.
void main() {
  late HttpServer server;
  var requests = 0;

  setUp(() async {
    requests = 0;
    final context = SecurityContext()
      ..useCertificateChain('test/support/tls/test_only_cert.pem')
      ..usePrivateKey('test/support/tls/test_only_key.pem');
    server = await shelf_io.serve(
      (request) {
        requests++;
        return Response.ok(
          '{"status":"ok"}',
          headers: {'content-type': 'application/json'},
        );
      },
      InternetAddress.loopbackIPv4,
      0,
      securityContext: context,
    );
  });

  tearDown(() => server.close(force: true));

  ApplianceAddress address() =>
      ApplianceAddress.parse('https://127.0.0.1:${server.port}');

  test(
    'a self-signed certificate maps to TlsUntrusted with the host',
    () async {
      final failures = <ApiFailure>[];
      final client = GiCoreClient.create(
        address: address(),
        vault: InMemoryTokenVault(),
        clientInfo: testClientInfo,
        onFailure: failures.add,
        retryBackoff: (_) => Duration.zero,
      );
      addTearDown(client.close);

      await expectLater(
        client.healthLive(),
        throwsA(
          isA<TlsUntrustedFailure>()
              .having((f) => f.host, 'host', '127.0.0.1')
              .having((f) => f.code, 'code', 'TLS_CERT_UNTRUSTED'),
        ),
      );
      expect(failures.single, isA<TlsUntrustedFailure>());
      // The handshake failed, so the handler never saw a request.
      expect(requests, 0);
    },
  );

  test('the connect probe reports the same failure', () async {
    final probe = ApplianceProbe(clientInfo: testClientInfo);

    await expectLater(
      probe.probe(address().origin.toString()),
      throwsA(
        isA<TlsUntrustedFailure>().having((f) => f.host, 'host', '127.0.0.1'),
      ),
    );
    expect(requests, 0);
  });
}
