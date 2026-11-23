import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/demo/data/demo_http_client_adapter.dart';

const boilerId = '9d3c6a52-1f0e-4c8b-a6d2-0b7e5f4a1c01';
const sensorId = '9d3c6a52-1f0e-4c8b-a6d2-0b7e5f4a1c02';
const light = 'demo-relay-light';

String demoFixtures() =>
    File('assets/demo_fixtures/demo_core.json').readAsStringSync();

void main() {
  late DateTime now;
  late DemoCore core;

  setUp(() {
    now = DateTime.utc(2026, 11, 20, 8);
    core = DemoCore.fromJsonString(demoFixtures(), now: () => now);
  });

  Map<String, Object?> ok(DemoReply reply) {
    expect(reply.status, 200, reason: '${reply.body}');
    return reply.body! as Map<String, Object?>;
  }

  DeviceDetail detail([String id = boilerId]) => DeviceDetail.fromJson(
    ok(core.handle('GET', '/api/v1/devices/$id', null)),
  );

  void expectError(DemoReply reply, int status, String code) {
    expect(reply.status, status);
    expect((reply.body! as Map)['code'], code);
  }

  DemoReply put(String entityId, Object? body, {String id = boilerId}) =>
      core.handle('PUT', '/api/v1/devices/$id/entities/$entityId/state', body);

  DemoReply suspend({required bool suspended}) => core.handle(
    'PATCH',
    '/api/v1/devices/$boilerId',
    {'heatingSuspended': suspended},
  );

  group('fixtures', () {
    test('are sanitized: no IP addresses and no real accounts', () {
      final text = demoFixtures();
      expect(RegExp(r'\b\d{1,3}(\.\d{1,3}){3}\b').hasMatch(text), isFalse);
      expect(text, isNot(contains('gihome.test')));
      expect(text, isNot(contains('"lastKnownIp": "')));
    });

    test('decode as the app models them', () {
      final setup = SetupStatus.fromJson(
        ok(core.handle('GET', '/api/v1/setup/status', null)),
      );
      expect(setup.initialized, isTrue);
      final list = ok(core.handle('GET', '/api/v1/devices', null));
      final items = [
        for (final item in list['items']! as List)
          DeviceListItem.fromJson(item as Map<String, dynamic>),
      ];
      expect(items.map((d) => d.id), [boilerId, sensorId]);
      final rooms = core.handle('GET', '/api/v1/rooms', null).body! as List;
      expect(
        [for (final r in rooms) Room.fromJson(r as Map<String, dynamic>).name],
        ['Kotłownia', 'Salon'],
      );
      final boiler = detail();
      expect(boiler.communicationMode, CommunicationMode.giEdgeV1);
      expect(boiler.heatingRelayEntityId, 'demo-relay-boiler');
      expect(boiler.diagnostics?.relay(3)?.output, isFalse);
      expect(detail(sensorId).entities, hasLength(1));
      final me = CurrentUser.fromJson(
        ok(core.handle('GET', '/api/v1/auth/me', null)),
      );
      expect(me.role, UserRole.owner);
      final profile = UserProfile.fromJson(
        ok(core.handle('GET', '/api/v1/users/me/profile', null)),
      );
      expect(profile.locale, 'pl-PL');
    });

    test('the list item is the list shape, the detail the detail shape', () {
      final items = ok(core.handle('GET', '/api/v1/devices', null))['items'];
      final item = (items! as List).first as Map;
      expect(item['status'], 'ONLINE');
      expect(item['activeFaultCount'], 0);
      expect(item['currentState'], 'HEATING');
      expect(item.containsKey('entities'), isFalse);
      final raw = ok(core.handle('GET', '/api/v1/devices/$boilerId', null));
      expect(raw['status'], 'online');
      expect(raw.containsKey('createdAt'), isFalse);
    });
  });

  group('routing', () {
    test('answers the public and session routes', () {
      expect(ok(core.handle('GET', '/api/v1/health/live', null)), {
        'status': 'ok',
      });
      final login = ok(
        core.handle('POST', '/api/v1/auth/login', {'email': 'x'}),
      );
      expect(login['user'], isNotNull);
      final refresh = ok(core.handle('POST', '/api/v1/auth/refresh', null));
      expect(refresh.containsKey('user'), isFalse);
      expect(core.handle('POST', '/api/v1/auth/logout', null), (
        status: 204,
        body: null,
      ));
      expect(
        core.handle('POST', '/api/v1/users/me/change-password', {}).status,
        400,
      );
      final system = ok(core.handle('GET', '/api/v1/settings/system', null));
      expect(system['timezone'], 'Europe/Warsaw');
      final updates = ok(
        core.handle('GET', '/api/v1/appliance/updates/status', null),
      );
      expect(updates['configured'], isFalse);
    });

    test('unknown routes and devices answer 404 like GI Core', () {
      expectError(core.handle('GET', '/api/v1/nope', null), 404, 'HTTP_404');
      expectError(core.handle('GET', '/elsewhere', null), 404, 'HTTP_404');
      expectError(
        core.handle('DELETE', '/api/v1/devices/$boilerId', null),
        404,
        'HTTP_404',
      );
      expectError(
        core.handle('GET', '/api/v1/devices/missing', null),
        404,
        'DEVICE_NOT_FOUND',
      );
    });
  });

  group('PUT switch state (GI_EDGE_V1)', () {
    test('writes optimistically; a later heartbeat reports it', () {
      final result = SwitchCommandResult.fromJson(
        ok(put(light, {'state': true})),
      );
      expect(result.state, isTrue);
      expect(result.confirmedAt, now);
      expect(
        detail().entities.firstWhere((e) => e.id == light).value,
        const EntityValue.boolean(true),
      );
      // Before the heartbeat the device has not reported it.
      now = now.add(const Duration(seconds: 2));
      expect(detail().lastSeenAt!.isAfter(result.confirmedAt), isFalse);
      expect(detail().diagnostics?.relay(3)?.output, isFalse);
      now = now.add(const Duration(seconds: 2));
      final after = detail();
      expect(
        after.lastSeenAt,
        result.confirmedAt.add(const Duration(seconds: 3)),
      );
      expect(
        after.diagnostics?.relay(3),
        const RelayDiagnostics(output: true, commanded: true),
      );
    });

    test('rejects like GI Core', () {
      expectError(put(light, 'on'), 400, 'VALIDATION_FAILED');
      expectError(put(light, {'state': 'on'}), 400, 'VALIDATION_FAILED');
      expectError(
        put('missing', {'state': true}),
        404,
        'DEVICE_ENTITY_NOT_FOUND',
      );
      expectError(
        put('demo-supply', {'state': true}),
        422,
        'ENTITY_NOT_WRITABLE',
      );
      expectError(
        put(light, {'state': true}, id: 'missing'),
        404,
        'DEVICE_NOT_FOUND',
      );
    });

    test('a disabled entity answers 409 ENTITY_DISABLED', () {
      final fixtures = jsonDecode(demoFixtures()) as Map<String, Object?>;
      final boiler = (fixtures['devices']! as List).first as Map;
      final entities = boiler['entities'] as List;
      (entities.firstWhere((e) => (e as Map)['id'] == light)
              as Map)['enabled'] =
          false;
      core = DemoCore(fixtures, now: () => now);
      expectError(put(light, {'state': true}), 409, 'ENTITY_DISABLED');
    });

    test('while suspended ON is refused, OFF is allowed', () {
      ok(suspend(suspended: true));
      expectError(put(light, {'state': true}), 409, 'HEATING_SUSPENDED');
      expect(ok(put(light, {'state': false}))['state'], isFalse);
    });
  });

  group('PATCH heatingSuspended', () {
    test(
      'suspending reconciles mode OFF; the heartbeat turns switches off',
      () {
        final version = detail().configurationVersion;
        final item = DeviceListItem.fromJson(ok(suspend(suspended: true)));
        expect(item.heatingSuspended, isTrue);
        expect(item.updatedAt, now);
        final suspended = detail();
        expect(suspended.controlStrategy?.mode, ControlStrategyMode.off);
        expect(suspended.baseControlStrategy?.mode, ControlStrategyMode.auto);
        expect(suspended.configurationVersion, version + 1);
        now = now.add(const Duration(seconds: 3));
        final reported = detail();
        expect(reported.lastSeenAt!.isAfter(item.updatedAt), isTrue);
        for (final n in [1, 2, 3]) {
          expect(
            reported.diagnostics?.relay(n)?.output,
            isFalse,
            reason: 'relay$n',
          );
        }
        expect(reported.diagnostics?.currentState, FirmwareState.idle);
      },
    );

    test('resuming restores the base strategy and the thermostat', () {
      ok(suspend(suspended: true));
      now = now.add(const Duration(seconds: 5));
      detail();
      ok(suspend(suspended: false));
      expect(detail().controlStrategy?.mode, ControlStrategyMode.auto);
      now = now.add(const Duration(seconds: 3));
      // 49.5 °C is below 55 − 4: the boiler relay is commanded on.
      expect(detail().diagnostics?.relay(1)?.output, isTrue);
    });

    test('anything but a lone boolean heatingSuspended is a 400', () {
      for (final body in <Object?>[
        null,
        {'heatingSuspended': 'yes'},
        {'heatingSuspended': true, 'dryRun': true},
      ]) {
        expectError(
          core.handle('PATCH', '/api/v1/devices/$boilerId', body),
          400,
          'VALIDATION_FAILED',
        );
      }
    });
  });

  group('PATCH control-strategy', () {
    DemoReply patch(Object? body) => core.handle(
      'PATCH',
      '/api/v1/devices/$boilerId/control-strategy',
      body,
    );

    test('sets the base strategy; effective follows it', () {
      final result = ControlStrategyUpdateResult.fromJson(
        ok(
          patch({
            'targetTemperatureCelsius': 45,
            'hysteresisCelsius': 3,
            'mode': 'MANUAL',
          }),
        ),
      );
      expect(result.baseControlStrategy?.targetTemperatureCelsius, 45);
      expect(result.controlStrategy, result.baseControlStrategy);
      expect(detail().configurationVersion, result.configurationVersion);
      now = now.add(const Duration(seconds: 3));
      // 49.5 °C is above 45: the boiler relay is commanded off.
      expect(detail().diagnostics?.relay(1)?.output, isFalse);
    });

    test('while suspended the effective mode stays OFF', () {
      ok(suspend(suspended: true));
      final body = ok(
        patch({
          'targetTemperatureCelsius': 60,
          'hysteresisCelsius': 5,
          'mode': 'AUTO',
        }),
      );
      expect((body['controlStrategy']! as Map)['mode'], 'OFF');
      expect((body['baseControlStrategy']! as Map)['mode'], 'AUTO');
    });

    test('out of range or missing fields are a 400', () {
      for (final body in [
        {
          'targetTemperatureCelsius': 101,
          'hysteresisCelsius': 4,
          'mode': 'AUTO',
        },
        {
          'targetTemperatureCelsius': 50,
          'hysteresisCelsius': 0.5,
          'mode': 'AUTO',
        },
        {'targetTemperatureCelsius': 50, 'hysteresisCelsius': 4, 'mode': 'ECO'},
        {'targetTemperatureCelsius': 50, 'hysteresisCelsius': 4},
      ]) {
        expectError(patch(body), 400, 'VALIDATION_FAILED');
      }
    });
  });

  test('without commands the device keeps reporting, never going stale', () {
    final first = detail().lastSeenAt!;
    now = now.add(const Duration(seconds: 10));
    expect(detail().lastSeenAt, first);
    now = now.add(const Duration(seconds: 15));
    expect(detail().lastSeenAt, now);
    expect(core.deviceDetail(sensorId)?['lastSeenAt'], now.toIso8601String());
    expect(core.deviceDetail('missing'), isNull);
  });

  test('responses are copies: callers cannot change the demo state', () {
    final raw = ok(core.handle('GET', '/api/v1/devices/$boilerId', null));
    (raw['entities']! as List).clear();
    expect(detail().entities, isNotEmpty);
  });

  group('DemoHttpClientAdapter', () {
    late Dio dio;
    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: 'https://demo.gi-home.invalid/api/v1',
          validateStatus: (_) => true,
        ),
      )..httpClientAdapter = DemoHttpClientAdapter(core);
    });

    test('passes the JSON body and returns JSON', () async {
      final response = await dio.put<Map<String, dynamic>>(
        '/devices/$boilerId/entities/$light/state',
        data: {'state': true},
      );
      expect(response.statusCode, 200);
      expect(response.data?['state'], isTrue);
      final bad = await dio.put<Object?>(
        '/devices/$boilerId/entities/$light/state',
        data: '{not json',
      );
      expect(bad.statusCode, 400);
    });

    test('sets the refresh cookie on login and refresh only', () async {
      final login = await dio.post<Object?>(
        '/auth/login',
        data: {'email': 'a', 'password': 'b'},
      );
      expect(login.headers['set-cookie'], [DemoCore.setCookie]);
      final refresh = await dio.post<Object?>('/auth/refresh');
      expect(refresh.headers['set-cookie'], isNotNull);
      final me = await dio.get<Object?>('/auth/me');
      expect(me.headers['set-cookie'], isNull);
      final logout = await dio.post<Object?>('/auth/logout');
      expect(logout.statusCode, 204);
    });

    test('answers with the names of the language it is asked for', () async {
      Future<List<String>> roomNames(String Function()? language) async {
        dio.httpClientAdapter = DemoHttpClientAdapter(
          core,
          languageCode: language,
        );
        final response = await dio.get<List<dynamic>>('/rooms');
        return [
          for (final room in response.data!)
            (room as Map<String, dynamic>)['name'] as String,
        ];
      }

      final polish = await roomNames(null);
      expect(polish, contains('Salon'));
      expect(await roomNames(() => 'pl'), polish);
      final english = await roomNames(() => 'en');
      expect(english, contains('Living room'));
      expect(english, isNot(contains('Salon')));
    });

    test('waits for its latency and survives close()', () async {
      dio.httpClientAdapter = DemoHttpClientAdapter(
        core,
        latency: const Duration(milliseconds: 10),
      )..close();
      final response = await dio.get<Map<String, dynamic>>('/health/live');
      expect(response.data, {'status': 'ok'});
    });
  });
}
