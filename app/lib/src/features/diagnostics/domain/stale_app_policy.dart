import 'package:gi_core_api/gi_core_api.dart';

/// When the app is probably older than the GI Core it talks to (plan §16
/// point 4): [UnexpectedShapeFailure] [threshold] or more times in one app
/// session on one of the [keyEndpoints] of the MVP. One odd response can be
/// a glitch; a key endpoint that keeps failing to decode means the contract
/// moved on.
abstract final class StaleAppPolicy {
  static const threshold = 3;

  /// Session, device list, device details and setup status: without them
  /// the app cannot do its job.
  static final Set<String> keyEndpoints = {
    GiEndpoints.authMe.id,
    GiEndpoints.devicesList.id,
    GiEndpoints.devicesDetail.id,
    GiEndpoints.setupStatus.id,
  };

  /// Whether [counts] (unexpected shapes by endpoint id, this session)
  /// call for "Zaktualizuj aplikację".
  static bool suggestsUpdate(Map<String, int> counts) =>
      keyEndpoints.any((id) => (counts[id] ?? 0) >= threshold);
}
