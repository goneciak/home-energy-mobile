import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/ref_polling.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_list_notifier.g.dart';

/// `GET /devices`, polled every 30 s while Home or device details are
/// visible and the app is in the foreground (plan §11). It is the shared
/// source of status, faults, heating and dry-run flags.
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
      task: () async {
        state = state.refreshing();
        try {
          final devices = await repository.fetchDevices();
          if (buildRef.mounted) state = state.succeeded(devices);
        } on ForbiddenFailure catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          poller.halt();
        } on Object catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          rethrow;
        }
      },
    );
    return PolledData(data: repository.lastDevices, isRefreshing: true);
  }

  /// Pull-to-refresh and "Try again"; joins a refresh already running.
  Future<void> refresh() => _poller.refresh();
}
