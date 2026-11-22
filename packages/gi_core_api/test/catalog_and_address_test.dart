import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

void main() {
  group('GiEndpoints', () {
    test('ids are unique and only reads are retried', () {
      final ids = GiEndpoints.all.map((e) => e.id).toSet();

      expect(ids, hasLength(GiEndpoints.all.length));
      for (final endpoint in GiEndpoints.all) {
        if (endpoint.maxRetries > 0) {
          expect(endpoint.isIdempotent, isTrue, reason: endpoint.id);
        }
      }
      expect(GiEndpoints.authRefresh.maxRetries, 0);
      expect(GiEndpoints.authLogin.maxRetries, 0);
      expect(GiEndpoints.usersMeChangePassword.maxRetries, 0);
      expect(GiEndpoints.devicesDetail.maxRetries, 2);
    });

    test('public endpoints never carry a Bearer token', () {
      final public = GiEndpoints.all
          .where((e) => !e.requiresAuth)
          .map((e) => e.path);

      expect(
        public,
        unorderedEquals([
          '/health/live',
          '/setup/status',
          '/auth/login',
          '/auth/refresh',
          '/auth/recovery/reset',
        ]),
      );
    });

    test('role gating', () {
      for (final role in UserRole.values.where((r) => r != UserRole.unknown)) {
        expect(GiEndpoints.devicesList.allows(role), isTrue, reason: '$role');
      }
      expect(GiEndpoints.devicesList.allows(UserRole.unknown), isFalse);
      expect(GiEndpoints.setupStatus.allows(UserRole.unknown), isTrue);
    });

    test('timeouts follow the plan', () {
      expect(
        GiEndpoints.devicesList.timeout.receive,
        const Duration(seconds: 10),
      );
      expect(
        GiEndpoints.authLogout.timeout.receive,
        const Duration(seconds: 15),
      );
      expect(
        GiEndpoints.authRefresh.timeout.receive,
        const Duration(seconds: 30),
      );
      expect(TimeoutClass.probe.connect, const Duration(milliseconds: 1500));
    });

    test('path parameters are encoded and required', () {
      expect(
        GiEndpoints.devicesDetail.resolvePath({'id': 'a/b c'}),
        '/devices/a%2Fb%20c',
      );
      expect(
        () => GiEndpoints.devicesDetail.resolvePath(),
        throwsArgumentError,
      );
      expect(GiEndpoints.roomsList.resolvePath(), '/rooms');
    });
  });

  group('ApplianceAddress.parse', () {
    const cases = {
      '192.168.1.10': 'http://192.168.1.10',
      ' gi-home.local ': 'http://gi-home.local',
      'http://localhost:3000': 'http://localhost:3000',
      'HTTP://GI-HOME.LOCAL:3000/': 'http://gi-home.local:3000',
      'http://192.168.1.10:3000/api/v1/': 'http://192.168.1.10:3000',
      'http://192.168.1.10:3000/api/v1/?x=1#top': 'http://192.168.1.10:3000',
      'http://host/api': 'http://host',
      'https://home.example.com/gi/api/v1': 'https://home.example.com/gi',
      'gi-home.local:80': 'http://gi-home.local',
      'fe80::1': 'http://[fe80::1]',
      '[fd00::5]:3000': 'http://[fd00::5]:3000',
    };

    for (final MapEntry(key: input, value: expected) in cases.entries) {
      test('normalises "$input"', () {
        expect(ApplianceAddress.parse(input).toString(), expected);
      });
    }

    test('derives the API base and display authority', () {
      final address = ApplianceAddress.parse('http://192.168.1.10:3000/api/v1');

      expect(address.apiBaseUrl.toString(), 'http://192.168.1.10:3000/api/v1');
      expect(address.authority, '192.168.1.10:3000');
      expect(address.isCleartext, isTrue);
      expect(
        ApplianceAddress.parse('gi-home.local').authority,
        'gi-home.local',
      );
      expect(address, ApplianceAddress.parse('192.168.1.10:3000/'));
    });

    test('rejects unusable input', () {
      for (final input in [
        '',
        '   ',
        'ftp://host',
        'http://',
        'http://u:p@host',
      ]) {
        expect(
          () => ApplianceAddress.parse(input),
          throwsFormatException,
          reason: input,
        );
      }
    });
  });

  group('TransportPolicy', () {
    test('allows cleartext only inside the home network', () {
      const allowed = [
        'http://192.168.1.10',
        'http://10.0.2.2:3000',
        'http://172.16.0.1',
        'http://172.31.255.255',
        'http://169.254.10.1',
        'http://127.0.0.1:3000',
        'http://localhost:3000',
        'http://gi-home.local',
        'http://[::1]:3000',
        'http://[fe80::1]',
        'http://[fd12::1]',
        'https://example.com',
      ];
      const denied = [
        'http://example.com',
        'http://8.8.8.8',
        'http://172.32.0.1',
        'http://192.169.0.1',
        'http://[2001:db8::1]',
        'ftp://192.168.1.10',
      ];

      for (final url in allowed) {
        expect(TransportPolicy.allows(Uri.parse(url)), isTrue, reason: url);
      }
      for (final url in denied) {
        expect(TransportPolicy.allows(Uri.parse(url)), isFalse, reason: url);
      }
    });
  });

  test('ClientInfo builds a sanitised User-Agent', () {
    const info = ClientInfo(
      appVersion: '1.2.3',
      platform: 'Linux; Android 15; Pixel (8)\n',
    );

    expect(info.userAgent, 'GIHome-Mobile/1.2.3 (Linux; Android 15; Pixel 8)');
  });
}
