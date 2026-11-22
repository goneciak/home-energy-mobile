/// Live device contract on the fake device of a contract stack (plan §17.3,
/// spike S6): provisioning outcome, switching both ways, role gating and the
/// control-strategy response. Strict decoding throughout.
///
/// Runs only against a Core seeded for contract use (`tools/seed_core.dart
/// --init` on `contract/compose.contract.yml`): the fake device must be
/// provisioned. Without it the group is skipped, unless `FAKE_ESPHOME_URL` is
/// set, which declares a contract stack and turns a missing device into a
/// failure. Two logins: the seeded ADMIN and USER.
@Tags(['contract'])
library;

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.authLogin,
  GiEndpoints.devicesList,
  GiEndpoints.devicesDetail,
];

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final fakeUrl = ContractEnv.fakeEsphomeUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('fake device', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    // Conditional GET of the list and details (plan §6.5 pt 4, spike S4).
    final etags = EtagCache();
    late DeviceListItem listed;
    late String relayId;
    String? notSeeded;

    Future<Response<Object?>> asAdmin(
      String method,
      String path, {
      Object? data,
    }) async => await raw.request<Object?>(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {
          'authorization': 'Bearer ${await admin.session.accessToken()}',
        },
      ),
    );

    /// The relay state as the fake device itself reports it.
    Future<bool> physicalRelay() async {
      final response = await Dio().get<Map<String, dynamic>>(
        '$fakeUrl/fake/state',
      );
      return response.data!['relayOn'] as bool;
    }

    setUpAll(() async {
      raw = rawDio(probe!.address);
      admin = strictClient(
        address: probe.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
        etagCache: etags,
      );
      void notContractSeeded(String reason) {
        notSeeded = '$reason: not a Core seeded for contract use';
        if (fakeUrl != null) fail('$notSeeded, but FAKE_ESPHOME_URL is set');
      }

      final account = ContractEnv.seededAccount('ADMIN');
      final CurrentUser user;
      try {
        user = await respectingLoginLimit(
          () => admin.login(email: account.email, password: account.password),
        );
      } on UnauthorizedFailure {
        return notContractSeeded('no seeded ADMIN at $base');
      }
      expect(user.role, UserRole.admin);

      final fake = (await admin.devices()).items.where(FakeDevice.matches);
      if (fake.isEmpty) return notContractSeeded('no fake device at $base');
      listed = fake.single;
      final detail = await admin.device(listed.id);
      relayId = detail.heatingRelayEntityId!;
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
          await body();
        });

    seededTest(
      'conditional GET: If-None-Match on /devices gets a 304 served from '
      'the ETag cache',
      () async {
        // The list's ETag changes with every legacy poll (every 30 s, S4),
        // so a pair of requests may straddle a change: try again.
        for (var attempt = 0; attempt < 5; attempt++) {
          final hits = etags.hits;
          final first = await admin.devices();
          final second = await admin.devices();
          if (etags.hits > hits) {
            expect(second, first);
            return;
          }
          printOnFailure('ETag changed between requests; again');
        }
        fail('no 304 for GET /devices in 5 attempts');
      },
    );

    seededTest(
      'is ONLINE as LEGACY_ESPHOME despite 404 on /gi-provision',
      () async {
        final detail = await admin.device(listed.id);

        expect(listed.status, DeviceListStatus.online);
        expect(listed.connectivityState, ConnectivityState.online);
        expect(detail.status, ProductStatus.online);
        expect(detail.communicationMode, CommunicationMode.legacyEsphome);
        expect(detail.manufacturer, FakeDevice.manufacturer);
        expect(detail.entities, hasLength(2));
        if (fakeUrl != null) {
          // GI Core tried GI Edge auto-activation and the device refused it.
          final state = await Dio().get<Map<String, dynamic>>(
            '$fakeUrl/fake/state',
          );
          expect(state.data!['provisioningAttempts'], greaterThan(0));
        }
      },
    );

    seededTest(
      'seeded wiring: heating relay, temperature, MANUAL strategy',
      () async {
        final detail = await admin.device(listed.id);
        final relay = detail.entities.firstWhere((e) => e.id == relayId);
        final temperature = detail.entities.firstWhere(
          (e) => e.id == detail.controlTemperatureEntityId,
        );

        expect(relay.domain, EntityDomain.switch_);
        expect(relay.writable, isTrue);
        expect(temperature.deviceClass, 'temperature');
        expect(temperature.unit, '°C');
        expect(detail.baseControlStrategy?.mode, ControlStrategyMode.manual);
      },
    );

    seededTest('switch ON then OFF through GI Core', () async {
      for (final state in [true, false]) {
        final response = await asAdmin(
          'PUT',
          '/devices/${listed.id}/entities/$relayId/state',
          data: {'state': state},
        );

        expect(response.statusCode, 200, reason: '${response.data}');
        final body = response.data! as Map<String, dynamic>;
        expect(body.keys, {'entityId', 'state', 'availability', 'confirmedAt'});
        expect(body['entityId'], relayId);
        expect(body['state'], state);
        if (fakeUrl != null) expect(await physicalRelay(), state);

        final relay = (await admin.device(listed.id)).entities
            .firstWhere((e) => e.id == relayId);
        expect(relay.value, EntityValue.boolean(state));
      }
    });

    seededTest('USER may not switch: 403 HTTP_403 (login 2 of 2)', () async {
      final user = strictClient(
        address: probe!.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      addTearDown(user.close);
      final account = ContractEnv.seededAccount('USER');
      expect(
        (await respectingLoginLimit(
          () => user.login(email: account.email, password: account.password),
        )).role,
        UserRole.user,
      );

      final response = await raw.put<Object?>(
        '/devices/${listed.id}/entities/$relayId/state',
        data: {'state': true},
        options: Options(
          headers: {
            'authorization': 'Bearer ${await user.session.accessToken()}',
          },
        ),
      );

      expect(response.statusCode, 403);
      expect(ApiErrorEnvelope.tryParse(response.data)?.code, 'HTTP_403');
      if (fakeUrl != null) expect(await physicalRelay(), isFalse);
      // USER still reads the device.
      expect((await user.device(listed.id)).id, listed.id);
    });

    seededTest(
      'control-strategy answers with three keys, not the DTO',
      () async {
        final response = await asAdmin(
          'PATCH',
          '/devices/${listed.id}/control-strategy',
          data: {
            'targetTemperatureCelsius': 55,
            'hysteresisCelsius': 4,
            'mode': 'MANUAL',
          },
        );

        expect(response.statusCode, 200, reason: '${response.data}');
        final body = response.data! as Map<String, dynamic>;
        expect(body.keys, {
          'controlStrategy',
          'baseControlStrategy',
          'configurationVersion',
        });
        expect(body['baseControlStrategy'], {
          'targetTemperatureCelsius': 55,
          'hysteresisCelsius': 4,
          'mode': 'MANUAL',
        });
      },
    );
  });
}
