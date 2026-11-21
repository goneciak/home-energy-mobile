import 'dart:io';

import 'package:gi_tools/src/coverage/lcov.dart';

/// The coverage gates of plan §17.2.
///
/// Line coverage is enforced everywhere. Branch thresholds apply wherever
/// the report carries branch data (`--branch-coverage`, which CI passes);
/// without it they fall back to the line thresholds alone.
const List<CoverageRule> defaultCoverageRules = [
  CoverageRule(
    name: 'gi_core_api',
    include: 'packages/gi_core_api/lib/**',
    minLinePercent: 90,
    // Export-only and const-only: never in an lcov report.
    allowMissing: [
      'packages/gi_core_api/lib/gi_core_api.dart',
      'packages/gi_core_api/lib/src/catalog/endpoints.dart',
    ],
  ),
  CoverageRule(
    name: 'app domain',
    include: 'app/lib/**/domain/**',
    minLinePercent: 90,
  ),
  CoverageRule(
    name: 'TransportPolicy',
    include: 'packages/gi_core_api/lib/src/http/transport_policy.dart',
    minLinePercent: 100,
    minBranchPercent: 100,
    perFile: true,
  ),
  // SafetyPolicy and ConfirmationPolicy (M2) get the same 100% as soon as
  // they exist; until then the rule has nothing to check. A file of a
  // perFile rule that no test loads fails it.
  CoverageRule(
    name: 'Safety/ConfirmationPolicy',
    include: 'app/lib/**/{safety,confirmation}_policy.dart',
    minLinePercent: 100,
    minBranchPercent: 100,
    perFile: true,
    requireMatch: false,
  ),
];

/// One lcov report and the workspace member it belongs to.
final class CoverageReport {
  const new({required this.packageDir, required this.lcovPath});

  /// Parses `<packageDir>=<lcovPath>` (both relative to the repo root).
  factory parse(String spec) {
    final eq = spec.indexOf('=');
    if (eq <= 0 || eq == spec.length - 1) {
      throw FormatException('Expected <packageDir>=<lcovFile>, got "$spec"');
    }
    return CoverageReport(
      packageDir: _trimSlashes(spec.substring(0, eq)),
      lcovPath: spec.substring(eq + 1),
    );
  }

  /// Repository-relative folder of the member, e.g. `app`.
  final String packageDir;

  /// The tracefile; relative paths resolve against the repo root.
  final String lcovPath;
}

/// The reports CI writes: `dart test --coverage-path` in gi_core_api and
/// `flutter test --coverage` in the app.
const List<CoverageReport> defaultCoverageReports = [
  CoverageReport(
    packageDir: 'packages/gi_core_api',
    lcovPath: 'packages/gi_core_api/coverage/lcov.info',
  ),
  CoverageReport(packageDir: 'app', lcovPath: 'app/coverage/lcov.info'),
];

String _trimSlashes(String path) =>
    path.replaceAll(r'\', '/').replaceAll(RegExp(r'^\./|/+$'), '');

/// [sourceFile] (an `SF:` entry of the lcov report of [packageDir]) as a
/// repository-relative path with forward slashes. Absolute paths
/// (`dart test`) are made relative to [repoRoot]; relative ones
/// (`flutter test`: `lib/...`) to the member.
String resolveSourcePath(
  String sourceFile, {
  required String repoRoot,
  required String packageDir,
}) {
  final path = sourceFile.trim().replaceAll(r'\', '/');
  final isAbsolute =
      path.startsWith('/') || RegExp('^[A-Za-z]:/').hasMatch(path);
  if (!isAbsolute) return '$packageDir/${path.replaceFirst('./', '')}';
  final root = '${_trimSlashes(repoRoot)}/';
  // Windows paths differ in drive-letter case between tools.
  final windows = RegExp('^[A-Za-z]:/').hasMatch(root);
  final matches = windows
      ? path.toLowerCase().startsWith(root.toLowerCase())
      : path.startsWith(root);
  return matches ? path.substring(root.length) : path;
}

/// Coverage of every file in [reports], keyed by repository-relative path.
Map<String, FileCoverage> loadCoverage(
  Directory repoRoot,
  List<CoverageReport> reports,
) {
  final all = <String, FileCoverage>{};
  for (final report in reports) {
    final file = File(
      _isAbsolute(report.lcovPath)
          ? report.lcovPath
          : '${repoRoot.path}/${report.lcovPath}',
    );
    if (!file.existsSync()) {
      throw FileSystemException(
        'lcov report not found (run the tests with coverage first)',
        file.path,
      );
    }
    final parsed = parseLcov(
      file.readAsStringSync(),
      resolvePath: (sf) => resolveSourcePath(
        sf,
        repoRoot: repoRoot.absolute.path,
        packageDir: report.packageDir,
      ),
    );
    for (final f in parsed.values) {
      all.update(f.path, (existing) => existing..merge(f), ifAbsent: () => f);
    }
  }
  return all;
}

bool _isAbsolute(String path) =>
    path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);

/// Repository-relative paths of the Dart sources under `<packageDir>/lib`.
List<String> listSources(Directory repoRoot, String packageDir) {
  final lib = Directory('${repoRoot.path}/$packageDir/lib');
  if (!lib.existsSync()) return const [];
  final prefix = lib.absolute.path.replaceAll(r'\', '/');
  return [
    for (final entity in lib.listSync(recursive: true))
      if (entity is File && entity.path.endsWith('.dart'))
        '$packageDir/lib${entity.absolute.path.replaceAll(r'\', '/').substring(prefix.length)}',
  ]..sort();
}

/// Whether [rule] concerns one of the members in [reports].
bool ruleApplies(CoverageRule rule, List<CoverageReport> reports) =>
    reports.any((r) => rule.include.startsWith('${r.packageDir}/'));

String _status(RuleResult r) => r.skipped
    ? 'SKIP'
    : r.passed
    ? 'PASS'
    : 'FAIL';

String _lineSummary(RuleResult r) =>
    'lines ${formatPercent(r.linePercent)} (${r.linesHit}/${r.linesFound}, '
    'min ${formatPercent(r.rule.minLinePercent)})';

String _branchSummary(RuleResult r) {
  final branch = r.branchPercent;
  if (branch == null) return '';
  final min = r.rule.minBranchPercent;
  return ', branches ${formatPercent(branch)} '
      '(${r.branchesHit}/${r.branchesFound}'
      '${min == null ? '' : ', min ${formatPercent(min)}'})';
}

String _fileLine(FileCoverage f) {
  final uncovered = f.uncoveredLines;
  final value = formatPercent(percent(f.linesHit, f.linesFound)).padLeft(6);
  final detail = uncovered.isEmpty
      ? ''
      : '  (uncovered: ${formatRanges(uncovered)})';
  return '        $value  ${f.path}$detail';
}

/// Human-readable result of [results]. Lists the files below 100% (worst
/// first, at most [maxFiles] per rule), or every file with [verbose].
String formatResults(
  List<RuleResult> results, {
  bool verbose = false,
  int maxFiles = 10,
}) {
  final out = StringBuffer();
  for (final r in results) {
    out.writeln(
      '${_status(r)}  ${r.rule.name} (${r.rule.include})'
      '${r.skipped ? ': no matching file yet' : ''}',
    );
    if (r.skipped) continue;
    out.writeln(
      '      ${_lineSummary(r)}${_branchSummary(r)}, ${r.files.length} files',
    );
    double ratio(FileCoverage f) => percent(f.linesHit, f.linesFound);
    final shown =
        r.files.where((f) => verbose || f.linesHit < f.linesFound).toList()
          ..sort((a, b) => ratio(a).compareTo(ratio(b)));
    for (final f in verbose ? shown : shown.take(maxFiles)) {
      out.writeln(_fileLine(f));
    }
    if (!verbose && shown.length > maxFiles) {
      out.writeln('        ... ${shown.length - maxFiles} more below 100%');
    }
    for (final path in r.missingFiles.where(r.rule.mayBeMissing)) {
      out.writeln(
        '      ! $path: not in the report (allowed: no executable lines)',
      );
    }
    for (final failure in r.failures) {
      out.writeln('      ✗ $failure');
    }
  }
  return out.toString();
}

/// [results] as a Markdown table for `$GITHUB_STEP_SUMMARY`.
String formatMarkdownSummary(List<RuleResult> results) {
  final out = StringBuffer()
    ..writeln('### Coverage (plan §17.2)')
    ..writeln()
    ..writeln('| Gate | Scope | Lines | Branches | Result |')
    ..writeln('|---|---|---|---|---|');
  for (final r in results) {
    final branch = r.branchPercent;
    final lines = r.skipped
        ? '-'
        : '${formatPercent(r.linePercent)} '
              '(min ${formatPercent(r.rule.minLinePercent)})';
    out.writeln(
      '| ${r.rule.name} | `${r.rule.include}` | $lines '
      '| ${branch == null ? '-' : formatPercent(branch)} '
      '| ${_status(r).toLowerCase()} |',
    );
  }
  return out.toString();
}
