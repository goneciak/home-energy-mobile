/// Spikes S4 (conditional GET) and S5 (quirks) of plan M0 against the Core
/// at `GI_CORE_URL`. Results: `docs/spikes/s4-conditional-get.md` and
/// `docs/spikes/s5-fixtures-quirks.md`.
///
/// * S4: `GET /devices` and `GET /devices/:id` carry a weak ETag and answer
///   `If-None-Match` with 304 and an empty body.
/// * S5: `communicationMode` tells GI Edge from legacy ESPHome devices on
///   the list and the detail; the control-strategy shape on the detail;
///   `initializedAt` survives `PATCH /settings/system`; `configurationVersion`
///   grows (and the ETag changes) without any user change (L16).
///
/// Runs only against a Core seeded for contract use (the fake device is
/// provisioned): it renames the appliance (and restores the name) and waits
/// for the legacy poll. One login: the seeded ADMIN. The measured values are
/// printed, prefixed with `S4`/`S5`.
@Tags(['contract'])
library;

// The spike's measurements are part of its output.
// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live (plan §6.2, §19.1). Read by
/// `test/catalog_coverage_test.dart` and scanned by
/// `tools/gen_backend_contract.dart`.
const liveCoverage = <Endpoint>[
  GiEndpoints.setupStatus,
  GiEndpoints.authLogin,
  GiEndpoints.devicesList,
  GiEndpoints.devicesDetail,
];

/// Longer than the legacy ESPHome poll (30 s) with margin.
const _pollWindow = Duration(seconds: 70);

final _weakEtag = RegExp(r'^W/"[0-9a-f]+-[A-Za-z0-9+/=_-]+"$');

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  // The fake device exists only in a contract stack (plan D20), which is
  // declared by FAKE_ESPHOME_URL; against the dev Core this group is skipped.
  final skip =
      ContractEnv.skipReason(base, probe) ??
      (ContractEnv.fakeEsphomeUrl == null
          ? 'needs a seeded contract stack: set FAKE_ESPHOME_URL '
                '(tools/dev-up.ps1 -Contract -Seed)'
          : false);

  group('S4/S5 Core quirks', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    late DeviceListItem fake;

    Future<Response<Object?>> asAdmin(
      String method,
      String path, {
      Object? data,
      Map<String, Object?> headers = const {},
    }) async => await raw.request<Object?>(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {
          'authorization': 'Bearer ${await admin.session.accessToken()}',
          ...headers,
        },
      ),
    );

    setUpAll(() async {
      raw = rawDio(probe!.address);
      admin = strictClient(
        address: probe.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      final account = ContractEnv.seededAccount('ADMIN');
      await respectingLoginLimit(
        () => admin.login(email: account.email, password: account.password),
      );
      final page = await admin.devices();
      final found = page.items.where(FakeDevice.matches).firstOrNull;
      if (found == null) {
        fail(
          'the fake device is not provisioned at $base: seed a contract '
          'stack (tools/dev-up.ps1 -Contract -Seed)',
        );
      }
      fake = found;
    });

    tearDownAll(() async {
      await admin.close();
      raw.close();
    });

    group('S4 conditional GET', () {
      for (final (name, path) in [
        ('GET /devices', '/devices?limit=100'),
        ('GET /devices/:id', null),
      ]) {
        test('$name: weak ETag, If-None-Match gives 304, no body', () async {
          final url = path ?? '/devices/${fake.id}';
          // The device changes on its own with every legacy poll (30 s) and
          // other contract files switch it; a 200 with a new ETag means it
          // changed between the two requests, so the pair is repeated.
          for (var attempt = 1; ; attempt++) {
            final first = await asAdmin('GET', url);
            final etag = first.headers.value('etag');

            expect(first.statusCode, 200);
            expect(etag, matches(_weakEtag));
            expect(first.headers.value('cache-control'), isNull);
            expect(first.headers.value('last-modified'), isNull);

            final second = await asAdmin(
              'GET',
              url,
              headers: {'if-none-match': etag},
            );
            if (second.statusCode == 200 &&
                second.headers.value('etag') != etag &&
                attempt < 5) {
              printOnFailure('S4 $name changed between requests; again');
              continue;
            }
            expect(second.statusCode, 304);
            expect(second.data, anyOf(isNull, ''));
            expect(second.headers.value('etag'), etag);

            final stale = await asAdmin(
              'GET',
              url,
              headers: {'if-none-match': 'W/"0-stale"'},
            );
            expect(stale.statusCode, 200);
            print(
              'S4 $name -> ${first.statusCode} etag=$etag; with '
              'If-None-Match -> ${second.statusCode}; with another tag -> '
              '${stale.statusCode} (attempt $attempt)',
            );
            return;
          }
        });
      }
    });

    group('S5 quirks', () {
      test('communicationMode tells GI Edge from legacy ESPHome', () async {
        final detail = await admin.device(fake.id);

        expect(fake.communicationMode, CommunicationMode.legacyEsphome);
        expect(detail.communicationMode, CommunicationMode.legacyEsphome);
        // Legacy devices send no heartbeat: no diagnostics, no state.
        expect(detail.diagnostics, isNull);
        expect(fake.currentState, isNull);
        expect(fake.activeFaultCount, 0);
        print(
          'S5 fake device: list communicationMode=${fake.communicationMode} '
          'currentState=${fake.currentState} '
          'activeFaultCount=${fake.activeFaultCount}; detail '
          'diagnostics=${detail.diagnostics}',
        );
      });

      test('the detail carries both strategies with three keys and an integer '
          'configurationVersion', () async {
        final response = await asAdmin('GET', '/devices/${fake.id}');
        final body = response.data! as Map<String, dynamic>;
        const keys = {'targetTemperatureCelsius', 'hysteresisCelsius', 'mode'};

        expect((body['controlStrategy'] as Map).keys.toSet(), keys);
        expect((body['baseControlStrategy'] as Map).keys.toSet(), keys);
        expect(body['configurationVersion'], isA<int>());
        print(
          'S5 detail controlStrategy=${body['controlStrategy']} '
          'baseControlStrategy=${body['baseControlStrategy']} '
          'configurationVersion=${body['configurationVersion']}',
        );
      });

      test('initializedAt is stable after PATCH /settings/system', () async {
        final before = await admin.setupStatus();
        final original = (await asAdmin('GET', '/settings/system')).data!;
        final settings = original as Map<String, dynamic>;
        addTearDown(
          () => asAdmin(
            'PATCH',
            '/settings/system',
            data: {
              'deviceName': settings['deviceName'],
              'timezone': settings['timezone'],
            },
          ),
        );

        final patched = await asAdmin(
          'PATCH',
          '/settings/system',
          data: {
            'deviceName': '${settings['deviceName']} S5',
            'timezone': 'America/New_York',
          },
        );
        expect(patched.statusCode, 200, reason: '${patched.data}');

        final after = await admin.setupStatus();
        expect(after.initializedAt, before.initializedAt);
        expect(after.deviceName, '${settings['deviceName']} S5');
        expect(after.timezone, 'America/New_York');
        print(
          'S5 PATCH /settings/system -> ${patched.statusCode} '
          '${patched.data}; initializedAt before=${before.initializedAt} '
          'after=${after.initializedAt}',
        );
      });

      test(
        'configurationVersion and the ETag change without any user change',
        timeout: const Timeout(Duration(minutes: 3)),
        () async {
          final first = await asAdmin('GET', '/devices/${fake.id}');
          final v0 = (first.data! as Map)['configurationVersion'] as int;
          final seen0 = (first.data! as Map)['lastSeenAt'];
          final etag0 = first.headers.value('etag');

          await Future<void>.delayed(_pollWindow);

          final later = await asAdmin(
            'GET',
            '/devices/${fake.id}',
            headers: {'if-none-match': etag0},
          );
          final v1 = (later.data! as Map)['configurationVersion'] as int;
          expect(later.statusCode, 200);
          expect(later.headers.value('etag'), isNot(etag0));
          expect(v1, greaterThan(v0));
          expect((later.data! as Map)['lastSeenAt'], isNot(seen0));
          print(
            'S5 over ${_pollWindow.inSeconds} s with no user change: '
            'configurationVersion $v0 -> $v1, lastSeenAt $seen0 -> '
            '${(later.data! as Map)['lastSeenAt']}, conditional GET with the '
            'old ETag -> ${later.statusCode}',
          );
        },
      );
    });
  });
}
