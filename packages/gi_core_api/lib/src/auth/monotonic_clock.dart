/// Monotonic time source for access token expiry; immune to wall-clock jumps.
///
/// It may not advance while the device is suspended, so token expiry is also
/// checked against the wall clock (see `AuthSessionManager`).
abstract interface class MonotonicClock {
  /// Time elapsed since an arbitrary fixed origin.
  Duration get elapsed;
}

final class StopwatchClock implements MonotonicClock {
  new() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  Duration get elapsed => _stopwatch.elapsed;
}
