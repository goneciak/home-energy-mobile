import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/lifecycle/app_foreground.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/core/polling/foreground_poller.dart';
import 'package:gi_home/src/core/polling/polling_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

extension RefPolling on Ref {
  /// Runs [task] now and then every [interval] for as long as this provider
  /// lives, but only while the app is in the foreground AND at least one
  /// listener of the provider is active.
  ///
  /// Riverpod pauses the subscriptions of widgets that are not visible (a
  /// covered route, an inactive tab), which pauses this provider and stops
  /// polling; becoming visible again resumes it with one run after a short
  /// jitter (plan §11). The first run starts right after the provider's
  /// build, so [task] may set the provider's state. The poller measures
  /// time on [clockProvider], like the screens.
  ///
  /// The poller shares its backoff with every other poller of the appliance
  /// ([applianceReachabilityProvider]) and is refreshed with them after a
  /// network change ([pollCoordinatorProvider]). While another poller probes
  /// an unreachable appliance this one sends nothing and hands the shared
  /// error to [onSharedFailure] instead, to publish like its own failure.
  /// [phase] offsets the poller within its cadence ([ForegroundPoller]).
  ForegroundPoller pollWhileWatched({
    required Duration interval,
    required Future<void> Function() task,
    void Function(Object error)? onSharedFailure,
    Duration phase = Duration.zero,
  }) {
    final active = _PollingActivity(watch(appForegroundProvider));
    final poller = ForegroundPoller(
      foreground: active,
      interval: interval,
      phase: phase,
      task: task,
      onSharedFailure: onSharedFailure,
      reachability: read(applianceReachabilityProvider),
      now: read(clockProvider),
    );
    onDispose(read(pollCoordinatorProvider).register(poller));
    // A dependent provider that rebuilds drops its subscription and adds it
    // back on the scheduler's next flush, which fires onCancel and then
    // onResume. Only a provider still paused once pending rebuilds are done
    // counts as unwatched; otherwise every rebuild would restart polling.
    onCancel(
      () => scheduleMicrotask(() async {
        if (!mounted) return;
        await container.pump();
        if (mounted && isPaused) active.watched = false;
      }),
    );
    onResume(() => active.watched = true);
    onDispose(() {
      poller.dispose();
      active.dispose();
    });
    scheduleMicrotask(() {
      if (mounted) poller.start();
    });
    return poller;
  }
}

/// `true` while the app is in the foreground and the provider is watched.
class _PollingActivity extends ValueNotifier<bool> {
  new(this._foreground) : super(_foreground.value) {
    _foreground.addListener(_update);
  }

  final ValueListenable<bool> _foreground;
  bool _watched = true;

  bool get watched => _watched;

  set watched(bool watched) {
    _watched = watched;
    _update();
  }

  void _update() => value = _foreground.value && _watched;

  @override
  void dispose() {
    _foreground.removeListener(_update);
    super.dispose();
  }
}
