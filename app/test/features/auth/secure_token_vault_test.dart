import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/auth/data/secure_token_vault.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

void main() {
  const profileId = 'abc123';
  const key = 'p/abc123/rt';
  const accessKey = 'p/abc123/at';
  final cookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'A' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17, 22),
    absoluteExpiry: DateTime.utc(2026, 12, 17, 22),
    generation: 3,
  );

  late MockSecureStorage storage;
  late SecureTokenVault vault;

  setUp(() {
    storage = MockSecureStorage();
    vault = SecureTokenVault(storage: storage, profileId: profileId);
  });

  test('scopes the entry to the profile', () {
    expect(vault.key, key);
  });

  test('write stores the cookie as JSON under the profile key', () async {
    when(
      () => storage.write(
        key: key,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    await vault.write(cookie);

    final stored =
        verify(
              () => storage.write(
                key: key,
                value: captureAny(named: 'value'),
              ),
            ).captured.single
            as String;
    expect(
      RefreshCookie.fromJson(jsonDecode(stored) as Map<String, dynamic>),
      cookie,
    );
  });

  test('read returns the stored cookie', () async {
    when(() => storage.read(key: key))
        .thenAnswer((_) async => jsonEncode(cookie.toJson()));

    final result = await vault.read();

    expect(result, isA<VaultPresent>());
    expect((result as VaultPresent).cookie, cookie);
  });

  test('read reports absent when nothing is stored', () async {
    when(() => storage.read(key: key)).thenAnswer((_) async => null);

    expect(
      await vault.read(),
      isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isFalse),
    );
  });

  test(
    'read reports unavailable on a platform error and keeps the entry',
    () async {
      final error = PlatformException(code: 'errSecInteractionNotAllowed');
      when(() => storage.read(key: key)).thenThrow(error);

      final result = await vault.read();

      expect(result, isA<VaultUnavailable>());
      expect((result as VaultUnavailable).error, same(error));
      verifyNever(() => storage.delete(key: any(named: 'key')));
    },
  );

  test('a corrupt entry is removed and reported as wiped', () async {
    when(() => storage.read(key: key)).thenAnswer((_) async => '{"name": 1');
    when(() => storage.delete(key: key)).thenAnswer((_) async {});

    expect(
      await vault.read(),
      isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
    );
    verify(() => storage.delete(key: key)).called(1);
  });

  test('a corrupt entry that cannot be removed is still wiped', () async {
    when(() => storage.read(key: key)).thenAnswer((_) async => 'not json');
    when(() => storage.delete(key: key))
        .thenThrow(PlatformException(code: 'KeystoreError'));

    expect(
      await vault.read(),
      isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
    );
  });

  test('write and clear propagate platform errors', () async {
    when(
      () => storage.write(
        key: key,
        value: any(named: 'value'),
      ),
    ).thenThrow(PlatformException(code: 'KeystoreError'));
    when(() => storage.delete(key: key))
        .thenThrow(PlatformException(code: 'KeystoreError'));

    await expectLater(vault.write(cookie), throwsA(isA<PlatformException>()));
    await expectLater(vault.clear(), throwsA(isA<PlatformException>()));
  });

  test('clear deletes the cookie and the access token', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

    await vault.clear();

    verify(() => storage.delete(key: key)).called(1);
    verify(() => storage.delete(key: accessKey)).called(1);
  });

  group('access token (D3)', () {
    final token = PersistedAccessToken(
      token: 'header.payload.signature',
      expiresAt: DateTime.utc(2026, 11, 17, 22, 15),
    );

    test('is stored as JSON next to the cookie of the profile', () async {
      when(
        () => storage.write(
          key: accessKey,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await vault.writeAccessToken(token);

      expect(vault.accessTokenKey, accessKey);
      final stored =
          verify(
                () => storage.write(
                  key: accessKey,
                  value: captureAny(named: 'value'),
                ),
              ).captured.single
              as String;
      expect(jsonDecode(stored), {
        'token': 'header.payload.signature',
        'expiresAt': '2026-11-17T22:15:00.000Z',
      });
    });

    test('reads back what was stored', () async {
      when(() => storage.read(key: accessKey))
          .thenAnswer((_) async => jsonEncode(token.toJson()));

      expect(await vault.readAccessToken(), token);
    });

    test('a missing entry is no token', () async {
      when(() => storage.read(key: accessKey)).thenAnswer((_) async => null);

      expect(await vault.readAccessToken(), isNull);
    });

    test('an unavailable store is no token and touches nothing', () async {
      when(() => storage.read(key: accessKey))
          .thenThrow(PlatformException(code: 'errSecInteractionNotAllowed'));

      expect(await vault.readAccessToken(), isNull);
      verifyNever(() => storage.delete(key: any(named: 'key')));
    });

    test('an undecodable entry is removed, the cookie is kept', () async {
      when(() => storage.read(key: accessKey))
          .thenAnswer((_) async => '{not json');
      when(() => storage.delete(key: accessKey)).thenAnswer((_) async {});

      expect(await vault.readAccessToken(), isNull);
      verify(() => storage.delete(key: accessKey)).called(1);
      verifyNever(() => storage.delete(key: key));
    });

    test('clearAccessToken removes only the token', () async {
      when(() => storage.delete(key: accessKey)).thenAnswer((_) async {});

      await vault.clearAccessToken();

      verify(() => storage.delete(key: accessKey)).called(1);
      verifyNever(() => storage.delete(key: key));
    });
  });
}
