import 'package:gi_core_api/gi_core_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

void main() {
  group('recorded fixtures decode', () {
    test('health/live', () {
      expect(
        HealthLive.fromJson(fixtureObject('HealthController_live/ok.json'))
            .isLive,
        isTrue,
      );
    });

    test('setup/status in both states and inside the initialize response', () {
      final initialized = SetupStatus.fromJson(
        fixtureObject('SetupController_getStatus/initialized.json'),
      );
      final fresh = SetupStatus.fromJson(
        fixtureObject('SetupController_getStatus/uninitialized.json'),
      );
      final fromInitialize = SetupStatus.fromJson(
        fixtureObject('SetupController_initialize/ok.json')['setup']
            as Map<String, dynamic>,
      );

      expect(initialized.initialized, isTrue);
      expect(
        initialized.initializedAt,
        DateTime.utc(2026, 11, 17, 22, 6, 20, 184),
      );
      expect(initialized.deviceName, 'GI Home Dev');
      expect(initialized.timezone, 'Europe/Warsaw');
      expect(fresh.initialized, isFalse);
      expect(fresh.initializedAt, isNull);
      expect(fresh.deviceName, isNull);
      expect(fromInitialize, initialized);
    });

    test('auth/login response and auth/me', () {
      final login = LoginResponse.fromJson(
        fixtureObject('AuthController_login/ok.json'),
      );
      final me = CurrentUser.fromJson(
        fixtureObject('AuthController_getMe/owner.json'),
      );

      expect(login.expiresIn, 900);
      expect(login.user, me);
      expect(me.role, UserRole.owner);
      expect(me.lastName, 'Owner');
      expect(me.mustChangePassword, isFalse);
      expect(login.toString(), isNot(contains(login.accessToken)));
    });

    test('users/me/profile', () {
      final profile = UserProfile.fromJson(
        fixtureObject('UsersController_getProfile/owner.json'),
      );

      expect(profile.role, UserRole.owner);
      expect(profile.locale, 'pl-PL');
      expect(profile.enabled, isTrue);
      expect(profile.lastLoginAt, DateTime.utc(2026, 11, 17, 22, 6, 20, 312));
    });

    test('rooms list', () {
      final rooms = [
        for (final json
            in fixtureJson('RoomsController_list/seeded.json')!
                as List<Object?>)
          Room.fromJson(json! as Map<String, dynamic>),
      ];

      expect(rooms.map((r) => r.name), ['Kotłownia', 'Salon']);
      expect(rooms.first.description, isNull);
    });

    test('devices list page', () {
      final page = ListPage.fromJson(
        fixtureObject('DevicesController_list/seeded.json'),
        (json) => DeviceListItem.fromJson(json! as Map<String, dynamic>),
      );

      expect(page.total, 3);
      expect(page.limit, 100);
      expect(page.isTruncated, isFalse);
      final boiler = page.items.singleWhere(
        (d) => d.name == 'Sterownik kotłowni',
      );
      expect(boiler.status, DeviceListStatus.unknown);
      expect(boiler.type, DeviceType.esp32);
      expect(boiler.connectivityState, ConnectivityState.unknown);
      expect(boiler.communicationMode, CommunicationMode.legacyEsphome);
      expect(boiler.inverterIntegrationMode, InverterIntegrationMode.disabled);
      expect(
        boiler.localControlTemperatureSource,
        LocalControlTemperatureSource.supply,
      );
      expect(boiler.currentState, isNull);
      expect(boiler.activeFaultCount, 0);
      expect(boiler.isHeating, isFalse);
      expect(boiler.capabilities, isEmpty);
      expect(page.items.map((d) => d.type), contains(DeviceType.virtual));
    });

    test('device detail', () {
      final detail = DeviceDetail.fromJson(
        fixtureObject('DevicesController_get/no_room_no_entities.json'),
      );

      expect(detail.status, ProductStatus.connecting);
      expect(detail.connectivityState, ConnectivityState.unknown);
      expect(detail.entities, isEmpty);
      expect(detail.diagnostics, isNull);
      expect(detail.controlStrategy, isNull);
      expect(detail.configurationVersion, 1);
      expect(detail.fallbackThresholdMs, 120000);
      expect(detail.pvBoostActive, isFalse);
    });
  });

  group('tolerant decoding', () {
    Map<String, dynamic> device() =>
        (fixtureObject('DevicesController_list/seeded.json')['items']
                    as List<Object?>)
                .first!
            as Map<String, dynamic>;

    test(
      'unknown enum values decode to unknown and unknown keys are ignored',
      () {
        final item = DeviceListItem.fromJson({
          ...device(),
          'status': 'HIBERNATING',
          'type': 'TOASTER',
          'connectivityState': 'SLEEPY',
          'communicationMode': 'GI_EDGE_V9',
          'currentState': 'DANCING',
          'capabilities': [
            {'id': 'c1', 'type': 'TELEPORT'},
            {'id': 'c2', 'type': 'SWITCH'},
          ],
          'brandNewField': {'nested': true},
        });

        expect(item.status, DeviceListStatus.unknown);
        expect(item.type, DeviceType.unknown);
        expect(item.connectivityState, ConnectivityState.unknown);
        expect(item.communicationMode, CommunicationMode.unknown);
        expect(item.currentState, FirmwareState.unknown);
        expect(item.capabilities.map((c) => c.type), [
          CapabilityType.unknown,
          CapabilityType.switch_,
        ]);
      },
    );

    test('the three status vocabularies stay separate', () {
      final listItem = DeviceListItem.fromJson({
        ...device(),
        'status': 'ONLINE',
        'connectivityState': 'STALE',
        'currentState': 'SAFE_MODE',
        'heatingRelayEntityId': 'e1',
      });
      final detail = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'status': 'needs_configuration',
        'connectivityState': 'ONLINE',
      });
      final upperInDetail = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'status': 'ONLINE',
      });

      expect(listItem.status, DeviceListStatus.online);
      expect(listItem.connectivityState, ConnectivityState.stale);
      expect(listItem.currentState!.isCritical, isTrue);
      expect(listItem.isHeating, isTrue);
      expect(detail.status, ProductStatus.needsConfiguration);
      expect(upperInDetail.status, ProductStatus.unknown);
    });

    test('a missing required field fails with its name', () {
      final json = device()..remove('heatingSuspended');

      expect(
        () => DeviceListItem.fromJson(json),
        throwsA(
          isA<CheckedFromJsonException>().having(
            (e) => e.key,
            'key',
            'heatingSuspended',
          ),
        ),
      );
    });

    test('device detail with entities, strategies and diagnostics', () {
      final detail = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'heatingRelayEntityId': 'relay',
        'entities': [
          _entity('relay', domain: 'switch', value: true),
          _entity('temp', domain: 'sensor', value: 21.5, unit: '°C'),
          _entity('mode', domain: 'text_sensor', value: 'eco'),
          _entity('blob', domain: 'climate', value: {'a': 1}),
          _entity('none', domain: 'sensor', value: null),
          _entity('weird', domain: 'hologram', value: [1, 2]),
        ],
        'controlStrategy': {
          'targetTemperatureCelsius': 55,
          'hysteresisCelsius': '4.5',
          'mode': 'AUTO',
        },
        'baseControlStrategy': {
          'targetTemperatureCelsius': 50.5,
          'hysteresisCelsius': 4,
          'mode': 'TURBO',
        },
        'pvHeatingConfig': {
          'mode': 'HYBRID',
          'safeMaxTemperatureCelsius': 60,
          'shortDwellMs': 120000,
          'longDwellMs': 600000,
          'forecastFavorableProductionRatio': 0.4,
        },
        'diagnostics': {
          'currentState': 'HEATING',
          'activeFaults': ['F1', 'F2'],
          'safetyInterlockActive': false,
          'wifi': {'rssi': -60, 'ip': '192.168.1.40'},
          'uptimeMs': 93784000,
          'bootCount': 12,
          'rebootLoopDetected': false,
        },
      });

      expect(detail.isHeating, isTrue);
      expect(
        detail.entityById('relay')!.value,
        const EntityValue.boolean(true),
      );
      expect(detail.entityById('relay')!.domain, EntityDomain.switch_);
      expect(detail.entityById('temp')!.value, const EntityValue.number(21.5));
      expect(detail.entityById('mode')!.domain, EntityDomain.textSensor);
      expect(detail.entityById('mode')!.value, const EntityValue.text('eco'));
      expect(detail.entityById('blob')!.value, isA<EntityValueStructured>());
      expect(detail.entityById('none')!.value, const EntityValue.none());
      expect(detail.entityById('weird')!.domain, EntityDomain.unknown);
      expect(detail.entityById('missing'), isNull);
      expect(detail.entityById(null), isNull);
      expect(detail.controlStrategy!.hysteresisCelsius, 4.5);
      expect(detail.controlStrategy!.mode, ControlStrategyMode.auto);
      expect(detail.baseControlStrategy!.mode, ControlStrategyMode.unknown);
      expect(detail.pvHeatingConfig!.mode, PvControlMode.hybrid);
      expect(detail.diagnostics!.currentState, FirmwareState.heating);
      expect(detail.diagnostics!.activeFaultCount, 2);
      expect(detail.diagnostics!.safetyInterlockActive, isFalse);
      expect(detail.diagnostics!.wifiRssi, -60);
      expect(
        detail.diagnostics!.uptime,
        const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
      );
      expect(detail.diagnostics!.bootCount, 12);
      expect(detail.diagnostics!.rebootLoopDetected, isFalse);
      expect(detail.entityById('blob')!.value.raw, {'a': 1});
    });

    test('diagnostics accessors tolerate missing or mistyped keys', () {
      final odd = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'diagnostics': {
          'currentState': 7,
          'activeFaults': 'many',
          'wifi': -60,
          'uptimeMs': '1 day',
          'bootCount': -1,
          'rebootLoopDetected': 'no',
        },
      });
      final notAnObject = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'diagnostics': ['unexpected'],
      });

      expect(odd.diagnostics!.currentState, isNull);
      expect(odd.diagnostics!.activeFaultCount, isNull);
      expect(odd.diagnostics!.safetyInterlockActive, isNull);
      expect(odd.diagnostics!.wifiRssi, isNull);
      expect(odd.diagnostics!.uptime, isNull);
      expect(odd.diagnostics!.bootCount, isNull);
      expect(odd.diagnostics!.rebootLoopDetected, isNull);
      expect(notAnObject.diagnostics, isNull);
    });

    test('unusable stored blobs hide their section, not the device', () {
      final detail = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'controlStrategy': {'targetTemperatureCelsius': 55, 'mode': 'AUTO'},
        'baseControlStrategy': {
          'targetTemperatureCelsius': 'warm',
          'hysteresisCelsius': 4,
          'mode': 'AUTO',
        },
        'pvHeatingConfig': {'mode': 'HYBRID'},
      });
      final notObjects = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'controlStrategy': 'AUTO',
        'pvHeatingConfig': [60],
      });

      expect(detail.controlStrategy, isNull);
      expect(detail.baseControlStrategy, isNull);
      expect(detail.pvHeatingConfig, isNull);
      expect(notObjects.controlStrategy, isNull);
      expect(notObjects.pvHeatingConfig, isNull);
    });

    test('a legacy PV configuration takes the backend defaults', () {
      final detail = DeviceDetail.fromJson({
        ...fixtureObject('DevicesController_get/no_room_no_entities.json'),
        'pvHeatingConfig': {
          'mode': 'FORECAST_ONLY',
          'safeMaxTemperatureCelsius': 58,
          'longDwellMs': 'long',
        },
      });

      expect(
        detail.pvHeatingConfig,
        const PvHeatingConfig(
          mode: PvControlMode.forecastOnly,
          safeMaxTemperatureCelsius: 58,
          shortDwellMs: 120000,
          longDwellMs: 600000,
          forecastFavorableProductionRatio: 0.4,
        ),
      );
    });

    test('a non-numeric temperature fails decoding', () {
      expect(
        () => ControlStrategy.fromJson({
          'targetTemperatureCelsius': 'warm',
          'hysteresisCelsius': 4,
          'mode': 'AUTO',
        }),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });

  group('request bodies', () {
    test('send exactly the keys the ValidationPipe allows', () {
      const login = LoginRequest(email: 'a@b.c', password: 'secret');
      const change = ChangePasswordRequest(
        currentPassword: 'Old12345',
        newPassword: 'New12345',
      );

      expect(login.toJson().keys, unorderedEquals(['email', 'password']));
      expect(
        change.toJson().keys,
        unorderedEquals(['currentPassword', 'newPassword']),
      );
      expect(login.toString(), isNot(contains('secret')));
      expect(change.toString(), isNot(contains('New12345')));
    });
  });
}

Map<String, Object?> _entity(
  String id, {
  required String domain,
  required Object? value,
  String? unit,
}) => {
  'id': id,
  'displayName': id,
  'sourceName': id,
  'domain': domain,
  'deviceClass': null,
  'value': value,
  'unit': unit,
  'readable': true,
  'writable': domain == 'switch',
  'availability': true,
  'lastSeenAt': '2026-11-17T22:06:20.000Z',
  'assignedFunction': {'code': 'HEATING', 'name': 'Grzanie'},
  'assignedRole': null,
  'enabled': true,
};
