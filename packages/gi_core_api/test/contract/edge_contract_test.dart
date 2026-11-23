/// Live contract of the GI Edge path (plan §12.2) on the simulated controller
/// of a contract stack (`tools/gi_edge_sim`, docs/gi-edge-simulator.md).
///
/// GI Core handles a `GI_EDGE_V1` device differently from the legacy fake:
/// `PUT .../state` answers at once with an optimistic value and
/// `confirmedAt` = request time, and the controller's real answer only shows
/// in a later heartbeat (`diagnostics.relayN.commanded/output`, with a
/// `lastSeenAt` after the request). The device acknowledges success with
/// `ACCEPTED`, which is not final in Core, so a command that worked is listed
/// as `TIMED_OUT` later. These tests assert exactly that, and the failure
/// modes the simulator can inject (no acknowledgement, refusal, silence, a
/// frozen heartbeat, invalid sensors, faults, a skewed clock, a reboot).
///
/// Runs only on a Core seeded with `--edge-sim`
/// (`tools/dev-up.ps1 -Contract -Seed -EdgeSim`) and with
/// `GI_EDGE_SIM_CONTROL_URL` set. Tests tagged `slow` wait for Core's own
/// timers (command timeout sweep, offline detection) and take up to a few
/// minutes; skip them with `-x slow`.
///
/// Every test returns the controller to idle with the relays off, dry-run and
/// suspension off, also when it fails. Run with `-j 1` like the other
/// contract suites. Logins: the seeded ADMIN (one).
@Tags(['contract'])
library;

import 'package:dio/dio.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:test/test.dart';

import 'support/contract_env.dart';

/// Catalog entries this file exercises live.
const liveCoverage = <Endpoint>[
  GiEndpoints.setSwitchState,
  GiEndpoints.updateDevice,
];

/// How long the app waits for the heartbeat (SwitchCommandController).
const _heartbeatWait = Duration(seconds: 45);

Future<void> main() async {
  final base = ContractEnv.coreUrl;
  final controlUrl = ContractEnv.edgeSimControlUrl;
  final probe = await ContractEnv.probe(base);
  final skip =
      ContractEnv.skipReason(base, probe) ??
      (controlUrl == null ? 'GI_EDGE_SIM_CONTROL_URL is not set' : false);

  group('GI Edge device (simulator)', skip: skip, () {
    late Dio raw;
    late GiCoreClient admin;
    late EdgeSimControl sim;
    late String deviceId;
    late String relayId;
    late String pumpId;
    late String sensorId;
    String? notSeeded;

    Future<Response<Object?>> send(
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

    /// Repeats [probe] until it returns a value; [what] names the wait.
    Future<T> eventually<T extends Object>(
      String what,
      Future<T?> Function() probe, {
      Duration timeout = _heartbeatWait,
      Duration every = const Duration(seconds: 1),
    }) async {
      final deadline = DateTime.now().add(timeout);
      while (true) {
        final value = await probe();
        if (value != null) return value;
        if (DateTime.now().isAfter(deadline)) {
          fail('$what did not happen within $timeout');
        }
        await Future<void>.delayed(every);
      }
    }

    /// Command rows of `GET /edge/devices/:id/commands`, newest first.
    Future<List<Map<String, dynamic>>> commands() async {
      final response = await send(
        'GET',
        '/edge/devices/$deviceId/commands?limit=50',
      );
      expect(response.statusCode, 200, reason: '${response.data}');
      var data = (response.data! as Map<String, dynamic>)['data'];
      if (data is Map) data = data['items'] ?? data['commands'];
      return (data! as List).cast<Map<String, dynamic>>();
    }

    Future<Set<String>> knownCommandIds() async => {
      for (final c in await commands()) c['id'] as String,
    };

    /// The first command not in [known] that satisfies [test].
    Future<Map<String, dynamic>?> newCommand(
      Set<String> known,
      bool Function(Map<String, dynamic> c) test,
    ) async => (await commands())
        .where((c) => !known.contains(c['id']) && test(c))
        .firstOrNull;

    Future<Duration> uptimeNow() async =>
        (await admin.device(deviceId)).diagnostics?.uptime ?? Duration.zero;

    /// The next heartbeat Core stored after [requestedAt] whose relay 2
    /// reports [commanded]: the only observable truth (the app's rule). A
    /// new heartbeat is told by its uptime.
    Future<DeviceDetail> heartbeatShowing({
      required DateTime requestedAt,
      required bool commanded,
      required Duration uptimeAtRequest,
    }) => eventually('a heartbeat with relay_2 commanded=$commanded', () async {
      final device = await admin.device(deviceId);
      final seen = device.lastSeenAt;
      final uptime = device.diagnostics?.uptime;
      final relay = device.diagnostics?.relay(2);
      if (seen != null &&
          seen.isAfter(requestedAt) &&
          uptime != null &&
          uptime > uptimeAtRequest &&
          relay?.commanded == commanded) {
        return device;
      }
      return null;
    });

    Future<void> waitForState(Set<String> states, {Duration? timeout}) =>
        eventually('the controller to reach $states', () async {
          final device = await sim.device();
          return states.contains(device['state']) ? true : null;
        }, timeout: timeout ?? const Duration(seconds: 60));

    /// Back to idle, relays off, dry-run and suspension off.
    Future<void> restore() async {
      await sim.normal();
      final device = await admin.device(deviceId);
      if (device.heatingSuspended || device.dryRun) {
        await send(
          'PATCH',
          '/devices/$deviceId',
          data: {'heatingSuspended': false, 'dryRun': false},
        );
      }
      await eventually(
        'Core to see the controller online',
        () async {
          final d = await admin.device(deviceId);
          return d.connectivityState == ConnectivityState.online ? true : null;
        },
        timeout: const Duration(minutes: 4),
        every: const Duration(seconds: 5),
      );
      await eventually('the controller to take dry-run off', () async {
        return (await sim.device())['dryRun'] == false ? true : null;
      });
      final state = await sim.device();
      if ((state['relay2'] as Map<String, dynamic>)['commanded'] == true ||
          state['state'] != 'IDLE') {
        await send('PUT', statePath(relayId), data: {'state': false});
      }
      await waitForState({'IDLE'});
    }

    setUpAll(() async {
      raw = rawDio(probe!.address);
      sim = EdgeSimControl(controlUrl!);
      admin = strictClient(
        address: probe.address,
        vault: InMemoryTokenVault(),
        expectedInitializedAt: probe.setup.initializedAt,
      );
      void notEdgeSeeded(String reason) {
        notSeeded = '$reason: not a Core seeded with --edge-sim';
        fail('$notSeeded, but GI_EDGE_SIM_CONTROL_URL is set');
      }

      final account = ContractEnv.seededAccount('ADMIN');
      try {
        await respectingLoginLimit(
          () => admin.login(email: account.email, password: account.password),
        );
      } on UnauthorizedFailure {
        return notEdgeSeeded('no seeded ADMIN at $base');
      }
      final found = (await admin.devices()).items.where(EdgeSimDevice.matches);
      if (found.isEmpty) return notEdgeSeeded('no edge device at $base');
      deviceId = found.single.id;
      final detail = await admin.device(deviceId);
      relayId = detail.heatingRelayEntityId!;
      sensorId = detail.controlTemperatureEntityId!;
      pumpId = detail.entities.firstWhere((e) => e.sourceName == 'relay_1').id;
      await restore();
    });

    tearDownAll(() async {
      if (notSeeded == null) await restore();
      await admin.close();
      raw.close();
      sim.close();
    });

    void edgeTest(String description, Future<void> Function() body) =>
        test(description, () async {
          if (notSeeded case final reason?) {
            markTestSkipped(reason);
            return;
          }
          addTearDown(restore);
          await body();
        }, timeout: const Timeout(Duration(minutes: 6)));

    edgeTest(
      'is GI_EDGE_V1 and decodes strictly, ghost entities included',
      () async {
        final detail = await admin.device(deviceId);
        expect(detail.communicationMode, CommunicationMode.giEdgeV1);
        expect(detail.heatingRelayEntityId, relayId);
        expect(
          detail.entities.map((e) => e.id),
          containsAll(<String>[relayId, pumpId, sensorId]),
        );
        final diagnostics = detail.diagnostics!;
        expect(diagnostics.currentState, FirmwareState.idle);
        expect(diagnostics.relay(1), isNotNull);
        expect(diagnostics.relay(2)?.commanded, isFalse);
        expect(diagnostics.wifiRssi, isNegative);
        expect(diagnostics.bootCount, isNotNull);
        // The diagnostic entities Core creates are unassigned, so
        // needs_configuration is an expected status, not an error.
        expect(
          detail.status,
          anyOf(ProductStatus.online, ProductStatus.needsConfiguration),
        );
        expect(detail.connectivityState, ConnectivityState.online);
        final sensor = detail.entities.firstWhere((e) => e.id == sensorId);
        expect(sensor.value, isA<EntityValueNumber>());
      },
    );

    group('PUT state is optimistic; the heartbeat decides', () {
      edgeTest('ON then OFF: confirmed only by a later heartbeat', () async {
        await waitForState({'IDLE'});
        for (final state in [true, false]) {
          final uptime = await uptimeNow();
          final before = DateTime.now().toUtc().subtract(
            const Duration(seconds: 1),
          );
          final result = await admin.setSwitchState(
            deviceId,
            relayId,
            state: state,
          );

          // Written at once, before the controller acted.
          expect(result.state, state);
          expect(result.confirmedAt.isAfter(before), isTrue);
          final relay = (await admin.device(deviceId)).entities
              .firstWhere((e) => e.id == relayId);
          expect(relay.value, EntityValue.boolean(state));

          final device = await heartbeatShowing(
            requestedAt: result.confirmedAt,
            commanded: state,
            uptimeAtRequest: uptime,
          );
          expect(device.diagnostics!.relay(2)?.output, state);
          if (state) await waitForState({'HEATING', 'FAULT'});
        }
      });

      edgeTest(
        'dry-run: the old value comes back, the output stays low',
        () async {
          await send('PATCH', '/devices/$deviceId', data: {'dryRun': true});
          await eventually('the controller to learn dry-run', () async {
            return (await sim.device())['dryRun'] == true ? true : null;
          });
          await waitForState({'IDLE'});
          final uptime = await uptimeNow();

          final result = await admin.setSwitchState(
            deviceId,
            relayId,
            state: true,
          );

          expect(
            result.state,
            isFalse,
            reason: 'dry-run returns the OLD value',
          );
          final device = await heartbeatShowing(
            requestedAt: result.confirmedAt,
            commanded: true,
            uptimeAtRequest: uptime,
          );
          expect(device.diagnostics!.relay(2)?.output, isFalse);
          final relay = device.entities.firstWhere((e) => e.id == relayId);
          expect(relay.value, const EntityValue.boolean(false));
        },
      );

      edgeTest('the pump relay is refused by the controller', () async {
        await waitForState({'IDLE'});
        final known = await knownCommandIds();

        await admin.setSwitchState(deviceId, pumpId, state: true);

        final command = await eventually('the refused command', () async {
          final c = await newCommand(
            known,
            (c) => (c['payload'] as Map?)?['entityKey'] == 'relay_1',
          );
          return c != null && c['state'] == 'FAILED' ? c : null;
        });
        expect(command['error'], contains('not permitted'));
        expect((await sim.device())['state'], 'IDLE');
      });

      edgeTest(
        'the controller refuses: FAILED is final, the value reverts',
        () async {
          await waitForState({'IDLE'});
          await sim.scenario({
            'mode': 'ack_failed',
            'error': 'rejected by local safety policy',
          });
          final known = await knownCommandIds();
          final uptime = await uptimeNow();

          final result = await admin.setSwitchState(
            deviceId,
            relayId,
            state: true,
          );
          expect(result.state, isTrue);

          final command = await eventually('a FAILED command', () async {
            final c = await newCommand(known, (c) => c['type'] == 'TURN_ON');
            return c != null && c['state'] == 'FAILED' ? c : null;
          });
          expect(command['error'], contains('safety policy'));
          // The next heartbeat takes the optimistic value back.
          final device = await eventually('the entity to revert', () async {
            final d = await admin.device(deviceId);
            final e = d.entities.firstWhere((e) => e.id == relayId);
            final up = d.diagnostics?.uptime;
            return e.value == const EntityValue.boolean(false) &&
                    up != null &&
                    up > uptime
                ? d
                : null;
          });
          expect(device.diagnostics!.relay(2)?.commanded, isFalse);
        },
      );

      edgeTest('a frozen heartbeat is never read as a confirmation', () async {
        await waitForState({'IDLE'});
        await sim.scenario({'mode': 'stale_heartbeat'});
        final before = await admin.device(deviceId);

        final result = await admin.setSwitchState(
          deviceId,
          relayId,
          state: true,
        );

        // Telemetry keeps lastSeenAt moving past the request...
        await eventually('telemetry after the request', () async {
          final d = await admin.device(deviceId);
          return d.lastSeenAt?.isAfter(result.confirmedAt) ?? false
              ? true
              : null;
        });
        // ...but the diagnostics stay frozen: no confirmation.
        await Future<void>.delayed(const Duration(seconds: 20));
        final later = await admin.device(deviceId);
        expect(later.diagnostics!.uptime, before.diagnostics!.uptime);
        expect(later.diagnostics!.relay(2)?.commanded, isFalse);
      });
    });

    edgeTest(
      'suspension: ON refused with 409, OFF allowed, all switches off',
      () async {
        await waitForState({'IDLE'});
        final known = await knownCommandIds();
        await admin.setHeatingSuspended(deviceId, suspended: true);

        expectError(
          await send('PUT', statePath(relayId), data: {'state': true}),
          409,
          'HEATING_SUSPENDED',
        );
        final off = await admin.setSwitchState(deviceId, relayId, state: false);
        expect(off.state, isFalse);

        // Core enqueues a TURN_OFF for every switch; the controller polls them.
        await eventually('the suspend TURN_OFF commands', () async {
          final list = (await commands()).where(
            (c) =>
                !known.contains(c['id']) &&
                '${c['correlationId']}'.startsWith('heating-suspend-'),
          );
          return list.length >= 2 ? list : null;
        });
        expect((await sim.device())['state'], 'IDLE');
      },
    );

    edgeTest(
      'a fault: reported by the heartbeat, a start is refused',
      () async {
        await sim.scenario({'mode': 'fault', 'code': 'SENSOR_STALE'});
        final faulty = await eventually('a heartbeat with the fault', () async {
          final d = await admin.device(deviceId);
          return d.diagnostics?.currentState == FirmwareState.fault ? d : null;
        });
        expect(faulty.diagnostics!.activeFaultCount, greaterThan(0));
        final listed = (await admin.devices()).items.firstWhere(
          EdgeSimDevice.matches,
        );
        expect(listed.currentState, FirmwareState.fault);
        expect(listed.activeFaultCount, greaterThan(0));

        final known = await knownCommandIds();
        await admin.setSwitchState(deviceId, relayId, state: true);
        final command = await eventually('the refusal', () async {
          final c = await newCommand(known, (c) => c['type'] == 'TURN_ON');
          return c != null && c['state'] == 'FAILED' ? c : null;
        });
        expect(command['error'], isA<String>());
      },
    );

    edgeTest(
      'a skewed clock: 401 from Core, accepted again after the fix',
      () async {
        await sim.scenario({'mode': 'clock_skew', 'seconds': 600});
        await eventually('a 401 push', () async {
          final pushes = ((await sim.state())['pushes'] as List)
              .cast<Map<String, dynamic>>();
          return pushes.any((p) => p['status'] == 401) ? true : null;
        });
        await sim.normal();
        await eventually('accepted pushes again', () async {
          final pushes = ((await sim.state())['pushes'] as List)
              .cast<Map<String, dynamic>>();
          return pushes.isNotEmpty && pushes.first['status'] == 200
              ? true
              : null;
        });
      },
    );

    edgeTest('a reboot keeps the sequence: no replay', () async {
      final first = await sim.state();
      final boots = first['bootCount'] as int;
      final sequence = first['sequence'] as int;
      final startedAt = DateTime.now().toUtc();

      await sim.scenario({'mode': 'reboot'});

      final device = await eventually('a heartbeat of the new boot', () async {
        final d = await admin.device(deviceId);
        return (d.diagnostics?.bootCount ?? 0) > boots ? d : null;
      });
      expect(device.diagnostics!.bootCount, boots + 1);
      expect((await sim.state())['sequence'] as int, greaterThan(sequence));
      // Telemetry after the reboot is accepted (sequence above Core's last).
      await eventually('accepted telemetry', () async {
        final pushes = ((await sim.state())['pushes'] as List)
            .cast<Map<String, dynamic>>();
        final telemetry = pushes.where((p) => p['kind'] == 'telemetry');
        return telemetry.isNotEmpty && telemetry.first['status'] == 200
            ? true
            : null;
      });
      final pushes = ((await sim.state())['pushes'] as List)
          .cast<Map<String, dynamic>>();
      expect(
        pushes.where(
          (p) =>
              p['status'] == 401 &&
              DateTime.parse(p['at'] as String).isAfter(startedAt),
        ),
        isEmpty,
      );
    });

    group('Core timers', tags: ['slow'], () {
      edgeTest(
        'no acknowledgement: the command times out, not stuck',
        () async {
          await waitForState({'IDLE'});
          await sim.scenario({'mode': 'no_ack'});
          final known = await knownCommandIds();

          await admin.setSwitchState(deviceId, relayId, state: true);

          // 30 s deadline plus up to 30 s sweep of the timeout job.
          final command = await eventually(
            'the command to time out',
            () async {
              final c = await newCommand(known, (c) => c['type'] == 'TURN_ON');
              return c != null && c['state'] == 'TIMED_OUT' ? c : null;
            },
            timeout: const Duration(seconds: 100),
            every: const Duration(seconds: 3),
          );
          expect(command['completedAt'], isNotNull);
        },
      );

      edgeTest('a command that worked also ends TIMED_OUT: ACCEPTED is not '
          'final', () async {
        await waitForState({'IDLE'});
        final known = await knownCommandIds();
        final uptime = await uptimeNow();

        final result = await admin.setSwitchState(
          deviceId,
          relayId,
          state: true,
        );
        await heartbeatShowing(
          requestedAt: result.confirmedAt,
          commanded: true,
          uptimeAtRequest: uptime,
        );

        final command = await eventually(
          'the command to time out',
          () async {
            final c = await newCommand(known, (c) => c['type'] == 'TURN_ON');
            return c != null && c['state'] == 'TIMED_OUT' ? c : null;
          },
          timeout: const Duration(seconds: 100),
          every: const Duration(seconds: 3),
        );
        expect(command['correlationId'], isA<String>());
      });

      edgeTest(
        'an invalid sensor: the temperature keeps its old value',
        () async {
          final before = (await admin.device(deviceId)).entities
              .firstWhere((e) => e.id == sensorId);
          expect(before.lastSeenAt, isNotNull);
          await sim.scenario({
            'mode': 'sensor_invalid',
            'sensor': 'both',
            'status': 'TIMEOUT',
          });
          final uptime = await uptimeNow();
          await eventually('two heartbeats with invalid sensors', () async {
            final d = await admin.device(deviceId);
            final up = d.diagnostics?.uptime;
            return up != null && up > uptime + const Duration(seconds: 16)
                ? d
                : null;
          }, timeout: const Duration(seconds: 70));

          final after = (await admin.device(deviceId)).entities
              .firstWhere((e) => e.id == sensorId);
          expect(after.availability, isTrue);
          expect(after.value, isA<EntityValueNumber>());
          // Never nulled and never refreshed: the app must show it as stale.
          expect(after.lastSeenAt, before.lastSeenAt);
        },
      );

      edgeTest(
        'silence: Core marks the device offline and refuses ON',
        () async {
          await sim.scenario({'mode': 'offline'});

          // HEARTBEAT_TIMEOUT_SECONDS (90) plus up to 60 s of the job cadence.
          await eventually(
            'Core to mark the device offline',
            () async {
              final d = await admin.device(deviceId);
              return d.connectivityState == ConnectivityState.offline
                  ? d
                  : null;
            },
            timeout: const Duration(minutes: 4),
            every: const Duration(seconds: 5),
          );
          expect((await admin.device(deviceId)).status, ProductStatus.offline);

          expectError(
            await send('PUT', statePath(relayId), data: {'state': true}),
            503,
            'DEVICE_OFFLINE',
          );
        },
      );
    });
  });
}
