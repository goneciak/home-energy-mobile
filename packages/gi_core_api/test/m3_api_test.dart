import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

const _deviceId = '5f0c1b9e-3a7d-4c2e-8b6f-0d1e2f3a4b5c';
const _relayId = '9b1d6c2e-4f3a-4e8b-9c1d-2a3b4c5d6e7f';
const _schedulesPath = '/devices/$_deviceId/schedules';
const _historyPath = '/devices/$_deviceId/entities/$_relayId/history';

const _input = HeatingScheduleInput(
  name: 'Poranek',
  daysOfWeek: [1, 2, 3, 4, 5],
  startTime: '05:30',
  endTime: '07:00',
  targetTemperatureCelsius: 58.5,
  hysteresisCelsius: 3,
);

FakeResponse _fixture(Object? body, {int status = 200}) =>
    FakeResponse.json(body, status: status);

void main() {
  late FakeCore core;
  late GiCoreClient client;

  setUp(() async {
    core = FakeCore();
    client = testClient(core, decodeMode: DecodeMode.strict);
    core
      ..on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.json(
          loginBody(),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue1)],
          },
        ),
      )
      ..on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.json(
          refreshBody('access-2'),
          headers: {
            'set-cookie': [setCookieFor(testCookieValue2)],
          },
        ),
      );
    await client.login(email: 'a@b.c', password: 'pw');
  });

  tearDown(() => client.close());

  group('catalog', () {
    test('schedule list is any role, writes are OWNER/ADMIN only', () {
      for (final role in [
        UserRole.owner,
        UserRole.admin,
        UserRole.user,
        UserRole.service,
      ]) {
        expect(GiEndpoints.schedulesList.allows(role), isTrue);
        for (final read in [
          GiEndpoints.weatherCurrent,
          GiEndpoints.weatherHourly,
          GiEndpoints.weatherDaily,
          GiEndpoints.solarCurrent,
          GiEndpoints.pvForecast,
          GiEndpoints.pvHeatingPlan,
          GiEndpoints.entityHistory,
        ]) {
          expect(read.allows(role), isTrue, reason: '${read.id} $role');
          expect(read.isIdempotent, isTrue);
        }
      }
      for (final write in [
        GiEndpoints.scheduleCreate,
        GiEndpoints.scheduleUpdate,
        GiEndpoints.scheduleRemove,
      ]) {
        expect(write.roles, {UserRole.owner, UserRole.admin});
        expect(write.allows(UserRole.user), isFalse);
        expect(write.allows(UserRole.service), isFalse);
        expect(write.maxRetries, 0);
        expect(write.milestone, Milestone.m3);
      }
    });

    test('"no data" endpoints are not retried', () {
      expect(GiEndpoints.weatherCurrent.maxRetries, 0);
      expect(GiEndpoints.pvForecast.maxRetries, 0);
    });

    test('forbidden endpoints (plan §4.4) are not in the catalog', () {
      final paths = GiEndpoints.all.map((e) => e.path).toSet();
      expect(paths, isNot(contains('/weather/refresh')));
      expect(paths, isNot(contains('/solar/events')));
      expect(paths, isNot(contains('/settings/location/search')));
    });
  });

  group('schedules', () {
    test('list decodes the plain array in order', () async {
      core.on(
        'GET',
        _schedulesPath,
        (_) => _fixture(
          fixtureJson(
            'HeatingScheduleController_list/two_rows_handwritten.json',
          ),
        ),
      );

      final rows = await client.schedules(_deviceId);

      expect(rows.map((r) => r.name), ['Poranek w tygodniu', 'Noc weekendowa']);
      expect(rows.first.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(rows.first.startMinutes, 5 * 60 + 30);
      expect(rows.first.targetTemperatureCelsius, 58.5);
      expect(rows.last.hysteresisCelsius, 5.0);
      expect(rows.last.enabled, isFalse);
      expect(rows.last.endMinutes, 6 * 60);
    });

    test('create sends exactly the DTO keys and decodes the 201', () async {
      core.on(
        'POST',
        _schedulesPath,
        (_) => _fixture(
          fixtureJson(
            'HeatingScheduleController_create/created_handwritten.json',
          ),
          status: 201,
        ),
      );

      final row = await client.createSchedule(_deviceId, _input);

      expect(core.requestsTo('POST', _schedulesPath).single.json, {
        'name': 'Poranek',
        'daysOfWeek': [1, 2, 3, 4, 5],
        'startTime': '05:30',
        'endTime': '07:00',
        'targetTemperatureCelsius': 58.5,
        'hysteresisCelsius': 3.0,
        'enabled': true,
      });
      expect(row.id, 'cmi9x2k7d0001qz8h3v5b6n7m');
    });

    test('create maps VALIDATION_FAILED and is never retried', () async {
      core.on(
        'POST',
        _schedulesPath,
        (_) => _fixture(
          fixtureJson(
            'HeatingScheduleController_create/error_validation_handwritten.json',
          ),
          status: 400,
        ),
      );

      await expectLater(
        client.createSchedule(_deviceId, _input),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.details.keys,
            'fields',
            containsAll(['endTime', 'daysOfWeek']),
          ),
        ),
      );
      expect(core.requestsTo('POST', _schedulesPath), hasLength(1));
    });

    test('an invalid input is rejected before sending', () {
      const bad = HeatingScheduleInput(
        name: '',
        daysOfWeek: [1, 1, 7],
        startTime: '24:00',
        endTime: '6:00',
        targetTemperatureCelsius: 101,
        hysteresisCelsius: 0.5,
      );

      expect(bad.validate(), ScheduleInputProblem.values.toSet());
      expect(() => client.createSchedule(_deviceId, bad), throwsArgumentError);
      expect(core.requestsTo('POST', _schedulesPath), isEmpty);
    });

    test('validation bounds mirror the DTO', () {
      expect(HeatingScheduleRules.validTime('00:00'), isTrue);
      expect(HeatingScheduleRules.validTime('23:59'), isTrue);
      expect(HeatingScheduleRules.validTime('24:00'), isFalse);
      expect(HeatingScheduleRules.validTime('6:00'), isFalse);
      expect(HeatingScheduleRules.validDays([0, 1, 2, 3, 4, 5, 6]), isTrue);
      expect(HeatingScheduleRules.validDays([]), isFalse);
      expect(HeatingScheduleRules.validDays([-1]), isFalse);
      expect(HeatingScheduleRules.validName('x' * 120), isTrue);
      expect(HeatingScheduleRules.validName('x' * 121), isFalse);
      expect(HeatingScheduleRules.validTarget(0), isTrue);
      expect(HeatingScheduleRules.validTarget(100), isTrue);
      expect(HeatingScheduleRules.validTarget(double.nan), isFalse);
      expect(HeatingScheduleRules.validHysteresis(1), isTrue);
      expect(HeatingScheduleRules.validHysteresis(20), isTrue);
      expect(HeatingScheduleRules.validHysteresis(20.5), isFalse);
      expect(HeatingScheduleRules.formatMinutes(5 * 60 + 7), '05:07');
      expect(() => HeatingScheduleRules.formatMinutes(1440), throwsRangeError);
    });

    test('patch sends only the set fields; {} is valid', () async {
      const path = '$_schedulesPath/cmi9x2k7d0001qz8h3v5b6n7m';
      core.on(
        'PATCH',
        path,
        (_) => _fixture(
          fixtureJson(
            'HeatingScheduleController_update/disabled_handwritten.json',
          ),
        ),
      );

      final row = await client.updateSchedule(
        _deviceId,
        'cmi9x2k7d0001qz8h3v5b6n7m',
        const HeatingSchedulePatch(enabled: false),
      );
      await client.updateSchedule(
        _deviceId,
        'cmi9x2k7d0001qz8h3v5b6n7m',
        const HeatingSchedulePatch(),
      );

      final sent = core.requestsTo('PATCH', path);
      expect(sent.first.json, {'enabled': false});
      expect(sent.last.json, isEmpty);
      expect(row.enabled, isFalse);
      expect(const HeatingSchedulePatch(startTime: '24:00').validate(), {
        ScheduleInputProblem.startTime,
      });
    });

    test('patch of a missing schedule is a NotFoundFailure', () async {
      const path = '$_schedulesPath/cmi9missing';
      core.on(
        'PATCH',
        path,
        (_) => _fixture(
          fixtureJson(
            'HeatingScheduleController_update/error_not_found_handwritten.json',
          ),
          status: 404,
        ),
      );

      await expectLater(
        client.updateSchedule(
          _deviceId,
          'cmi9missing',
          const HeatingSchedulePatch(name: 'x'),
        ),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.code,
            'code',
            'HEATING_SCHEDULE_NOT_FOUND',
          ),
        ),
      );
    });

    test('delete accepts an empty 204 and maps 404', () async {
      core
        ..on('DELETE', '$_schedulesPath/a', (_) => FakeResponse.empty())
        ..on(
          'DELETE',
          '$_schedulesPath/b',
          (_) => _fixture(
            fixtureJson(
              'HeatingScheduleController_remove/error_not_found_handwritten.json',
            ),
            status: 404,
          ),
        );

      await client.deleteSchedule(_deviceId, 'a');

      await expectLater(
        client.deleteSchedule(_deviceId, 'b'),
        throwsA(isA<NotFoundFailure>()),
      );
      expect(core.requestsTo('DELETE', '$_schedulesPath/b'), hasLength(1));
    });

    test('unknown fields are tolerated in tolerant mode', () {
      final json = {
        ...fixtureObject(
          'HeatingScheduleController_create/created_handwritten.json',
        ),
        'priority': 3,
      };

      expect(HeatingSchedule.fromJson(json).name, 'Poranek w tygodniu');
    });
  });

  group('weather', () {
    test('current decodes the envelope', () async {
      core.on(
        'GET',
        '/weather/current',
        (_) => _fixture(
          fixtureJson('EnvironmentController_current/ok_handwritten.json'),
        ),
      );

      final result = await client.weatherCurrent();

      final envelope = result.valueOrNull!;
      expect(envelope.stale, isFalse);
      expect(envelope.lastError, isNull);
      expect(envelope.fetchedAt, DateTime.utc(2026, 11, 22, 10, 5, 12, 331));
      expect(envelope.data.temperatureC, 3.4);
      expect(envelope.data.symbolCode, 'lightrain');
      expect(envelope.data.observedAt, DateTime.utc(2026, 11, 22, 10));
    });

    test('stale data with every number null decodes', () {
      final envelope = WeatherEnvelope.fromJson(
        fixtureObject(
          'EnvironmentController_current/stale_nulls_handwritten.json',
        ),
        (json) => CurrentWeather.fromJson(json! as Map<String, dynamic>),
      );

      expect(envelope.stale, isTrue);
      expect(envelope.lastError, 'Weather provider temporarily unavailable.');
      expect(envelope.data, const CurrentWeather());
    });

    test('503 HTTP_503 is "no data", not an error, and not retried', () async {
      core.on(
        'GET',
        '/weather/current',
        (_) => _fixture(
          fixtureJson(
            'EnvironmentController_current/error_no_data_handwritten.json',
          ),
          status: 503,
        ),
      );

      final result = await client.weatherCurrent();

      expect(result, isA<EnvironmentNoData<Object?>>());
      expect(result.valueOrNull, isNull);
      expect(core.requestsTo('GET', '/weather/current'), hasLength(1));
    });

    test('hourly keeps night and polar twilight symbol codes', () async {
      core.on(
        'GET',
        '/weather/hourly',
        (_) => _fixture(
          fixtureJson('EnvironmentController_hourly/ok_handwritten.json'),
        ),
      );

      final rows = (await client.weatherHourly()).valueOrNull!.data;

      expect(rows, hasLength(3));
      expect(rows.first.time, DateTime.utc(2026, 11, 22, 22));
      expect(rows.first.time.isUtc, isTrue);
      expect(rows.first.symbolCode, 'clearsky_night');
      expect(rows[1].symbolCode, 'partlycloudy_polartwilight');
      expect(rows[1].precipitationProbabilityPercent, isNull);
      expect(rows.last.temperatureC, isNull);
    });

    test('daily decodes UTC days', () async {
      core.on(
        'GET',
        '/weather/daily',
        (_) => _fixture(
          fixtureJson('EnvironmentController_daily/ok_handwritten.json'),
        ),
      );

      final rows = (await client.weatherDaily()).valueOrNull!.data;

      expect(rows.first.date, const LocalWallTime(2026, 11, 22));
      expect(rows.first.maximumTemperatureC, 4.9);
      expect(rows.last.minimumTemperatureC, isNull);
      expect(rows.last.precipitationMm, 0);
    });

    test('other failures are rethrown', () async {
      core.on(
        'GET',
        '/weather/daily',
        (_) => FakeResponse.error(403, 'HTTP_403'),
      );

      await expectLater(
        client.weatherDaily(),
        throwsA(isA<ForbiddenFailure>()),
      );
    });
  });

  group('solar', () {
    test('decodes the current position', () async {
      core.on(
        'GET',
        '/solar/current',
        (_) => _fixture(
          fixtureJson('EnvironmentController_solarCurrent/ok_handwritten.json'),
        ),
      );

      final solar = (await client.solarCurrent()).valueOrNull!;

      expect(solar.aboveHorizon, isTrue);
      expect(solar.currentElevationDegrees, closeTo(17.34, 0.01));
      expect(solar.dayLengthSeconds, 29365);
      expect(solar.sunrise, DateTime.utc(2026, 11, 22, 6, 21, 40, 512));
    });

    test('polar night: nullable times', () {
      final solar = SolarStatus.fromJson(
        fixtureObject(
          'EnvironmentController_solarCurrent/polar_night_handwritten.json',
        ),
      );

      expect(solar.sunrise, isNull);
      expect(solar.dayLengthSeconds, isNull);
      expect(solar.aboveHorizon, isFalse);
    });

    test('400 HTTP_400 (no coordinates) is "not configured"', () async {
      core.on(
        'GET',
        '/solar/current',
        (_) => _fixture(
          fixtureJson(
            'EnvironmentController_solarCurrent/error_no_location_handwritten.json',
          ),
          status: 400,
        ),
      );

      expect(
        await client.solarCurrent(),
        isA<EnvironmentNotConfigured<SolarStatus>>(),
      );
    });
  });

  group('PV forecast', () {
    test('decodes house-local times without converting them', () async {
      core.on(
        'GET',
        '/pv/forecast',
        (_) => _fixture(
          fixtureJson('EnvironmentController_pvForecast/ok_handwritten.json'),
        ),
      );

      final forecast = (await client.pvForecast()).valueOrNull!;

      expect(forecast.peakPowerKw, 6.5);
      expect(forecast.hourly[1].time, const LocalWallTime(2026, 11, 22, 12));
      expect(forecast.hourly[1].time.toIso(), '2026-11-22T12:00');
      expect(forecast.hourly[1].estimatedProductionKw, 1.83);
      expect(forecast.hourly.last.shortwaveRadiationWm2, isNull);
      expect(forecast.daily.first.date, const LocalWallTime(2026, 11, 22));
      expect(forecast.daily.first.estimatedProductionKwh, 7.42);
      expect(forecast.toJson()['daily'], [
        {'date': '2026-11-22', 'estimatedProductionKwh': 7.42},
        {'date': '2026-11-23', 'estimatedProductionKwh': 3.1},
      ]);
    });

    test('400 is "not configured", 500 is "no data"', () async {
      core.on(
        'GET',
        '/pv/forecast',
        (_) => _fixture(
          fixtureJson(
            'EnvironmentController_pvForecast/error_not_configured_handwritten.json',
          ),
          status: 400,
        ),
      );
      expect(
        await client.pvForecast(),
        isA<EnvironmentNotConfigured<PvForecast>>(),
      );

      core.on(
        'GET',
        '/pv/forecast',
        (_) => _fixture(
          fixtureJson(
            'EnvironmentController_pvForecast/error_provider_handwritten.json',
          ),
          status: 500,
        ),
      );
      expect(await client.pvForecast(), isA<EnvironmentNoData<PvForecast>>());
    });

    test('a 400 with another code is not swallowed', () async {
      core.on(
        'GET',
        '/pv/forecast',
        (_) => FakeResponse.error(400, 'SOMETHING_ELSE'),
      );

      await expectLater(client.pvForecast(), throwsA(isA<DomainFailure>()));
    });
  });

  group('LocalWallTime', () {
    test('parses, orders and rejects offsets', () {
      final a = LocalWallTime.parse('2026-11-22T13:00');
      final b = LocalWallTime.parse('2026-11-22T13:05:59');

      expect(a.hour, 13);
      expect(b.minute, 5);
      expect(a.isBefore(b), isTrue);
      expect(b.date, LocalWallTime.parse('2026-11-22'));
      expect(
        () => LocalWallTime.parse('2026-11-22T13:00:00Z'),
        throwsFormatException,
      );
      expect(
        () => LocalWallTime.parse('2026-11-22T24:00'),
        throwsFormatException,
      );
    });
  });

  group('PV heating plan', () {
    const path = '/devices/$_deviceId/pv-heating-plan';

    test('DISABLED has no hours', () async {
      core.on(
        'GET',
        path,
        (_) => _fixture(
          fixtureJson('PvHeatingController_getPlan/disabled_handwritten.json'),
        ),
      );

      final plan = await client.pvHeatingPlan(_deviceId);

      expect(plan.mode, PvControlMode.disabled);
      expect(plan.hours, isEmpty);
      expect(plan.safeMaxTemperatureCelsius, 60);
      expect(plan.baseTargetCelsius, 55);
    });

    test('HYBRID hours use house-local time', () {
      final plan = PvHeatingPlan.fromJson(
        fixtureObject('PvHeatingController_getPlan/hybrid_handwritten.json'),
      );

      expect(plan.mode, PvControlMode.hybrid);
      expect(plan.hours.first.time, const LocalWallTime(2026, 11, 22, 11));
      expect(plan.hours.first.predictedBoostActive, isTrue);
      expect(plan.hours.last.estimatedProductionKw, isNull);
    });

    test('an unknown mode is tolerated', () {
      final plan = PvHeatingPlan.fromJson({
        ...fixtureObject(
          'PvHeatingController_getPlan/disabled_handwritten.json',
        ),
        'mode': 'NEURAL',
        'extra': true,
      });

      expect(plan.mode, PvControlMode.unknown);
    });
  });

  group('entity history', () {
    test('sends ISO UTC bounds and the limit', () async {
      core.on(
        'GET',
        _historyPath,
        (_) => _fixture(
          fixtureJson(
            'HistoryController_getEntityHistory/switch_handwritten.json',
          ),
        ),
      );

      final history = await client.entityHistory(
        _deviceId,
        _relayId,
        from: DateTime.utc(2026, 11, 21, 10, 15),
        to: DateTime.utc(2026, 11, 22, 10, 15),
        limit: 500,
      );

      final query = core.requestsTo('GET', _historyPath).single.options.uri;
      expect(query.queryParameters, {
        'from': '2026-11-21T10:15:00.000Z',
        'to': '2026-11-22T10:15:00.000Z',
        'limit': '500',
      });
      expect(history.samples, hasLength(2));
      expect(history.samples.first.kind, HistorySampleKind.switch_);
      expect(history.samples.first.value, isTrue);
      expect(history.samples.first.numericValue, 1);
      expect(history.samples.last.numericValue, 0);
    });

    test('decodes every kind; an unknown kind is tolerated', () {
      final history = EntityHistory.fromJson(
        fixtureObject(
          'HistoryController_getEntityHistory/mixed_kinds_handwritten.json',
        ),
      );

      expect(history.samples.map((s) => s.kind), [
        HistorySampleKind.temperature,
        HistorySampleKind.energy,
        HistorySampleKind.text,
        HistorySampleKind.unknown,
      ]);
      expect(history.samples.first.numericValue, 45.5);
      expect(history.samples.first.unit, '°C');
      expect(history.samples[2].value, 'idle');
      expect(history.samples[2].numericValue, isNull);
    });

    test('an out-of-range limit is rejected before sending', () {
      expect(
        () => client.entityHistory(_deviceId, _relayId, limit: 0),
        throwsRangeError,
      );
      expect(
        () => client.entityHistory(_deviceId, _relayId, limit: 5001),
        throwsRangeError,
      );
      expect(core.requestsTo('GET', _historyPath), isEmpty);
    });

    test('error codes map to typed failures', () async {
      core.on(
        'GET',
        _historyPath,
        (request) => request.options.uri.queryParameters['limit'] == '1'
            ? _fixture(
                fixtureJson(
                  'HistoryController_getEntityHistory/'
                  'error_entity_not_found_handwritten.json',
                ),
                status: 404,
              )
            : _fixture(
                fixtureJson(
                  'HistoryController_getEntityHistory/'
                  'error_range_invalid_handwritten.json',
                ),
                status: 400,
              ),
      );

      await expectLater(
        client.entityHistory(_deviceId, _relayId, limit: 1),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.code,
            'code',
            'DEVICE_ENTITY_NOT_FOUND',
          ),
        ),
      );
      await expectLater(
        client.entityHistory(_deviceId, _relayId),
        throwsA(
          isA<DomainFailure>().having(
            (f) => f.code,
            'code',
            'HISTORY_RANGE_INVALID',
          ),
        ),
      );
    });

    test(
      'paging continues from the last sample and drops the duplicate',
      () async {
        final from = DateTime.utc(2026, 11, 15);
        final to = DateTime.utc(2026, 11, 22);
        Map<String, Object?> sample(int hour) => {
          'at': from.add(Duration(hours: hour)).toIso8601String(),
          'kind': 'numeric',
          'value': hour,
          'unit': null,
        };
        core.on('GET', _historyPath, (request) {
          final pageFrom = DateTime.parse(
            request.options.uri.queryParameters['from']!,
          );
          final first = pageFrom.difference(from).inHours;
          // Three samples per page (limit 3), 7 samples in total (hours 0-6);
          // the inclusive `from` repeats the boundary sample.
          final hours = [for (var h = first; h < first + 3 && h <= 6; h++) h];
          return FakeResponse.json({
            'entityId': _relayId,
            'from': pageFrom.toIso8601String(),
            'to': to.toIso8601String(),
            'samples': [for (final h in hours) sample(h)],
          });
        });

        final result = await client.entityHistoryAll(
          _deviceId,
          _relayId,
          from: from,
          to: to,
          pageLimit: 3,
        );

        expect(result.complete, isTrue);
        expect(result.samples.map((s) => s.value), [0, 1, 2, 3, 4, 5, 6]);
        expect(
          core
              .requestsTo('GET', _historyPath)
              .map((r) => r.options.uri.queryParameters['from']),
          [
            '2026-11-15T00:00:00.000Z',
            '2026-11-15T02:00:00.000Z',
            '2026-11-15T04:00:00.000Z',
            '2026-11-15T06:00:00.000Z',
          ],
        );
      },
    );

    test('paging stops at maxPages and reports an incomplete range', () async {
      var page = 0;
      core.on('GET', _historyPath, (_) {
        page++;
        return FakeResponse.json({
          'entityId': _relayId,
          'from': '2026-11-15T00:00:00.000Z',
          'to': '2026-11-22T00:00:00.000Z',
          'samples': [
            {
              'at': DateTime.utc(2026, 11, 15, page).toIso8601String(),
              'kind': 'numeric',
              'value': page,
              'unit': null,
            },
          ],
        });
      });

      final result = await client.entityHistoryAll(
        _deviceId,
        _relayId,
        from: DateTime.utc(2026, 11, 15),
        to: DateTime.utc(2026, 11, 22),
        pageLimit: 1,
        maxPages: 2,
      );

      expect(result.complete, isFalse);
      expect(result.samples, hasLength(2));
    });

    test('nextFrom stops on a short page or a stuck boundary', () {
      final page = EntityHistory(
        entityId: _relayId,
        from: DateTime.utc(2026, 11, 15),
        to: DateTime.utc(2026, 11, 22),
        samples: [HistorySample(at: DateTime.utc(2026, 11, 15))],
      );

      expect(HistoryPaging.nextFrom(page, 2), isNull);
      // The only sample sits on `from`: advancing would repeat the request.
      expect(HistoryPaging.nextFrom(page, 1), isNull);
    });

    test('a full page stuck on `from` is reported as incomplete', () async {
      core.on('GET', _historyPath, (_) {
        return FakeResponse.json({
          'entityId': _relayId,
          'from': '2026-11-15T00:00:00.000Z',
          'to': '2026-11-22T00:00:00.000Z',
          'samples': [
            for (final v in [true, false])
              {
                'at': '2026-11-15T00:00:00.000Z',
                'kind': 'switch',
                'value': v,
                'unit': null,
              },
          ],
        });
      });

      final result = await client.entityHistoryAll(
        _deviceId,
        _relayId,
        from: DateTime.utc(2026, 11, 15),
        to: DateTime.utc(2026, 11, 22),
        pageLimit: 2,
      );

      expect(result.complete, isFalse);
      expect(result.samples.map((s) => s.value), [true, false]);
      expect(core.requestsTo('GET', _historyPath), hasLength(1));
    });

    test('mergePages keeps same-instant samples, drops only the boundary', () {
      final from = DateTime.utc(2026, 11, 15);
      final to = DateTime.utc(2026, 11, 22);
      final t1 = from.add(const Duration(hours: 1));
      final t2 = from.add(const Duration(hours: 2));
      HistorySample s(DateTime at, Object v) =>
          HistorySample(at: at, kind: HistorySampleKind.switch_, value: v);
      EntityHistory page(DateTime f, List<HistorySample> samples) =>
          EntityHistory(entityId: _relayId, from: f, to: to, samples: samples);

      final merged = HistoryPaging.mergePages([
        // Two rows at t1 in one page: both stay.
        page(from, [s(from, true), s(t1, true), s(t1, false)]),
        // Boundary repeats both t1 rows; a genuinely new t1 row follows.
        page(t1, [s(t1, true), s(t1, false), s(t1, true), s(t2, false)]),
      ]);

      expect(merged.map((x) => (x.at, x.value)), [
        (from, true),
        (t1, true),
        (t1, false),
        (t1, true),
        (t2, false),
      ]);
    });

    test('slices split a range into consecutive windows', () {
      final slices = HistoryPaging.slices(
        DateTime.utc(2026, 11, 15),
        DateTime.utc(2026, 11, 22, 12),
        const Duration(days: 2),
      );

      expect(slices, hasLength(4));
      expect(slices.first.from, DateTime.utc(2026, 11, 15));
      expect(slices.first.to, DateTime.utc(2026, 11, 17));
      expect(slices.last.to, DateTime.utc(2026, 11, 22, 12));
      expect(
        () => HistoryPaging.slices(
          DateTime.utc(2026),
          DateTime.utc(2027),
          Duration.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  test('a transport failure on a schedule write is not retried', () async {
    core.on('POST', _schedulesPath, (request) {
      throw DioException.receiveTimeout(
        timeout: const Duration(seconds: 15),
        requestOptions: request.options,
      );
    });

    await expectLater(
      client.createSchedule(_deviceId, _input),
      throwsA(isA<TimeoutFailure>()),
    );
    expect(core.requestsTo('POST', _schedulesPath), hasLength(1));
  });
}
