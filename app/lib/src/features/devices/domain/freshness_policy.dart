/// How often data is polled and when it counts as outdated: plan §11 shows
/// "Dane z HH:MM" once data is older than twice its polling interval.
final class FreshnessPolicy {
  const new({required this.interval});

  /// `GET /devices` on Home (shared by Home and device details).
  static const deviceList = FreshnessPolicy(interval: Duration(seconds: 30));

  /// `GET /devices/:id` while the device details screen is open.
  static const deviceDetail = FreshnessPolicy(interval: Duration(seconds: 5));

  /// `GET /devices/:id` on the details screen once the user has not touched
  /// or scrolled it for [deviceDetailIdleAfter].
  static const deviceDetailIdle = FreshnessPolicy(
    interval: Duration(seconds: 15),
  );

  /// Time without interaction after which the details poll at the
  /// [deviceDetailIdle] cadence.
  static const deviceDetailIdleAfter = Duration(minutes: 2);

  /// `GET /devices/:id` of each heating card while Home is visible.
  static const heatingCard = FreshnessPolicy(interval: Duration(seconds: 15));

  final Duration interval;

  Duration get staleAfter => interval * 2;

  /// Age of data received at [fetchedAt]; never negative, so a clock that
  /// moved backwards does not make data look fresher than "just now".
  static Duration ageOf(DateTime fetchedAt, DateTime now) {
    final age = now.difference(fetchedAt);
    return age.isNegative ? Duration.zero : age;
  }

  bool isStale(DateTime fetchedAt, DateTime now) =>
      ageOf(fetchedAt, now) > staleAfter;
}
