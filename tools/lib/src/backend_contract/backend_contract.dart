import 'dart:io';

import 'package:gi_core_api/gi_core_api.dart';

import 'package:gi_tools/src/repo.dart';

/// Where `docs/backend-contract.md` comes from: the catalog plus what the
/// repo has for each entry (fixtures, decode tests, live contract tests).
final class ContractSources {
  const new({
    required this.backendRef,
    required this.endpoints,
    required this.fieldNames,
    required this.fixtureFiles,
    required this.liveTests,
    required this.exemptions,
  });

  /// Reads everything from the repo checkout at [root].
  factory read(Directory root, {List<Endpoint> endpoints = GiEndpoints.all}) {
    final ref = readBackendRef(root);
    final package = '${root.path}/packages/gi_core_api';
    final fieldNames = parseCatalogFieldNames(
      File('$package/lib/src/catalog/endpoints.dart').readAsStringSync(),
    );

    final fixtureFiles = <String, List<String>>{};
    for (final endpoint in endpoints) {
      final dir = Directory('${fixturesRoot(root).path}/$ref/${endpoint.id}');
      fixtureFiles[endpoint.id] = dir.existsSync()
          ? ([
              for (final file in dir.listSync().whereType<File>())
                file.uri.pathSegments.last,
            ]..sort())
          : const [];
    }

    final liveTests = <String, Set<String>>{};
    for (final file in _dartFiles(Directory('$package/test/contract'))) {
      final name = file.uri.pathSegments.last;
      if (!name.endsWith('_contract_test.dart')) continue;
      for (final field in parseLiveCoverage(file.readAsStringSync())) {
        final id = fieldNames[field];
        if (id != null) (liveTests[id] ??= {}).add(name);
      }
    }

    final exemptionsFile = File(
      '$package/test/contract/support/live_coverage.dart',
    );
    final exemptions = <String, String>{
      if (exemptionsFile.existsSync())
        for (final MapEntry(:key, :value) in parseLiveCoverageExemptions(
          exemptionsFile.readAsStringSync(),
        ).entries)
          fieldNames[key] ?? key: value,
    };

    return ContractSources(
      backendRef: ref,
      endpoints: endpoints,
      fieldNames: fieldNames,
      fixtureFiles: fixtureFiles,
      liveTests: liveTests,
      exemptions: exemptions,
    );
  }

  final String backendRef;
  final List<Endpoint> endpoints;

  /// `GiEndpoints` field name -> catalog id.
  final Map<String, String> fieldNames;

  /// Catalog id -> fixture file names under `fixtures/core/<ref>/<id>/`.
  final Map<String, List<String>> fixtureFiles;

  /// Catalog id -> contract test files whose `liveCoverage` names it.
  final Map<String, Set<String>> liveTests;

  /// Catalog id -> why it has no live contract test.
  final Map<String, String> exemptions;
}

Iterable<File> _dartFiles(Directory dir) sync* {
  if (!dir.existsSync()) return;
  final files =
      dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  yield* files;
}

final _catalogField = RegExp(
  r"static const (\w+) = Endpoint\(\s*id:\s*'([^']+)'",
);

/// `GiEndpoints` field name -> catalog id, read from `endpoints.dart`.
Map<String, String> parseCatalogFieldNames(String source) => {
  for (final match in _catalogField.allMatches(source)) match[1]!: match[2]!,
};

final _liveCoverageList = RegExp(
  r'const liveCoverage = <Endpoint>\[([^\]]*)\]',
);
final _catalogReference = RegExp(r'GiEndpoints\.(\w+)');

/// Field names in the `const liveCoverage = <Endpoint>[...]` list of a live
/// contract test file (the registry `catalog_coverage_test.dart` checks).
List<String> parseLiveCoverage(String source) {
  final list = _liveCoverageList.firstMatch(source);
  if (list == null) return const [];
  return [
    for (final match in _catalogReference.allMatches(list[1]!)) match[1]!,
  ];
}

const _stringLiteral =
    r"'(?:[^'\\]|\\.)*'"
    '|'
    r'"(?:[^"\\]|\\.)*"';
final _exemption = RegExp(
  'GiEndpoints\\.(\\w+)\\s*:\\s*((?:(?:$_stringLiteral)\\s*)+)',
);
final _stringPart = RegExp(_stringLiteral);

/// `liveCoverageExemptions` entries (field name -> reason) of
/// `test/contract/support/live_coverage.dart`. Plain (non-raw, no
/// interpolation) string literals in either quote are supported; adjacent
/// literals are joined.
Map<String, String> parseLiveCoverageExemptions(String source) => {
  for (final match in _exemption.allMatches(source))
    match[1]!: [
      for (final part in _stringPart.allMatches(match[2]!))
        part[0]!
            .substring(1, part[0]!.length - 1)
            .replaceAllMapped(RegExp(r'\\(.)'), (m) => m[1]!),
    ].join(),
};

const Set<UserRole> _allRoles = {
  UserRole.owner,
  UserRole.admin,
  UserRole.user,
  UserRole.service,
};

String _auth(Endpoint endpoint) {
  if (endpoint.refreshCookie) return 'ciasteczko refresh';
  if (endpoint.isPublic) return 'publiczny';
  if (endpoint.roles.containsAll(_allRoles)) return 'Bearer, każda rola';
  final roles = [
    for (final role in UserRole.values)
      if (endpoint.roles.contains(role)) role.name.toUpperCase(),
  ];
  return 'Bearer: ${roles.join(', ')}';
}

String _timeout(Endpoint endpoint) {
  final retries = switch (endpoint.maxRetries) {
    0 => '',
    1 => ', 1 ponowienie',
    final n when n < 5 => ', $n ponowienia',
    final n => ', $n ponowień',
  };
  return '`${endpoint.timeout.name}`$retries';
}

String _cases(List<String> files) => files.isEmpty
    ? '**brak**'
    : files
          .map((f) => f.endsWith('.json') ? f.substring(0, f.length - 5) : f)
          .map((c) => '`$c`')
          .join(', ');

String _files(Set<String>? files) => files == null || files.isEmpty
    ? '**brak**'
    : (files.toList()..sort()).map((f) => '`$f`').join(', ');

String _cell(String text) => text.replaceAll('|', r'\|');

/// Renders `docs/backend-contract.md` (plan §6.2). Deterministic: no dates,
/// sorted lists, `\n` line endings.
String renderBackendContract(ContractSources sources) {
  final out = StringBuffer()
    ..writeln('<!--')
    ..writeln('  Generated by tools/gen_backend_contract.dart from')
    ..writeln('  GiEndpoints.all (packages/gi_core_api). Do not edit by hand:')
    ..writeln('  dart run tools/gen_backend_contract.dart')
    ..writeln('  tools/test/backend_contract_test.dart fails when it is stale.')
    ..writeln('-->')
    ..writeln()
    ..writeln('# Kontrakt GI Core używany przez aplikację mobilną')
    ..writeln()
    ..writeln(
      'Wpisy katalogu `GiEndpoints.all` '
      '(`packages/gi_core_api/lib/src/catalog/endpoints.dart`, plan §6.2). '
      'Ścieżki są względne wobec `/api/v1`. Backend: '
      '`${sources.backendRef}` (`contract/backend.lock`), snapshot '
      'specyfikacji: `contract/openapi/core-${sources.backendRef}.json` '
      '(`tools/spec_diff.dart`).',
    )
    ..writeln()
    ..writeln(
      '| Id | Metoda | Ścieżka | Autoryzacja | Kamień milowy | Funkcja '
      "| Timeout | Fixture'y | Testy na żywo |",
    )
    ..writeln('|---|---|---|---|---|---|---|---|---|');

  for (final endpoint in sources.endpoints) {
    final exemption = sources.exemptions[endpoint.id];
    final live = sources.liveTests[endpoint.id];
    final liveCell = live != null && live.isNotEmpty
        ? _files(live)
        : exemption != null
        ? 'zwolniony (niżej)'
        : '**brak**';
    final cells = [
      '`${endpoint.id}`',
      endpoint.method.verb,
      '`${endpoint.path}`',
      _auth(endpoint),
      endpoint.milestone.label,
      '`${endpoint.feature}`',
      _timeout(endpoint),
      _cases(sources.fixtureFiles[endpoint.id] ?? const []),
      liveCell,
    ];
    out.writeln('| ${cells.map(_cell).join(' | ')} |');
  }

  final exempt = [
    for (final endpoint in sources.endpoints)
      if (sources.exemptions[endpoint.id] case final reason?)
        (endpoint.id, reason),
  ];
  out
    ..writeln()
    ..writeln('## Zwolnienia z testu na żywo')
    ..writeln();
  if (exempt.isEmpty) {
    out.writeln('Brak: każdy wpis ma test kontraktowy na żywo.');
  } else {
    for (final (id, reason) in exempt) {
      out.writeln('- `$id`: $reason');
    }
  }

  out
    ..writeln()
    ..writeln('## Legenda')
    ..writeln()
    ..writeln(
      '- **Autoryzacja:** „Bearer” to token dostępu w nagłówku '
      '`Authorization`; 401 wyzwala jedno odświeżenie sesji. '
      '„Ciasteczko refresh” to wyłącznie `POST /auth/refresh` z ręcznym '
      'nagłówkiem `Cookie` (plan §7.2).',
    )
    ..writeln(
      '- **Timeout:** klasa z planu §6.6 (`read` 4/10 s, `write` 4/15 s, '
      '`refresh` 4/30 s); ponowienia tylko dla odczytów.',
    )
    ..writeln(
      "- **Fixture'y:** pliki w `packages/gi_core_api/test/fixtures/core/"
      '${sources.backendRef}/<Id>/`.',
    )
    ..writeln(
      '- **Testy na żywo:** pliki `test/contract/*_contract_test.dart`, '
      'których lista `liveCoverage` wymienia wpis. Pełną regułę pokrycia '
      'katalogu (fixture, test dekodujący fixture, test na żywo albo '
      'zwolnienie z powodem) sprawdza '
      '`packages/gi_core_api/test/catalog_coverage_test.dart` (plan §19.1).',
    );
  return out.toString();
}
