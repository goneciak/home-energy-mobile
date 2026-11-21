import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/appliance/data/appliance_profile_store.dart';
import 'package:gi_home/src/features/appliance/domain/appliance_profile.dart';

import '../../support/fake_core_adapter.dart';
import '../../support/test_app.dart';

ProbeResult probeAt(String address, Map<String, Object?> setup) => ProbeResult(
  address: ApplianceAddress.parse(address),
  health: const HealthLive(status: 'ok'),
  setup: SetupStatus.fromJson(setup),
);

void main() {
  group('hosts[] (plan §7.1)', () {
    test(
      'a profile stored before hosts existed loads without data loss',
      () async {
        // The exact JSON the previous app version wrote.
        const stored = {
          'profileId': '0123456789abcdef0123456789abcdef',
          'label': 'GI Home Dev',
          'baseUrl': 'http://192.168.1.20:3000',
          'deviceName': 'GI Home Dev',
          'initializedAt': '2026-11-17T22:06:20.184Z',
          'lastUserEmail': 'owner@gihome.test',
          'lastUserId': 'cmwl8s1se000680n2ryr54481',
        };
        final prefs = await inMemoryPreferences();
        await prefs.setString(
          ApplianceProfileStore.profileKey,
          jsonEncode(stored),
        );

        final profile = ApplianceProfileStore(prefs).read()!;

        expect(profile.profileId, '0123456789abcdef0123456789abcdef');
        expect(profile.label, 'GI Home Dev');
        expect(profile.baseUrl, 'http://192.168.1.20:3000');
        expect(profile.hosts, ['http://192.168.1.20:3000']);
        expect(profile.deviceName, 'GI Home Dev');
        expect(
          profile.initializedAt,
          DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
        );
        expect(profile.lastUserEmail, 'owner@gihome.test');
        expect(profile.lastUserId, 'cmwl8s1se000680n2ryr54481');
        expect(profile.cleartextNoticeShown, isFalse);
      },
    );

    test('round-trips through the store', () async {
      final prefs = await inMemoryPreferences();
      final store = ApplianceProfileStore(prefs);
      final profile = testProfile
          .movedTo('http://gi-home.local')
          .copyWith(cleartextNoticeShown: true);

      await store.write(profile);

      expect(store.read(), profile);
      expect(store.read()!.hosts, [
        'http://gi-home.local',
        'http://10.0.2.2:3000',
      ]);
    });

    test('the active address comes first, without duplicates, at most '
        '${ApplianceProfile.maxHosts}', () {
      var profile = ApplianceProfile.fromProbe(
        probeAt('192.168.1.20', initializedSetup),
      );
      expect(profile.hosts, ['http://192.168.1.20']);

      for (final host in [
        'http://192.168.1.21',
        'http://192.168.1.22',
        'http://192.168.1.20',
        'http://192.168.1.23',
        'http://192.168.1.24',
        'http://gi-home.local',
      ]) {
        profile = profile.movedTo(host);
      }

      expect(profile.baseUrl, 'http://gi-home.local');
      expect(profile.hosts, [
        'http://gi-home.local',
        'http://192.168.1.24',
        'http://192.168.1.23',
        'http://192.168.1.20',
        'http://192.168.1.22',
      ]);
    });

    test('a decoded profile always lists its baseUrl first', () {
      final profile = ApplianceProfile.fromJson({
        ...testProfile.toJson(),
        'hosts': ['http://gi-home.local', 'http://10.0.2.2:3000'],
      });

      expect(profile.hosts, ['http://10.0.2.2:3000', 'http://gi-home.local']);
    });
  });

  group('matches', () {
    test('the same fingerprint on any address is the same appliance', () {
      expect(
        testProfile.matches(probeAt('gi-home.local', initializedSetup)),
        isTrue,
      );
      expect(
        testProfile.matches(
          probeAt('10.0.2.2:3000', {
            ...initializedSetup,
            'initializedAt': '2025-01-01T00:00:00.000Z',
          }),
        ),
        isFalse,
      );
    });

    test('without a fingerprint only its own hosts match', () {
      final notSetUp = testProfile.asReset();

      expect(
        notSetUp.matches(probeAt('10.0.2.2:3000', uninitializedSetup)),
        isTrue,
      );
      expect(
        notSetUp.matches(probeAt('10.0.2.2:3000', initializedSetup)),
        isTrue,
      );
      expect(
        notSetUp.matches(probeAt('gi-home.local', uninitializedSetup)),
        isFalse,
      );
    });
  });
}
