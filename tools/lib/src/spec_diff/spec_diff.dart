import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_tools/src/spec_diff/client_shapes.dart';
import 'package:gi_tools/src/spec_diff/openapi.dart';

enum Severity { error, warning }

/// One difference between the snapshot and the live spec.
final class SpecFinding {
  const new({
    required this.severity,
    required this.kind,
    required this.message,
    this.endpointId,
    this.operation,
    this.field,
  });

  final Severity severity;

  /// Stable machine-readable kind, e.g. `endpoint-removed`.
  final String kind;
  final String message;

  /// Catalog id; null for an operation outside the catalog.
  final String? endpointId;

  /// `METHOD /path` as in the live (or snapshot) spec.
  final String? operation;

  /// Field path (`$.items[].id`) or parameter (`query:limit`).
  final String? field;

  Map<String, Object?> toJson() => {
    'severity': severity.name,
    'kind': kind,
    'endpointId': ?endpointId,
    'operation': ?operation,
    'field': ?field,
    'message': message,
  };
}

final class SpecDiffReport {
  const new({required this.checkedEndpoints, required this.findings});

  final int checkedEndpoints;
  final List<SpecFinding> findings;

  Iterable<SpecFinding> get errors =>
      findings.where((f) => f.severity == Severity.error);

  Iterable<SpecFinding> get warnings =>
      findings.where((f) => f.severity == Severity.warning);

  bool get hasErrors => errors.isNotEmpty;

  /// 1 with errors, else 0.
  int get exitCode => hasErrors ? 1 : 0;

  Map<String, Object?> toJson({String? live, String? snapshot}) => {
    'live': ?live,
    'snapshot': ?snapshot,
    'checkedEndpoints': checkedEndpoints,
    'errors': errors.length,
    'warnings': warnings.length,
    'findings': [for (final f in findings) f.toJson()],
  };

  /// Human-readable report.
  String format({String? live, String? snapshot}) {
    final out = StringBuffer();
    if (live != null && snapshot != null) {
      out.writeln('spec_diff: $live vs $snapshot');
    }
    out.writeln(
      'Catalog endpoints checked: $checkedEndpoints. '
      'Errors: ${errors.length}. Warnings: ${warnings.length}.',
    );
    for (final severity in Severity.values) {
      final group = findings.where((f) => f.severity == severity).toList();
      if (group.isEmpty) continue;
      out
        ..writeln()
        ..writeln(severity == Severity.error ? 'ERRORS' : 'WARNINGS');
      for (final f in group) {
        final where = [?f.endpointId, ?f.operation, ?f.field].join('  ');
        out
          ..writeln('  [${f.kind}] $where')
          ..writeln('      ${f.message}');
      }
    }
    if (!hasErrors) {
      out
        ..writeln()
        ..writeln('OK: no breaking change for the catalog endpoints.');
    }
    return out.toString();
  }
}

/// Compares the [live] spec with the committed [snapshot], filtered to the
/// operations of [endpoints] (paths relative to [prefix]), plan §17.5.
///
/// Errors (breaking for the client):
/// * a catalog operation missing from the live spec;
/// * a required request field or parameter added (or made required), a
///   required one removed or retyped, a request body becoming required;
/// * a response field the client decodes as required ([clientShapes])
///   removed, or a field the client decodes retyped.
///
/// Everything else is a warning: added optional fields, response fields the
/// client does not need, new operations, changed 2xx codes.
SpecDiffReport diffSpecs({
  required Map<String, Object?> snapshot,
  required Map<String, Object?> live,
  required List<Endpoint> endpoints,
  Map<String, ClientShape> clientShapes = const {},
  String prefix = '/api/v1',
}) {
  final before = readOperations(snapshot);
  final after = readOperations(live);
  final findings = <SpecFinding>[];

  for (final endpoint in endpoints) {
    final key =
        '${endpoint.method.verb} ${normalizePath(prefix + endpoint.path)}';
    final display = '${endpoint.method.verb} $prefix${endpoint.path}';
    final old = before[key];
    final now = after[key];
    void add(Severity severity, String kind, String message, [String? field]) =>
        findings.add(
          SpecFinding(
            severity: severity,
            kind: kind,
            message: message,
            endpointId: endpoint.id,
            operation: display,
            field: field,
          ),
        );

    if (now == null) {
      add(
        Severity.error,
        'endpoint-removed',
        'the catalog operation is missing from the live spec',
      );
      continue;
    }
    if (old == null) {
      add(
        Severity.warning,
        'snapshot-missing-endpoint',
        'the snapshot does not have this catalog operation; re-record it',
      );
      continue;
    }
    if (now.operationId != endpoint.id) {
      add(
        Severity.warning,
        'operation-id-changed',
        'operationId is ${now.operationId}, the catalog says ${endpoint.id} '
            '(fixture folders use the catalog id)',
      );
    }

    _diffParameters(old, now, add);
    _diffRequest(old, now, add);
    _diffResponse(old, now, clientShapes[endpoint.id], add);
  }

  for (final MapEntry(:key, value: op) in after.entries) {
    if (before.containsKey(key)) continue;
    findings.add(
      SpecFinding(
        severity: Severity.warning,
        kind: 'endpoint-added',
        message: 'new operation ${op.operationId ?? ''}'.trimRight(),
        operation: '${op.method.toUpperCase()} ${op.path}',
      ),
    );
  }

  return SpecDiffReport(checkedEndpoints: endpoints.length, findings: findings);
}

typedef _Add = void Function(
  Severity severity,
  String kind,
  String message, [
  String? field,
]);

void _diffParameters(SpecOperation old, SpecOperation now, _Add add) {
  final before = {for (final p in old.parameters) p.key: p};
  final after = {for (final p in now.parameters) p.key: p};
  for (final MapEntry(:key, value: p) in after.entries) {
    final was = before[key];
    if (p.required && (was == null || !was.required)) {
      add(
        Severity.error,
        'parameter-required',
        was == null
            ? 'new required parameter'
            : 'the parameter became required',
        key,
      );
    } else if (was == null) {
      add(Severity.warning, 'parameter-added', 'new optional parameter', key);
    }
  }
  for (final MapEntry(:key, value: p) in before.entries) {
    if (after.containsKey(key)) continue;
    add(
      p.required ? Severity.error : Severity.warning,
      'parameter-removed',
      p.required
          ? 'a required parameter was removed'
          : 'an optional parameter was removed (the server may now reject it)',
      key,
    );
  }
}

void _diffRequest(SpecOperation old, SpecOperation now, _Add add) {
  if (now.requestRequired && !old.requestRequired) {
    add(Severity.error, 'request-body-required', 'a request body is required');
  }
  for (final MapEntry(:key, value: field) in now.request.entries) {
    if (key == r'$') continue;
    final was = old.request[key];
    if (field.required && (was == null || !was.required)) {
      add(
        Severity.error,
        'request-field-required',
        was == null
            ? 'new required request field (${field.type})'
            : 'the request field became required',
        key,
      );
    } else if (was == null) {
      if (_parentIsNew(key, old.request)) continue;
      add(
        Severity.warning,
        'request-field-added',
        'new optional request field (${field.type})',
        key,
      );
    } else if (was.type != field.type) {
      add(
        was.required ? Severity.error : Severity.warning,
        'request-field-type-changed',
        'type ${was.type} -> ${field.type}',
        key,
      );
    }
  }
  for (final MapEntry(:key, value: was) in old.request.entries) {
    if (key == r'$' || now.request.containsKey(key)) continue;
    if (_parentIsNew(key, now.request)) continue;
    add(
      was.required ? Severity.error : Severity.warning,
      'request-field-removed',
      was.required
          ? 'a required request field was removed (the client sends it)'
          : 'an optional request field was removed (the server rejects '
                'unknown fields)',
      key,
    );
  }
}

void _diffResponse(
  SpecOperation old,
  SpecOperation now,
  ClientShape? shape,
  _Add add,
) {
  final client = shape ?? const ClientShape();
  final oldCodes = old.successStatuses.join(',');
  final newCodes = now.successStatuses.join(',');
  if (oldCodes != newCodes) {
    add(
      Severity.warning,
      'success-status-changed',
      'declared 2xx $oldCodes -> $newCodes',
    );
  }

  for (final MapEntry(:key, value: was) in old.response.entries) {
    final field = now.response[key];
    if (field == null) {
      if (_parentIsNew(key, now.response)) continue;
      final needed = client.requires(key);
      add(
        needed ? Severity.error : Severity.warning,
        'response-field-removed',
        needed
            ? 'the client decodes this field as required'
            : 'the client does not require this field',
        key,
      );
    } else if (field.type != was.type) {
      final read =
          client.decodes(key) ||
          (key == r'$' && client.decodedFields.isNotEmpty);
      add(
        read ? Severity.error : Severity.warning,
        'response-field-type-changed',
        'type ${was.type} -> ${field.type}'
            '${read ? ' (the client decodes it)' : ''}',
        key,
      );
    } else if (client.requires(key) &&
        ((was.required && !field.required) ||
            (!was.nullable && field.nullable))) {
      add(
        Severity.warning,
        'response-field-optional',
        'the spec no longer guarantees a field the client requires',
        key,
      );
    }
  }
  for (final MapEntry(:key, value: field) in now.response.entries) {
    if (old.response.containsKey(key) || _parentIsNew(key, old.response)) {
      continue;
    }
    add(
      Severity.warning,
      'response-field-added',
      'new response field (${field.type})',
      key,
    );
  }
}

/// Whether the parent of [path] is missing from [other] too, so only the
/// top of a new or removed subtree is reported.
bool _parentIsNew(String path, Map<String, SchemaField> other) {
  final parent = _parent(path);
  return parent != null && parent != r'$' && !other.containsKey(parent);
}

String? _parent(String path) {
  if (path.endsWith('[]')) return path.substring(0, path.length - 2);
  final dot = path.lastIndexOf('.');
  return dot <= 0 ? null : path.substring(0, dot);
}
