import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

/// Every branch of [TransportPolicy] (plan §9.4 requires full branch
/// coverage): the scheme switch, each home-network rule and the edges of
/// the private ranges.
void main() {
  bool allows(String url) => TransportPolicy.allows(Uri.parse(url));

  group('scheme', () {
    test('https is allowed to any host', () {
      for (final url in [
        'https://example.com',
        'https://8.8.8.8',
        'https://[2001:db8::1]:8443/api/v1',
        'https://gi-home.local',
      ]) {
        expect(allows(url), isTrue, reason: url);
      }
    });

    test('http depends on the host', () {
      expect(allows('http://192.168.1.10:3000'), isTrue);
      expect(allows('http://example.com'), isFalse);
    });

    test('any other scheme is refused, even at home', () {
      for (final url in [
        'ftp://192.168.1.10',
        'ws://localhost:3000',
        'file:///etc/hosts',
        '//192.168.1.10',
      ]) {
        expect(allows(url), isFalse, reason: url);
      }
    });
  });

  group('home network hosts over http', () {
    void expectHosts(Map<String, bool> hosts) {
      for (final MapEntry(key: host, value: allowed) in hosts.entries) {
        expect(TransportPolicy.isHomeNetworkHost(host), allowed, reason: host);
      }
    }

    test('localhost and *.local by name, in any case', () {
      expectHosts({
        'localhost': true,
        'LOCALHOST': true,
        'gi-home.local': true,
        'GI-Home.Local': true,
        'gi-home.local.example.com': false,
        'notlocal': false,
        'localhost.example.com': false,
      });
    });

    test('an unparsable or public name is not at home', () {
      expectHosts({
        '': false,
        'example.com': false,
        'gi_home': false,
        '999.1.1.1': false,
        '192.168.1': false,
        '[not-an-address]': false,
      });
    });

    test('loopback, IPv4 and IPv6', () {
      expectHosts({'127.0.0.1': true, '127.255.255.254': true, '::1': true});
    });

    test('link-local, IPv4 and IPv6', () {
      expectHosts({
        '169.254.10.1': true,
        '169.255.0.1': false,
        'fe80::1': true,
        'fe80::1ff:fe23:4567:890a': true,
      });
    });

    test('10.0.0.0/8, including the emulator alias 10.0.2.2', () {
      expectHosts({
        '10.0.0.1': true,
        '10.0.2.2': true,
        '10.255.255.255': true,
        '11.0.0.1': false,
        '9.255.255.255': false,
      });
    });

    test('172.16.0.0/12 and its edges', () {
      expectHosts({
        '172.16.0.1': true,
        '172.20.10.5': true,
        '172.31.255.255': true,
        '172.15.255.255': false,
        '172.32.0.1': false,
        '173.16.0.1': false,
      });
    });

    test('192.168.0.0/16', () {
      expectHosts({
        '192.168.0.1': true,
        '192.168.255.255': true,
        '192.169.0.1': false,
        '192.167.0.1': false,
        '193.168.0.1': false,
      });
    });

    test('unique-local IPv6 fc00::/7', () {
      expectHosts({
        'fc00::1': true,
        'fd12:3456::1': true,
        'fdff:ffff::1': true,
        'fe00::1': false,
        'fb00::1': false,
      });
    });

    test('public addresses are not at home', () {
      expectHosts({
        '8.8.8.8': false,
        '1.1.1.1': false,
        '100.64.0.1': false,
        '2001:db8::1': false,
        '2a00:1450:4001::200e': false,
        // IPv4-mapped IPv6 is not unwrapped.
        '::ffff:192.168.1.1': false,
      });
    });

    test('a bracketed IPv6 literal is unwrapped', () {
      expectHosts({
        '[::1]': true,
        '[fe80::1]': true,
        '[fd12::1]': true,
        '[2001:db8::1]': false,
      });
      // Uri drops the brackets itself; both paths agree.
      expect(allows('http://[::1]:3000'), isTrue);
      expect(allows('http://[fd12::1]'), isTrue);
      expect(allows('http://[2001:db8::1]'), isFalse);
    });
  });
}
