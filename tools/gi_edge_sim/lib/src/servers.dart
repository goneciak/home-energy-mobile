import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gi_edge_sim/src/simulator.dart';

/// The device HTTP API (port 80): what GI Core's ESPHome client calls to
/// discover and synchronize the device, plus `/gi-provision`.
class DeviceServer {
  new(this.sim);

  final Simulator sim;

  Future<HttpServer> bind(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    unawaited(_serve(server));
    return server;
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      unawaited(_handle(request));
    }
  }

  Map<String, Object?> manifest() {
    final model = sim.model;
    final config = sim.config;
    Map<String, Object?> sensor(
      String key,
      String name,
      double value,
      String status,
    ) {
      final valid = status == 'VALID';
      return {
        'key': key,
        'type': 'sensor',
        'name': name,
        'dataType': 'number',
        'deviceClass': 'temperature',
        'unit': '°C',
        'readable': true,
        'writable': false,
        'value': valid ? double.parse(value.toStringAsFixed(1)) : null,
        'available': valid,
      };
    }

    Map<String, Object?> relay(String key, bool value) => {
      'key': key,
      'type': 'switch',
      'name': key,
      'dataType': 'boolean',
      'readable': true,
      'writable': true,
      'value': value,
      'available': true,
    };

    return {
      'schemaVersion': '1.0',
      'device': {
        'deviceId': config.legacyDeviceId,
        'name': 'GI Boiler Room Controller (simulator)',
        'type': 'ESP32',
        'manufacturer': 'GI Industries',
        'model': 'GI Boiler Room Controller',
        'firmwareVersion': '0.1.0',
        'hardwareRevision': 'gi-controller-2ch',
        'hardwareProfile': 'generic',
        'hostname': config.hostname,
      },
      'network': {'ip': config.ip, 'mac': config.physicalMac, 'rssi': -84},
      'capabilities': [
        {
          'key': 'wifi',
          'type': 'wifi',
          'name': 'Wi-Fi',
          'readable': true,
          'writable': false,
        },
        {
          'key': 'ota',
          'type': 'ota',
          'name': 'OTA',
          'readable': false,
          'writable': true,
        },
      ],
      'entities': [
        sensor(
          'temperature_1',
          'Temperature 1',
          model.supply,
          model.supplyStatus,
        ),
        sensor(
          'temperature_2',
          'Temperature 2',
          model.returnTemp,
          model.returnStatus,
        ),
        relay('relay_1', model.relay1.output),
        relay('relay_2', model.relay2.output),
      ],
    };
  }

  Future<void> _handle(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    try {
      final body = await utf8.decodeStream(request);
      switch ((request.method, segments)) {
        case ('GET', ['healthz']):
          return await _json(request, 200, {'ok': true});
        case ('GET', ['api', 'v1', 'device']):
          return await _json(request, 200, manifest());
        case ('GET', ['api', 'v1', 'status']):
          return await _json(request, 200, {
            'schemaVersion': '1.0',
            'status': {'availability': 'online'},
            'diagnostics': {'uptimeSeconds': sim.model.uptimeSeconds.round()},
          });
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
          return await _legacyState(request, key);
        case ('POST', ['gi-provision']):
          return await _provision(request, body);
        default:
          return await _json(request, 404, {'error': 'not found'});
      }
    } on Object catch (e) {
      stderr.writeln('${request.method} ${request.uri} failed: $e');
      try {
        await _json(request, 500, {'error': 'internal'});
      } on Object {
        // Response already started.
      }
    }
  }

  Future<void> _legacyState(HttpRequest request, String key) async {
    final state = request.uri.queryParameters['state'];
    final on = state == 'on' || state == 'true';
    if (!on && state != 'off' && state != 'false') {
      return await _json(request, 400, {'error': 'state must be on or off'});
    }
    if (key.startsWith('temperature_')) {
      return await _json(request, 422, {'error': 'entity is not writable'});
    }
    if (key != 'relay_2') {
      return await _json(request, 409, {
        'error': 'only the heating relay is writable',
      });
    }
    final accepted = sim.model.requestHeating(on: on);
    if (!accepted) {
      return await _json(request, 409, {
        'error': 'rejected by local safety policy',
      });
    }
    return await _json(request, 200, {
      'schemaVersion': '1.0',
      'entity': {'key': key, 'state': on, 'available': true},
    });
  }

  /// The form GI Core posts (`core_url`, `device_id`, `activation_token`):
  /// answer 200 at once and activate in the background, like the firmware.
  Future<void> _provision(HttpRequest request, String body) async {
    final Map<String, String> form;
    try {
      form = Uri.splitQueryString(body);
    } on Object {
      return await _json(request, 400, {'error': 'invalid form'});
    }
    final deviceId = form['device_id'];
    final token = form['activation_token'];
    if (deviceId == null ||
        deviceId.isEmpty ||
        token == null ||
        token.isEmpty) {
      return await _json(request, 400, {
        'error': 'device_id and activation_token required',
      });
    }
    await _json(request, 200, {'ok': true});
    unawaited(
      sim.activate(
        deviceId: deviceId,
        activationToken: token,
        coreUrl: form['core_url'],
      ),
    );
  }
}

/// `/fake/*` control surface, published on a loopback-only port.
class ControlServer {
  new(this.sim);

  final Simulator sim;

  Future<HttpServer> bind(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    unawaited(_serve(server));
    return server;
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      unawaited(_handle(request));
    }
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final text = await utf8.decodeStream(request);
      Map<String, Object?> json() {
        if (text.trim().isEmpty) return {};
        final decoded = jsonDecode(text);
        if (decoded is! Map<String, Object?>) {
          throw const FormatException('JSON object expected');
        }
        return decoded;
      }

      switch ((request.method, request.uri.path)) {
        case ('GET', '/healthz'):
          return await _json(request, 200, {'ok': true});
        case ('GET', '/fake/state'):
          return await _json(request, 200, sim.debugState());
        case ('POST', '/fake/scenario'):
          sim.applyScenario(json());
          return await _json(request, 200, sim.debugState());
        case ('POST', '/fake/reset'):
          sim.factoryReset();
          return await _json(request, 200, sim.debugState());
        case ('POST', '/fake/activate'):
          final body = json();
          final deviceId = body['deviceId'];
          final token = body['activationToken'];
          if (deviceId is! String || token is! String) {
            throw const FormatException(
              'deviceId (the Core UUID) and activationToken are required',
            );
          }
          final result = await sim.activate(
            deviceId: deviceId,
            activationToken: token,
            coreUrl: body['coreUrl'] as String?,
          );
          return await _json(request, result.ok ? 200 : 502, result.toJson());
        default:
          return await _json(request, 404, {'error': 'not found'});
      }
    } on FormatException catch (e) {
      await _json(request, 400, {'error': e.message});
    } on Object catch (e) {
      stderr.writeln('${request.method} ${request.uri} failed: $e');
      try {
        await _json(request, 500, {'error': 'internal'});
      } on Object {
        // Response already started.
      }
    }
  }
}

Future<void> _json(HttpRequest request, int status, Object body) async {
  request.response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body));
  await request.response.close();
}
