import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Lowercase hex SHA-256 of the exact bytes sent (Core hashes `rawBody`).
String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

/// The canonical signing material (GI Core `gi-edge-signing-material.ts`).
String signingMaterial({
  required String path,
  required String bodyHash,
  required String deviceId,
  required String timestamp,
  required String nonce,
  required String sequence,
  String method = 'POST',
}) => [method, path, bodyHash, deviceId, timestamp, nonce, sequence].join('\n');

/// base64url without padding of HMAC-SHA256 (key = the secret as UTF-8).
String signMaterial(String sharedSecret, String material) {
  final mac = Hmac(sha256, utf8.encode(sharedSecret));
  return base64Url
      .encode(mac.convert(utf8.encode(material)).bytes)
      .replaceAll('=', '');
}

/// ISO-8601 with milliseconds and a `Z`, as the firmware sends it.
String isoMillis(DateTime time) => DateTime.fromMillisecondsSinceEpoch(
  time.millisecondsSinceEpoch,
  isUtc: true,
).toIso8601String();

/// 16 hex characters, fresh for every request.
String newNonce(Random random) => List.generate(
  8,
  (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// The signed headers (plus content type) of one request.
Map<String, String> signedHeaders({
  required String sharedSecret,
  required String deviceId,
  required String path,
  required List<int> body,
  required String timestamp,
  required String nonce,
  required int sequence,
  String protocolVersion = '1.0',
}) {
  final bodyHash = sha256Hex(body);
  final signature = signMaterial(
    sharedSecret,
    signingMaterial(
      path: path,
      bodyHash: bodyHash,
      deviceId: deviceId,
      timestamp: timestamp,
      nonce: nonce,
      sequence: '$sequence',
    ),
  );
  return {
    'content-type': 'application/json',
    'x-gi-device-id': deviceId,
    'x-gi-timestamp': timestamp,
    'x-gi-nonce': nonce,
    'x-gi-sequence': '$sequence',
    'x-gi-content-sha256': bodyHash,
    'x-gi-signature': signature,
    'x-gi-protocol-version': protocolVersion,
  };
}
