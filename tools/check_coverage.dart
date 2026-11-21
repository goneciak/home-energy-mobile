// Coverage gate (plan §17.2): reads the lcov reports of the test runs and
// enforces
//   * >= 90% of lines in packages/gi_core_api/lib,
//   * >= 90% of lines in app/lib/**/domain/**,
//   * 100% of lines and branches in TransportPolicy (and, once they exist,
//     SafetyPolicy and ConfirmationPolicy).
// Generated code (*.g.dart, *.freezed.dart) is left out. Branch thresholds
// apply when the reports carry branch data (--branch-coverage); otherwise
// line coverage stands in for them. A source file absent from every report
// (never loaded by a test, or without executable lines; lcov cannot tell
// which) fails its gate, unless the gate lists it in allowMissing (known
// export-only or const-only files), where it is only a warning.
//
//   (cd packages/gi_core_api && dart test -x contract \
//       --coverage-path=coverage/lcov.info --branch-coverage)
//   (cd app && flutter test -x golden --branch-coverage)
//   dart run tools/check_coverage.dart [--report <packageDir>=<lcov>]... [-v]
//
// Without --report it reads packages/gi_core_api/coverage/lcov.info and
// app/coverage/lcov.info; gates of a member without a report are skipped.
// Exit codes: 0 all gates pass, 1 a gate fails, 2 a report is missing,
// 64 usage error.
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/coverage.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addMultiOption(
      'report',
      help:
          'A member folder and its lcov file, both relative to the repo '
          'root, e.g. app=app/coverage/lcov.info. Repeatable.',
    )
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'List every file.')
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults options;
  final List<CoverageReport> reports;
  try {
    options = parser.parse(args);
    final specs = options.multiOption('report');
    reports = specs.isEmpty
        ? defaultCoverageReports
        : [for (final spec in specs) CoverageReport.parse(spec)];
  } on FormatException catch (e) {
    stderr.writeln('${e.message}\n\n${parser.usage}');
    exit(64);
  }
  if (options.flag('help')) {
    print(
      'Usage: dart run tools/check_coverage.dart [options]\n\n'
      '${parser.usage}',
    );
    return;
  }

  final root = findRepoRoot();
  final Map<String, FileCoverage> coverage;
  try {
    coverage = loadCoverage(root, reports);
  } on FileSystemException catch (e) {
    stderr.writeln('${e.message}: ${e.path}');
    exit(2);
  }

  final sources = [
    for (final report in reports) ...listSources(root, report.packageDir),
  ];
  final results = [
    for (final rule in defaultCoverageRules)
      if (ruleApplies(rule, reports))
        evaluateRule(rule, coverage, sourceFiles: sources),
  ];

  stdout.write(formatResults(results, verbose: options.flag('verbose')));

  final summary = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (summary != null && summary.isNotEmpty) {
    File(
      summary,
    ).writeAsStringSync(formatMarkdownSummary(results), mode: FileMode.append);
  }

  final failed = results.where((r) => !r.passed).length;
  if (failed > 0) {
    stderr.writeln('$failed coverage gate(s) failed (plan §17.2).');
    exitCode = 1;
  } else {
    print('All coverage gates pass.');
  }
}
