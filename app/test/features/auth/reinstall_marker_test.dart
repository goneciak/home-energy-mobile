import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/auth/data/reinstall_marker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/test_app.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

/// Reinstall detection of plan §7.1.
void main() {
  late MockSecureStorage storage;
  late SharedPreferencesWithCache prefs;

  setUp(() async {
    storage = MockSecureStorage();
    prefs = await inMemoryPreferences();
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    when(storage.deleteAll).thenAnswer((_) async {});
  });

  test('a fresh install wipes profile entries left in the Keychain', () async {
    when(storage.readAll).thenAnswer(
      (_) async => {
        'p/old-profile/rt': '{"name":"gi_refresh_token"}',
        'p/old-profile/at': '{"token":"t","expiresAt":"2026-11-17T22:15:00Z"}',
        'p/other/rt': '{}',
        'unrelated': 'x',
      },
    );

    final wiped = await ReinstallMarker(
      prefs,
      storage,
    ).check(hasProfile: false);

    expect(wiped, isTrue);
    verify(() => storage.delete(key: 'p/old-profile/rt')).called(1);
    // The persisted access token (D3) goes with the cookie.
    verify(() => storage.delete(key: 'p/old-profile/at')).called(1);
    verify(() => storage.delete(key: 'p/other/rt')).called(1);
    verifyNever(() => storage.delete(key: 'unrelated'));
    expect(prefs.getBool(ReinstallMarker.key), isTrue);
  });

  test('with the marker set nothing is wiped', () async {
    await prefs.setBool(ReinstallMarker.key, true);

    final wiped = await ReinstallMarker(
      prefs,
      storage,
    ).check(hasProfile: false);

    expect(wiped, isFalse);
    verifyNever(storage.readAll);
    verifyNever(() => storage.delete(key: any(named: 'key')));
  });

  test('the second start after a reinstall keeps the new session', () async {
    when(storage.readAll).thenAnswer((_) async => {'p/old/rt': '{}'});
    await ReinstallMarker(prefs, storage).check(hasProfile: false);
    clearInteractions(storage);

    final wiped = await ReinstallMarker(prefs, storage).check(hasProfile: true);

    expect(wiped, isFalse);
    verifyNever(storage.readAll);
  });

  test('an existing profile without the marker is an update, not a '
      'reinstall', () async {
    final wiped = await ReinstallMarker(prefs, storage).check(hasProfile: true);

    expect(wiped, isFalse);
    verifyNever(storage.readAll);
    expect(prefs.getBool(ReinstallMarker.key), isTrue);
  });

  test('a store that cannot be listed is cleared entirely', () async {
    when(storage.readAll).thenThrow(PlatformException(code: 'KeystoreError'));

    final wiped = await ReinstallMarker(
      prefs,
      storage,
    ).check(hasProfile: false);

    expect(wiped, isTrue);
    verify(storage.deleteAll).called(1);
    expect(prefs.getBool(ReinstallMarker.key), isTrue);
  });

  test('a store that cannot be wiped still gets the marker', () async {
    when(storage.readAll).thenThrow(PlatformException(code: 'KeystoreError'));
    when(storage.deleteAll).thenThrow(PlatformException(code: 'KeystoreError'));

    final wiped = await ReinstallMarker(
      prefs,
      storage,
    ).check(hasProfile: false);

    expect(wiped, isFalse);
    expect(prefs.getBool(ReinstallMarker.key), isTrue);
  });
}
