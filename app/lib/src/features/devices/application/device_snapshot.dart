import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/data/device_snapshot_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_snapshot.g.dart';

/// Where the device list snapshot is kept: secure storage, or memory in demo
/// mode (the demo never writes anything real).
@Riverpod(keepAlive: true)
DeviceSnapshotStore deviceSnapshotStore(Ref ref) =>
    ref.watch(demoModeProvider) != null
    ? MemoryDeviceSnapshotStore()
    : SecureDeviceSnapshotStore(ref.watch(secureStorageProvider));

/// Keeps the persistent snapshot of the device list in step with the
/// session (plan §8.3): saved after each good list, restored for a cold
/// start, wiped on logout, on a user change and when the session ends or
/// is lost (`AuthSessionNotifier`).
@Riverpod(keepAlive: true)
DeviceSnapshotKeeper deviceSnapshotKeeper(Ref ref) =>
    DeviceSnapshotKeeper(ref.watch(deviceSnapshotStoreProvider));

/// See [deviceSnapshotKeeper].
final class DeviceSnapshotKeeper {
  new(this._store);

  final DeviceSnapshotStore _store;
  String? _lastWritten;

  /// Saves [devices] for [userId] of [profileId] unless it is what was
  /// saved last (each poll re-sends mostly the same list).
  Future<void> save({
    required String profileId,
    required String userId,
    required Fetched<List<DeviceListItem>> devices,
  }) async {
    final snapshot = DeviceSnapshot(userId: userId, devices: devices);
    final content = jsonEncode([
      profileId,
      userId,
      for (final device in devices.value) device.toJson(),
    ]);
    if (content == _lastWritten) return;
    _lastWritten = content;
    await _store.write(profileId, snapshot);
  }

  Future<DeviceSnapshot?> restore({
    required String profileId,
    required String userId,
  }) => _store.read(profileId: profileId, userId: userId);

  /// Removes every snapshot of [profileId].
  Future<void> wipe(String profileId) async {
    _lastWritten = null;
    await _store.wipe(profileId);
  }
}

/// The snapshot a cold start without a connection can show: the one of the
/// profile's last signed-in user (plan §8.3), or `null`.
@riverpod
Future<DeviceSnapshot?> offlineSnapshot(Ref ref) async {
  final profile = ref.watch(applianceProfileProvider);
  final userId = profile?.lastUserId;
  if (profile == null || userId == null) return null;
  return await ref
      .watch(deviceSnapshotKeeperProvider)
      .restore(profileId: profile.profileId, userId: userId);
}

/// The latest device list known to the app, without polling for it: set by
/// the device list poll (and its snapshot seed), cleared with the session.
/// The "Uwaga" badge reads it so that the tab bar alone never keeps the
/// list polling (plan §11 load budget).
@Riverpod(keepAlive: true)
class LastDeviceList extends _$LastDeviceList {
  @override
  Fetched<List<DeviceListItem>>? build() {
    // A new appliance, client or user starts empty.
    ref
      ..watch(devicesRepositoryProvider)
      ..watch(currentUserProvider.select((user) => user?.id));
    return null;
  }

  // A setter would hide that this publishes to every listener.
  // ignore: use_setters_to_change_properties
  void publish(Fetched<List<DeviceListItem>> devices) => state = devices;
}
