import 'package:gi_core_api/gi_core_api.dart';

/// How long a sensor may stay silent before its last value stops being
/// shown as current. GI Core never marks an entity unavailable because the
/// device went quiet, so the age of `lastSeenAt` is the only signal; five
/// minutes is where Core itself starts calling a device `STALE`.
const Duration sensorStaleAfter = Duration(minutes: 5);

/// A reading whose [DeviceEntity.lastSeenAt] is older than
/// [sensorStaleAfter] (plain sensors only; switches have their own report).
bool isStaleReading(DeviceEntity entity, DateTime now) {
  final seen = entity.lastSeenAt;
  return entity.domain == EntityDomain.sensor &&
      seen != null &&
      now.difference(seen) > sensorStaleAfter;
}

/// Entities GI Edge creates by itself (`device_uptime`, `diagnostics.*`)
/// that nobody assigned a role or function to: they belong under technical
/// data, not among the readings of the room.
bool isTechnicalEntity(DeviceEntity entity) {
  if (entity.assignedRole != null || entity.assignedFunction != null) {
    return false;
  }
  bool technical(String name) =>
      name == 'device_uptime' || name.startsWith('diagnostics.');
  return technical(entity.sourceName) || technical(entity.displayName);
}

/// Whether `needs_configuration` of [detail] points at something to
/// configure. GI Edge lists unassigned diagnostics entities on every device,
/// and Core reports `needs_configuration` for them alone; that is benign. An
/// enabled entity that is not technical and has no role or function (a
/// heating relay, a sensor) is a real gap.
bool needsRealConfiguration(DeviceDetail detail) {
  if (detail.communicationMode != CommunicationMode.giEdgeV1) return true;
  return detail.entities.any(
    (e) =>
        e.enabled &&
        e.assignedRole == null &&
        e.assignedFunction == null &&
        !isTechnicalEntity(e),
  );
}
