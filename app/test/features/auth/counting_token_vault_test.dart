import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/app/preference_keys.dart';
import 'package:gi_home/src/features/auth/data/counting_token_vault.dart';
import 'package:gi_home/src/features/auth/data/secure_token_vault.dart';
import 'package:gi_home/src/features/auth/data/vault_read_failures.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

/// The "N = 3" rule of plan §7.1, part of the M1 failure test pack.
void main() {
  const profileId = 'abc123';
  final cookie = RefreshCookie(
    name: 'gi_refresh_token',
    value: '11111111-1111-4111-8111-111111111111.${'A' * 43}',
    path: '/api/v1/auth/refresh',
    obtainedAt: DateTime.utc(2026, 11, 17, 22),
    absoluteExpiry: DateTime.utc(2026, 12, 17, 22),
  );
  final keychainLocked = PlatformException(code: 'errSecInteractionNotAllowed');

  late SharedPreferencesWithCache prefs;
  late InMemoryTokenVault inner;
  late int unavailableReports;

  /// Preferences as a new app process sees them: same platform store,
  /// empty cache.
  Future<SharedPreferencesWithCache> restartPrefs() =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: appPreferenceKeys,
        ),
      );

  CountingTokenVault vaultFor(
    SharedPreferencesWithCache prefs, {
    String profile = profileId,
    TokenVault? over,
  }) => CountingTokenVault(
    inner: over ?? inner,
    failures: VaultReadFailures(prefs, profileId: profile),
    onUnavailable: () => unavailableReports++,
  );

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = await restartPrefs();
    inner = InMemoryTokenVault(cookie);
    unavailableReports = 0;
  });

  test('the first and second failed read keep the entry', () async {
    final vault = vaultFor(prefs);
    inner.readError = keychainLocked;

    for (var attempt = 1; attempt <= 2; attempt++) {
      final result = await vault.read();
      expect(result, isA<VaultUnavailable>());
      expect((result as VaultUnavailable).error, same(keychainLocked));
      expect(inner.cookie, cookie, reason: 'attempt $attempt');
    }
    expect(VaultReadFailures(prefs, profileId: profileId).count, 2);
  });

  test('the third failed read in a row wipes the entry', () async {
    final vault = vaultFor(prefs);
    inner.readError = keychainLocked;

    await vault.read();
    await vault.read();
    final third = await vault.read();

    expect(third, isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue));
    expect(inner.cookie, isNull);
    // The next streak starts from zero.
    expect(VaultReadFailures(prefs, profileId: profileId).count, 0);
    expect(unavailableReports, 3);
  });

  test('a successful read in between resets the count', () async {
    final vault = vaultFor(prefs);
    inner.readError = keychainLocked;
    await vault.read();
    await vault.read();

    inner.readError = null;
    expect(await vault.read(), isA<VaultPresent>());

    inner.readError = keychainLocked;
    await vault.read();
    expect(await vault.read(), isA<VaultUnavailable>());
    expect(inner.cookie, cookie);
  });

  test('an absent entry counts as a successful read', () async {
    inner = InMemoryTokenVault();
    final vault = vaultFor(prefs);
    inner.readError = keychainLocked;
    await vault.read();
    await vault.read();

    inner.readError = null;
    expect(
      await vault.read(),
      isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isFalse),
    );
    expect(VaultReadFailures(prefs, profileId: profileId).count, 0);
  });

  test('the count survives an app restart', () async {
    inner.readError = keychainLocked;
    await vaultFor(prefs).read();
    await vaultFor(await restartPrefs()).read();

    final third = await vaultFor(await restartPrefs()).read();

    expect(third, isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue));
    expect(inner.cookie, isNull);
  });

  test('failures of another profile are not counted', () async {
    inner.readError = keychainLocked;
    await vaultFor(prefs, profile: 'old-profile').read();
    await vaultFor(prefs, profile: 'old-profile').read();

    expect(await vaultFor(prefs).read(), isA<VaultUnavailable>());
    expect(inner.cookie, cookie);
  });

  test('a vault that throws on read counts as unavailable', () async {
    final vault = vaultFor(prefs, over: _ThrowingVault());

    expect(await vault.read(), isA<VaultUnavailable>());
    expect(await vault.read(), isA<VaultUnavailable>());
    expect(
      await vault.read(),
      isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
    );
  });

  test('login after a streak starts counting again', () async {
    final vault = vaultFor(prefs);
    inner.readError = keychainLocked;
    await vault.read();
    await vault.read();

    await vault.write(cookie);

    expect(VaultReadFailures(prefs, profileId: profileId).count, 0);
  });

  test('a failing diagnostics callback does not change the result', () async {
    final vault = CountingTokenVault(
      inner: inner,
      failures: VaultReadFailures(prefs, profileId: profileId),
      onUnavailable: () => throw StateError('diagnostics'),
    );
    inner.readError = keychainLocked;

    expect(await vault.read(), isA<VaultUnavailable>());
  });

  group('access token (D3)', () {
    final token = PersistedAccessToken(
      token: 'access',
      expiresAt: DateTime.utc(2026, 11, 17, 22, 15),
    );

    test('is passed through to the platform vault', () async {
      final vault = vaultFor(prefs);

      await vault.writeAccessToken(token);
      expect(await vault.readAccessToken(), token);
      await vault.clearAccessToken();

      expect(inner.accessToken, isNull);
      expect(inner.cookie, cookie);
    });

    test('an unreadable token is not counted as a vault failure', () async {
      final vault = vaultFor(prefs);
      await vault.writeAccessToken(token);
      inner.accessReadError = keychainLocked;

      for (
        var i = 0;
        i < CountingTokenVault.defaultMaxConsecutiveFailures;
        i++
      ) {
        expect(await vault.readAccessToken(), isNull);
      }

      expect(VaultReadFailures(prefs, profileId: profileId).count, 0);
      expect(unavailableReports, 0);
      expect(await vault.read(), isA<VaultPresent>());
    });

    test('a vault that throws on the token read reports no token', () async {
      final vault = vaultFor(prefs, over: _ThrowingVault());

      expect(await vault.readAccessToken(), isNull);
    });

    test('the third failed cookie read wipes the token too', () async {
      final vault = vaultFor(prefs);
      await vault.writeAccessToken(token);
      inner.readError = keychainLocked;

      for (
        var i = 0;
        i < CountingTokenVault.defaultMaxConsecutiveFailures;
        i++
      ) {
        await vault.read();
      }

      expect(inner.accessToken, isNull);
    });
  });

  group('with the secure storage vault', () {
    late MockSecureStorage storage;
    final key = SecureTokenVault.keyFor(profileId);

    setUp(() {
      storage = MockSecureStorage();
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
    });

    test('a decode error wipes at once and resets the count', () async {
      final vault = vaultFor(
        prefs,
        over: SecureTokenVault(storage: storage, profileId: profileId),
      );
      when(() => storage.read(key: key)).thenThrow(keychainLocked);
      await vault.read();
      when(() => storage.read(key: key)).thenAnswer((_) async => 'not json');

      expect(
        await vault.read(),
        isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
      );
      verify(() => storage.delete(key: key)).called(1);
      expect(VaultReadFailures(prefs, profileId: profileId).count, 0);
    });

    test('the third platform error deletes the Keychain entry', () async {
      final vault = vaultFor(
        prefs,
        over: SecureTokenVault(storage: storage, profileId: profileId),
      );
      when(() => storage.read(key: key)).thenThrow(keychainLocked);

      await vault.read();
      await vault.read();
      verifyNever(() => storage.delete(key: key));

      expect(
        await vault.read(),
        isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
      );
      verify(() => storage.delete(key: key)).called(1);
    });

    test('a wipe that fails still forces a login', () async {
      final vault = vaultFor(
        prefs,
        over: SecureTokenVault(storage: storage, profileId: profileId),
      );
      when(() => storage.read(key: key)).thenThrow(keychainLocked);
      when(() => storage.delete(key: key)).thenThrow(keychainLocked);

      await vault.read();
      await vault.read();

      expect(
        await vault.read(),
        isA<VaultAbsent>().having((r) => r.wiped, 'wiped', isTrue),
      );
    });
  });
}

final class _ThrowingVault implements TokenVault {
  @override
  Future<VaultResult> read() => throw StateError('keystore corrupted');

  @override
  Future<void> write(RefreshCookie cookie) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<PersistedAccessToken?> readAccessToken() =>
      throw StateError('keystore corrupted');

  @override
  Future<void> writeAccessToken(PersistedAccessToken token) async {}

  @override
  Future<void> clearAccessToken() async {}
}
