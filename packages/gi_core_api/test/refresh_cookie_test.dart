import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  final now = DateTime.utc(2026, 11, 17, 22, 6, 20);

  group('RefreshCookieCodec.select', () {
    test('selects the recorded login cookie with Max-Age expiry', () {
      final header = fixtureText('AuthController_login/ok.set-cookie.txt')
          .trim();

      final selection = RefreshCookieCodec.select([header], now: now);

      final cookie = (selection as RefreshCookieFound).cookie;
      expect(cookie.name, 'gi_refresh_token');
      expect(cookie.path, '/api/v1/auth/refresh');
      expect(cookie.value, matches(RefreshCookieCodec.valuePattern));
      expect(cookie.absoluteExpiry, now.add(const Duration(seconds: 2592000)));
      expect(cookie.obtainedAt, now);
      expect(cookie.generation, 0);
      expect(cookie.cookieHeader, 'gi_refresh_token=${cookie.value}');
    });

    test('Max-Age wins over Expires, Expires is used alone', () {
      final withBoth = RefreshCookieCodec.parse(
        'a=b; Max-Age=60; Expires=Thu, 01 Jan 2099 00:00:00 GMT',
      )!;
      final expiresOnly = RefreshCookieCodec.parse(
        'a=b; Expires=Thu, 17 Dec 2026 22:06:20 GMT',
      )!;

      expect(withBoth.expiryFrom(now), now.add(const Duration(seconds: 60)));
      expect(
        expiresOnly.expiryFrom(now),
        DateTime.utc(2026, 12, 17, 22, 6, 20),
      );
    });

    test('prefers the cookie scoped to /auth/refresh over other cookies', () {
      final selection = RefreshCookieCodec.select([
        'session=abc; Path=/',
        'other=${'x' * 10}; Path=/api/v1/auth/refresh-not',
        setCookieFor(testCookieValue2),
      ], now: now);

      expect((selection as RefreshCookieFound).cookie.value, testCookieValue2);
    });

    test('falls back to the cookie name when the path differs', () {
      final selection = RefreshCookieCodec.select([
        'gi_refresh_token=$testCookieValue1; Path=/gi/api/v1/refresh; Max-Age=10',
      ], now: now);

      final cookie = (selection as RefreshCookieFound).cookie;
      expect(cookie.value, testCookieValue1);
      expect(cookie.path, '/gi/api/v1/refresh');
    });

    test('splits values folded into one header by a proxy', () {
      final folded =
          'theme=dark; Path=/; Expires=Thu, 17 Dec 2026 22:06:20 GMT, '
          '${setCookieFor(testCookieValue3)}';

      final cookies = RefreshCookieCodec.parseAll([folded]);
      final selection = RefreshCookieCodec.select([folded], now: now);

      expect(cookies.map((c) => c.name), ['theme', 'gi_refresh_token']);
      expect(cookies.first.expires, DateTime.utc(2026, 12, 17, 22, 6, 20));
      expect((selection as RefreshCookieFound).cookie.value, testCookieValue3);
    });

    test('detects a cleared cookie', () {
      const clearedHeader =
          'gi_refresh_token=; Path=/api/v1/auth/refresh; '
          'Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly';
      const cleared = [clearedHeader];
      final maxAgeZero = [
        'gi_refresh_token=$testCookieValue1; Path=/api/v1/auth/refresh; Max-Age=0',
      ];
      final pastExpiresHeader =
          'gi_refresh_token=$testCookieValue1; Path=/api/v1/auth/refresh; '
          'Expires=Thu, 01 Jan 1970 00:00:00 GMT';
      final pastExpires = [pastExpiresHeader];

      for (final headers in [cleared, maxAgeZero, pastExpires]) {
        expect(
          RefreshCookieCodec.select(headers, now: now),
          isA<RefreshCookieCleared>(),
          reason: headers.single,
        );
      }
    });

    test('rejects a malformed value and reports a missing cookie', () {
      expect(
        RefreshCookieCodec.select([
          'gi_refresh_token=not-a-token; Path=/api/v1/auth/refresh',
        ], now: now),
        isA<RefreshCookieMalformed>(),
      );
      expect(
        RefreshCookieCodec.select(['theme=dark; Path=/'], now: now),
        isA<RefreshCookieMissing>(),
      );
      expect(
        RefreshCookieCodec.select(const [], now: now),
        isA<RefreshCookieMissing>(),
      );
    });

    test('parses attributes case-insensitively and strips quotes', () {
      final cookie = RefreshCookieCodec.parse(
        'gi_refresh_token="$testCookieValue1"; path=/api/v1/auth/refresh; '
        'max-age=5; HTTPONLY; secure; samesite=Lax; Domain=gi-home.local',
      )!;

      expect(cookie.value, testCookieValue1);
      expect(cookie.path, '/api/v1/auth/refresh');
      expect(cookie.maxAge, 5);
      expect(cookie.httpOnly, isTrue);
      expect(cookie.secure, isTrue);
      expect(cookie.sameSite, 'Lax');
      expect(cookie.domain, 'gi-home.local');
      expect(RefreshCookieCodec.parse('no-equals-sign'), isNull);
      expect(RefreshCookieCodec.parse('=value'), isNull);
    });

    test('stores the requested generation', () {
      final selection = RefreshCookieCodec.select(
        [setCookieFor(testCookieValue1)],
        now: now,
        generation: 7,
      );

      expect((selection as RefreshCookieFound).cookie.generation, 7);
    });
  });

  group('RefreshCookie', () {
    test('round-trips through JSON for the vault', () {
      final cookie = storedCookie(generation: 3);

      final restored = RefreshCookie.fromJson(cookie.toJson());

      expect(restored, cookie);
    });

    test('never prints its value', () {
      final cookie = storedCookie();

      expect(cookie.toString(), isNot(contains(cookie.value)));
      expect(
        RefreshCookieCodec.parse(setCookieFor(testCookieValue1)).toString(),
        isNot(contains(testCookieValue1)),
      );
    });

    test('knows when its absolute expiry has passed', () {
      final cookie = storedCookie(absoluteExpiry: now);

      expect(
        cookie.isExpiredAt(now.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(cookie.isExpiredAt(now), isTrue);
    });
  });
}
