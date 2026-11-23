/// The polling cadences of the app and the request budget they must keep.
///
/// Pure Dart on purpose (no imports): the app uses these constants for its
/// pollers, the budget tests assert against them, and `tools/load` replays
/// the same cadences against a contract stack.
///
/// GI Core runs on a Raspberry Pi shared by several phones and the web
/// panel, so one phone on Home may send at most [homeRequestsPerMinute]
/// requests per minute (details in `docs/load-budget.md`).
abstract final class PollingBudget {
  /// Requests per minute one phone may send while Home is on screen.
  static const homeRequestsPerMinute = 12;

  /// `GET /devices` while Home or device details are open.
  static const deviceList = Duration(seconds: 30);

  /// `GET /devices/:id` while the device details screen is in use.
  static const deviceDetail = Duration(seconds: 5);

  /// `GET /devices/:id` on the details screen once the user is idle.
  static const deviceDetailIdle = Duration(seconds: 15);

  /// Time without interaction after which details poll at
  /// [deviceDetailIdle].
  static const deviceDetailIdleAfter = Duration(minutes: 2);

  /// `GET /devices/:id` of a heating card on Home when few cards are shown;
  /// the cadence of a larger Home is [heatingCardInterval].
  static const heatingCard = Duration(seconds: 15);

  /// At most this many heating card requests run at once.
  static const heatingCardMaxConcurrency = 3;

  /// Poll of the device while a command waits for its confirmation (switch
  /// heartbeat, heating suspension). A short burst that ends when the
  /// command settles or times out.
  static const postCommandPoll = Duration(seconds: 2);

  /// Longest a command is confirmed for: heartbeat window of a switch.
  static const postCommandWindow = Duration(seconds: 45);

  /// Share of the Home budget the device list uses.
  static double get deviceListRequestsPerMinute => perMinute(deviceList);

  /// Requests per minute left for the heating cards on Home.
  static double get heatingCardRequestsPerMinute =>
      homeRequestsPerMinute - deviceListRequestsPerMinute;

  /// Cadence of each of [cards] visible heating cards so that the list and
  /// the cards together stay within [homeRequestsPerMinute]: the base
  /// [heatingCard] cadence while it fits, slower beyond that.
  static Duration heatingCardInterval(int cards) {
    if (cards <= 0) return heatingCard;
    final seconds = (cards * 60 / heatingCardRequestsPerMinute).ceil();
    return seconds <= heatingCard.inSeconds
        ? heatingCard
        : Duration(seconds: seconds);
  }

  /// Requests per minute of Home with [cards] heating cards on screen (list
  /// plus cards), at the steady cadence.
  static double homeRequestsPerMinuteFor(int cards) =>
      deviceListRequestsPerMinute +
      cards * perMinute(heatingCardInterval(cards));

  /// Requests per minute of a poller that runs every [interval].
  static double perMinute(Duration interval) =>
      Duration.microsecondsPerMinute / interval.inMicroseconds;
}
