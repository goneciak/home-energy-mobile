/// Live contract of the M3 read endpoints that need no schedule: entity
/// history on the fake device, weather, solar and the PV forecast, and the
/// system settings. Strict decoding throughout.
///
/// The contract stack has no house location and no PV (the app may not
/// write `/settings/energy*`, plan §4.4), so weather, solar and the PV
/// forecast only show their "nothing to show" answers here: 503 `HTTP_503`
/// for weather, 400 `HTTP_400` for solar and the PV forecast. Their 200
/// shapes are decoded from hand-written fixtures (`m3_api_test.dart`).
///
/// The fake device's temperature is constant (45.5 °C) and history records
/// changes only, so the temperature history is empty; toggling the relay
/// records `switch` samples. The relay is switched OFF again afterwards.
///
/// Logins: the seeded ADMIN and USER (two).
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
  GiEndpoints.entityHistory,
  GiEndpoints.weatherCurrent,
  GiEndpoints.weatherHourly,
  GiEndpoints.weatherDaily,
  GiEndpoints.solarCurrent,
  GiEndpoints.pvForecast,
  GiEndpoints.settingsSystem,
];

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('history and environment', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    late GiCoreClient user;
    late String deviceId;
    late String relayId;
    late String sensorId;
    String? notSeeded;

    Future<Response<Object?>> send(
      GiCoreClient client,
      String path, {
      Map<String, Object?>? query,
    }) async => await raw.get<Object?>(
      path,
      queryParameters: query,
      options: Options(
        headers: {
          'authorization': 'Bearer ${await client.session.accessToken()}',
        },
      ),
    );

    void expectError(Response<Object?> response, int status, String code) {
      expect(response.statusCode, status, reason: '${response.data}');
      expect(
        ApiErrorEnvelope.tryParse(response.data)?.code,
        code,
        reason: '${response.data}',
      );
    }

    GiCoreClient newClient() => strictClient(
      address: probe!.address,
      vault: InMemoryTokenVault(),
      expectedInitializedAt: probe.setup.initializedAt,
    );

    setUpAll(() async {
      raw = rawDio(probe!.address);
      admin = newClient();
      user = newClient();
      void notContractSeeded(String reason) {
        notSeeded = '$reason: not a Core seeded for contract use';
        if (ContractEnv.fakeEsphomeUrl != null) {
          fail('$notSeeded, but FAKE_ESPHOME_URL is set');
        }
      }

      try {
        for (final (client, role) in [(admin, 'ADMIN'), (user, 'USER')]) {
          final account = ContractEnv.seededAccount(role);
          await respectingLoginLimit(
            () =>
                client.login(email: account.email, password: account.password),
          );
        }
      } on UnauthorizedFailure {
        return notContractSeeded('no seeded ADMIN/USER at $base');
      }
      final fake = (await admin.devices()).items.where(FakeDevice.matches);
      if (fake.isEmpty) return notContractSeeded('no fake device at $base');
      deviceId = fake.single.id;
      final detail = await admin.device(deviceId);
      relayId = detail.heatingRelayEntityId!;
      sensorId = detail.controlTemperatureEntityId!;
    });

    tearDownAll(() async {
      await admin.close();
      await user.close();
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

    String historyPath(String entityId) =>
        '/devices/$deviceId/entities/$entityId/history';

    group('entity history', () {
      seededTest('toggling the relay records switch samples, oldest '
          'first', () async {
        addTearDown(
          () => admin.setSwitchState(deviceId, relayId, state: false),
        );
        final from = DateTime.now().toUtc().subtract(
          const Duration(seconds: 5),
        );
        await admin.setSwitchState(deviceId, relayId, state: true);
        await admin.setSwitchState(deviceId, relayId, state: false);

        // The history listener runs asynchronously.
        final deadline = DateTime.now().add(const Duration(seconds: 15));
        EntityHistory history;
        while (true) {
          history = await user.entityHistory(deviceId, relayId, from: from);
          if (history.samples.length >= 2 || DateTime.now().isAfter(deadline)) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }

        expect(history.entityId, relayId);
        expect(history.from.difference(from).inMilliseconds.abs(), lessThan(1));
        expect(history.samples, isNotEmpty);
        for (final sample in history.samples) {
          expect(sample.kind, HistorySampleKind.switch_);
          expect(sample.value, isA<bool>());
          expect(sample.at.isBefore(from), isFalse);
        }
        final instants = history.samples.map((s) => s.at).toList();
        expect(instants, [...instants]..sort());
        expect(history.samples.last.value, isFalse);
        if (history.samples.length >= 2) {
          expect(history.samples[history.samples.length - 2].value, isTrue);
        }

        // limit=1 keeps the oldest sample of the range.
        final first = await user.entityHistory(
          deviceId,
          relayId,
          from: from,
          limit: 1,
        );
        expect(first.samples, [history.samples.first]);
      });

      seededTest('the constant temperature has no samples', () async {
        final history = await admin.entityHistory(deviceId, sensorId);
        expect(history.entityId, sensorId);
        expect(history.to.isAfter(history.from), isTrue);
        expect(history.to.difference(history.from), const Duration(hours: 24));
        expect(
          history.samples.where((s) => s.kind == HistorySampleKind.temperature),
          isEmpty,
        );
      });

      seededTest('range, limit and entity errors', () async {
        final now = DateTime.now().toUtc();
        expectError(
          await send(
            admin,
            historyPath(relayId),
            query: {
              'from': now.toIso8601String(),
              'to': now.subtract(const Duration(hours: 1)).toIso8601String(),
            },
          ),
          400,
          'HISTORY_RANGE_INVALID',
        );
        expectError(
          await send(admin, historyPath(relayId), query: {'from': 'wczoraj'}),
          400,
          'HISTORY_RANGE_INVALID',
        );
        for (final query in <Map<String, Object?>>[
          {'limit': 0},
          {'limit': 5001},
          {'limit': 'dużo'},
          {'page': 1},
        ]) {
          expectError(
            await send(admin, historyPath(relayId), query: query),
            400,
            'VALIDATION_FAILED',
          );
        }
        expectError(
          await send(admin, historyPath('contract-missing-entity')),
          404,
          'DEVICE_ENTITY_NOT_FOUND',
        );
      });
    });

    group('environment without a house location', () {
      seededTest('weather: 503 HTTP_503 on current, hourly and daily, mapped '
          'to "no data"', () async {
        for (final path in [
          '/weather/current',
          '/weather/hourly',
          '/weather/daily',
        ]) {
          expectError(await send(user, path), 503, 'HTTP_503');
        }
        expect(await user.weatherCurrent(), isA<EnvironmentNoData<Object?>>());
        expect(await user.weatherHourly(), isA<EnvironmentNoData<Object?>>());
        expect(await user.weatherDaily(), isA<EnvironmentNoData<Object?>>());
      });

      seededTest('solar and PV forecast: 400 HTTP_400, mapped to "not '
          'configured"', () async {
        expectError(await send(user, '/solar/current'), 400, 'HTTP_400');
        expectError(await send(user, '/pv/forecast'), 400, 'HTTP_400');
        expect(
          await user.solarCurrent(),
          isA<EnvironmentNotConfigured<Object?>>(),
        );
        expect(
          await user.pvForecast(),
          isA<EnvironmentNotConfigured<Object?>>(),
        );
      });
    });

    group('system settings', () {
      seededTest('ADMIN reads the defaults; USER gets 403 HTTP_403', () async {
        final settings = await admin.systemSettings();
        expect(settings.locale, isNotEmpty);
        expect(settings.timezone, isNotEmpty);

        expectError(await send(user, '/settings/system'), 403, 'HTTP_403');
      });
    });
  });
}
