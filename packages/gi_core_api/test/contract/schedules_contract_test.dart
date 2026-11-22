/// Live contract of the M3 heating schedules (plan §20 M3) and the PV heating
/// plan on the fake device of a contract stack: CRUD with its status codes
/// (201/200/204), the DTO rules, the domain 404s, role gating and the
/// server-side reconcile of the effective control strategy. Strict decoding
/// throughout.
///
/// The contract stack runs GI Core in UTC (spike S7), so a window computed
/// from the UTC clock is the one the server evaluates. Every schedule this
/// file creates is deleted again, also when a test fails; the base strategy
/// stays the seeded 55 °C / 4 K / MANUAL (`tools/seed_core.dart`).
///
/// Runs with `-j 1` next to `control_contract_test.dart`, which changes the
/// same device's strategy. Logins: the seeded ADMIN and USER (two).
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
  GiEndpoints.schedulesList,
  GiEndpoints.scheduleCreate,
  GiEndpoints.scheduleUpdate,
  GiEndpoints.scheduleRemove,
  GiEndpoints.pvHeatingPlan,
];

const _seededTarget = 55.0;
const _seededHysteresis = 4.0;
const _allDays = [0, 1, 2, 3, 4, 5, 6];
const _namePrefix = 'contract-';

final _weakEtag = RegExp(r'^W/"[0-9a-f]+-[A-Za-z0-9+/=_-]+"$');

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final probe = await ContractEnv.probe(base);
  final skip = ContractEnv.skipReason(base, probe) ?? false;

  group('heating schedules on the fake device', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    late String deviceId;
    String? notSeeded;

    Future<Response<Object?>> send(
      GiCoreClient client,
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
          ...headers,
          'authorization': 'Bearer ${await client.session.accessToken()}',
        },
      ),
    );

    String schedulesPath([String? scheduleId]) =>
        ['/devices/$deviceId/schedules', ?scheduleId].join('/');

    void expectError(Response<Object?> response, int status, String code) {
      expect(response.statusCode, status, reason: '${response.data}');
      expect(
        ApiErrorEnvelope.tryParse(response.data)?.code,
        code,
        reason: '${response.data}',
      );
    }

    HeatingScheduleInput input({
      String name = 'tydzień',
      List<int> days = const [1, 2, 3, 4, 5],
      String start = '06:00',
      String end = '22:00',
      double target = 50,
      double hysteresis = 3,
      bool enabled = true,
    }) => HeatingScheduleInput(
      name: '$_namePrefix$name',
      daysOfWeek: days,
      startTime: start,
      endTime: end,
      targetTemperatureCelsius: target,
      hysteresisCelsius: hysteresis,
      enabled: enabled,
    );

    /// Deletes every schedule of the device (the contract stack has none of
    /// its own) so the effective strategy is the base again.
    Future<void> deleteAll() async {
      for (final schedule in await admin.schedules(deviceId)) {
        await admin.deleteSchedule(deviceId, schedule.id);
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
        if (ContractEnv.fakeEsphomeUrl != null) {
          fail('$notSeeded, but FAKE_ESPHOME_URL is set');
        }
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
      await deleteAll();
    });

    tearDownAll(() async {
      if (notSeeded == null) await deleteAll();
      await admin.close();
      raw.close();
    });

    void seededTest(String description, Future<void> Function() body) =>
        test(description, () async {
          if (notSeeded case final reason?) {
            markTestSkipped(reason);
            return;
          }
          addTearDown(deleteAll);
          await body();
        });

    seededTest('CRUD: create 201, list oldest first, PATCH 200 (also {}), '
        'DELETE 204 with no body', () async {
      expect(await admin.schedules(deviceId), isEmpty);

      final created = await send(
        admin,
        'POST',
        schedulesPath(),
        data: input(days: [6, 0], target: 47.5).toJson(),
      );
      expect(created.statusCode, 201, reason: '${created.data}');
      final first = HeatingSchedule.fromJson(
        created.data! as Map<String, dynamic>,
      );
      expect(first.deviceId, deviceId);
      expect(first.name, '${_namePrefix}tydzień');
      expect(first.daysOfWeek, unorderedEquals([6, 0]));
      expect(first.startTime, '06:00');
      expect(first.endTime, '22:00');
      expect(first.targetTemperatureCelsius, 47.5);
      expect(first.hysteresisCelsius, 3);
      expect(first.enabled, isTrue);

      // `enabled` defaults to true; strict decoding through the client.
      final second = await admin.createSchedule(
        deviceId,
        input(name: 'noc', start: '22:00', end: '06:00', enabled: false),
      );
      expect(second.enabled, isFalse);
      expect(second.id, isNot(first.id));

      final listed = await admin.schedules(deviceId);
      expect(listed.map((s) => s.id), [first.id, second.id]);
      expect(listed.first, first);

      final patched = await admin.updateSchedule(
        deviceId,
        second.id,
        const HeatingSchedulePatch(enabled: true, targetTemperatureCelsius: 44),
      );
      expect(patched.enabled, isTrue);
      expect(patched.targetTemperatureCelsius, 44);
      expect(patched.name, second.name);
      expect(patched.startTime, '22:00');
      expect(patched.updatedAt.isBefore(second.updatedAt), isFalse);

      final empty = await send(
        admin,
        'PATCH',
        schedulesPath(second.id),
        data: <String, Object>{},
      );
      expect(empty.statusCode, 200, reason: '${empty.data}');
      expect(
        HeatingSchedule.fromJson(empty.data! as Map<String, dynamic>)
            .targetTemperatureCelsius,
        44,
      );

      final deleted = await send(admin, 'DELETE', schedulesPath(first.id));
      expect(deleted.statusCode, 204);
      expect(deleted.data, anyOf(isNull, ''));
      await admin.deleteSchedule(deviceId, second.id);
      expect(await admin.schedules(deviceId), isEmpty);
    });

    seededTest('the server has no overlap, same-time or name rules: '
        'overlapping duplicates and start == end are accepted', () async {
      final a = await admin.createSchedule(deviceId, input(name: 'a'));
      final b = await admin.createSchedule(deviceId, input(name: 'a'));
      final allDay = await admin.createSchedule(
        deviceId,
        input(name: 'doba', start: '07:00', end: '07:00', enabled: false),
      );
      expect({a.id, b.id, allDay.id}, hasLength(3));
      expect(allDay.startTime, allDay.endTime);
    });

    seededTest('DTO rules: 400 VALIDATION_FAILED', () async {
      final valid = input().toJson();
      for (final body in <Map<String, Object?>>[
        {...valid, 'startTime': '24:00'},
        {...valid, 'endTime': '6:00'},
        {
          ...valid,
          'daysOfWeek': [1, 1],
        },
        {
          ...valid,
          'daysOfWeek': [7],
        },
        {...valid, 'daysOfWeek': <int>[]},
        {...valid, 'name': ''},
        {...valid, 'targetTemperatureCelsius': 101},
        {...valid, 'hysteresisCelsius': 0.5},
        {...valid, 'priority': 1},
        {...valid}..remove('name'),
      ]) {
        expectError(
          await send(admin, 'POST', schedulesPath(), data: body),
          400,
          'VALIDATION_FAILED',
        );
      }

      final row = await admin.createSchedule(deviceId, input());
      for (final body in <Map<String, Object?>>[
        {'startTime': '24:00'},
        {
          'daysOfWeek': [1, 1],
        },
        {'deviceId': deviceId},
      ]) {
        expectError(
          await send(admin, 'PATCH', schedulesPath(row.id), data: body),
          400,
          'VALIDATION_FAILED',
        );
      }
      expect(await admin.schedules(deviceId), [row]);
    });

    seededTest('unknown ids: 400 for a device id that is not a UUID, 404 '
        'DEVICE_NOT_FOUND and HEATING_SCHEDULE_NOT_FOUND', () async {
      final response = await send(
        admin,
        'GET',
        '/devices/not-a-uuid/schedules',
      );
      expectError(response, 400, 'HTTP_400');
      expectError(
        await send(
          admin,
          'GET',
          '/devices/00000000-0000-4000-8000-000000000000/schedules',
        ),
        404,
        'DEVICE_NOT_FOUND',
      );
      // The schedule id is a cuid and not validated: any string is a 404.
      for (final method in ['PATCH', 'DELETE']) {
        expectError(
          await send(
            admin,
            method,
            schedulesPath('ckcontractmissing0000000'),
            data: method == 'PATCH' ? {'enabled': false} : null,
          ),
          404,
          'HEATING_SCHEDULE_NOT_FOUND',
        );
      }
    });

    seededTest('USER may list but not write: 403 HTTP_403', () async {
      final row = await admin.createSchedule(deviceId, input());
      final user = strictClient(
        address: probe!.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      addTearDown(user.close);
      final account = ContractEnv.seededAccount('USER');
      await respectingLoginLimit(
        () => user.login(email: account.email, password: account.password),
      );

      expect(await user.schedules(deviceId), [row]);
      for (final (method, path, data) in <(String, String, Object?)>[
        ('POST', schedulesPath(), input().toJson()),
        ('PATCH', schedulesPath(row.id), {'enabled': false}),
        ('DELETE', schedulesPath(row.id), null),
      ]) {
        expectError(
          await send(user, method, path, data: data),
          403,
          'HTTP_403',
        );
      }
      expect(await admin.schedules(deviceId), [row]);
    });

    seededTest('reconcile: a matching enabled schedule sets the effective '
        'target and hysteresis, keeps the base mode; disabling or deleting '
        'it restores the base', () async {
      final before = await admin.device(deviceId);
      expect(
        before.baseControlStrategy?.targetTemperatureCelsius,
        _seededTarget,
      );
      expect(before.controlStrategy, before.baseControlStrategy);
      final baseMode = before.baseControlStrategy!.mode;

      // A two-hour window around the UTC "now" on every day of the week:
      // the minute boundary cannot matter, and the wrap past midnight is
      // covered by including every day.
      final now = DateTime.now().toUtc();
      final minutes = now.hour * 60 + now.minute;
      String at(int m) => HeatingScheduleRules.formatMinutes(m % (24 * 60));
      final active = await admin.createSchedule(
        deviceId,
        input(
          name: 'teraz',
          days: _allDays,
          start: at(minutes - 60),
          end: at(minutes + 60),
          target: 61.5,
          hysteresis: 2,
        ),
      );

      final during = await admin.device(deviceId);
      expect(during.controlStrategy?.targetTemperatureCelsius, 61.5);
      expect(during.controlStrategy?.hysteresisCelsius, 2);
      expect(during.controlStrategy?.mode, baseMode);
      expect(during.baseControlStrategy, before.baseControlStrategy);
      expect(
        during.configurationVersion,
        greaterThan(before.configurationVersion),
      );

      // A later schedule that also matches loses to the older one.
      await admin.createSchedule(
        deviceId,
        input(name: 'później', days: _allDays, start: '00:00', end: '00:00'),
      );
      expect(
        (await admin.device(deviceId))
            .controlStrategy
            ?.targetTemperatureCelsius,
        61.5,
      );

      await admin.updateSchedule(
        deviceId,
        active.id,
        const HeatingSchedulePatch(enabled: false),
      );
      // Now the all-day one (50 °C / 3 K) is the first enabled match.
      final second = await admin.device(deviceId);
      expect(second.controlStrategy?.targetTemperatureCelsius, 50);
      expect(second.controlStrategy?.hysteresisCelsius, 3);

      await deleteAll();
      final after = await admin.device(deviceId);
      expect(after.controlStrategy, after.baseControlStrategy);
      expect(after.controlStrategy?.targetTemperatureCelsius, _seededTarget);
      expect(after.controlStrategy?.hysteresisCelsius, _seededHysteresis);
    });

    seededTest('a window that does not cover now leaves the base in '
        'effect', () async {
      final now = DateTime.now().toUtc();
      final minutes = now.hour * 60 + now.minute;
      String at(int m) => HeatingScheduleRules.formatMinutes(m % (24 * 60));
      await admin.createSchedule(
        deviceId,
        input(
          name: 'później',
          days: _allDays,
          start: at(minutes + 120),
          end: at(minutes + 180),
          target: 30,
        ),
      );

      final device = await admin.device(deviceId);
      expect(device.controlStrategy, device.baseControlStrategy);
    });

    seededTest('GET schedules: weak ETag, If-None-Match gives 304', () async {
      await admin.createSchedule(deviceId, input());
      final first = await send(admin, 'GET', schedulesPath());
      final etag = first.headers.value('etag');
      expect(etag, matches(_weakEtag));

      final second = await send(
        admin,
        'GET',
        schedulesPath(),
        headers: {'if-none-match': etag},
      );
      expect(second.statusCode, 304);
      expect(second.data, anyOf(isNull, ''));
    });

    seededTest('PV heating plan: DISABLED with no hours on a device without '
        'PV configuration; the base target is the seeded one', () async {
      final plan = await admin.pvHeatingPlan(deviceId);

      expect(plan.deviceId, deviceId);
      expect(plan.mode, PvControlMode.disabled);
      expect(plan.hours, isEmpty);
      expect(plan.safeMaxTemperatureCelsius, 60);
      expect(plan.baseTargetCelsius, _seededTarget);

      expectError(
        await send(admin, 'GET', '/devices/not-a-uuid/pv-heating-plan'),
        400,
        'HTTP_400',
      );
      expectError(
        await send(
          admin,
          'GET',
          '/devices/00000000-0000-4000-8000-000000000000/pv-heating-plan',
        ),
        404,
        'DEVICE_NOT_FOUND',
      );
    });
  });
}
