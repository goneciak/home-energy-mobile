import 'package:gi_core_api/gi_core_api.dart';

/// The heating schedule endpoints (plan §4.2). Every method throws only
/// [ApiFailure]; writes are never retried automatically.
abstract interface class ScheduleSource {
  /// `GET /devices/:deviceId/schedules`, oldest first.
  Future<List<HeatingSchedule>> schedules(String deviceId);

  /// `POST /devices/:deviceId/schedules` (201).
  Future<HeatingSchedule> createSchedule(
    String deviceId,
    HeatingScheduleInput input,
  );

  /// `PATCH /devices/:deviceId/schedules/:scheduleId` (200).
  Future<HeatingSchedule> updateSchedule(
    String deviceId,
    String scheduleId,
    HeatingSchedulePatch patch,
  );

  /// `DELETE /devices/:deviceId/schedules/:scheduleId` (204).
  Future<void> deleteSchedule(String deviceId, String scheduleId);
}

/// [ScheduleSource] backed by the GI Core client.
final class GiCoreScheduleSource implements ScheduleSource {
  const new(this._client);

  final GiCoreClient _client;

  @override
  Future<List<HeatingSchedule>> schedules(String deviceId) =>
      _client.schedules(deviceId);

  @override
  Future<HeatingSchedule> createSchedule(
    String deviceId,
    HeatingScheduleInput input,
  ) => _client.createSchedule(deviceId, input);

  @override
  Future<HeatingSchedule> updateSchedule(
    String deviceId,
    String scheduleId,
    HeatingSchedulePatch patch,
  ) => _client.updateSchedule(deviceId, scheduleId, patch);

  @override
  Future<void> deleteSchedule(String deviceId, String scheduleId) =>
      _client.deleteSchedule(deviceId, scheduleId);
}
