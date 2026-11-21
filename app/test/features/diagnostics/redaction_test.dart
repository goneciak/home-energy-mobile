import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/diagnostics/domain/redaction.dart';

void main() {
  const jwt =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJzdWIiOiIxMjMiLCJzaWQiOiJhYmMifQ.'
      'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
  const refreshValue =
      '11111111-1111-4111-8111-111111111111.'
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  const recoveryCode = 'A1B2-C3D4-E5F6-0718-293A-4B5C-6D7E-8F90';

  String redact(String input) => Redactor.redact(input);

  group('tokens', () {
    test('a JWT anywhere in the text', () {
      expect(redact('token was $jwt, rejected'), 'token was <jwt>, rejected');
    });

    test('a Bearer token, JWT or opaque', () {
      expect(redact('authorization: Bearer $jwt'), isNot(contains('eyJ')));
      expect(redact('Bearer abc.DEF-123_x'), 'Bearer <redacted>');
      expect(redact('bearer opaque-token'), 'bearer <redacted>');
    });

    test('the refresh cookie by name, in headers and Set-Cookie', () {
      expect(
        redact('Cookie: gi_refresh_token=$refreshValue'),
        isNot(contains('1111')),
      );
      expect(
        redact(
          'set-cookie: gi_refresh_token=$refreshValue; '
          'Path=/api/v1/auth/refresh; HttpOnly',
        ),
        allOf(contains('Path=/api/v1/auth/refresh'), isNot(contains('AAAA'))),
      );
      expect(
        redact('gi_refresh_token=opaque; Path=/'),
        'gi_refresh_token=<redacted>; Path=/',
      );
    });

    test('the refresh token value without its name', () {
      expect(redact('value $refreshValue end'), 'value <redacted> end');
    });

    test('values of sensitive keys in JSON, maps and query-like text', () {
      expect(
        redact('{"accessToken":"opaque123","expiresIn":900}'),
        '{"accessToken":"<redacted>","expiresIn":900}',
      );
      expect(
        redact('{password: hunter2, email: x}'),
        '{password: <redacted>, email: x}',
      );
      expect(redact('refresh_token=abc&x=1'), 'refresh_token=<redacted>&x=1');
      expect(
        redact("{'newPassword': 'Secret123', 'currentPassword': 'Old1'}"),
        allOf(isNot(contains('Secret123')), isNot(contains('Old1'))),
      );
      expect(redact('recoveryCode: XYZ'), 'recoveryCode: <redacted>');
    });

    test('a quoted value goes whole, up to its closing quote', () {
      expect(
        redact('{"password":"hunter two words","email":"x"}'),
        '{"password":"<redacted>","email":"x"}',
      );
      expect(
        redact("password = 'correct horse; battery' rest"),
        "password = '<redacted>' rest",
      );
      expect(
        redact(r'{"password":"a \"quoted\" pass phrase","x":1}'),
        '{"password":"<redacted>","x":1}',
      );
      // Unclosed: up to the end of the line.
      expect(
        redact('"secret": "never closed here\nnext line'),
        '"secret": "<redacted>\nnext line',
      );
    });

    test('JSON-escaped keys and values', () {
      expect(
        redact(r'body: {\"password\":\"Secret123\",\"email\":\"x\"}'),
        r'body: {\"password\":\"<redacted>\",\"email\":\"x\"}',
      );
      expect(
        redact(r'{\"accessToken\":\"opaque two\"}'),
        r'{\"accessToken\":\"<redacted>\"}',
      );
    });

    test('a placeholder is not redacted again', () {
      expect(redact('"accessToken":"$jwt"'), '"accessToken":"<jwt>"');
    });
  });

  group('personal data', () {
    test('e-mail addresses', () {
      expect(
        redact('login failed for jan.kowalski+gi@example.co.uk.'),
        'login failed for <email>.',
      );
      expect(redact('owner@gihome.test'), '<email>');
    });

    test('recovery codes, grouped or normalised', () {
      expect(redact('code $recoveryCode used'), 'code <recovery-code> used');
      expect(
        redact(recoveryCode.toLowerCase().replaceAll('-', ' ')),
        '<recovery-code>',
      );
      expect(redact(recoveryCode.replaceAll('-', '')), '<recovery-code>');
    });

    test('request ids and UUIDs are kept for support', () {
      const requestId = 'm-0123456789abcdef0123456789abcdef';
      const uuid = '341584fe-d238-44e5-b97b-191ff594bb09';
      expect(redact('id=$requestId'), 'id=$requestId');
      expect(redact('device $uuid'), 'device $uuid');
    });
  });

  group('addresses', () {
    test('the host of a URL; port and path stay, the query goes', () {
      expect(
        redact('GET http://192.168.1.10:3000/api/v1/devices failed'),
        'GET http://<host>:3000/api/v1/devices failed',
      );
      expect(
        redact('https://user:pw@gi.example.com/setup?token=abc&x=1'),
        'https://<host>/setup?<redacted>',
      );
      expect(redact('http://[fe80::1]:3000/'), 'http://<host>:3000/');
    });

    test('.local names and host lookups', () {
      expect(redact('resolving gi-home.local'), 'resolving <host>');
      expect(
        redact("Failed host lookup: 'gi.example.com' (OS Error)"),
        "Failed host lookup: '<host>' (OS Error)",
      );
    });

    test('IPv4 addresses, also with a port', () {
      expect(
        redact(
          'SocketException: Connection refused, '
          'address = 10.0.2.2, port = 51234',
        ),
        'SocketException: Connection refused, address = <ip>, port = 51234',
      );
      expect(redact('peer 172.16.0.1:3000.'), 'peer <ip>:3000.');
    });

    test('host names after address = and host:', () {
      expect(
        redact(
          'SocketException: Connection refused (OS Error: errno = 111), '
          'address = gi-home.lan, port = 54321',
        ),
        'SocketException: Connection refused (OS Error: errno = 111), '
        'address = <host>, port = 54321',
      );
      expect(
        redact('ApiFailure.tlsUntrusted(host: myhouse.duckdns.org, reason: x)'),
        'ApiFailure.tlsUntrusted(host: <host>, reason: x)',
      );
      expect(redact('Host: gi-home.lan:3000'), 'Host: <host>:3000');
      expect(redact('hostname=nas'), 'hostname=<host>');
    });

    test('IPv6 addresses, compressed, full, zoned and mapped', () {
      expect(redact('from ::1 to fe80::1%wlan0'), 'from <ip> to <ip>');
      expect(
        redact('2001:0db8:85a3:0000:0000:8a2e:0370:7334 down'),
        '<ip> down',
      );
      expect(redact('mapped ::ffff:192.168.1.20'), 'mapped <ip>');
    });

    test('times, versions and stack frames are not addresses', () {
      const frame =
          '#0 Foo.bar (package:gi_home/src/x.dart:12:5)\n'
          'at 12:30:45 version 1.2.3 build 10.0.19045.1';
      expect(redact(frame), frame);
      expect(redact('aa:bb:cc:dd:ee:ff'), 'aa:bb:cc:dd:ee:ff');
    });
  });

  test('empty text stays empty', () {
    expect(redact(''), '');
  });

  test('redactJson redacts nested strings and keys, keeps other values', () {
    final redacted = Redactor.redactJson({
      'user': {'email': 'a.b@example.com', 'id': 7},
      'hosts': ['192.168.0.5', 'gi-home.local'],
      'owner@example.com': true,
      42: null,
      'ok': 1.5,
    });

    expect(redacted, {
      'user': {'email': '<email>', 'id': 7},
      'hosts': ['<ip>', '<host>'],
      '<email>': true,
      '42': null,
      'ok': 1.5,
    });
  });
}
