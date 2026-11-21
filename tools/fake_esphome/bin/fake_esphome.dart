// Fake GI/ESPHome controller for the contract stack (contract/compose.contract.yml).
//
// Emulates exactly the device HTTP API GI Core calls in
// apps/gi-core/src/modules/integrations/esphome/infrastructure/esphome-http.client.ts
// (backend ref in contract/backend.lock):
//
//   GET  /api/v1/device                           manifest, schemaVersion "1.0"
//   GET  /api/v1/status                           read-only status snapshot
//   GET  /api/v1/events?fromId=&limit=            event journal page (always empty)
//   GET  /api/v1/events/latest                    same shape
//   POST /api/v1/entities/<key>/state?state=on|off  switch command, echoes the new state
//   POST /gi-provision                            404: no gi_provisioning
//                                                 component, so GI Edge
//                                                 auto-activation is rejected
//                                                 and the device stays
//                                                 LEGACY_ESPHOME
//
// plus the classic ESPHome web_server REST routes over the same state, for
// poking the device by hand:
//
//   GET  /switch/heating_relay, POST /switch/heating_relay/turn_on|turn_off|toggle
//   GET  /sensor/supply_temperature
//
// and two routes of its own: GET /healthz (Docker healthcheck) and GET
// /fake/state (the physical relay state and a command log, for contract tests).
//
// One switch (heating relay) and one temperature sensor. dart:io only; the
// image runs the AOT-compiled binary on the Dart runtime base
// (tools/fake_esphome/Dockerfile).
//
//   fake_esphome [--port 80]      serve (PORT env var also works)
//   fake_esphome --healthcheck    exit 0 when the local server answers /healthz
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _relayKey = 'heating_relay';
const _temperatureKey = 'supply_temperature';

Future<void> main(List<String> args) async {
  final portArg = args.indexOf('--port');
  final port = portArg >= 0 && portArg + 1 < args.length
      ? int.parse(args[portArg + 1])
      : int.tryParse(Platform.environment['PORT'] ?? '') ?? 80;

  if (args.contains('--healthcheck')) {
    exit(await _healthcheck(port) ? 0 : 1);
  }

  final device = FakeDevice(
    hostname: Platform.environment['FAKE_ESPHOME_HOSTNAME'] ?? 'fake-esphome',
    ip: await _ownIpv4(),
  );
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('fake_esphome listening on 0.0.0.0:$port as ${device.ip}');
  ProcessSignal.sigterm.watch().listen((_) async {
    await server.close(force: true);
    exit(0);
  });
  await for (final request in server) {
    unawaited(_handle(device, request));
  }
}

/// Device state shared by every route.
final class FakeDevice {
  new({required this.hostname, required this.ip});

  final String hostname;
  final String ip;
  final DateTime startedAt = DateTime.now().toUtc();
  bool relayOn = false;
  double supplyTemperature = 45.5;
  final List<Map<String, Object?>> commands = [];
  int provisioningAttempts = 0;

  int get uptimeSeconds =>
      DateTime.now().toUtc().difference(startedAt).inSeconds;

  Map<String, Object?> manifest() => {
    'schemaVersion': '1.0',
    'device': {
      'deviceId': 'gi-fake-esphome-01',
      'name': 'Fake kotłownia',
      'type': 'heating_controller',
      'manufacturer': 'GI Contract Fakes',
      'model': 'fake-esphome',
      'firmwareVersion': '0.1.0-fake',
      'hardwareRevision': 'docker',
      'hostname': hostname,
    },
    'network': {'ip': ip, 'mac': '02:00:00:00:00:01', 'rssi': -48},
    'capabilities': [
      {
        'key': 'relay',
        'type': 'relay',
        'name': 'Przekaźnik',
        'readable': true,
        'writable': true,
      },
      {
        'key': 'temperature',
        'type': 'temperature',
        'name': 'Temperatura',
        'unit': '°C',
        'readable': true,
        'writable': false,
      },
    ],
    'entities': [
      {
        'key': _relayKey,
        'type': 'switch',
        'name': 'Przekaźnik grzania',
        'dataType': 'boolean',
        'readable': true,
        'writable': true,
        'value': relayOn,
        'available': true,
      },
      {
        'key': _temperatureKey,
        'type': 'sensor',
        'name': 'Temperatura zasilania',
        'dataType': 'number',
        'deviceClass': 'temperature',
        'unit': '°C',
        'readable': true,
        'writable': false,
        'value': supplyTemperature,
        'available': true,
      },
    ],
  };

  Map<String, Object?> status() => {
    'schemaVersion': '1.0',
    'status': {'availability': 'online'},
    'diagnostics': {'uptimeSeconds': uptimeSeconds},
  };

  Map<String, Object?> switchCommand(bool state, String via) {
    relayOn = state;
    commands.add({
      'at': DateTime.now().toUtc().toIso8601String(),
      'key': _relayKey,
      'state': state,
      'via': via,
    });
    return {
      'schemaVersion': '1.0',
      'entity': {'key': _relayKey, 'state': relayOn, 'available': true},
    };
  }

  Map<String, Object?> debugState() => {
    'relayOn': relayOn,
    'supplyTemperature': supplyTemperature,
    'commands': commands,
    'provisioningAttempts': provisioningAttempts,
    'uptimeSeconds': uptimeSeconds,
  };
}

Future<void> _handle(FakeDevice device, HttpRequest request) async {
  final method = request.method;
  final segments = request.uri.pathSegments;
  final path = '/${segments.join('/')}';
  try {
    // Drain the body (form posts to /gi-provision, empty command posts).
    await request.drain<void>();
    switch ((method, segments)) {
      case ('GET', ['healthz']):
        return await _json(request, 200, {'ok': true});
      case ('GET', ['fake', 'state']):
        return await _json(request, 200, device.debugState());
      case ('GET', ['api', 'v1', 'device']):
        return await _json(request, 200, device.manifest());
      case ('GET', ['api', 'v1', 'status']):
        return await _json(request, 200, device.status());
      case ('GET', ['api', 'v1', 'events']) ||
          ('GET', ['api', 'v1', 'events', 'latest']):
        final fromId =
            int.tryParse(request.uri.queryParameters['fromId'] ?? '') ?? 0;
        return await _json(request, 200, {
          'events': const <Object>[],
          'hasMore': false,
          'nextFromId': fromId,
        });
      case ('POST', ['api', 'v1', 'entities', final key, 'state']):
        if (key == _temperatureKey) {
          return await _json(request, 422, {'error': 'entity is not writable'});
        }
        if (key != _relayKey) {
          return await _json(request, 404, {'error': 'unknown entity'});
        }
        final state = switch (request.uri.queryParameters['state']) {
          'on' || 'true' => true,
          'off' || 'false' => false,
          _ => null,
        };
        if (state == null) {
          return await _json(request, 400, {
            'error': 'state must be on or off',
          });
        }
        return await _json(request, 200, device.switchCommand(state, 'gi-api'));
      case ('GET', ['switch', _relayKey]):
        return await _json(request, 200, {
          'id': 'switch-$_relayKey',
          'value': device.relayOn,
          'state': device.relayOn ? 'ON' : 'OFF',
        });
      case ('POST', ['switch', _relayKey, final action]):
        final next = switch (action) {
          'turn_on' => true,
          'turn_off' => false,
          'toggle' => !device.relayOn,
          _ => null,
        };
        if (next == null) {
          return await _json(request, 404, {'error': 'not found'});
        }
        device.switchCommand(next, 'web_server');
        return await _json(request, 200, {
          'id': 'switch-$_relayKey',
          'value': device.relayOn,
          'state': device.relayOn ? 'ON' : 'OFF',
        });
      case ('GET', ['sensor', _temperatureKey]):
        return await _json(request, 200, {
          'id': 'sensor-$_temperatureKey',
          'value': device.supplyTemperature,
          'state': '${device.supplyTemperature} °C',
        });
      case (_, ['gi-provision']):
        device.provisioningAttempts++;
        return await _json(request, 404, {
          'error': 'gi_provisioning not compiled in',
        });
      default:
        return await _json(request, 404, {'error': 'not found'});
    }
  } on Object catch (e) {
    stderr.writeln('$method $path failed: $e');
    try {
      await _json(request, 500, {'error': 'internal'});
    } on Object {
      // Response already started.
    }
  } finally {
    stdout.writeln('$method ${request.uri} -> ${request.response.statusCode}');
  }
}

Future<void> _json(HttpRequest request, int status, Object body) async {
  request.response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body));
  await request.response.close();
}

/// The container's own private IPv4 (what GI Core resolves `fake-esphome` to).
Future<String> _ownIpv4() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (!address.isLoopback) return address.address;
    }
  }
  return '127.0.0.1';
}

Future<bool> _healthcheck(int port) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.get('127.0.0.1', port, '/healthz');
    final response = await request.close().timeout(const Duration(seconds: 2));
    await response.drain<void>();
    return response.statusCode == 200;
  } on Object {
    return false;
  } finally {
    client.close(force: true);
  }
}
