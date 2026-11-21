import 'dart:async';

import 'package:flutter/foundation.dart';

/// Whether the user has stopped interacting with a screen: [value] turns
/// `true` once [idleAfter] passed without a [touch], and `false` again on
/// the next one (plan §11: details poll more slowly after 2 min idle).
///
/// [touch] is cheap enough to call on every pointer and scroll event: it
/// only records the time on the `now` clock, and a single timer checks it
/// when the idle period could be over.
class IdleTracker extends ValueNotifier<bool> {
  new({required this.idleAfter, required DateTime Function() now})
    : _now = now,
      _lastActivity = now(),
      super(false) {
    _arm(idleAfter);
  }

  final Duration idleAfter;
  final DateTime Function() _now;
  DateTime _lastActivity;
  Timer? _timer;
  bool _disposed = false;

  bool get isIdle => value;

  /// The user interacted: not idle, and the idle period starts again.
  void touch() {
    if (_disposed) return;
    _lastActivity = _now();
    value = false;
    if (!(_timer?.isActive ?? false)) _arm(idleAfter);
  }

  void _arm(Duration delay) => _timer = Timer(delay, _check);

  void _check() {
    if (_disposed) return;
    final quiet = _now().difference(_lastActivity);
    if (quiet >= idleAfter) {
      value = true;
    } else {
      _arm(idleAfter - quiet);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
