import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/data/devices_repository.dart';
import 'package:gi_home/src/features/devices/data/rooms_repository.dart';

import '../../support/fake_device_source.dart';
import '../../support/fixtures.dart';

void main() {
  late FakeDeviceSource source;
  late DateTime now;
  DateTime clock() => now;

  setUp(() {
    now = DateTime.utc(2026, 11, 18, 7, 41);
    source = FakeDeviceSource(
      deviceList: fixtureDevices(),
      roomList: fixtureRooms(),
      details: {fixtureDetail().id: fixtureDetail()},
    );
  });

  group('DevicesRepository', () {
    late DevicesRepository repository;

    setUp(() => repository = DevicesRepository(source, clock: clock));

    test('keeps the last good list with the time it arrived', () async {
      expect(repository.lastDevices, isNull);

      final fetched = await repository.fetchDevices();

      expect(fetched.value, hasLength(3));
      expect(fetched.fetchedAt, now);
      expect(repository.lastDevices, same(fetched));
      expect(fetched.value.clear, throwsUnsupportedError);
    });

    test('a failed refresh keeps the previous list', () async {
      final good = await repository.fetchDevices();
      source.devicesFailure = const ApiFailure.unreachable();
      now = now.add(const Duration(minutes: 1));

      await expectLater(
        repository.fetchDevices(),
        throwsA(isA<UnreachableFailure>()),
      );
      expect(repository.lastDevices, same(good));
    });

    test('details are cached per device and kept on failure', () async {
      final id = fixtureDetail().id;
      final good = await repository.fetchDevice(id);
      source.detailFailure = const ApiFailure.timeout();

      await expectLater(
        repository.fetchDevice(id),
        throwsA(isA<TimeoutFailure>()),
      );
      expect(repository.lastDevice(id), same(good));
      expect(repository.lastDevice('other'), isNull);
    });

    test('a device that no longer exists is dropped from the cache', () async {
      final id = fixtureDetail().id;
      await repository.fetchDevice(id);
      source.details.clear();

      await expectLater(
        repository.fetchDevice(id),
        throwsA(isA<NotFoundFailure>()),
      );
      expect(repository.lastDevice(id), isNull);
    });

    test('clear forgets everything', () async {
      await repository.fetchDevices();
      await repository.fetchDevice(fixtureDetail().id);

      repository.clear();

      expect(repository.lastDevices, isNull);
      expect(repository.lastDevice(fixtureDetail().id), isNull);
    });
  });

  group('RoomsRepository', () {
    late RoomsRepository repository;

    setUp(() => repository = RoomsRepository(source, clock: clock));

    test('rooms are ordered by sortOrder, then name', () async {
      source.roomList = [
        for (final (id, name, order) in [
          ('r1', 'salon', 2),
          ('r2', 'Biuro', 1),
          ('r3', 'Antresola', 2),
        ])
          Room(
            id: id,
            name: name,
            sortOrder: order,
            createdAt: now,
            updatedAt: now,
          ),
      ];

      final fetched = await repository.fetchRooms();

      expect(
        [for (final r in fetched.value) r.name],
        ['Biuro', 'Antresola', 'salon'],
      );
      expect(fetched.fetchedAt, now);
    });

    test(
      'a failed refresh keeps the previous rooms; clear drops them',
      () async {
        final good = await repository.fetchRooms();
        source.roomsFailure = const ApiFailure.server(statusCode: 503);

        await expectLater(
          repository.fetchRooms(),
          throwsA(isA<ServerFailure>()),
        );
        expect(repository.lastRooms, same(good));

        repository.clear();
        expect(repository.lastRooms, isNull);
      },
    );
  });
}
