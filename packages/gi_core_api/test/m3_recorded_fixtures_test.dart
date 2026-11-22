import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

/// The M3 responses recorded by `tools/seed_core.dart --fixtures` on a
/// contract stack decode, and re-encode to the same JSON (nothing unknown).
void main() {
  Map<String, dynamic> object(String path) =>
      fixtureJson(path)! as Map<String, dynamic>;

  test('schedule rows: create, list, update', () {
    final created = object('HeatingScheduleController_create/created.json');
    expect(HeatingSchedule.fromJson(created).toJson(), created);
    final renamed = object('HeatingScheduleController_update/renamed.json');
    expect(HeatingSchedule.fromJson(renamed).name, 'Dni robocze (zmienione)');
    final list =
        fixtureJson('HeatingScheduleController_list/one_row.json')!
            as List<dynamic>;
    expect(list, hasLength(1));
    expect(
      HeatingSchedule.fromJson(list.single as Map<String, dynamic>).id,
      created['id'],
    );
    expect(fixtureJson('HeatingScheduleController_list/empty.json'), isEmpty);
  });

  test('PV heating plan: DISABLED without hours', () {
    final plan = PvHeatingPlan.fromJson(
      object('PvHeatingController_getPlan/disabled.json'),
    );
    expect(plan.mode, PvControlMode.disabled);
    expect(plan.hours, isEmpty);
    expect(plan.safeMaxTemperatureCelsius, 60);
  });

  test('history: relay switch samples and an empty temperature', () {
    final relay = EntityHistory.fromJson(
      object('HistoryController_getEntityHistory/relay.json'),
    );
    for (final sample in relay.samples) {
      expect(sample.kind, HistorySampleKind.switch_);
      expect(sample.value, isA<bool>());
    }
    final temperature = EntityHistory.fromJson(
      object('HistoryController_getEntityHistory/temperature_empty.json'),
    );
    expect(temperature.samples, isEmpty);
  });

  test('profile PATCH {} answers the profile', () {
    final profile = UserProfile.fromJson(
      object('UsersController_updateProfile/unchanged.json'),
    );
    expect(profile.email, isNotEmpty);
  });

  test('error envelopes carry the documented codes', () {
    for (final (path, status, code) in [
      (
        'HeatingScheduleController_create/error_validation.json',
        400,
        'VALIDATION_FAILED',
      ),
      (
        'HeatingScheduleController_update/error_not_found.json',
        404,
        'HEATING_SCHEDULE_NOT_FOUND',
      ),
      (
        'HeatingScheduleController_remove/error_not_found.json',
        404,
        'HEATING_SCHEDULE_NOT_FOUND',
      ),
      (
        'HistoryController_getEntityHistory/error_range_invalid.json',
        400,
        'HISTORY_RANGE_INVALID',
      ),
      (
        'HistoryController_getEntityHistory/error_validation.json',
        400,
        'VALIDATION_FAILED',
      ),
      (
        'HistoryController_getEntityHistory/error_entity_not_found.json',
        404,
        'DEVICE_ENTITY_NOT_FOUND',
      ),
      ('EnvironmentController_current/error_no_data.json', 503, 'HTTP_503'),
      ('EnvironmentController_hourly/error_no_data.json', 503, 'HTTP_503'),
      ('EnvironmentController_daily/error_no_data.json', 503, 'HTTP_503'),
      (
        'EnvironmentController_solarCurrent/error_no_location.json',
        400,
        'HTTP_400',
      ),
      (
        'EnvironmentController_pvForecast/error_not_configured.json',
        400,
        'HTTP_400',
      ),
      (
        'AuthController_revokeSession/error_not_found.json',
        404,
        'AUTH_SESSION_NOT_FOUND',
      ),
    ]) {
      final envelope = ApiErrorEnvelope.tryParse(fixtureJson(path));
      expect(envelope?.code, code, reason: path);
      expect(envelope?.statusCode, status, reason: path);
    }
  });
}
