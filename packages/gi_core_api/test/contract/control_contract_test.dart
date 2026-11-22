/// Live contract of the M2 control paths (plan §12, §20 M2 item 8) on the
/// fake device of a contract stack: switching through
/// `PUT /devices/:id/entities/:entityId/state`, heating suspend/resume
/// through `PATCH /devices/:id` and the control strategy through
/// `PATCH /devices/:id/control-strategy`. Strict decoding throughout.
///
/// The fake device is LEGACY_ESPHOME: GI Core switches it synchronously and
/// confirms from the device's echo. The GI Edge paths (optimistic write,
/// dry-run returning the old state, heartbeat confirmation), DEVICE_OFFLINE,
/// the ESPHOME 502/503/504 codes, PV boost and FAULT are not reachable here;
/// they are covered by hand-written fixtures (`m2_writes_test.dart`) and the
/// mock Core (`tools/lib/src/mock_core`).
///
/// Every test restores what it changed (relay OFF, entity enabled, not
/// suspended, dry-run off, the seeded 55 °C / 4 K / MANUAL strategy), also
/// when it fails. Runs only on a Core seeded for contract use; without the
/// fake device the group is skipped, unless `FAKE_ESPHOME_URL` is set.
///
/// This file and `devices_contract_test.dart` both switch the same relay:
/// run the contract suites with `-j 1` (`dart test -t contract -j 1`).
///
/// Logins: the seeded ADMIN, USER and SERVICE (three).
@Tags(['contract'])
library;

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.setSwitchState,
  GiEndpoints.updateDevice,
  GiEndpoints.updateControlStrategy,
];

/// The strategy `tools/seed_core.dart` sets (step 7).
const Map<String, Object> _seeded = {
  'targetTemperatureCelsius': 55,
  'hysteresisCelsius': 4,
  'mode': 'MANUAL',
};

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final fakeUrl = ContractEnv.fakeEsphomeUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('control paths on the fake device', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    late String deviceId;
    late String relayId;
    late String sensorId;
    String? notSeeded;

    Future<Response<Object?>> send(
      GiCoreClient client,
      String method,
      String path, {
      Object? data,
    }) async => await raw.request<Object?>(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {
          'authorization': 'Bearer ${await client.session.accessToken()}',
        },
      ),
    );

    Future<Response<Object?>> asAdmin(
      String method,
      String path, {
      Object? data,
    }) => send(admin, method, path, data: data);

    String statePath(String entityId) =>
        '/devices/$deviceId/entities/$entityId/state';

    void expectError(Response<Object?> response, int status, String code) {
      expect(response.statusCode, status, reason: '${response.data}');
      expect(
        ApiErrorEnvelope.tryParse(response.data)?.code,
        code,
        reason: '${response.data}',
      );
    }

    /// The relay state as the fake device itself reports it; null without
    /// `FAKE_ESPHOME_URL`.
    Future<bool?> physicalRelay() async {
      if (fakeUrl == null) return null;
      final response = await Dio().get<Map<String, dynamic>>(
        '$fakeUrl/fake/state',
      );
      return response.data!['relayOn'] as bool;
    }

    /// Re-reads the device until [done] holds (the server applies the
    /// suspension's consequences asynchronously, plan §12.1).
    Future<DeviceDetail> pollDevice(
      bool Function(DeviceDetail device) done, {
      Duration timeout = const Duration(seconds: 20),
    }) async {
      final deadline = DateTime.now().add(timeout);
      while (true) {
        final device = await admin.device(deviceId);
        if (done(device)) return device;
        if (DateTime.now().isAfter(deadline)) {
          fail(
            'device did not settle within $timeout: '
            'suspended=${device.heatingSuspended} '
            'effective=${device.controlStrategy} '
            'base=${device.baseControlStrategy}',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    /// Back to the seeder's state, whatever a test left behind.
    Future<void> restore() async {
      final device = await admin.device(deviceId);
      final relay = device.entities.firstWhere((e) => e.id == relayId);
      if (!relay.enabled) {
        await asAdmin(
          'PATCH',
          '/devices/$deviceId/entities/$relayId',
          data: {'enabled': true},
        );
      }
      if (device.heatingSuspended || device.dryRun) {
        await asAdmin(
          'PATCH',
          '/devices/$deviceId',
          data: {'heatingSuspended': false, 'dryRun': false},
        );
      }
      if (relay.value != const EntityValue.boolean(false)) {
        await asAdmin('PUT', statePath(relayId), data: {'state': false});
      }
      final strategy = device.baseControlStrategy;
      if (strategy == null ||
          strategy.targetTemperatureCelsius != 55 ||
          strategy.hysteresisCelsius != 4 ||
          strategy.mode != ControlStrategyMode.manual) {
        await asAdmin(
          'PATCH',
          '/devices/$deviceId/control-strategy',
          data: _seeded,
        );
      }
    }

    setUpAll(() async {
      raw = rawDio(probe!.address);
      admin = strictClient(
        address: probe.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      void notContractSeeded(String reason) {
        notSeeded = '$reason: not a Core seeded for contract use';
        if (fakeUrl != null) fail('$notSeeded, but FAKE_ESPHOME_URL is set');
      }

      final account = ContractEnv.seededAccount('ADMIN');
      try {
        await respectingLoginLimit(
          () => admin.login(email: account.email, password: account.password),
        );
      } on UnauthorizedFailure {
        return notContractSeeded('no seeded ADMIN at $base');
      }

      final fake = (await admin.devices()).items.where(FakeDevice.matches);
      if (fake.isEmpty) return notContractSeeded('no fake device at $base');
      deviceId = fake.single.id;
      final detail = await admin.device(deviceId);
      relayId = detail.heatingRelayEntityId!;
      sensorId = detail.controlTemperatureEntityId!;
      await restore();
    });

    tearDownAll(() async {
      await admin.close();
      raw.close();
    });

    void seededTest(String description, Future<void> Function() body) =>
        test(description, () async {
          if (notSeeded case final reason?) {
            markTestSkipped(reason);
            return;
          }
          addTearDown(restore);
          await body();
        });

    group('PUT state', () {
      seededTest(
        'ON then OFF: confirmed synchronously by the device',
        () async {
          for (final state in [true, false]) {
            final result = await admin.setSwitchState(
              deviceId,
              relayId,
              state: state,
            );

            expect(result.entityId, relayId);
            expect(result.state, state);
            expect(result.availability, isTrue);
            final physical = await physicalRelay();
            if (physical != null) expect(physical, state);

            // LEGACY_ESPHOME writes the confirmed value at confirmedAt.
            final relay = (await admin.device(deviceId)).entities
                .firstWhere((e) => e.id == relayId);
            expect(relay.value, EntityValue.boolean(state));
            expect(relay.availability, isTrue);
            expect(relay.lastSeenAt, result.confirmedAt);
          }
        },
      );

      seededTest('unknown entity: 404 DEVICE_ENTITY_NOT_FOUND', () async {
        final entity = 'contract-${Random().nextInt(1 << 32)}';

        expectError(
          await asAdmin('PUT', statePath(entity), data: {'state': false}),
          404,
          'DEVICE_ENTITY_NOT_FOUND',
        );
      });

      seededTest('non-boolean state: 400 VALIDATION_FAILED', () async {
        for (final state in ['on', 1, null]) {
          expectError(
            await asAdmin('PUT', statePath(relayId), data: {'state': state}),
            400,
            'VALIDATION_FAILED',
          );
        }
        expectError(
          await asAdmin('PUT', statePath(relayId), data: <String, Object>{}),
          400,
          'VALIDATION_FAILED',
        );
        expect(await physicalRelay(), anyOf(isNull, isFalse));
      });

      seededTest('device id that is not a UUID: 400', () async {
        final response = await asAdmin(
          'PUT',
          '/devices/not-a-uuid/entities/$relayId/state',
          data: {'state': false},
        );

        expect(response.statusCode, 400, reason: '${response.data}');
        expect(ApiErrorEnvelope.tryParse(response.data), isNotNull);
      });

      seededTest('the temperature sensor: 422 ENTITY_NOT_WRITABLE', () async {
        expectError(
          await asAdmin('PUT', statePath(sensorId), data: {'state': true}),
          422,
          'ENTITY_NOT_WRITABLE',
        );
      });

      seededTest('a disabled entity: 409 ENTITY_DISABLED', () async {
        final disable = await asAdmin(
          'PATCH',
          '/devices/$deviceId/entities/$relayId',
          data: {'enabled': false},
        );
        expect(disable.statusCode, 200, reason: '${disable.data}');

        expectError(
          await asAdmin('PUT', statePath(relayId), data: {'state': true}),
          409,
          'ENTITY_DISABLED',
        );
        expect(await physicalRelay(), anyOf(isNull, isFalse));
        // restore() enables it again.
      });
    });

    group('suspend and resume (PATCH /devices/:id)', () {
      seededTest('suspended: ON refused with 409, OFF allowed, mode OFF; '
          'resume restores the base mode', () async {
        final suspended = await admin.setHeatingSuspended(
          deviceId,
          suspended: true,
        );
        expect(suspended.id, deviceId);
        expect(suspended.heatingSuspended, isTrue);

        expectError(
          await asAdmin('PUT', statePath(relayId), data: {'state': true}),
          409,
          'HEATING_SUSPENDED',
        );
        expect(await physicalRelay(), anyOf(isNull, isFalse));
        // Turning OFF is always allowed while suspended.
        final off = await admin.setSwitchState(deviceId, relayId, state: false);
        expect(off.state, isFalse);

        // The effective strategy goes OFF asynchronously; the base keeps
        // the user's mode. The suspension's relay TURN_OFF is a GI Edge
        // MQTT command and never reaches this legacy device, so the
        // physical relay is not asserted here.
        final whileSuspended = await pollDevice(
          (d) => d.controlStrategy?.mode == ControlStrategyMode.off,
        );
        expect(whileSuspended.heatingSuspended, isTrue);
        expect(
          whileSuspended.baseControlStrategy?.mode,
          ControlStrategyMode.manual,
        );
        expect(
          whileSuspended.controlStrategy?.targetTemperatureCelsius,
          whileSuspended.baseControlStrategy?.targetTemperatureCelsius,
        );
        expect(
          whileSuspended.controlStrategy?.hysteresisCelsius,
          whileSuspended.baseControlStrategy?.hysteresisCelsius,
        );

        final resumed = await admin.setHeatingSuspended(
          deviceId,
          suspended: false,
        );
        expect(resumed.heatingSuspended, isFalse);
        final after = await pollDevice(
          (d) => d.controlStrategy?.mode == ControlStrategyMode.manual,
        );
        expect(after.heatingSuspended, isFalse);
        expect(after.controlStrategy, after.baseControlStrategy);

        // ON is accepted again.
        final on = await admin.setSwitchState(deviceId, relayId, state: true);
        expect(on.state, isTrue);
      });

      seededTest('dryRun is ignored on the legacy path: the device still '
          'switches, the flag only shows in details', () async {
        final patched = await asAdmin(
          'PATCH',
          '/devices/$deviceId',
          data: {'dryRun': true},
        );
        expect(patched.statusCode, 200, reason: '${patched.data}');
        expect((await admin.device(deviceId)).dryRun, isTrue);

        final on = await admin.setSwitchState(deviceId, relayId, state: true);
        expect(on.state, isTrue);
        final physical = await physicalRelay();
        if (physical != null) expect(physical, isTrue);
        final relay = (await admin.device(deviceId)).entities
            .firstWhere((e) => e.id == relayId);
        expect(relay.value, const EntityValue.boolean(true));
        // restore() switches OFF and clears dryRun.
      });
    });

    group('PATCH control-strategy', () {
      seededTest('answers effective and base strategy; without schedules '
          'they are equal; the version increases', () async {
        final before = (await admin.device(deviceId)).configurationVersion;
        final result = await admin.updateControlStrategy(
          deviceId,
          targetTemperatureCelsius: 48.5,
          hysteresisCelsius: 3,
          mode: ControlStrategyMode.auto,
        );

        expect(
          result.baseControlStrategy,
          const ControlStrategy(
            targetTemperatureCelsius: 48.5,
            hysteresisCelsius: 3,
            mode: ControlStrategyMode.auto,
          ),
        );
        expect(result.controlStrategy, result.baseControlStrategy);
        expect(result.configurationVersion, greaterThan(before));

        final detail = await admin.device(deviceId);
        expect(detail.baseControlStrategy, result.baseControlStrategy);
        expect(detail.controlStrategy, result.controlStrategy);
        expect(
          detail.configurationVersion,
          greaterThanOrEqualTo(result.configurationVersion),
        );
      });

      seededTest('out of range or incomplete: 400 VALIDATION_FAILED, '
          'nothing changes', () async {
        final before = await admin.device(deviceId);
        for (final body in <Map<String, Object?>>[
          {..._seeded, 'targetTemperatureCelsius': 101},
          {..._seeded, 'targetTemperatureCelsius': -1},
          {..._seeded, 'hysteresisCelsius': 0.5},
          {..._seeded, 'hysteresisCelsius': 21},
          {..._seeded, 'mode': 'BOOST'},
          {'targetTemperatureCelsius': 50, 'hysteresisCelsius': 4},
          {'targetTemperatureCelsius': 50, 'mode': 'AUTO'},
          {'hysteresisCelsius': 4, 'mode': 'AUTO'},
        ]) {
          expectError(
            await asAdmin(
              'PATCH',
              '/devices/$deviceId/control-strategy',
              data: body,
            ),
            400,
            'VALIDATION_FAILED',
          );
        }

        final after = await admin.device(deviceId);
        expect(after.baseControlStrategy, before.baseControlStrategy);
      });

      seededTest(
        'while suspended the answer already carries mode OFF',
        () async {
          await admin.setHeatingSuspended(deviceId, suspended: true);
          await pollDevice(
            (d) => d.controlStrategy?.mode == ControlStrategyMode.off,
          );

          final result = await admin.updateControlStrategy(
            deviceId,
            targetTemperatureCelsius: 50,
            hysteresisCelsius: 5,
            mode: ControlStrategyMode.manual,
          );

          expect(result.baseControlStrategy?.mode, ControlStrategyMode.manual);
          expect(result.controlStrategy?.mode, ControlStrategyMode.off);
          expect(result.controlStrategy?.targetTemperatureCelsius, 50);
          expect(result.controlStrategy?.hysteresisCelsius, 5);
        },
      );
    });

    group('role gating (plan §12, HTTP_403)', () {
      for (final role in ['USER', 'SERVICE']) {
        seededTest('$role may read but not switch, suspend or change the '
            'strategy', () async {
          final client = strictClient(
            address: probe!.address,
            vault: InMemoryTokenVault(),
            expectedInitializedAt: probe.setup.initializedAt,
          );
          addTearDown(client.close);
          final account = ContractEnv.seededAccount(role);
          final user = await respectingLoginLimit(
            () =>
                client.login(email: account.email, password: account.password),
          );
          expect(user.role.name.toUpperCase(), role);
          final before = await admin.device(deviceId);

          for (final (method, path, data) in <(String, String, Object)>[
            ('PUT', statePath(relayId), {'state': true}),
            ('PATCH', '/devices/$deviceId', {'heatingSuspended': true}),
            (
              'PATCH',
              '/devices/$deviceId/control-strategy',
              {
                'targetTemperatureCelsius': 70,
                'hysteresisCelsius': 2,
                'mode': 'AUTO',
              },
            ),
          ]) {
            expectError(
              await send(client, method, path, data: data),
              403,
              'HTTP_403',
            );
          }

          expect(await physicalRelay(), anyOf(isNull, isFalse));
          final after = await admin.device(deviceId);
          expect(after.heatingSuspended, before.heatingSuspended);
          expect(after.baseControlStrategy, before.baseControlStrategy);
          // Reading is allowed for every role.
          expect((await client.device(deviceId)).id, deviceId);
        });
      }
    });
  });
}
