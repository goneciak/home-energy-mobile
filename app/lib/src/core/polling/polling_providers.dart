import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/reachability_tracker.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'polling_providers.g.dart';

/// One [ReachabilityTracker] per appliance profile, so a change of address
/// (same profile) keeps the tracker and another appliance gets its own.
final class ReachabilityRegistry {
  new(this._create);

  final ReachabilityTracker Function() _create;
  final Map<String?, ReachabilityTracker> _byProfile = {};

  ReachabilityTracker of(String? profileId) =>
      _byProfile.putIfAbsent(profileId, _create);
}

@Riverpod(keepAlive: true)
ReachabilityRegistry reachabilityRegistry(Ref ref) {
  final now = ref.read(clockProvider);
  return ReachabilityRegistry(() => ReachabilityTracker(now: now));
}

/// What the pollers of the saved appliance know about reaching it together
/// (see [ReachabilityTracker]). Without a readable profile (tests, before
/// connecting) everything shares one tracker.
@Riverpod(keepAlive: true)
ReachabilityTracker applianceReachability(Ref ref) {
  String? profileId;
  try {
    profileId = ref.watch(applianceProfileProvider)?.profileId;
  } on Object {
    // Keep the shared fallback tracker.
  }
  return ref.watch(reachabilityRegistryProvider).of(profileId);
}

/// Every poller that runs in a screen's provider, so one place can refresh
/// them all after a network change. Only reads (GET) are ever polled.
final class PollCoordinator {
  final Set<ForegroundPoller> _pollers = {};

  int get length => _pollers.length;

  /// Returns the call that removes [poller] again.
  void Function() register(ForegroundPoller poller) {
    _pollers.add(poller);
    return () => _pollers.remove(poller);
  }

  /// Runs every registered poller now, forgetting its backoff. A poller
  /// that is stopped, halted or in the background ignores it.
  Future<void> refreshAll() =>
      Future.wait([for (final poller in List.of(_pollers)) poller.pollNow()]);
}

@Riverpod(keepAlive: true)
PollCoordinator pollCoordinator(Ref ref) => PollCoordinator();
