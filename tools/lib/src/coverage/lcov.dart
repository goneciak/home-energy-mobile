/// Line and branch hits of one source file in an lcov report.
final class FileCoverage {
  new(this.path);

  /// Repository-relative path with forward slashes, e.g.
  /// `packages/gi_core_api/lib/src/http/transport_policy.dart`.
  final String path;

  /// Hit count per executable line (`DA:<line>,<hits>`).
  final Map<int, int> lines = {};

  /// Taken count per branch (`BRDA:<line>,<block>,<branch>,<taken>`), keyed
  /// `<line>,<block>,<branch>`; `-` (never evaluated) counts as 0.
  final Map<String, int> branches = {};

  int get linesFound => lines.length;
  int get linesHit => lines.values.where((hits) => hits > 0).length;
  int get branchesFound => branches.length;
  int get branchesHit => branches.values.where((taken) => taken > 0).length;

  /// Lines that no test executed, ascending.
  List<int> get uncoveredLines => [
    for (final MapEntry(:key, :value) in lines.entries)
      if (value == 0) key,
  ]..sort();

  /// Adds [other]'s hits to this file's (the same file reported twice).
  void merge(FileCoverage other) {
    other.lines.forEach((line, hits) {
      lines[line] = (lines[line] ?? 0) + hits;
    });
    other.branches.forEach((key, taken) {
      branches[key] = (branches[key] ?? 0) + taken;
    });
  }
}

/// Parses an lcov tracefile ([text]) into coverage per file.
///
/// [resolvePath] maps each `SF:` path (absolute, or relative to the package
/// the report belongs to) to the repository-relative path used as the key.
/// Records of the same file are merged.
Map<String, FileCoverage> parseLcov(
  String text, {
  required String Function(String sourceFile) resolvePath,
}) {
  final files = <String, FileCoverage>{};
  FileCoverage? current;
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      current = FileCoverage(resolvePath(line.substring(3)));
    } else if (line == 'end_of_record') {
      if (current != null) {
        files.update(
          current.path,
          (existing) => existing..merge(current!),
          ifAbsent: () => current!,
        );
      }
      current = null;
    } else if (current != null && line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length < 2) continue;
      final number = int.tryParse(parts[0]);
      final hits = int.tryParse(parts[1]);
      if (number == null || hits == null) continue;
      current.lines[number] = (current.lines[number] ?? 0) + hits;
    } else if (current != null && line.startsWith('BRDA:')) {
      final parts = line.substring(5).split(',');
      if (parts.length < 4) continue;
      final key = parts.take(3).join(',');
      final taken = int.tryParse(parts[3]) ?? 0;
      current.branches[key] = (current.branches[key] ?? 0) + taken;
    }
  }
  return files;
}

/// Whether [path] is generated code that the gates leave out.
bool isGeneratedDart(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

/// [glob] (`*` within a path segment, `**` across segments, `{a,b}`
/// alternatives, `?` one character) as an anchored [RegExp] over
/// forward-slash paths.
RegExp globToRegExp(String glob) {
  final out = StringBuffer('^');
  var inGroup = false;
  for (var i = 0; i < glob.length; i++) {
    final c = glob[i];
    switch (c) {
      case '*':
        if (i + 1 < glob.length && glob[i + 1] == '*') {
          i++;
          // `**/` also matches no folder at all.
          if (i + 1 < glob.length && glob[i + 1] == '/') {
            i++;
            out.write('(?:.*/)?');
          } else {
            out.write('.*');
          }
        } else {
          out.write('[^/]*');
        }
      case '?':
        out.write('[^/]');
      case '{':
        inGroup = true;
        out.write('(?:');
      case '}' when inGroup:
        inGroup = false;
        out.write(')');
      case ',' when inGroup:
        out.write('|');
      default:
        out.write(RegExp.escape(c));
    }
  }
  out.write(r'$');
  return RegExp(out.toString());
}

/// One coverage requirement: the files matching [include] (generated code
/// excluded) must reach [minLinePercent] of their lines together, and
/// [minBranchPercent] of their branches when the report has branch data.
final class CoverageRule {
  const new({
    required this.name,
    required this.include,
    required this.minLinePercent,
    this.minBranchPercent,
    this.perFile = false,
    this.requireMatch = true,
    this.allowMissing = const [],
  });

  final String name;
  final String include;
  final double minLinePercent;

  /// Branch threshold; applies only to files with `BRDA` records.
  final double? minBranchPercent;

  /// Enforce the thresholds on every file instead of the total.
  final bool perFile;

  /// Fail when no file matches (otherwise the rule is skipped, for files
  /// the plan names that do not exist yet).
  final bool requireMatch;

  /// Globs of files of the rule known to have no executable lines
  /// (export-only libraries, const tables), so lcov never lists them. Any
  /// other file of the rule missing from the reports fails the rule: no
  /// test loads it, and it would otherwise drop out of the percentage
  /// unnoticed. Ignored for [perFile] rules, where every file must be
  /// measured.
  final List<String> allowMissing;

  bool matches(String path) =>
      !isGeneratedDart(path) && globToRegExp(include).hasMatch(path);

  /// Whether [path] may be absent from the reports (see [allowMissing]).
  bool mayBeMissing(String path) =>
      !perFile && allowMissing.any((glob) => globToRegExp(glob).hasMatch(path));
}

/// What one [CoverageRule] measured.
final class RuleResult {
  const new({
    required this.rule,
    required this.files,
    required this.missingFiles,
    required this.failures,
  });

  final CoverageRule rule;

  /// Files of the rule found in the reports, sorted by path.
  final List<FileCoverage> files;

  /// Source files of the rule that no report mentions: either no test
  /// loads them, or they have no executable lines (export-only libraries,
  /// const tables). lcov cannot tell these apart, so only the files in
  /// [CoverageRule.allowMissing] are mere warnings; every other one is a
  /// failure.
  final List<String> missingFiles;

  /// Why the rule failed; empty when it passed or was skipped.
  final List<String> failures;

  bool get skipped => files.isEmpty && missingFiles.isEmpty;
  bool get passed => failures.isEmpty;

  int get linesFound => files.fold(0, (sum, f) => sum + f.linesFound);
  int get linesHit => files.fold(0, (sum, f) => sum + f.linesHit);
  int get branchesFound => files.fold(0, (sum, f) => sum + f.branchesFound);
  int get branchesHit => files.fold(0, (sum, f) => sum + f.branchesHit);

  double get linePercent => percent(linesHit, linesFound);
  double? get branchPercent =>
      branchesFound == 0 ? null : percent(branchesHit, branchesFound);
}

/// [hit] of [found] in percent; 100 when there is nothing to cover.
double percent(int hit, int found) => found == 0 ? 100 : 100 * hit / found;

/// Evaluates [rule] against [coverage]; [sourceFiles] are the
/// repository-relative source paths on disk, to find files no test loaded.
RuleResult evaluateRule(
  CoverageRule rule,
  Map<String, FileCoverage> coverage, {
  Iterable<String> sourceFiles = const [],
}) {
  final files = coverage.values.where((f) => rule.matches(f.path)).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final missing =
      sourceFiles
          .where((p) => rule.matches(p) && !coverage.containsKey(p))
          .toSet()
          .toList()
        ..sort();
  final failures = <String>[
    for (final path in missing)
      if (!rule.mayBeMissing(path))
        '$path: not in the report (no test loads it)',
  ];

  if (files.isEmpty && missing.isEmpty) {
    if (rule.requireMatch) {
      failures.add('no file matches ${rule.include}');
    }
    return RuleResult(
      rule: rule,
      files: files,
      missingFiles: missing,
      failures: failures,
    );
  }
  void check(String label, int hit, int found, double? min, String what) {
    if (min == null || found == 0) return;
    final value = percent(hit, found);
    if (value + 1e-9 < min) {
      failures.add(
        '$label: $what ${formatPercent(value)} ($hit/$found) '
        '< ${formatPercent(min)}',
      );
    }
  }

  if (rule.perFile) {
    for (final f in files) {
      check(f.path, f.linesHit, f.linesFound, rule.minLinePercent, 'lines');
      check(
        f.path,
        f.branchesHit,
        f.branchesFound,
        rule.minBranchPercent,
        'branches',
      );
    }
  } else {
    final found = files.fold(0, (sum, f) => sum + f.linesFound);
    final hit = files.fold(0, (sum, f) => sum + f.linesHit);
    check(rule.name, hit, found, rule.minLinePercent, 'lines');
    final bFound = files.fold(0, (sum, f) => sum + f.branchesFound);
    final bHit = files.fold(0, (sum, f) => sum + f.branchesHit);
    check(rule.name, bHit, bFound, rule.minBranchPercent, 'branches');
  }
  return RuleResult(
    rule: rule,
    files: files,
    missingFiles: missing,
    failures: failures,
  );
}

/// [value] with one decimal, rounded down so that 89.99 never reads as a
/// passing 90.0, e.g. `92.3%`.
String formatPercent(double value) =>
    '${((value * 10 + 1e-9).floor() / 10).toStringAsFixed(1)}%';

/// [lines] as compact ranges, e.g. `3-5, 9`.
String formatRanges(List<int> lines) {
  final parts = <String>[];
  var i = 0;
  while (i < lines.length) {
    var j = i;
    while (j + 1 < lines.length && lines[j + 1] == lines[j] + 1) {
      j++;
    }
    parts.add(i == j ? '${lines[i]}' : '${lines[i]}-${lines[j]}');
    i = j + 1;
  }
  return parts.join(', ');
}
