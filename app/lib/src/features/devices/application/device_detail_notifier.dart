import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/idle_tracker.dart';
import 'package:gi_home/src/core/polling/ref_polling.dart';
import 'package:gi_home/src/features/devices/application/device_repositories.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_detail_notifier.g.dart';

/// `GET /devices/:id`, polled while the device details screen is visible
/// and the app is in the foreground (plan §11): every 5 s, and every 15 s
/// once the user has not touched or scrolled the screen for 2 min (the
/// screen reports interaction with [userActive]); the next interaction
/// brings the 5 s cadence back at once.
///
/// Polling stops once the device is gone (404) or the role may not read it
/// (403, plan §7.5: no request every few seconds that can only fail); only
/// an explicit [refresh] asks again.
@riverpod
class DeviceDetailNotifier extends _$DeviceDetailNotifier {
  late ForegroundPoller _poller;
  late IdleTracker _idle;
  DateTime? _activeSince;

  @override
  PolledData<DeviceDetail> build(String deviceId) {
    final repository = ref.watch(devicesRepositoryProvider);
    final now = ref.read(clockProvider);
    // A result of an earlier build (another repository) is never committed.
    final buildRef = ref;
    late final ForegroundPoller poller;
    poller = _poller = ref.pollWhileWatched(
      interval: FreshnessPolicy.deviceDetail.interval,
      task: () async {
        state = state.refreshing();
        try {
          final detail = await repository.fetchDevice(deviceId);
          if (buildRef.mounted) state = state.succeeded(detail);
        } on NotFoundFailure catch (error) {
          // The device is gone: drop what was shown instead of keeping it,
          // and stop asking for it.
          if (buildRef.mounted) state = PolledData(error: error);
          poller.halt();
        } on ForbiddenFailure catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          poller.halt();
        } on Object catch (error) {
          if (buildRef.mounted) state = state.failed(error);
          rethrow;
        }
      },
    );
    _activeSince = null;
    final idle = _idle = IdleTracker(
      idleAfter: FreshnessPolicy.deviceDetailIdleAfter,
      now: now,
    );
    idle.addListener(() {
      if (!idle.isIdle) _activeSince = now();
      poller.interval = idle.isIdle
          ? FreshnessPolicy.deviceDetailIdle.interval
          : FreshnessPolicy.deviceDetail.interval;
    });
    ref.onDispose(idle.dispose);
    return PolledData(
      data: repository.lastDevice(deviceId),
      isRefreshing: true,
    );
  }

  /// Pull-to-refresh and "Try again"; joins a refresh already running.
  Future<void> refresh() => _poller.refresh();

  /// The user touched or scrolled the details screen.
  void userActive() => _idle.touch();

  /// The policy that decides whether details received at [fetchedAt] are
  /// outdated: the idle one while idle, and for details still from the idle
  /// cadence right after the user came back (until the at-once refresh
  /// arrives), so coming back never flashes a "may be outdated" banner.
  FreshnessPolicy freshnessOf(DateTime fetchedAt) {
    final activeSince = _activeSince;
    final fromIdleCadence =
        _idle.isIdle ||
        (activeSince != null && fetchedAt.isBefore(activeSince));
    return fromIdleCadence
        ? FreshnessPolicy.deviceDetailIdle
        : FreshnessPolicy.deviceDetail;
  }
}
