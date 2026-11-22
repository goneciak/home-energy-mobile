import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/features/devices/application/device_snapshot.dart';
import 'package:gi_home/src/features/devices/data/device_snapshot_store.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage;

/// Persistent device list snapshot (plan §8.3): restore and wipe.
void main() {
  const profile = 'p1';
  late Map<String, String> secrets;
  late MockSecureStorage storage;
  late SecureDeviceSnapshotStore store;
  final savedAt = DateTime(2026, 11, 22, 7, 41);

  DeviceSnapshot snapshotOf(String userId) => DeviceSnapshot(
    userId: userId,
    devices: Fetched(fixtureDevices(), savedAt),
  );

  setUp(() {
    secrets = {};
    storage = MockSecureStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((i) async => secrets[i.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((i) async {
      secrets[i.namedArguments[#key] as String] =
          i.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((i) async => secrets.remove(i.namedArguments[#key]));
    when(storage.readAll).thenAnswer((_) async => {...secrets});
    store = SecureDeviceSnapshotStore(storage);
  });

  test('a written snapshot is restored for the same profile and user, '
      'with its age', () async {
    await store.write(profile, snapshotOf('u1'));

    final restored = await store.read(profileId: profile, userId: 'u1');

    expect(restored!.devices.fetchedAt, savedAt);
    expect(
      restored.devices.value.map((d) => d.id),
      fixtureDevices().map((d) => d.id),
    );
    expect(await store.read(profileId: profile, userId: 'u2'), isNull);
    expect(await store.read(profileId: 'p2', userId: 'u1'), isNull);
  });

  test('wipe removes every user of the profile and nothing else', () async {
    await store.write(profile, snapshotOf('u1'));
    await store.write(profile, snapshotOf('u2'));
    await store.write('p2', snapshotOf('u1'));
    secrets['p/$profile/rt'] = 'cookie';

    await store.wipe(profile);

    expect(secrets.keys, {'p/$profile/rt', 'p/p2/snap/u1'});
  });

  test('an unreadable entry is removed and gives no snapshot', () async {
    secrets[SecureDeviceSnapshotStore.keyFor(profile, 'u1')] = '{"v":99}';

    expect(await store.read(profileId: profile, userId: 'u1'), isNull);
    expect(secrets, isEmpty);
  });

  test('storage failures never throw', () async {
    when(() => storage.read(key: any(named: 'key'))).thenThrow(Exception());
    when(storage.readAll).thenThrow(Exception());

    expect(await store.read(profileId: profile, userId: 'u1'), isNull);
    await store.wipe(profile);
  });

  test('the keeper skips writing an unchanged list', () async {
    final keeper = DeviceSnapshotKeeper(store);
    final devices = Fetched<List<DeviceListItem>>(fixtureDevices(), savedAt);

    await keeper.save(profileId: profile, userId: 'u1', devices: devices);
    await keeper.save(profileId: profile, userId: 'u1', devices: devices);

    verify(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).called(1);

    await keeper.wipe(profile);
    expect(await keeper.restore(profileId: profile, userId: 'u1'), isNull);
  });
}
