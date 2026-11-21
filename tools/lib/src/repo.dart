import 'dart:convert';
import 'dart:io';

/// The mobile repo checkout the tools run in: the folder holding
/// `contract/backend.lock`, searched upwards from [from] (default: the
/// running script's folder, then the current directory).
Directory findRepoRoot({Directory? from}) {
  final starts = [
    ?from,
    if (from == null && Platform.script.scheme == 'file')
      File.fromUri(Platform.script).parent,
    if (from == null) Directory.current,
  ];
  for (final start in starts) {
    var dir = start.absolute;
    while (true) {
      if (File('${dir.path}/contract/backend.lock').existsSync()) return dir;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  }
  throw StateError(
    'contract/backend.lock not found above ${starts.map((d) => d.path)}',
  );
}

/// `shortSha` of `contract/backend.lock` in [root]: the backend ref the
/// fixtures and the OpenAPI snapshot were recorded against.
String readBackendRef(Directory root) {
  final lock = File('${root.path}/contract/backend.lock');
  for (final line in lock.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('shortSha=')) {
      return trimmed.substring('shortSha='.length).trim();
    }
  }
  throw StateError('${lock.path} has no shortSha=');
}

/// `packages/gi_core_api/test/fixtures/core` in [root].
Directory fixturesRoot(Directory root) =>
    Directory('${root.path}/packages/gi_core_api/test/fixtures/core');

/// [json] as stable, pretty-printed text: object keys sorted, two-space
/// indent, a trailing newline. Array order is kept.
String canonicalJson(Object? json) =>
    '${const JsonEncoder.withIndent('  ').convert(_sortKeys(json))}\n';

Object? _sortKeys(Object? json) => switch (json) {
  final Map<dynamic, dynamic> map => {
    for (final key in map.keys.map((k) => '$k').toList()..sort())
      key: _sortKeys(map[key]),
  },
  final List<dynamic> list => [for (final item in list) _sortKeys(item)],
  _ => json,
};

/// Normalizes line endings so generated text compares equal on Windows
/// checkouts with `core.autocrlf`.
String normalizeNewlines(String text) => text.replaceAll('\r\n', '\n');
