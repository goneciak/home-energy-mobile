import 'dart:async';

import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/ref_polling.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/application/device_snapshot.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_list_notifier.g.dart';

/// `GET /devices`, polled every 30 s while Home or device details are
/// visible and the app is in the foreground (plan §11). It is the shared
/// source of status, faults, heating and dry-run flags.
///
/// Every good list is published to [lastDeviceListProvider] and saved as
/// the persistent snapshot (plan §8.3). Before the first list of a cold
/// start, that snapshot (of the same profile and user) is shown, with its
/// age; it is never written back as fresh.
///
/// A 403 stops the cadence (plan §7.5: the role may not read the list, so
/// asking again every 30 s could only fail); pull-to-refresh asks again.
@riverpod
class DeviceListNotifier extends _$DeviceListNotifier {
  late ForegroundPoller _poller;

  @override
  PolledData<List<DeviceListItem>> build() {
    final repository = ref.watch(devicesRepositoryProvider);
    // A result of an earlier build (another repository) is never committed.
    final buildRef = ref;
    late final ForegroundPoller poller;
    poller = _poller = ref.pollWhileWatched(
      interval: FreshnessPolicy.deviceList.interval,
      onSharedFailure: (error) {
        if (buildRef.mounted) state = state.failed(error);
      },
      task: () async {
        state = state.refreshing();
        try {
          final devices = await repository.fetchDevices();
          if (buildRef.mounted) {
            state = state.succeeded(devices);
            _keep(devices);
          }
        } on ForbiddenFailure catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          poller.halt();
        } on Object catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          rethrow;
        }
      },
    );
    final last = repository.lastDevices;
    if (last == null) unawaited(_seedFromSnapshot());
    return PolledData(data: last, isRefreshing: true);
  }

  ({String profileId, String userId})? get _owner {
    // Signed out (or in tests without a user): nothing to keep.
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return null;
    final String? profileId;
    try {
      profileId = ref.read(applianceProfileProvider)?.profileId;
    } on Object {
      // The snapshot is best effort; without a readable profile (e.g. a
      // screen hosted without preferences) the list works as before.
      return null;
    }
    if (profileId == null) return null;
    return (profileId: profileId, userId: userId);
  }

  void _keep(Fetched<List<DeviceListItem>> devices) {
    ref.read(lastDeviceListProvider.notifier).publish(devices);
    if (_owner case final owner?) {
      unawaited(
        ref
            .read(deviceSnapshotKeeperProvider)
            .save(
              profileId: owner.profileId,
              userId: owner.userId,
              devices: devices,
            ),
      );
    }
  }

  Future<void> _seedFromSnapshot() async {
    final owner = _owner;
    if (owner == null) return;
    final buildRef = ref;
    final snapshot = await ref
        .read(deviceSnapshotKeeperProvider)
        .restore(profileId: owner.profileId, userId: owner.userId);
    if (snapshot == null || !buildRef.mounted || state.hasData) return;
    state = PolledData(
      data: snapshot.devices,
      error: state.error,
      isRefreshing: state.isRefreshing,
    );
    if (ref.read(lastDeviceListProvider) == null) {
      ref.read(lastDeviceListProvider.notifier).publish(snapshot.devices);
    }
  }

  /// Pull-to-refresh and "Try again"; joins a refresh already running.
  Future<void> refresh() => _poller.refresh();
}
