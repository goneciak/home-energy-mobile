import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:gi_core_api/src/catalog/endpoint.dart';
import 'package:gi_core_api/src/failures/api_failure.dart';
import 'package:json_annotation/json_annotation.dart';

const requestIdHeader = 'x-request-id';

/// How strictly response bodies are decoded (plan §6.4, §17.3).
enum DecodeMode {
  /// Unknown fields are ignored, so a newer GI Core that adds fields keeps
  /// working. The app always uses this.
  tolerant,

  /// A field the model does not know fails the call with
  /// [ApiFailure.unexpectedShape] naming the endpoint and the field. For
  /// contract tests that must notice API drift.
  strict;

  /// Environment variable that turns [strict] on in [fromEnvironment].
  static const environmentVariable = 'GI_CORE_STRICT_DECODING';

  /// [strict] when [environmentVariable] is `1` or `true` in [environment]
  /// (default: the process environment), otherwise [tolerant].
  static DecodeMode fromEnvironment([Map<String, String>? environment]) {
    final value = (environment ?? Platform.environment)[environmentVariable];
    return switch (value?.trim().toLowerCase()) {
      '1' || 'true' => strict,
      _ => tolerant,
    };
  }
}

/// Decodes a 2xx body with [decode], turning any shape mismatch into
/// [ApiFailure.unexpectedShape] and a non-JSON body into
/// [ApiFailure.unexpectedResponse]. Never lets a decoding error escape.
///
/// In [DecodeMode.strict], [encode] turns the decoded value back into JSON
/// and every key of the body missing from it is reported as an unknown
/// field; without [encode] the body is not checked.
T decodeResponse<T>(
  Endpoint endpoint,
  Response<Object?> response,
  T Function(Object? json) decode, {
  DecodeMode mode = DecodeMode.tolerant,
  Object? Function(T value)? encode,
}) {
  final data = response.data;
  if (data is String) {
    throw ApiFailure.unexpectedResponse(
      statusCode: response.statusCode,
      contentType: response.headers.value(Headers.contentTypeHeader),
    );
  }
  final requestId = response.headers.value(requestIdHeader);
  try {
    final value = decode(data);
    if (mode == DecodeMode.strict && encode != null) {
      final unknown = unknownJsonFields(data, encode(value));
      if (unknown.isNotEmpty) {
        throw ApiFailure.unexpectedShape(
          endpointId: endpoint.id,
          requestId: requestId,
          fieldPath: unknown.first,
          message:
              'strict decoding: ${endpoint.method.verb} ${endpoint.path} '
              '(${endpoint.id}) returned unknown '
              '${unknown.length == 1 ? 'field' : 'fields'} '
              '${unknown.join(', ')}',
        );
      }
    }
    return value;
  } on CheckedFromJsonException catch (e) {
    throw ApiFailure.unexpectedShape(
      endpointId: endpoint.id,
      requestId: requestId,
      fieldPath: [?e.className, ?e.key].join('.'),
      message: e.message ?? '${e.innerError}',
    );
  } on FormatException catch (e) {
    throw ApiFailure.unexpectedShape(
      endpointId: endpoint.id,
      requestId: requestId,
      fieldPath: r'$',
      message: e.message,
    );
    // Generated fromJson casts throw TypeError on a mistyped field; that is
    // a wire-shape problem, not a bug in this code.
    // ignore: avoid_catching_errors
  } on TypeError catch (e) {
    throw ApiFailure.unexpectedShape(
      endpointId: endpoint.id,
      requestId: requestId,
      message: '$e',
    );
  }
}

/// JSON paths (`$.entities[0].foo`) of the object keys in [wire] that are
/// missing from [known] at the same place. [known] is the decoded model
/// encoded again, so it holds exactly the fields the model understands.
/// Values are not compared, and a branch whose shapes differ (a blob the
/// model dropped, lists of different length) is not descended into.
List<String> unknownJsonFields(Object? wire, Object? known) {
  final unknown = <String>[];
  void walk(Object? wire, Object? known, String path) {
    if (wire is Map && known is Map) {
      for (final MapEntry(:key, :value) in wire.entries) {
        final child = '$path.$key';
        if (known.containsKey(key)) {
          walk(value, known[key], child);
        } else {
          unknown.add(child);
        }
      }
    } else if (wire is List && known is List && wire.length == known.length) {
      for (var i = 0; i < wire.length; i++) {
        walk(wire[i], known[i], '$path[$i]');
      }
    }
  }

  walk(wire, known, r'$');
  return unknown;
}
