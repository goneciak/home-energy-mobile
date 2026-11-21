/// A small, pragmatic reader of the OpenAPI 3 documents GI Core's Swagger
/// module exports (`/docs-json`). It only understands what spec_diff needs:
/// operations, parameters, JSON request bodies and the first JSON 2xx
/// response, with `$ref`, `allOf`, nested objects and arrays flattened into
/// field paths.
library;

/// One field of a flattened schema.
final class SchemaField {
  const new({
    required this.type,
    required this.required,
    this.nullable = false,
  });

  /// `string`, `number`, `integer`, `boolean`, `object`, `array`, `union`
  /// or `any` (no type given).
  final String type;

  /// Required at its level and at every level above it (the whole chain from
  /// the root), so a client must always send or may always expect it.
  final bool required;
  final bool nullable;

  Map<String, Object?> toJson() => {
    'type': type,
    'required': required,
    if (nullable) 'nullable': true,
  };

  @override
  String toString() => '$type${nullable ? '?' : ''}${required ? '' : ' (opt)'}';
}

/// A query, path or header parameter.
final class SpecParameter {
  const new({
    required this.name,
    required this.location,
    this.required = false,
  });

  final String name;

  /// `query`, `path`, `header` or `cookie`.
  final String location;
  final bool required;

  String get key => '$location:$name';
}

/// One operation (path + method) of a spec.
final class SpecOperation {
  const new({
    required this.method,
    required this.path,
    required this.operationId,
    required this.parameters,
    required this.requestRequired,
    required this.request,
    required this.successStatuses,
    required this.response,
  });

  /// Lower-case HTTP method.
  final String method;

  /// Full spec path, e.g. `/api/v1/devices/{id}`.
  final String path;
  final String? operationId;
  final List<SpecParameter> parameters;

  /// Whether a JSON request body is required at all.
  final bool requestRequired;

  /// Flattened JSON request body; empty without one.
  final Map<String, SchemaField> request;

  /// Declared 2xx status codes, sorted.
  final List<String> successStatuses;

  /// Flattened schema of the first 2xx JSON response; empty without one
  /// (GI Core declares no schema for many operations, plan §6.1).
  final Map<String, SchemaField> response;

  String get key => '${method.toUpperCase()} ${normalizePath(path)}';
}

/// [path] with every `{placeholder}` replaced by `{}`, so `/devices/{id}`
/// and `/devices/{deviceId}` compare equal.
String normalizePath(String path) =>
    path.replaceAll(RegExp(r'\{[^}]*\}'), '{}');

const _methods = {'get', 'put', 'post', 'delete', 'options', 'head', 'patch'};

/// Every operation of [spec], keyed by [SpecOperation.key].
Map<String, SpecOperation> readOperations(Map<String, Object?> spec) {
  final reader = _SpecReader(spec);
  final operations = <String, SpecOperation>{};
  final paths = spec['paths'];
  if (paths is! Map) return operations;
  for (final MapEntry(key: path, value: item) in paths.entries) {
    if (item is! Map) continue;
    for (final MapEntry(key: method, value: op) in item.entries) {
      final verb = '$method'.toLowerCase();
      if (!_methods.contains(verb) || op is! Map) continue;
      final operation = reader.operation('$path', verb, op, item);
      operations[operation.key] = operation;
    }
  }
  return operations;
}

/// Flattens [schema] of [spec] into field paths: `$` for the root, `$.a.b`
/// for properties, `$.a[]` for array items (`$[]` for a root array).
Map<String, SchemaField> flattenSchema(
  Map<String, Object?> spec,
  Object? schema,
) => _SpecReader(spec).flatten(schema, rootRequired: true);

final class _SpecReader {
  new(this.spec);

  final Map<String, Object?> spec;

  SpecOperation operation(
    String path,
    String method,
    Map<dynamic, dynamic> op,
    Map<dynamic, dynamic> pathItem,
  ) {
    final parameters = <String, SpecParameter>{};
    for (final source in [pathItem['parameters'], op['parameters']]) {
      if (source is! List) continue;
      for (final raw in source) {
        final param = _resolve(raw);
        if (param == null) continue;
        final parameter = SpecParameter(
          name: '${param['name']}',
          location: '${param['in']}',
          required: param['required'] == true,
        );
        parameters[parameter.key] = parameter;
      }
    }

    final body = _resolve(op['requestBody']);
    final requestSchema = _jsonSchema(body?['content']);
    final requestRequired = body != null && body['required'] == true;

    final statuses = <String>[];
    Object? responseSchema;
    final responses = op['responses'];
    if (responses is Map) {
      final codes = responses.keys.map((k) => '$k').toList()..sort();
      for (final code in codes) {
        if (!code.startsWith('2')) continue;
        statuses.add(code);
        final response = _resolve(responses[code]);
        responseSchema ??= _jsonSchema(response?['content']);
      }
    }

    return SpecOperation(
      method: method,
      path: path,
      operationId: op['operationId'] as String?,
      parameters: parameters.values.toList(),
      requestRequired: requestRequired,
      request: requestSchema == null
          ? const {}
          : flatten(requestSchema, rootRequired: requestRequired),
      successStatuses: statuses,
      response: responseSchema == null
          ? const {}
          : flatten(responseSchema, rootRequired: true),
    );
  }

  Map<String, SchemaField> flatten(
    Object? schema, {
    required bool rootRequired,
  }) {
    final fields = <String, SchemaField>{};
    _walk(schema, r'$', rootRequired, fields, const {});
    return fields;
  }

  void _walk(
    Object? raw,
    String path,
    bool required,
    Map<String, SchemaField> fields,
    Set<String> refs,
  ) {
    if (raw is! Map) {
      fields[path] = SchemaField(type: 'any', required: required);
      return;
    }
    // Merge `$ref` and `allOf` parts into one view of the schema.
    final merged = <String, Object?>{};
    final requiredNames = <String>{};
    final properties = <String, Object?>{};
    Object? items;
    var nullable = false;
    var union = false;
    final seen = {...refs};

    void absorb(Object? part) {
      if (part is! Map) return;
      final ref = part[r'$ref'];
      if (ref is String) {
        if (!seen.add(ref)) return; // A recursive schema: stop here.
        absorb(_lookup(ref));
      }
      for (final MapEntry(:key, :value) in part.entries) {
        switch (key) {
          case 'allOf':
            if (value is List) value.forEach(absorb);
          case 'oneOf' || 'anyOf':
            union = true;
          case 'properties':
            if (value is Map) {
              for (final MapEntry(key: name, value: prop) in value.entries) {
                properties['$name'] = prop;
              }
            }
          case 'required':
            if (value is List) requiredNames.addAll(value.map((v) => '$v'));
          case 'items':
            items = value;
          case 'nullable':
            nullable = nullable || value == true;
          case r'$ref':
            break;
          default:
            merged['$key'] = value;
        }
      }
    }

    absorb(raw);

    final declared = merged['type'];
    final type = union
        ? 'union'
        : switch (declared) {
            final String t => t,
            final List<dynamic> t => t.where((v) => v != 'null').join('|'),
            _ when properties.isNotEmpty => 'object',
            _ when items != null => 'array',
            _ => 'any',
          };
    if (declared is List && declared.contains('null')) nullable = true;
    fields[path] = SchemaField(
      type: type,
      required: required,
      nullable: nullable,
    );

    for (final MapEntry(key: name, value: prop) in properties.entries) {
      _walk(
        prop,
        '$path.$name',
        required && requiredNames.contains(name),
        fields,
        seen,
      );
    }
    if (type == 'array' && items != null) {
      _walk(items, '$path[]', required, fields, seen);
    }
  }

  Object? _jsonSchema(Object? content) {
    if (content is! Map) return null;
    for (final MapEntry(:key, :value) in content.entries) {
      if ('$key'.contains('json') && value is Map) return value['schema'];
    }
    return null;
  }

  /// [raw] with a top-level `$ref` (parameters, request bodies, responses)
  /// followed.
  Map<dynamic, dynamic>? _resolve(Object? raw) {
    var current = raw;
    for (var hops = 0; hops < 8 && current is Map; hops++) {
      final ref = current[r'$ref'];
      if (ref is! String) return current;
      current = _lookup(ref);
    }
    return current is Map ? current : null;
  }

  Object? _lookup(String ref) {
    if (!ref.startsWith('#/')) return null;
    Object? node = spec;
    for (final segment in ref.substring(2).split('/')) {
      final key = segment.replaceAll('~1', '/').replaceAll('~0', '~');
      if (node is! Map) return null;
      node = node[key];
    }
    return node;
  }
}
