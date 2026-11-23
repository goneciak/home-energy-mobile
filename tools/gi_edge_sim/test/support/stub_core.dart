import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gi_edge_sim/gi_edge_sim.dart';

/// A tiny GI Core: verifies the GI Edge signature rules (hash of the raw body,
/// HMAC, clock skew, telemetry sequence) and queues commands, so the simulator
/// can be tested without Docker.
class StubCore {
  static const deviceId = '11111111-1111-4111-8111-111111111111';
  static const secret = 'stub-shared-secret';
  static const token = 'activation-token-ok';

  late final HttpServer _server;
  String get url => 'http://127.0.0.1:${_server.port}';

  /// Every accepted signed request: route, sequence, decoded body, raw body.
  final List<Map<String, Object?>> received = [];
  final List<String> rejections = [];
  final List<Map<String, Object?>> acks = [];
  final List<Map<String, Object?>> queue = [];
  int lastTelemetrySequence = 0;
  bool dryRun = false;
  String? heatingRelayKey = 'relay_2';

  /// While true every signed request is answered with 401.
  bool revoked = false;

  /// Secret handed out by self-heal; `null` answers 404 like an unknown MAC.
  String? selfHealSecret;
  int selfHealCalls = 0;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(() async {
      await for (final request in _server) {
        unawaited(_handle(request));
      }
    }());
  }

  Future<void> close() => _server.close(force: true);

  void enqueue(String type, String entityKey, {String? id}) {
    final correlationId = id ?? 'cmd-${queue.length + received.length}';
    queue.add({
      'id': correlationId,
      'deviceId': deviceId,
      'correlationId': correlationId,
      'type': type,
      'payload': {'entityKey': entityKey},
      'state': 'PENDING',
      'expiresAt': DateTime.now()
          .add(const Duration(seconds: 30))
          .toUtc()
          .toIso8601String(),
    });
  }

  List<Map<String, Object?>> of(String route) =>
      received.where((r) => r['route'] == route).toList();

  Future<void> _handle(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
    }
    final path = request.uri.path;
    const prefix = '/api/v1/edge/';
    if (!path.startsWith(prefix)) {
      return await _error(request, 404, 'NOT_FOUND');
    }
    final route = path.substring(prefix.length);
    final text = utf8.decode(bytes);
    final body = text.isEmpty ? <String, Object?>{} : jsonDecode(text);
    switch (route) {
      case 'activate':
        final map = body as Map<String, Object?>;
        if (map['activationToken'] != token || map['physicalMac'] is! String) {
          return await _error(request, 401, 'GI_EDGE_ACTIVATION_INVALID');
        }
        return await _ok(request, 201, {
          'deviceId': deviceId,
          'sharedSecret': secret,
          'protocolVersion': '1.0',
          'reusedExistingIdentity': false,
          'mqttPassword': 'x',
        });
      case 'self-heal':
        selfHealCalls++;
        final healed = selfHealSecret;
        if (healed == null) {
          return await _error(request, 404, 'GI_EDGE_SELF_HEAL_UNKNOWN_MAC');
        }
        revoked = false;
        return await _ok(request, 201, {
          'deviceId': deviceId,
          'sharedSecret': healed,
          'protocolVersion': '1.0',
          'reusedExistingIdentity': true,
          'mqttPassword': 'x',
        });
      case 'heartbeat' || 'telemetry' || 'commands/poll' || 'commands/ack':
        final failure = _verify(request, path, bytes, route);
        if (failure != null) {
          rejections.add(failure);
          return await _error(request, 401, failure);
        }
        received.add({
          'route': route,
          'sequence': int.parse(request.headers.value('x-gi-sequence')!),
          'body': body,
          'raw': text,
        });
        return await _respond(request, route, body as Map<String, Object?>);
      default:
        return await _error(request, 404, 'NOT_FOUND');
    }
  }

  String? _verify(
    HttpRequest request,
    String path,
    List<int> bytes,
    String route,
  ) {
    String? header(String name) => request.headers.value(name);
    for (final name in [
      'x-gi-device-id',
      'x-gi-timestamp',
      'x-gi-nonce',
      'x-gi-sequence',
      'x-gi-content-sha256',
      'x-gi-signature',
      'x-gi-protocol-version',
    ]) {
      if (header(name) == null) return 'GI_EDGE_HEADER_MISSING';
    }
    if (revoked || header('x-gi-device-id') != deviceId) {
      return 'GI_EDGE_CREDENTIAL_INVALID';
    }
    final skew = DateTime.now()
        .difference(DateTime.parse(header('x-gi-timestamp')!))
        .abs();
    if (skew > const Duration(minutes: 5)) return 'GI_EDGE_CLOCK_SKEW';
    final hash = sha256Hex(bytes);
    if (hash != header('x-gi-content-sha256')) {
      return 'GI_EDGE_BODY_HASH_INVALID';
    }
    final expected = signMaterial(
      secret,
      signingMaterial(
        path: path,
        bodyHash: hash,
        deviceId: deviceId,
        timestamp: header('x-gi-timestamp')!,
        nonce: header('x-gi-nonce')!,
        sequence: header('x-gi-sequence')!,
      ),
    );
    if (expected != header('x-gi-signature')) {
      return 'GI_EDGE_SIGNATURE_INVALID';
    }
    if (route == 'telemetry') {
      final sequence = int.parse(header('x-gi-sequence')!);
      if (sequence <= lastTelemetrySequence) return 'GI_EDGE_SEQUENCE_REPLAY';
      lastTelemetrySequence = sequence;
    }
    return null;
  }

  Future<void> _respond(
    HttpRequest request,
    String route,
    Map<String, Object?> body,
  ) async {
    switch (route) {
      case 'commands/poll':
        final commands = List<Map<String, Object?>>.of(queue);
        queue.clear();
        return await _ok(request, 200, {
          'commands': commands,
          'controlStrategy': null,
          'fallbackThresholdMs': 120000,
          'boilerEstimateWindowMinutes': 10,
          'localControlTemperatureSource': 'SUPPLY',
          'heatingRelayEntityKey': heatingRelayKey,
          'dryRun': dryRun,
        });
      case 'commands/ack':
        acks.add(body);
        return await _ok(request, 200, {'acknowledged': true});
      default:
        return await _ok(request, 200, {
          'acknowledgement': true,
          'sequence': request.headers.value('x-gi-sequence'),
          'duplicate': false,
          'serverTime': DateTime.now().toUtc().toIso8601String(),
        });
    }
  }

  Future<void> _ok(HttpRequest request, int status, Object data) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({
          'version': '1.0',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'requestId': 'r',
          'executionTimeMs': 1,
          'data': data,
        }),
      );
    await request.response.close();
  }

  Future<void> _error(HttpRequest request, int status, String code) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({'statusCode': status, 'code': code, 'message': code}),
      );
    await request.response.close();
  }
}
