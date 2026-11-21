import 'package:json_annotation/json_annotation.dart';

/// Accepts a JSON number or a numeric string (Prisma Decimal) and yields a
/// double. Anything else fails decoding so it surfaces as `unexpectedShape`.
class NumOrStringConverter implements JsonConverter<double, Object?> {
  const new();

  @override
  double fromJson(Object? json) => switch (json) {
    final num value => value.toDouble(),
    final String value when double.tryParse(value) != null => double.parse(
      value,
    ),
    _ => throw FormatException('Expected a number, got ${json.runtimeType}'),
  };

  @override
  Object? toJson(double value) => value;
}

/// A finite JSON number or numeric string as a double, otherwise `null`.
/// For tolerant decoding of stored blobs; [NumOrStringConverter] is strict.
double? finiteNumberOrNull(Object? json) {
  final value = switch (json) {
    final num number => number.toDouble(),
    final String text => double.tryParse(text),
    _ => null,
  };
  return value != null && value.isFinite ? value : null;
}

/// Casts a decoded JSON value to an object map, failing with a clear error
/// when the payload has a different top-level shape.
Map<String, dynamic> asJsonObject(Object? json) => switch (json) {
  final Map<String, dynamic> map => map,
  final Map<dynamic, dynamic> map => map.cast<String, dynamic>(),
  _ => throw FormatException('Expected a JSON object, got ${json.runtimeType}'),
};

/// Casts a decoded JSON value to a list.
List<Object?> asJsonList(Object? json) => switch (json) {
  final List<Object?> list => list,
  _ => throw FormatException('Expected a JSON array, got ${json.runtimeType}'),
};
