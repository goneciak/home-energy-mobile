import 'package:gi_core_api/gi_core_api.dart';

/// What a [DeviceGroup] on Home stands for.
enum DeviceGroupKind {
  /// Devices of one room.
  room,

  /// Devices without a (known) room: "Bez pokoju".
  unassigned,

  /// Every device, because the rooms could not be loaded.
  all,
}

/// Devices shown under one heading on Home.
final class DeviceGroup {
  const new room(Room this.room, this.devices) : kind = DeviceGroupKind.room;

  const new unassigned(this.devices)
    : kind = DeviceGroupKind.unassigned,
      room = null;

  const new all(this.devices) : kind = DeviceGroupKind.all, room = null;

  final DeviceGroupKind kind;
  final Room? room;
  final List<DeviceListItem> devices;
}

/// Groups [devices] by room in the order of [rooms] (already sorted by
/// `sortOrder`), then devices without a known room. Rooms without devices
/// are left out. When [rooms] is `null` (not loaded), a single
/// [DeviceGroupKind.all] group holds every device rather than wrongly
/// putting them all under "Bez pokoju".
///
/// Within a group heating devices come first, then by name.
List<DeviceGroup> groupDevicesByRoom(
  List<DeviceListItem> devices,
  List<Room>? rooms,
) {
  if (devices.isEmpty) return const [];
  if (rooms == null) return [DeviceGroup.all(_sorted(devices))];

  final byRoom = <String, List<DeviceListItem>>{};
  final unassigned = <DeviceListItem>[];
  final roomIds = {for (final room in rooms) room.id};
  for (final device in devices) {
    final roomId = device.roomId;
    if (roomId != null && roomIds.contains(roomId)) {
      (byRoom[roomId] ??= []).add(device);
    } else {
      unassigned.add(device);
    }
  }
  return [
    for (final room in rooms)
      if (byRoom[room.id] case final roomDevices?)
        DeviceGroup.room(room, _sorted(roomDevices)),
    if (unassigned.isNotEmpty) DeviceGroup.unassigned(_sorted(unassigned)),
  ];
}

List<DeviceListItem> _sorted(List<DeviceListItem> devices) =>
    List.unmodifiable(<DeviceListItem>[...devices]..sort(_compareDevices));

int _compareDevices(DeviceListItem a, DeviceListItem b) {
  if (a.isHeating != b.isHeating) return a.isHeating ? -1 : 1;
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}
