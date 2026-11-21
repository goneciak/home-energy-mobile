import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/account/data/session_locale_store.dart';
import 'package:gi_home/src/features/account/domain/app_locale.dart';

import '../../support/test_app.dart';

/// Language from the GI Core profile (plan §13.2).
void main() {
  group('supportedAppLocale', () {
    test('maps GI Core locales to the app languages', () {
      expect(supportedAppLocale('pl-PL'), const Locale('pl'));
      expect(supportedAppLocale('en-US'), const Locale('en'));
      expect(supportedAppLocale('en_GB'), const Locale('en'));
      expect(supportedAppLocale(' EN '), const Locale('en'));
    });

    test('a missing or unsupported locale means the phone language', () {
      for (final tag in [null, '', '  ', 'de-DE', 'pt']) {
        expect(supportedAppLocale(tag), isNull, reason: '$tag');
      }
    });
  });

  group('SessionLocaleStore', () {
    late SessionLocaleStore store;

    setUp(() async => store = SessionLocaleStore(await inMemoryPreferences()));

    test('keeps the language of one user on one appliance', () async {
      await store.write(profileId: 'p1', userId: 'u1', languageCode: 'en');

      expect(store.read(profileId: 'p1', userId: 'u1'), 'en');
      expect(store.read(profileId: 'p1', userId: 'u2'), isNull);
      expect(store.read(profileId: 'p2', userId: 'u1'), isNull);
    });

    test('no supported language removes it, and so does clear', () async {
      await store.write(profileId: 'p1', userId: 'u1', languageCode: 'en');
      await store.write(profileId: 'p1', userId: 'u1', languageCode: null);
      expect(store.read(profileId: 'p1', userId: 'u1'), isNull);

      await store.write(profileId: 'p1', userId: 'u1', languageCode: 'pl');
      await store.clear();
      expect(store.read(profileId: 'p1', userId: 'u1'), isNull);
    });
  });
}
