import 'package:gi_home/src/core/polling/polling_budget.dart';

/// How often data is polled and when it counts as outdated: plan §11 shows
/// "Dane z HH:MM" once data is older than twice its polling interval.
final class FreshnessPolicy {
  const new({required this.interval});

  /// The policy of each of [cards] heating cards on Home: the cadence slows
  /// down as cards are added so Home stays within the request budget.
  factory heatingCards(int cards) =>
      FreshnessPolicy(interval: PollingBudget.heatingCardInterval(cards));

  /// `GET /devices` on Home (shared by Home and device details).
  static const deviceList = FreshnessPolicy(interval: PollingBudget.deviceList);

  /// `GET /devices/:id` while the device details screen is open.
  static const deviceDetail = FreshnessPolicy(
    interval: PollingBudget.deviceDetail,
  );

  /// `GET /devices/:id` on the details screen once the user has not touched
  /// or scrolled it for [deviceDetailIdleAfter].
  static const deviceDetailIdle = FreshnessPolicy(
    interval: PollingBudget.deviceDetailIdle,
  );

  /// Time without interaction after which the details poll at the
  /// [deviceDetailIdle] cadence.
  static const Duration deviceDetailIdleAfter =
      PollingBudget.deviceDetailIdleAfter;

  /// `GET /devices/:id` of each heating card while Home is visible and few
  /// cards are shown; [FreshnessPolicy.heatingCards] gives the cadence of a
  /// larger Home.
  static const heatingCard = FreshnessPolicy(
    interval: PollingBudget.heatingCard,
  );

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
