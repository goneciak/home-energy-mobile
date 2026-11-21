import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error_envelope.freezed.dart';

/// GI Core error body `{statusCode, code, message, path, requestId,
/// timestamp, details?}` (`common/filters/api-exception.filter.ts`).
@freezed
abstract class ApiErrorEnvelope with _$ApiErrorEnvelope {
  const factory({
    required String code,
    int? statusCode,
    String? message,
    String? path,
    String? requestId,
    String? timestamp,

    /// Validation messages keyed by dotted field path.
    @Default(<String, List<String>>{}) Map<String, List<String>> details,
  }) = _ApiErrorEnvelope;

  /// Parses an error body tolerantly. Returns `null` when [data] is not an
  /// envelope (no string `code`), e.g. an HTML page from a proxy.
  static ApiErrorEnvelope? tryParse(Object? data) {
    if (data is! Map) return null;
    final code = data['code'];
    if (code is! String || code.isEmpty) return null;
    return ApiErrorEnvelope(
      code: code,
      statusCode: _asInt(data['statusCode']),
      message: _asString(data['message']),
      path: _asString(data['path']),
      requestId: _asString(data['requestId']),
      timestamp: _asString(data['timestamp']),
      details: _parseDetails(data['details']),
    );
  }
}

String? _asString(Object? value) => value is String ? value : null;

int? _asInt(Object? value) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v),
  _ => null,
};

Map<String, List<String>> _parseDetails(Object? raw) {
  if (raw is! Map) return const {};
  final details = <String, List<String>>{};
  raw.forEach((key, value) {
    final messages = switch (value) {
      final String message => [message],
      final List<Object?> list => [for (final item in list) ?_asString(item)],
      _ => const <String>[],
    };
    details['$key'] = messages;
  });
  return details;
}
