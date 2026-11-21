import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_foreground.g.dart';

/// Whether the app is in the foreground, driven by [AppLifecycleListener].
///
/// `resumed` and `inactive` (still visible, e.g. Control Center pulled down)
/// count as foreground; `hidden`, `paused` and `detached` do not. Polling and
/// session refreshes wait for the foreground (plan §7.4, §11).
class AppForeground extends ValueNotifier<bool> {
  new({bool initiallyForeground = true}) : super(initiallyForeground);

  /// Follows the app lifecycle of the running [WidgetsBinding].
  factory fromBinding() {
    final initial = WidgetsBinding.instance.lifecycleState;
    final foreground = AppForeground(
      initiallyForeground: initial == null || isForegroundState(initial),
    );
    foreground._listener = AppLifecycleListener(
      onStateChange: foreground.update,
    );
    return foreground;
  }

  AppLifecycleListener? _listener;

  static bool isForegroundState(AppLifecycleState state) =>
      state == AppLifecycleState.resumed || state == AppLifecycleState.inactive;

  void update(AppLifecycleState state) => value = isForegroundState(state);

  /// Completes immediately in the foreground, otherwise on the next return
  /// to it.
  Future<void> untilForeground() {
    if (value) return Future.value();
    final completer = Completer<void>();
    void check() {
      if (!value) return;
      removeListener(check);
      completer.complete();
    }

    addListener(check);
    return completer.future;
  }

  @override
  void dispose() {
    _listener?.dispose();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
AppForeground appForeground(Ref ref) {
  final foreground = AppForeground.fromBinding();
  ref.onDispose(foreground.dispose);
  return foreground;
}
