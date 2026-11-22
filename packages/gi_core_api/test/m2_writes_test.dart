import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/fake_core.dart';

const _deviceId = '5f0c1b9e-3a7d-4c2e-8b6f-0d1e2f3a4b5c';
const _entityId = '9b1d6c2e-4f3a-4e8b-9c1d-2a3b4c5d6e7f';
const _statePath = '/devices/$_deviceId/entities/$_entityId/state';
const _devicePath = '/devices/$_deviceId';
const _strategyPath = '/devices/$_deviceId/control-strategy';

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
    final writes = [
      GiEndpoints.setSwitchState,
      GiEndpoints.updateDevice,
      GiEndpoints.updateControlStrategy,
    ];

    test('M2 writes are OWNER/ADMIN only and never retried', () {
      for (final endpoint in writes) {
        expect(endpoint.allows(UserRole.owner), isTrue, reason: '$endpoint');
        expect(endpoint.allows(UserRole.admin), isTrue, reason: '$endpoint');
        expect(endpoint.allows(UserRole.user), isFalse, reason: '$endpoint');
        expect(endpoint.allows(UserRole.service), isFalse);
        expect(endpoint.allows(UserRole.unknown), isFalse);
        expect(endpoint.maxRetries, 0);
        expect(endpoint.isIdempotent, isFalse);
        expect(endpoint.requiresAuth, isTrue);
        expect(endpoint.timeout, TimeoutClass.write);
        expect(endpoint.milestone, Milestone.m2);
      }
      expect(GiEndpoints.setSwitchState.method, HttpMethod.put);
      expect(GiEndpoints.updateDevice.method, HttpMethod.patch);
      expect(GiEndpoints.updateControlStrategy.method, HttpMethod.patch);
    });

    test('the switch path needs both placeholders', () {
      expect(
        GiEndpoints.setSwitchState.resolvePath({
          'id': _deviceId,
          'entityId': _entityId,
        }),
        _statePath,
      );
      expect(
        () => GiEndpoints.setSwitchState.resolvePath({'id': _deviceId}),
        throwsArgumentError,
      );
    });

    test('settings and update status roles', () {
      expect(GiEndpoints.settingsSystem.allows(UserRole.service), isTrue);
      expect(GiEndpoints.settingsSystem.allows(UserRole.user), isFalse);
      expect(GiEndpoints.applianceUpdatesStatus.allows(UserRole.admin), isTrue);
      expect(
        GiEndpoints.applianceUpdatesStatus.allows(UserRole.service),
        isFalse,
      );
      expect(GiEndpoints.applianceUpdatesStatus.allows(UserRole.user), isFalse);
    });
  });

  group('setSwitchState', () {
    test('sends exactly {"state": bool}; legacy success decodes', () async {
      core.on(
        'PUT',
        _statePath,
        (_) => FakeResponse.json(
          fixtureJson(
            'DeviceEspHomeSyncController_setSwitchState/'
            'legacy_ok_handwritten.json',
          ),
        ),
      );

      final result = await client.setSwitchState(
        _deviceId,
        _entityId,
        state: true,
      );

      final request = core.requestsTo('PUT', _statePath).single;
      expect(request.json, {'state': true});
      expect(request.header('authorization'), 'Bearer access-1');
      expect(result.entityId, _entityId);
      expect(result.state, isTrue);
      expect(result.availability, isTrue);
      expect(result.confirmedAt, DateTime.utc(2026, 11, 20, 10, 15, 2, 481));
    });

    test('GI Edge optimistic: state is the request, at request time', () {
      final result = SwitchCommandResult.fromJson(
        fixtureObject(
          'DeviceEspHomeSyncController_setSwitchState/'
          'gi_edge_requested_handwritten.json',
        ),
      );

      expect(result.state, isTrue);
      expect(result.confirmedAt, DateTime.utc(2026, 11, 20, 10, 16));
    });

    test('GI Edge dry-run: state is the OLD value', () async {
      core.on(
        'PUT',
        _statePath,
        (_) => FakeResponse.json(
          fixtureJson(
            'DeviceEspHomeSyncController_setSwitchState/'
            'gi_edge_dry_run_handwritten.json',
          ),
        ),
      );

      final result = await client.setSwitchState(
        _deviceId,
        _entityId,
        state: true,
      );

      expect(core.requestsTo('PUT', _statePath).single.json, {'state': true});
      expect(result.state, isFalse);
    });

    test('state and availability pass through any JSON value', () {
      final result = SwitchCommandResult.fromJson({
        'entityId': _entityId,
        'state': 'on',
        'availability': null,
        'confirmedAt': '2026-11-20T10:00:00.000Z',
        'extra': 1,
      });

      expect(result.state, 'on');
      expect(result.availability, isNull);
    });

    test('sends false too', () async {
      core.on(
        'PUT',
        _statePath,
        (_) => FakeResponse.json({
          'entityId': _entityId,
          'state': false,
          'availability': true,
          'confirmedAt': '2026-11-20T10:00:00.000Z',
        }),
      );

      await client.setSwitchState(_deviceId, _entityId, state: false);

      expect(core.requestsTo('PUT', _statePath).single.json, {'state': false});
    });

    for (final status in [502, 503, 504]) {
      test('a $status is never retried', () async {
        core.on(
          'PUT',
          _statePath,
          (_) => FakeResponse.error(status, 'ESPHOME_COMMAND_TIMEOUT'),
        );

        await expectLater(
          client.setSwitchState(_deviceId, _entityId, state: true),
          throwsA(isA<ServerFailure>()),
        );
        expect(core.requestsTo('PUT', _statePath), hasLength(1));
      });
    }

    test('a transport timeout is never retried', () async {
      core.on('PUT', _statePath, (request) => throw receiveTimeout(request));

      await expectLater(
        client.setSwitchState(_deviceId, _entityId, state: true),
        throwsA(
          isA<TimeoutFailure>().having(
            (f) => f.isCommandOutcomeUnknown,
            'unknown outcome',
            isTrue,
          ),
        ),
      );
      expect(core.requestsTo('PUT', _statePath), hasLength(1));
    });

    test('a 401 refreshes and replays the write exactly once', () async {
      core.on(
        'PUT',
        _statePath,
        (request) => request.header('authorization') == 'Bearer access-2'
            ? FakeResponse.json(
                fixtureJson(
                  'DeviceEspHomeSyncController_setSwitchState/'
                  'legacy_ok_handwritten.json',
                ),
              )
            : FakeResponse.error(401, 'AUTH_ACCESS_TOKEN_EXPIRED'),
      );

      await client.setSwitchState(_deviceId, _entityId, state: true);

      expect(core.requestsTo('PUT', _statePath), hasLength(2));
      expect(core.requestsTo('POST', '/auth/refresh'), hasLength(1));
    });
  });

  group('setHeatingSuspended', () {
    test('sends ONLY heatingSuspended and decodes the list shape', () async {
      core.on(
        'PATCH',
        _devicePath,
        (_) => FakeResponse.json(
          fixtureJson('DevicesController_update/suspended_handwritten.json'),
        ),
      );

      final device = await client.setHeatingSuspended(
        _deviceId,
        suspended: true,
      );

      final request = core.requestsTo('PATCH', _devicePath).single;
      expect(request.json, {'heatingSuspended': true});
      expect(device.heatingSuspended, isTrue);
      expect(device.status, DeviceListStatus.online);
      expect(device.currentState, FirmwareState.idle);
      expect(device.activeFaultCount, 0);
      expect(device.isHeating, isTrue);
    });

    test('resume sends false; a 503 is not retried', () async {
      core.on(
        'PATCH',
        _devicePath,
        (_) => FakeResponse.html('<html/>', status: 503),
      );

      await expectLater(
        client.setHeatingSuspended(_deviceId, suspended: false),
        throwsA(isA<ServerFailure>()),
      );
      final requests = core.requestsTo('PATCH', _devicePath);
      expect(requests, hasLength(1));
      expect(requests.single.json, {'heatingSuspended': false});
    });

    test('an unknown status decodes to unknown', () {
      final json = fixtureObject(
        'DevicesController_update/suspended_handwritten.json',
      )..['status'] = 'HIBERNATING';

      expect(DeviceListItem.fromJson(json).status, DeviceListStatus.unknown);
    });
  });

  group('updateControlStrategy', () {
    test('sends all three fields and decodes effective and base', () async {
      core.on(
        'PATCH',
        _strategyPath,
        (_) => FakeResponse.json(
          fixtureJson(
            'DevicesController_updateControlStrategy/ok_handwritten.json',
          ),
        ),
      );

      final result = await client.updateControlStrategy(
        _deviceId,
        targetTemperatureCelsius: 55,
        hysteresisCelsius: 4,
        mode: ControlStrategyMode.manual,
      );

      expect(core.requestsTo('PATCH', _strategyPath).single.json, {
        'targetTemperatureCelsius': 55.0,
        'hysteresisCelsius': 4.0,
        'mode': 'MANUAL',
      });
      expect(result.configurationVersion, 7);
      expect(result.controlStrategy, result.baseControlStrategy);
      expect(result.baseControlStrategy?.mode, ControlStrategyMode.manual);
      expect(result.baseControlStrategy?.targetTemperatureCelsius, 55);
    });

    test('while suspended the effective mode is OFF, base keeps its mode', () {
      final result = ControlStrategyUpdateResult.fromJson(
        fixtureObject(
          'DevicesController_updateControlStrategy/'
          'suspended_handwritten.json',
        ),
      );

      expect(result.controlStrategy?.mode, ControlStrategyMode.off);
      expect(result.baseControlStrategy?.mode, ControlStrategyMode.auto);
      expect(result.configurationVersion, 12);
    });

    test('null strategies decode to null', () {
      final result = ControlStrategyUpdateResult.fromJson(
        fixtureObject(
          'DevicesController_updateControlStrategy/'
          'null_base_handwritten.json',
        ),
      );

      expect(result.controlStrategy, isNull);
      expect(result.baseControlStrategy, isNull);
      expect(result.configurationVersion, 1);
    });

    test('unknown mode, extra fields and broken blobs are tolerated', () {
      final result = ControlStrategyUpdateResult.fromJson({
        'controlStrategy': {
          'targetTemperatureCelsius': '50.5',
          'hysteresisCelsius': 3,
          'mode': 'TURBO',
        },
        'baseControlStrategy': {'mode': 'AUTO'},
        'configurationVersion': 3,
        'somethingNew': true,
      });

      expect(result.controlStrategy?.mode, ControlStrategyMode.unknown);
      expect(result.controlStrategy?.targetTemperatureCelsius, 50.5);
      expect(result.baseControlStrategy, isNull);
    });

    for (final (target, hysteresis, mode) in [
      (-0.1, 4.0, ControlStrategyMode.auto),
      (100.5, 4.0, ControlStrategyMode.auto),
      (double.nan, 4.0, ControlStrategyMode.auto),
      (50.0, 0.5, ControlStrategyMode.auto),
      (50.0, 20.5, ControlStrategyMode.auto),
      (50.0, double.infinity, ControlStrategyMode.auto),
      (50.0, 4.0, ControlStrategyMode.unknown),
    ]) {
      test('rejects $target/$hysteresis/${mode.name} before sending', () {
        expect(
          () => client.updateControlStrategy(
            _deviceId,
            targetTemperatureCelsius: target,
            hysteresisCelsius: hysteresis,
            mode: mode,
          ),
          throwsArgumentError,
        );
        expect(core.requestsTo('PATCH', _strategyPath), isEmpty);
      });
    }

    test('accepts the bounds and sends OFF and AUTO', () async {
      core.on(
        'PATCH',
        _strategyPath,
        (_) => FakeResponse.json(
          fixtureJson(
            'DevicesController_updateControlStrategy/ok_handwritten.json',
          ),
        ),
      );

      await client.updateControlStrategy(
        _deviceId,
        targetTemperatureCelsius: 0,
        hysteresisCelsius: 1,
        mode: ControlStrategyMode.off,
      );
      await client.updateControlStrategy(
        _deviceId,
        targetTemperatureCelsius: 100,
        hysteresisCelsius: 20,
        mode: ControlStrategyMode.auto,
      );

      final modes = [
        for (final r in core.requestsTo('PATCH', _strategyPath))
          r.json!['mode'],
      ];
      expect(modes, ['OFF', 'AUTO']);
    });
  });

  group('settings and update status', () {
    test('systemSettings decodes the recorded fixture', () async {
      core.on(
        'GET',
        '/settings/system',
        (_) => FakeResponse.json(
          fixtureJson('SettingsController_getSystem/ok.json'),
        ),
      );

      final settings = await client.systemSettings();

      expect(settings.deviceName, 'GI Home Dev');
      expect(settings.locale, 'pl-PL');
      expect(settings.timezone, 'Europe/Warsaw');
    });

    test('an unconfigured appliance has no running version', () async {
      core.on(
        'GET',
        '/appliance/updates/status',
        (_) => FakeResponse.json(
          fixtureJson(
            'ApplianceUpdateController_getStatus/'
            'unconfigured_handwritten.json',
          ),
        ),
      );

      final status = await client.applianceUpdateStatus();

      expect(status.configured, isFalse);
      expect(status.lastCheck, isNull);
      expect(status.runningVersion(), isNull);
    });

    test('the last check gives the running version per service', () {
      final status = ApplianceUpdateStatus.fromJson(
        fixtureObject(
          'ApplianceUpdateController_getStatus/checked_handwritten.json',
        ),
      );

      expect(status.configured, isTrue);
      expect(status.runningVersion(), '1.4.2');
      expect(status.runningVersion('gi-supervisor'), isNull);
      expect(status.lastCheck?.updateAvailable, isTrue);
      expect(status.lastInstall?.services, ['gi-core']);
    });
  });

  group('error codes', () {
    final table = <(int, String, Matcher)>[
      (404, GiErrorCodes.deviceEntityNotFound, isA<NotFoundFailure>()),
      (404, GiErrorCodes.deviceNotFound, isA<NotFoundFailure>()),
      (409, GiErrorCodes.heatingSuspended, isA<DomainFailure>()),
      (409, GiErrorCodes.entityDisabled, isA<DomainFailure>()),
      (422, GiErrorCodes.entityNotWritable, isA<DomainFailure>()),
      (503, GiErrorCodes.deviceOffline, isA<ServerFailure>()),
      (503, GiErrorCodes.espHomeDeviceUnreachable, isA<ServerFailure>()),
      (502, GiErrorCodes.espHomeCommandRejected, isA<ServerFailure>()),
      (502, GiErrorCodes.espHomeCommandUnconfirmed, isA<ServerFailure>()),
      (504, GiErrorCodes.espHomeCommandTimeout, isA<ServerFailure>()),
      (400, GiErrorCodes.espHomeHostForbidden, isA<DomainFailure>()),
      (400, GiErrorCodes.validationFailed, isA<ValidationFailure>()),
      (403, GiErrorCodes.forbidden, isA<ForbiddenFailure>()),
    ];
    const unknownOutcome = {
      GiErrorCodes.espHomeCommandRejected,
      GiErrorCodes.espHomeCommandUnconfirmed,
      GiErrorCodes.espHomeCommandTimeout,
    };

    for (final (status, code, matcher) in table) {
      test('$status $code', () async {
        core
          ..on('PUT', _statePath, (_) => FakeResponse.error(status, code))
          // An RBAC 403 reloads the user once.
          ..on(
            'GET',
            '/auth/me',
            (_) => FakeResponse.json(
              fixtureJson('AuthController_getMe/owner.json'),
            ),
          );

        ApiFailure? failure;
        try {
          await client.setSwitchState(_deviceId, _entityId, state: true);
        } on ApiFailure catch (e) {
          failure = e;
        }

        expect(failure, matcher);
        expect(failure!.code, code);
        expect(failure.requestId, 'srv-req-err');
        expect(failure.isCommandOutcomeUnknown, unknownOutcome.contains(code));
        expect(core.requestsTo('PUT', _statePath), hasLength(1));
      });
    }

    test('only command failures have an unknown outcome', () {
      expect(const ApiFailure.unreachable().isCommandOutcomeUnknown, isFalse);
      expect(
        const ApiFailure.server(statusCode: 502).isCommandOutcomeUnknown,
        isFalse,
      );
    });
  });

  group('DeviceDiagnostics.relay', () {
    test('reads relayN output and commanded', () {
      const diagnostics = DeviceDiagnostics({
        'relay1': {'output': false, 'commanded': true},
        'relay2': {'output': true},
      });

      expect(
        diagnostics.relay(1),
        const RelayDiagnostics(output: false, commanded: true),
      );
      expect(diagnostics.relay(2), const RelayDiagnostics(output: true));
    });

    test('missing or malformed relays are null-safe', () {
      const diagnostics = DeviceDiagnostics({
        'relay1': true,
        'relay2': {'output': 'on', 'commanded': 1},
      });

      expect(diagnostics.relay(1), isNull);
      expect(diagnostics.relay(3), isNull);
      expect(diagnostics.relay(2), const RelayDiagnostics());
      expect(const DeviceDiagnostics({}).relay(1), isNull);
    });

    test('decoded heartbeats keep nested relays', () {
      final diagnostics = const DeviceDiagnosticsConverter().fromJson({
        'relay1': {'output': true, 'commanded': true},
      });

      expect(diagnostics?.relay(1)?.output, isTrue);
    });
  });
}
