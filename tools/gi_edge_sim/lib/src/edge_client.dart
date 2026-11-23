import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:gi_edge_sim/src/identity_store.dart';
import 'package:gi_edge_sim/src/json_wire.dart';
import 'package:gi_edge_sim/src/signing.dart';

const apiPrefix = '/api/v1';

/// What GI Core answered. `status` 0 means no answer at all (network error).
class CoreResponse {
  const new(this.status, {this.data, this.code, this.message});

  final int status;

  /// The `data` member of Core's response envelope, when there was one.
  final Object? data;

  /// The `code` of an error body (for example `GI_EDGE_CLOCK_SKEW`).
  final String? code;
  final String? message;

  bool get ok => status >= 200 && status < 300;

  Map<String, Object?> get dataMap =>
      data is Map<String, Object?> ? data! as Map<String, Object?> : const {};
}

/// One entry of the push log shown by `GET /fake/state`.
class PushRecord {
  new({
    required this.at,
    required this.kind,
    required this.path,
    required this.status,
    this.sequence,
    this.code,
  });

  final DateTime at;
  final String kind;
  final String path;
  final int? sequence;
  final int status;
  final String? code;

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'kind': kind,
    'path': path,
    'sequence': sequence,
    'status': status,
    if (code != null) 'code': code,
  };
}

/// The device side of GI Core's GI Edge protocol: unsigned activation and
/// self-heal, HMAC-signed everything else.
class EdgeClient {
  new({
    required this.identity,
    required this.coreUrl,
    required this.deviceClock,
    required this.timeout,
    this.onPush,
    Random? random,
  }) : _random = random ?? Random.secure();

  final IdentityStore identity;
  final String Function() coreUrl;

  /// The device's own (possibly skewed) wall clock.
  final DateTime Function() deviceClock;
  final Duration timeout;
  final void Function(PushRecord record)? onPush;
  final Random _random;

  /// Set by the `revoke` scenario: signs with a wrong secret.
  bool corruptSecret = false;

  /// POST a signed JSON body. [body] is called with the freshly reserved
  /// sequence so the body can carry it.
  Future<CoreResponse> signedPost(
    String route,
    Object? Function(int sequence) body, {
    required String kind,
  }) async {
    final deviceId = identity.deviceId;
    final secret = identity.sharedSecret;
    if (deviceId == null || secret == null) {
      return const CoreResponse(0, message: 'not provisioned');
    }
    final path = '$apiPrefix$route';
    final sequence = identity.reserveSequence();
    final bytes = utf8.encode(encodeWireJson(body(sequence)));
    final headers = signedHeaders(
      sharedSecret: corruptSecret ? '$secret-corrupted' : secret,
      deviceId: deviceId,
      path: path,
      body: bytes,
      timestamp: isoMillis(deviceClock()),
      nonce: newNonce(_random),
      sequence: sequence,
    );
    final response = await _send(path, bytes, headers);
    onPush?.call(
      PushRecord(
        at: DateTime.now(),
        kind: kind,
        path: path,
        sequence: sequence,
        status: response.status,
        code: response.code,
      ),
    );
    return response;
  }

  /// POST an unsigned JSON body (activation, self-heal).
  Future<CoreResponse> unsignedPost(
    String route,
    Map<String, Object?> body, {
    required String kind,
  }) async {
    final path = '$apiPrefix$route';
    final response = await _send(path, utf8.encode(jsonEncode(body)), {
      'content-type': 'application/json',
    });
    onPush?.call(
      PushRecord(
        at: DateTime.now(),
        kind: kind,
        path: path,
        status: response.status,
        code: response.code,
      ),
    );
    return response;
  }

  Future<CoreResponse> _send(
    String path,
    List<int> bytes,
    Map<String, String> headers,
  ) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final base = Uri.parse(coreUrl());
      final request = await client
          .postUrl(base.replace(path: path))
          .timeout(timeout);
      headers.forEach(request.headers.set);
      request.contentLength = bytes.length;
      request.add(bytes);
      final response = await request.close().timeout(timeout);
      final text = await utf8.decodeStream(response).timeout(timeout);
      return _parse(response.statusCode, text);
    } on Object catch (e) {
      return CoreResponse(0, message: '$e');
    } finally {
      client.close(force: true);
    }
  }

  CoreResponse _parse(int status, String text) {
    Object? json;
    try {
      json = text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      json = null;
    }
    if (json is! Map<String, Object?>) return CoreResponse(status);
    if (status >= 200 && status < 300) {
      return CoreResponse(status, data: json['data']);
    }
    return CoreResponse(
      status,
      code: json['code'] as String?,
      message: json['message']?.toString(),
    );
  }
}
