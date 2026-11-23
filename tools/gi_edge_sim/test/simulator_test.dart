import 'dart:convert';
import 'dart:io';

import 'package:gi_edge_sim/gi_edge_sim.dart';
import 'package:test/test.dart';

import 'support/stub_core.dart';

void main() {
  late StubCore core;
  late Simulator sim;

  setUp(() async {
    core = StubCore();
    await core.start();
    sim = Simulator(
      config: SimConfig(
        coreUrl: core.url,
        noise: 0,
        bootGrace: Duration.zero,
        selfHealRetry: Duration.zero,
      ),
      identity: IdentityStore(),
    );
    for (var i = 0; i < 6; i++) {
      sim.tick();
    }
  });

  tearDown(() async {
    sim.stop();
    await core.close();
  });

  Future<void> activate() async {
    final result = await sim.activate(
      deviceId: StubCore.deviceId,
      activationToken: StubCore.token,
    );
    expect(result.ok, isTrue);
  }

  test('does nothing before it is activated', () async {
    expect(await sim.sendHeartbeat(), isNull);
    expect(await sim.pollCommands(), isNull);
    expect(core.received, isEmpty);
  });

  test(
    'activation with a wrong token fails and keeps it unprovisioned',
    () async {
      final result = await sim.activate(
        deviceId: StubCore.deviceId,
        activationToken: 'nope',
      );
      expect(result.ok, isFalse);
      expect(sim.provisioned, isFalse);
    },
  );

  test('signed pushes are accepted, sequences strictly increase', () async {
    await activate();
    for (var i = 0; i < 3; i++) {
      expect((await sim.sendHeartbeat())!.ok, isTrue);
      expect((await sim.sendTelemetry())!.ok, isTrue);
      expect((await sim.pollCommands())!.ok, isTrue);
    }
    expect(core.rejections, isEmpty);
    final sequences = core.received.map((r) => r['sequence']! as int).toList();
    expect(sequences, orderedEquals([...sequences]..sort()));
    expect(sequences.toSet(), hasLength(sequences.length));
    final heartbeat = core.of('heartbeat').first;
    final body = heartbeat['body']! as Map<String, Object?>;
    expect(body['currentState'], 'IDLE');
    expect(body['schemaVersion'], '1.1.0');
    expect(body['sequence'], heartbeat['sequence']);
    expect(heartbeat['raw']! as String, contains('"filtered":'));
    expect(
      heartbeat['raw']! as String,
      matches(RegExp(r'"filtered":\d+\.\d{6}')),
    );
    final telemetry =
        core.of('telemetry').first['body']! as Map<String, Object?>;
    final readings = telemetry['readings']! as List<Object?>;
    expect((readings.single! as Map)['entityKey'], 'device_uptime');
  });

  test(
    'TURN_ON from Core heats and the heartbeat shows it, ack is ACCEPTED',
    () async {
      await activate();
      await sim.pollCommands(); // adopts dryRun false and relay_2
      core.enqueue('TURN_ON', 'relay_2', id: 'on-1');
      await sim.pollCommands();
      expect(core.acks.single, {
        'correlationId': 'on-1',
        'state': 'ACCEPTED',
        'result': {'resultingState': 'HEATING_REQUESTED'},
      });
      sim.tick();
      await sim.sendHeartbeat();
      final body = core.of('heartbeat').last['body']! as Map<String, Object?>;
      expect((body['relay2']! as Map)['commanded'], isTrue);
      expect((body['relay2']! as Map)['output'], isTrue);
      expect((body['relay1']! as Map)['role'], 'pump');
    },
  );

  test('a command for the pump relay is refused by the device', () async {
    await activate();
    await sim.pollCommands();
    core.enqueue('TURN_ON', 'relay_1', id: 'pump-1');
    await sim.pollCommands();
    expect(core.acks.single['state'], 'FAILED');
    expect(
      core.acks.single['error'],
      'entity not permitted for remote control',
    );
  });

  test('no_ack executes the command without acknowledging it', () async {
    await activate();
    await sim.pollCommands();
    sim.applyScenario({'mode': 'no_ack'});
    core.enqueue('TURN_ON', 'relay_2', id: 'on-2');
    await sim.pollCommands();
    expect(core.acks, isEmpty);
    expect(sim.model.relay2.commanded, isFalse);
    sim.tick();
    expect(sim.model.relay2.commanded, isTrue);
    expect(sim.commands.first.ackStatus, isNull);
  });

  test(
    'ack_failed refuses with the given reason and does not execute',
    () async {
      await activate();
      await sim.pollCommands();
      sim.applyScenario({'mode': 'ack_failed', 'error': 'boom'});
      core.enqueue('TURN_ON', 'relay_2', id: 'on-3');
      await sim.pollCommands();
      expect(core.acks.single['error'], 'boom');
      sim.tick();
      expect(sim.model.relay2.commanded, isFalse);
      expect(sim.commands.first.outcome, 'NOT_EXECUTED');
    },
  );

  test(
    'offline stops every push, stale_heartbeat only the heartbeat',
    () async {
      await activate();
      sim.applyScenario({'mode': 'stale_heartbeat'});
      expect(await sim.sendHeartbeat(), isNull);
      expect((await sim.sendTelemetry())!.ok, isTrue);
      sim.applyScenario({'mode': 'offline'});
      final before = core.received.length;
      expect(await sim.sendTelemetry(), isNull);
      expect(await sim.pollCommands(), isNull);
      expect(core.received.length, before);
      sim.applyScenario({'mode': 'normal'});
      expect((await sim.sendHeartbeat())!.ok, isTrue);
    },
  );

  test(
    'clock_skew beyond five minutes is answered with 401 clock skew',
    () async {
      await activate();
      sim.applyScenario({'mode': 'clock_skew', 'seconds': 600});
      final response = (await sim.sendHeartbeat())!;
      expect(response.status, 401);
      expect(response.code, 'GI_EDGE_CLOCK_SKEW');
    },
  );

  test('sensor_invalid is reported in the heartbeat', () async {
    await activate();
    sim.applyScenario({'mode': 'sensor_invalid', 'status': 'CRC_ERROR'});
    sim.tick();
    await sim.sendHeartbeat();
    final body = core.of('heartbeat').last['body']! as Map<String, Object?>;
    expect((body['supplyTemperature']! as Map)['status'], 'CRC_ERROR');
  });

  test('fault and safe_mode show in the diagnostics', () async {
    await activate();
    sim.applyScenario({'mode': 'fault', 'code': 'ONEWIRE_BUS_ERROR'});
    sim.tick();
    await sim.sendHeartbeat();
    final body = core.of('heartbeat').last['body']! as Map<String, Object?>;
    expect(body['currentState'], 'FAULT');
    expect(body['activeFaults'], ['ONEWIRE_BUS_ERROR']);
    expect(body['safetyInterlockActive'], isTrue);
    expect(
      () => sim.applyScenario({'mode': 'bogus'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('reboot keeps the identity and the sequence, bumps bootCount', () async {
    await activate();
    await sim.sendHeartbeat();
    final sequence = sim.identity.sequence;
    final boots = sim.identity.bootCount;
    sim.applyScenario({'mode': 'reboot'});
    expect(sim.identity.bootCount, boots + 1);
    expect(sim.provisioned, isTrue);
    await sim.sendHeartbeat();
    expect(core.of('heartbeat').last['sequence'], greaterThan(sequence));
    final body = core.of('heartbeat').last['body']! as Map<String, Object?>;
    expect(body['bootCount'], boots + 1);
    expect(body['currentState'], 'BOOT');
    expect(body['dryRun'], isTrue);
  });

  test('three 401 answers wipe the credential, reboot and self-heal', () async {
    await activate();
    core.selfHealSecret = StubCore.secret;
    sim.applyScenario({'mode': 'revoke'});
    for (var i = 0; i < 3; i++) {
      expect((await sim.sendHeartbeat())!.status, 401);
    }
    expect(sim.provisioned, isFalse);
    expect(sim.model.state, DeviceState.boot);
    sim.tick();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(core.selfHealCalls, greaterThan(0));
    expect(sim.provisioned, isTrue);
    expect((await sim.sendHeartbeat())!.ok, isTrue);
  });

  test('self-heal that Core refuses leaves the device waiting', () async {
    await activate();
    core.revoked = true;
    for (var i = 0; i < 3; i++) {
      await sim.sendHeartbeat();
    }
    expect(sim.provisioned, isFalse);
    sim.tick();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(core.selfHealCalls, greaterThan(0));
    expect(sim.provisioned, isFalse);
    expect(await sim.sendHeartbeat(), isNull);
  });

  test('persisted identity survives a new process', () async {
    final dir = Directory.systemTemp.createTempSync('gi_edge_sim_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/state.json';
    final first = IdentityStore(path: path)
      ..adopt(deviceId: StubCore.deviceId, sharedSecret: 's');
    first
      ..reserveSequence()
      ..reserveSequence();
    final second = IdentityStore(path: path);
    expect(second.provisioned, isTrue);
    expect(second.sequence, 2);
    expect(second.reserveSequence(), 3);
  });

  group('HTTP surface', () {
    late HttpServer device;
    late HttpServer control;

    setUp(() async {
      device = await DeviceServer(sim).bind(0);
      control = await ControlServer(sim).bind(0);
    });

    tearDown(() async {
      await device.close(force: true);
      await control.close(force: true);
    });

    Future<(int, Object?)> call(
      HttpServer server,
      String method,
      String path, {
      Object? json,
      String? form,
    }) async {
      final client = HttpClient();
      try {
        final request = await client.openUrl(
          method,
          Uri.parse('http://127.0.0.1:${server.port}$path'),
        );
        if (json != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(json));
        }
        if (form != null) {
          request.headers.contentType = ContentType(
            'application',
            'x-www-form-urlencoded',
          );
          request.write(form);
        }
        final response = await request.close();
        final text = await utf8.decodeStream(response);
        return (response.statusCode, text.isEmpty ? null : jsonDecode(text));
      } finally {
        client.close(force: true);
      }
    }

    test('serves the legacy manifest Core discovers', () async {
      final (status, body) = await call(device, 'GET', '/api/v1/device');
      expect(status, 200);
      final manifest = body! as Map<String, Object?>;
      expect(manifest['schemaVersion'], '1.0');
      final entities = (manifest['entities']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(entities.map((e) => e['key']), [
        'temperature_1',
        'temperature_2',
        'relay_1',
        'relay_2',
      ]);
      expect(
        (manifest['device']! as Map)['deviceId'],
        matches(RegExp(r'^[a-zA-Z0-9_-]+$')),
      );
      // Core's zod schema: every capability has readable and writable.
      for (final capability in manifest['capabilities']! as List<Object?>) {
        final map = capability! as Map<String, Object?>;
        expect(map['readable'], isA<bool>());
        expect(map['writable'], isA<bool>());
        expect(map['key'], matches(RegExp(r'^[a-z0-9_]+$')));
      }
    });

    test('a sensor without a valid reading is null and unavailable', () async {
      sim.applyScenario({'mode': 'sensor_invalid', 'status': 'NOT_FOUND'});
      sim.tick();
      final (_, body) = await call(device, 'GET', '/api/v1/device');
      final first =
          ((body! as Map)['entities']! as List<Object?>).first!
              as Map<String, Object?>;
      expect(first['value'], isNull);
      expect(first['available'], isFalse);
    });

    test('/gi-provision answers 200 and activates in the background', () async {
      final (status, _) = await call(
        device,
        'POST',
        '/gi-provision',
        form:
            'core_url=http%3A%2F%2Fwrong%3A80&device_id=${StubCore.deviceId}'
            '&activation_token=${StubCore.token}',
      );
      expect(status, 200);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(sim.provisioned, isTrue);
      expect(sim.identity.deviceId, StubCore.deviceId);
      final (rejected, _) = await call(
        device,
        'POST',
        '/gi-provision',
        form: 'core_url=x',
      );
      expect(rejected, 400);
    });

    test('control surface: activate, scenario, state, reset', () async {
      final (activated, _) = await call(
        control,
        'POST',
        '/fake/activate',
        json: {
          'deviceId': StubCore.deviceId,
          'activationToken': StubCore.token,
        },
      );
      expect(activated, 200);
      final (scenario, _) = await call(
        control,
        'POST',
        '/fake/scenario',
        json: {'mode': 'offline'},
      );
      expect(scenario, 200);
      final (_, state) = await call(control, 'GET', '/fake/state');
      final map = state! as Map<String, Object?>;
      expect(map['provisioned'], isTrue);
      expect((map['scenario']! as Map)['offline'], isTrue);
      expect(map.toString(), isNot(contains(StubCore.secret)));
      final (bad, _) = await call(
        control,
        'POST',
        '/fake/scenario',
        json: {'mode': 'nope'},
      );
      expect(bad, 400);
      final (reset, _) = await call(control, 'POST', '/fake/reset');
      expect(reset, 200);
      expect(sim.provisioned, isFalse);
    });
  });
}
