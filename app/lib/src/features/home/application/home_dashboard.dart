import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/devices/application/device_list_notifier.dart';
import 'package:gi_home/src/features/devices/application/rooms_notifier.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/home/application/heating_card_notifier.dart';
import 'package:gi_home/src/features/home/domain/device_groups.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_dashboard.g.dart';

/// Everything the Home screen shows, derived from the device list, the
/// rooms and the latest results of the heating cards on screen.
/// Re-evaluated on every list or card state change (each poll marks its
/// data as refreshing first), so ages and the "outdated" rule use a current
/// clock.
final class HomeDashboard {
  const new({
    required this.devices,
    required this.rooms,
    required this.now,
    required this.condition,
    required this.groups,
    this.heatingCards = const {},
  });

  final PolledData<List<DeviceListItem>> devices;
  final PolledData<List<Room>> rooms;
  final DateTime now;

  /// `null` until the first device list arrives.
  final HomeCondition? condition;

  final List<DeviceGroup> groups;

  /// Latest card state of the enabled heating devices of the list whose
  /// card has been on screen, by id (see [hasHeatingCard]). Only the card
  /// widgets poll; this map is read-only and never keeps a card polling
  /// (plan §4.1, §11).
  final Map<String, PolledData<DeviceDetail>> heatingCards;

  /// Last list is older than twice the polling interval.
  bool get isStale => switch (devices.data) {
    final data? => FreshnessPolicy.deviceList.isStale(data.fetchedAt, now),
    null => false,
  };

  /// Room name of [roomId], when the rooms are known.
  String? roomName(String? roomId) {
    if (roomId == null) return null;
    for (final room in rooms.data?.value ?? const <Room>[]) {
      if (room.id == roomId) return room.name;
    }
    return null;
  }
}

@riverpod
HomeDashboard homeDashboard(Ref ref) {
  final devices = ref.watch(deviceListProvider);
  final rooms = ref.watch(roomsProvider);
  final now = ref.watch(clockProvider)();
  final data = devices.data;
  // Not `heatingCardProvider`: watching it here would poll every card,
  // also those out of view (plan §11 load budget).
  final results = ref.watch(heatingCardResultsProvider);
  final heatingCards = {
    for (final device in data?.value ?? const <DeviceListItem>[])
      if (hasHeatingCard(device)) device.id: ?results[device.id],
  };
  return HomeDashboard(
    devices: devices,
    rooms: rooms,
    now: now,
    condition: data == null
        ? null
        : HomeCondition.evaluate(
            data,
            now: now,
            refreshFailed: devices.error != null,
            heatingCards: heatingCards,
          ),
    groups: data == null
        ? const []
        : groupDevicesByRoom(data.value, rooms.data?.value),
    heatingCards: heatingCards,
  );
}

/// Enabled heating devices (recognised from the list) get a card; disabled
/// ones are shown, but not polled.
bool hasHeatingCard(DeviceListItem device) =>
    device.enabled && device.isHeating;
