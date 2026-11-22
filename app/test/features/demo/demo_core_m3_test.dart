import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/demo/data/demo_http_client_adapter.dart';
import 'package:gi_home/src/features/demo/data/demo_series.dart';

const boilerId = '9d3c6a52-1f0e-4c8b-a6d2-0b7e5f4a1c01';
const sensorId = '9d3c6a52-1f0e-4c8b-a6d2-0b7e5f4a1c02';
const morning = 'cdemoschedule000000000001';
const otherSession = '5e1d0c3b-2a4f-4b6e-8d7c-9a0b1c2d3e02';

String demoFixtures() =>
    File('assets/demo_fixtures/demo_core.json').readAsStringSync();

void main() {
  late DateTime now;
  late DemoCore core;

  setUp(() {
    // Friday 08:00 UTC: no seeded schedule matches.
    now = DateTime.utc(2026, 11, 20, 8);
    core = DemoCore.fromJsonString(demoFixtures(), now: () => now);
  });

  Object? ok(DemoReply reply) {
    expect(reply.status, 200, reason: '${reply.body}');
    return reply.body;
  }

  Map<String, dynamic> obj(DemoReply reply) =>
      ok(reply)! as Map<String, dynamic>;

  void expectError(DemoReply reply, int status, String code) {
    expect(reply.status, status, reason: '${reply.body}');
    expect((reply.body! as Map)['code'], code);
  }

  DeviceDetail detail() => DeviceDetail.fromJson(
    obj(core.handle('GET', '/api/v1/devices/$boilerId', null)),
  );

  const schedules = '/api/v1/devices/$boilerId/schedules';

  Map<String, Object?> scheduleBody({
    List<int> days = const [5],
    String start = '07:00',
    String end = '09:00',
    num target = 65,
    num hysteresis = 2,
  }) => {
    'name': 'Test',
    'daysOfWeek': days,
    'startTime': start,
    'endTime': end,
    'targetTemperatureCelsius': target,
    'hysteresisCelsius': hysteresis,
  };

  group('schedules', () {
    test('list decodes, oldest first', () {
      final rows = [
        for (final row in ok(core.handle('GET', schedules, null))! as List)
          HeatingSchedule.fromJson(row as Map<String, dynamic>),
      ];
      expect(rows.map((r) => r.name), ['Poranek', 'Wieczór', 'Weekend']);
      expect(detail().controlStrategy?.targetTemperatureCelsius, 55);
    });

    test('CRUD answers 201/200/204 and reconciles the strategy', () {
      final version = detail().configurationVersion;
      final created = core.handle('POST', schedules, scheduleBody());
      expect(created.status, 201);
      final row = HeatingSchedule.fromJson(
        created.body! as Map<String, dynamic>,
      );
      expect(row.id, startsWith('c'));
      expect(row.id, hasLength(25));
      expect(row.enabled, isTrue);
      final strategy = detail().controlStrategy!;
      expect(strategy.targetTemperatureCelsius, 65);
      expect(strategy.hysteresisCelsius, 2);
      expect(strategy.mode, ControlStrategyMode.auto);
      expect(detail().configurationVersion, greaterThan(version));

      final disabled = obj(
        core.handle('PATCH', '$schedules/${row.id}', {'enabled': false}),
      );
      expect(disabled['enabled'], isFalse);
      expect(detail().controlStrategy!.targetTemperatureCelsius, 55);
      expect(
        core
            .handle('PATCH', '$schedules/${row.id}', <String, Object?>{})
            .status,
        200,
      );

      expect(core.handle('DELETE', '$schedules/${row.id}', null), (
        status: 204,
        body: null,
      ));
      expect(ok(core.handle('GET', schedules, null)), hasLength(3));
      expectError(
        core.handle('DELETE', '$schedules/${row.id}', null),
        404,
        'HEATING_SCHEDULE_NOT_FOUND',
      );
      expectError(
        core.handle('PATCH', '$schedules/nope', {'enabled': true}),
        404,
        'HEATING_SCHEDULE_NOT_FOUND',
      );
    });

    test('validation mirrors the DTO', () {
      for (final body in [
        scheduleBody(end: '24:00'),
        scheduleBody(start: '6:00'),
        scheduleBody(days: [7]),
        scheduleBody(days: [1, 1]),
        scheduleBody(days: []),
        scheduleBody(hysteresis: 0.5),
        scheduleBody(target: 101),
        {...scheduleBody(), 'extra': true},
        {'name': 'x'},
      ]) {
        expectError(
          core.handle('POST', schedules, body),
          400,
          'VALIDATION_FAILED',
        );
      }
      expectError(
        core.handle('PATCH', '$schedules/$morning', {
          'daysOfWeek': [7],
        }),
        400,
        'VALIDATION_FAILED',
      );
      expectError(
        core.handle('POST', '/api/v1/devices/nope/schedules', scheduleBody()),
        404,
        'DEVICE_NOT_FOUND',
      );
    });

    test('the first enabled match by createdAt wins; the clock moves on', () {
      now = DateTime.utc(2026, 11, 20, 17); // Wieczór 16:00–20:00, daily.
      expect(detail().controlStrategy!.targetTemperatureCelsius, 58);
      expect(
        core
            .handle(
              'POST',
              schedules,
              scheduleBody(start: '16:30', end: '18:00'),
            )
            .status,
        201,
      );
      expect(detail().controlStrategy!.targetTemperatureCelsius, 58);
      now = DateTime.utc(2026, 11, 20, 20); // end is exclusive
      expect(detail().controlStrategy!.targetTemperatureCelsius, 55);
    });

    test('heating suspended wins over every schedule', () {
      now = DateTime.utc(2026, 11, 20, 17);
      core.handle('PATCH', '/api/v1/devices/$boilerId', {
        'heatingSuspended': true,
      });
      final strategy = detail().controlStrategy!;
      expect(strategy.mode, ControlStrategyMode.off);
      expect(strategy.targetTemperatureCelsius, 55);
    });

    test('a wrap window is anchored on its start day', () {
      core.handle(
        'POST',
        schedules,
        scheduleBody(days: [6], start: '22:00', end: '06:00'),
      );
      now = DateTime.utc(2026, 11, 21, 21, 59); // Saturday
      expect(detail().controlStrategy!.targetTemperatureCelsius, 55);
      now = DateTime.utc(2026, 11, 21, 22);
      expect(detail().controlStrategy!.targetTemperatureCelsius, 65);
      now = DateTime.utc(2026, 11, 22, 5, 59); // Sunday
      expect(detail().controlStrategy!.targetTemperatureCelsius, 65);
      now = DateTime.utc(2026, 11, 22, 6);
      expect(detail().controlStrategy!.targetTemperatureCelsius, 55);
    });
  });

  group('account', () {
    List<AuthSessionInfo> sessions() => [
      for (final s
          in ok(core.handle('GET', '/api/v1/auth/sessions', null))! as List)
        AuthSessionInfo.fromJson(s as Map<String, dynamic>),
    ];

    test('change-password answers 200 {revokedSessions} like Core', () {
      final reply = obj(
        core.handle('POST', '/api/v1/users/me/change-password', {
          'currentPassword': 'Demo1234',
          'newPassword': 'Demo12345',
        }),
      );
      expect(reply, {'revokedSessions': 2});
      expect(sessions().single.current, isTrue);
      expectError(
        core.handle('POST', '/api/v1/users/me/change-password', {
          'currentPassword': 'Demo1234',
          'newPassword': 'short',
        }),
        400,
        'VALIDATION_FAILED',
      );
    });

    test('sessions: list, revoke, logout-all, login again', () {
      expect(sessions(), hasLength(3));
      expect(sessions().where((s) => s.current), hasLength(1));
      expect(
        core
            .handle('DELETE', '/api/v1/auth/sessions/$otherSession', null)
            .status,
        204,
      );
      expect(sessions(), hasLength(2));
      expectError(
        core.handle('DELETE', '/api/v1/auth/sessions/$otherSession', null),
        404,
        'AUTH_SESSION_NOT_FOUND',
      );
      expectError(
        core.handle('DELETE', '/api/v1/auth/sessions/bad', null),
        400,
        'HTTP_400',
      );
      expect(core.handle('POST', '/api/v1/auth/logout-all', null).status, 204);
      expect(sessions(), isEmpty);
      core.handle('POST', '/api/v1/auth/login', {
        'email': 'a',
        'password': 'b',
      });
      expect(sessions().single.current, isTrue);
    });

    test('recovery: regenerate, then reset with that code only', () {
      final code = RecoveryCodeResult.fromJson(
        obj(core.handle('POST', '/api/v1/auth/recovery/regenerate', null)),
      ).recoveryCode;
      expect(RecoveryCodeFormat.check(code), isNull);
      Map<String, Object?> body(String c) => {
        'email': 'Demo@gi-home.invalid',
        'recoveryCode': c,
        'newPassword': 'Recovered1',
      };
      expectError(
        core.handle(
          'POST',
          '/api/v1/auth/recovery/reset',
          body('0000-0000-0000-0000-0000-0000-0000-0000'),
        ),
        400,
        'AUTH_RECOVERY_INVALID',
      );
      expect(
        core.handle('POST', '/api/v1/auth/recovery/reset', body(code)).status,
        204,
      );
      expect(sessions(), isEmpty);
    });

    test('profile update', () {
      final profile = UserProfile.fromJson(
        obj(
          core.handle('PATCH', '/api/v1/users/me/profile', {
            'locale': 'en-US',
            'firstName': ' Ada ',
            'lastName': '',
          }),
        ),
      );
      expect(profile.locale, 'en-US');
      expect(profile.firstName, 'Ada');
      expect(profile.lastName, isNull);
      expectError(
        core.handle('PATCH', '/api/v1/users/me/profile', {'role': 'ADMIN'}),
        400,
        'VALIDATION_FAILED',
      );
    });
  });

  group('environment', () {
    test('weather, sun and PV decode as the app models them', () {
      final current = WeatherEnvelope<CurrentWeather>.fromJson(
        obj(core.handle('GET', '/api/v1/weather/current', null)),
        (j) => CurrentWeather.fromJson(j! as Map<String, dynamic>),
      );
      expect(current.stale, isFalse);
      expect(current.data.temperatureC, isNotNull);
      final hourly = WeatherEnvelope<List<HourlyWeather>>.fromJson(
        obj(core.handle('GET', '/api/v1/weather/hourly', null)),
        (j) => [
          for (final r in j! as List)
            HourlyWeather.fromJson(r as Map<String, dynamic>),
        ],
      );
      expect(hourly.data, hasLength(48));
      expect(hourly.data.first.time, now);
      final daily = WeatherEnvelope<List<DailyWeather>>.fromJson(
        obj(core.handle('GET', '/api/v1/weather/daily', null)),
        (j) => [
          for (final r in j! as List)
            DailyWeather.fromJson(r as Map<String, dynamic>),
        ],
      );
      expect(daily.data, hasLength(7));
      final solar = SolarStatus.fromJson(
        obj(core.handle('GET', '/api/v1/solar/current', null)),
      );
      expect(solar.aboveHorizon, isTrue);
      final pv = PvForecast.fromJson(
        obj(core.handle('GET', '/api/v1/pv/forecast', null)),
      );
      expect(pv.hourly, hasLength(72));
      expect(pv.daily, hasLength(3));
    });

    test('PV plan: FORECAST_ONLY with hours, DISABLED without config', () {
      final plan = PvHeatingPlan.fromJson(
        obj(
          core.handle('GET', '/api/v1/devices/$boilerId/pv-heating-plan', null),
        ),
      );
      expect(plan.mode, PvControlMode.forecastOnly);
      expect(plan.hours, hasLength(24));
      expect(plan.hours.where((h) => h.forecastFavorable), isNotEmpty);
      expect(
        plan.hours
            .where((h) => h.forecastFavorable)
            .first
            .predictedTargetCelsius,
        70,
      );
      final none = PvHeatingPlan.fromJson(
        obj(
          core.handle('GET', '/api/v1/devices/$sensorId/pv-heating-plan', null),
        ),
      );
      expect(none.mode, PvControlMode.disabled);
      expect(none.hours, isEmpty);
      expect(none.safeMaxTemperatureCelsius, 60);
    });
  });

  group('history', () {
    const base = '/api/v1/devices/$boilerId/entities';

    DemoReply history(String entity, Map<String, String> query) =>
        core.handle('GET', '$base/$entity/history', null, query: query);

    test('a 7-day change log, ascending, oldest first when truncated', () {
      final full = DemoSeries.history({
        'id': 'demo-supply',
        'domain': 'sensor',
        'deviceClass': 'temperature',
        'value': 49.5,
        'unit': '°C',
      }, now);
      expect(full.length, greaterThan(10000));
      final day = EntityHistory.fromJson(obj(history('demo-supply', {})));
      expect(day.samples, isNotEmpty);
      expect(day.samples.first.kind, HistorySampleKind.temperature);
      final ats = day.samples.map((s) => s.at).toList();
      expect(ats, [...ats]..sort());
      final week = EntityHistory.fromJson(
        obj(
          history('demo-supply', {
            'from': now.subtract(const Duration(days: 7)).toIso8601String(),
            'to': now.toIso8601String(),
            'limit': '5000',
          }),
        ),
      );
      expect(week.samples, hasLength(5000));
      expect(
        week.samples.first.at,
        DateTime.parse(full.first['at']! as String),
      );
      final relay = EntityHistory.fromJson(
        obj(history('demo-relay-boiler', {})),
      );
      expect(relay.samples.first.kind, HistorySampleKind.switch_);
      expect(relay.samples.first.value, isA<bool>());
    });

    test('errors', () {
      final t = now.toIso8601String();
      expectError(
        history('demo-supply', {'from': t, 'to': t}),
        400,
        'HISTORY_RANGE_INVALID',
      );
      expectError(
        history('demo-supply', {'limit': '0'}),
        400,
        'VALIDATION_FAILED',
      );
      expectError(
        history('demo-supply', {'limit': '5001'}),
        400,
        'VALIDATION_FAILED',
      );
      expectError(history('demo-supply', {'x': '1'}), 400, 'VALIDATION_FAILED');
      expectError(history('nope', {}), 404, 'DEVICE_ENTITY_NOT_FOUND');
    });

    test('the adapter passes the query', () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://demo.gi-home.invalid/api/v1',
          validateStatus: (_) => true,
        ),
      )..httpClientAdapter = DemoHttpClientAdapter(core);
      final response = await dio.get<Map<String, dynamic>>(
        '/devices/$boilerId/entities/demo-supply/history',
        queryParameters: {'limit': 3},
      );
      expect(response.statusCode, 200);
      expect(response.data!['samples'], hasLength(3));
    });
  });

  test('every catalog endpoint is answered in demo mode', () {
    const params = {
      'id': boilerId,
      'entityId': 'demo-supply',
      'scheduleId': morning,
      'sessionId': otherSession,
    };
    for (final endpoint in GiEndpoints.all) {
      final fresh = DemoCore.fromJsonString(demoFixtures(), now: () => now);
      final path = endpoint.path.replaceAllMapped(
        RegExp(r'\{(\w+)\}'),
        (m) => params[m[1]]!,
      );
      final reply = fresh.handle(
        endpoint.method.verb,
        '/api/v1$path',
        <String, Object?>{},
      );
      final code = reply.body is Map ? (reply.body! as Map)['code'] : null;
      expect(
        code,
        isNot('HTTP_404'),
        reason: '${endpoint.id} is not handled by the demo',
      );
    }
  });
}
