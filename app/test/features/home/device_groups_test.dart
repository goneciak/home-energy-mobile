import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/data/rooms_repository.dart';
import 'package:gi_home/src/features/home/domain/device_groups.dart';

import '../../support/fixtures.dart';

void main() {
  List<String> titles(List<DeviceGroup> groups) => [
    for (final group in groups)
      switch (group.kind) {
        DeviceGroupKind.room => group.room!.name,
        DeviceGroupKind.unassigned => '(no room)',
        DeviceGroupKind.all => '(all)',
      },
  ];

  List<List<String>> names(List<DeviceGroup> groups) => [
    for (final group in groups) [for (final d in group.devices) d.name],
  ];

  test('recorded devices are grouped by the recorded rooms', () {
    final rooms = [...fixtureRooms()]..sort(RoomsRepository.compareRooms);

    final groups = groupDevicesByRoom(fixtureDevices(), rooms);

    expect(titles(groups), ['Kotłownia', 'Salon', '(no room)']);
    expect(names(groups), [
      ['Sterownik kotłowni'],
      ['Lampa w salonie'],
      ['Czujnik bez pokoju'],
    ]);
  });

  test('rooms keep their order, empty rooms are left out', () {
    final rooms = [
      Room.fromJson({..._room('r2', 'B'), 'sortOrder': 1}),
      Room.fromJson({..._room('r1', 'A'), 'sortOrder': 2}),
      Room.fromJson(_room('r3', 'Empty')),
    ];
    final devices = [
      listedDevice({'id': 'd1', 'name': 'one', 'roomId': 'r1'}),
      listedDevice({'id': 'd2', 'name': 'two', 'roomId': 'r2'}),
    ];

    expect(titles(groupDevicesByRoom(devices, rooms)), ['B', 'A']);
  });

  test('a device in an unknown room goes to "no room"', () {
    final groups = groupDevicesByRoom([
      listedDevice({'id': 'd1', 'name': 'one', 'roomId': 'deleted-room'}),
    ], fixtureRooms());

    expect(titles(groups), ['(no room)']);
  });

  test('without rooms all devices form one group', () {
    final groups = groupDevicesByRoom(fixtureDevices(), null);

    expect(titles(groups), ['(all)']);
    expect(groups.single.devices, hasLength(3));
  });

  test('heating devices first, then by name', () {
    final groups = groupDevicesByRoom([
      listedDevice({'id': 'd1', 'name': 'beta'}),
      listedDevice({'id': 'd2', 'name': 'Alfa'}),
      listedDevice({'id': 'd3', 'name': 'zeta', 'heatingRelayEntityId': 'r'}),
    ], const []);

    expect(names(groups), [
      ['zeta', 'Alfa', 'beta'],
    ]);
  });

  test('no devices, no groups', () {
    expect(groupDevicesByRoom(const [], fixtureRooms()), isEmpty);
  });
}

Map<String, Object?> _room(String id, String name) => {
  'id': id,
  'name': name,
  'description': null,
  'sortOrder': 0,
  'createdAt': '2026-11-17T22:06:20.443Z',
  'updatedAt': '2026-11-17T22:06:20.443Z',
};
