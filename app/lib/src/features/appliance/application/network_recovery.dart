import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/network_change_source.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/polling_providers.dart';
import 'package:gi_home/src/features/appliance/application/appliance_profile_notifier.dart';
import 'package:gi_home/src/features/appliance/application/appliance_rebinder.dart';
import 'package:gi_home/src/features/demo/application/demo_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_recovery.g.dart';

/// Reacts to the phone changing network (Wi-Fi to mobile, another Wi-Fi,
/// back online) and to the app returning to the foreground, so the app finds
/// its appliance again without waiting for a backoff to run out.
///
/// After a change that settled for [debounce]:
/// 1. the backoff is forgotten ([resetReachability]) and every poller runs
///    now ([refreshPollers], reads only);
/// 2. in parallel the saved appliance is looked for under its new address
///    ([rebind], reads only, fingerprint-checked, never for `https`).
///
/// On the return to the foreground the backoff is forgotten and the pollers
/// refresh themselves. The appliance is also looked for whenever the pollers
/// find it unreachable ([unreachable]), at most once per [searchEvery]: that
/// covers a new address after a router restart, which no network event
/// announces.
///
/// Nothing here sends a write, ever: a command that was in flight when the
/// network changed is not repeated, its outcome is read from the device.
final class NetworkRecovery {
  new({
    required this.changes,
    required this.foreground,
    required this.isActive,
    required this.resetReachability,
    required this.refreshPollers,
    required this.rebind,
    this.unreachable,
    this.debounce = const Duration(milliseconds: 500),
    this.searchEvery = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Stream<NetworkState> changes;
  final ValueListenable<bool> foreground;

  /// Whether there is an appliance to recover (not in demo mode, a profile
  /// that is set up).
  final bool Function() isActive;
  final void Function() resetReachability;
  final Future<void> Function() refreshPollers;
  final Future<bool> Function() rebind;
  final Duration debounce;

  /// Told when the pollers met an unreachable appliance.
  final Listenable? unreachable;

  /// The shortest time between searches started by [unreachable].
  final Duration searchEvery;
  final DateTime Function() _now;
  DateTime? _lastSearch;

  StreamSubscription<NetworkState>? _subscription;
  Timer? _debounce;
  NetworkState? _last;
  late bool _wasForeground;
  bool _started = false;
  bool _disposed = false;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    _wasForeground = foreground.value;
    foreground.addListener(_onForegroundChanged);
    unreachable?.addListener(_onUnreachable);
    _subscription = changes.listen(_onChange, onError: (Object _) {});
  }

  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    unawaited(_subscription?.cancel());
    if (_started) {
      foreground.removeListener(_onForegroundChanged);
      unreachable?.removeListener(_onUnreachable);
    }
  }

  void _onChange(NetworkState state) {
    _last = state;
    _debounce?.cancel();
    _debounce = Timer(debounce, _recover);
  }

  void _recover() {
    if (_disposed || !isActive() || _last?.isConnected == false) return;
    resetReachability();
    unawaited(refreshPollers().then<void>((_) {}, onError: (Object _) {}));
    unawaited(rebind().then<void>((_) {}, onError: (Object _) {}));
  }

  void _onForegroundChanged() {
    final resumed = foreground.value && !_wasForeground;
    _wasForeground = foreground.value;
    if (!resumed || _disposed || !isActive()) return;
    // The pollers run again on their own; if they find the appliance gone,
    // [unreachable] starts the search.
    resetReachability();
  }

  void _onUnreachable() {
    if (_disposed || !foreground.value || !isActive()) return;
    final last = _lastSearch;
    final now = _now();
    if (last != null && now.difference(last) < searchEvery) return;
    _lastSearch = now;
    unawaited(rebind().then<void>((_) {}, onError: (Object _) {}));
  }
}

/// Started by the app root and kept alive for the session.
@Riverpod(keepAlive: true)
NetworkRecovery networkRecovery(Ref ref) {
  final recovery = NetworkRecovery(
    changes: ref.watch(networkChangeSourceProvider).changes,
    foreground: ref.watch(appForegroundProvider),
    isActive: () =>
        ref.read(demoModeProvider) == null &&
        ref.read(applianceProfileProvider)?.isInitialized == true,
    resetReachability: () => ref.read(applianceReachabilityProvider).reset(),
    refreshPollers: () => ref.read(pollCoordinatorProvider).refreshAll(),
    rebind: () => ref.read(applianceRebinderProvider).rebindIfMoved(),
    unreachable: ref.read(applianceReachabilityProvider).onFailure,
    now: ref.read(clockProvider),
  )..start();
  ref.onDispose(recovery.dispose);
  return recovery;
}
