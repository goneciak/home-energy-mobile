import 'dart:convert';

/// Encodes [value] as JSON the way the firmware writes it: doubles with six
/// decimals (`std::to_string`, so `45.500000`), keys in insertion order.
String encodeWireJson(Object? value) {
  final buffer = StringBuffer();
  _write(buffer, value);
  return buffer.toString();
}

void _write(StringBuffer out, Object? value) {
  switch (value) {
    case null:
      out.write('null');
    case bool() || int():
      out.write(value);
    case double():
      out.write(value.toStringAsFixed(6));
    case String():
      out.write(jsonEncode(value));
    case List<Object?>():
      out.write('[');
      for (var i = 0; i < value.length; i++) {
        if (i > 0) out.write(',');
        _write(out, value[i]);
      }
      out.write(']');
    case Map<String, Object?>():
      out.write('{');
      var first = true;
      for (final entry in value.entries) {
        if (!first) out.write(',');
        first = false;
        out
          ..write(jsonEncode(entry.key))
          ..write(':');
        _write(out, entry.value);
      }
      out.write('}');
    default:
      throw ArgumentError('Not JSON encodable: ${value.runtimeType}');
  }
}
