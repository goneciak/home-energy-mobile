@Timeout(Duration(minutes: 2))
library;

import 'dart:io';

import 'package:gi_tools/coverage.dart';
import 'package:test/test.dart';

String _record(
  String sf,
  Map<int, int> lines, {
  Map<String, String> branches = const {},
}) {
  final out = StringBuffer('SF:$sf\n');
  lines.forEach((line, hits) => out.writeln('DA:$line,$hits'));
  branches.forEach((key, taken) => out.writeln('BRDA:$key,$taken'));
  out.writeln('end_of_record');
  return out.toString();
}

Map<String, FileCoverage> _parse(String text, {String packageDir = 'app'}) =>
    parseLcov(
      text,
      resolvePath: (sf) =>
          resolveSourcePath(sf, repoRoot: '/repo', packageDir: packageDir),
    );

void main() {
  group('parseLcov', () {
    test('reads lines and branches and merges repeated files', () {
      final coverage = _parse(
        _record(
              'lib/a.dart',
              {1: 1, 2: 0, 3: 0},
              branches: {'1,0,0': '1', '1,0,1': '-'},
            ) +
            _record('lib/a.dart', {2: 3}, branches: {'1,0,1': '2'}),
      );

      final a = coverage['app/lib/a.dart']!;
      expect(a.linesFound, 3);
      expect(a.linesHit, 2);
      expect(a.uncoveredLines, [3]);
      expect(a.branchesFound, 2);
      expect(a.branchesHit, 2);
    });

    test('ignores malformed records', () {
      final coverage = _parse(
        'DA:1,1\nSF:lib/b.dart\nDA:x,1\nDA:2\nBRDA:1\n'
        'DA:4,0\nend_of_record\n',
      );

      expect(coverage['app/lib/b.dart']!.lines, {4: 0});
    });
  });

  group('resolveSourcePath', () {
    test('makes absolute paths repo-relative (any slash, drive case)', () {
      expect(
        resolveSourcePath(
          r'c:\Repo\packages\gi_core_api\lib\x.dart',
          repoRoot: r'C:\Repo',
          packageDir: 'packages/gi_core_api',
        ),
        'packages/gi_core_api/lib/x.dart',
      );
      expect(
        resolveSourcePath(
          '/home/runner/work/m/m/packages/gi_core_api/lib/x.dart',
          repoRoot: '/home/runner/work/m/m',
          packageDir: 'packages/gi_core_api',
        ),
        'packages/gi_core_api/lib/x.dart',
      );
    });

    test('prefixes relative paths with the member folder', () {
      expect(
        resolveSourcePath(
          r'lib\src\a.dart',
          repoRoot: '/repo',
          packageDir: 'app',
        ),
        'app/lib/src/a.dart',
      );
    });
  });

  group('globToRegExp', () {
    test('** spans folders, * stays in one, {a,b} alternates', () {
      final domain = globToRegExp('app/lib/**/domain/**');
      expect(domain.hasMatch('app/lib/src/features/x/domain/y.dart'), isTrue);
      expect(domain.hasMatch('app/lib/src/features/x/data/y.dart'), isFalse);

      final policy = globToRegExp(
        'app/lib/**/{safety,confirmation}_policy.dart',
      );
      expect(policy.hasMatch('app/lib/a/b/safety_policy.dart'), isTrue);
      expect(policy.hasMatch('app/lib/confirmation_policy.dart'), isTrue);
      expect(policy.hasMatch('app/lib/a/freshness_policy.dart'), isFalse);

      expect(globToRegExp('lib/*.dart').hasMatch('lib/a/b.dart'), isFalse);
      expect(globToRegExp('lib/?.dart').hasMatch('lib/a.dart'), isTrue);
    });
  });

  group('evaluateRule', () {
    const rule = CoverageRule(
      name: 'domain',
      include: 'app/lib/**/domain/**',
      minLinePercent: 90,
    );

    test('passes at the threshold and leaves out generated code', () {
      final coverage = _parse(
        _record('lib/f/domain/a.dart', {
              for (var i = 1; i <= 10; i++) i: i == 10 ? 0 : 1,
            }) +
            _record('lib/f/domain/a.g.dart', {1: 0, 2: 0}) +
            _record('lib/f/domain/a.freezed.dart', {1: 0}) +
            _record('lib/f/data/b.dart', {1: 0}),
      );

      final result = evaluateRule(rule, coverage);

      expect(result.passed, isTrue, reason: '${result.failures}');
      expect(result.linePercent, 90);
      expect(result.files.map((f) => f.path), ['app/lib/f/domain/a.dart']);
    });

    test('fails below the threshold and says by how much', () {
      final coverage = _parse(_record('lib/f/domain/a.dart', {1: 1, 2: 0}));

      final result = evaluateRule(rule, coverage);

      expect(result.passed, isFalse);
      expect(result.failures.single, 'domain: lines 50.0% (1/2) < 90.0%');
    });

    test('per-file rules check lines and branches of each file', () {
      const strict = CoverageRule(
        name: 'policy',
        include: 'app/lib/**/*_policy.dart',
        minLinePercent: 100,
        minBranchPercent: 100,
        perFile: true,
      );
      final coverage = _parse(
        _record('lib/a_policy.dart', {1: 1}) +
            _record(
              'lib/b_policy.dart',
              {1: 1},
              branches: {'1,0,0': '1', '1,0,1': '-'},
            ),
      );

      final result = evaluateRule(strict, coverage);

      expect(result.failures, [
        'app/lib/b_policy.dart: branches 50.0% (1/2) < 100.0%',
      ]);
    });

    test('a required rule without files fails; an optional one skips', () {
      expect(evaluateRule(rule, const {}).failures, [
        'no file matches app/lib/**/domain/**',
      ]);

      const optional = CoverageRule(
        name: 'later',
        include: 'app/lib/**/safety_policy.dart',
        minLinePercent: 100,
        requireMatch: false,
      );
      final result = evaluateRule(optional, const {});
      expect(result.skipped, isTrue);
      expect(result.passed, isTrue);
    });

    test('a source missing from the report fails the rule', () {
      final coverage = _parse(_record('lib/f/domain/a.dart', {1: 1}));

      final result = evaluateRule(
        rule,
        coverage,
        sourceFiles: ['app/lib/f/domain/a.dart', 'app/lib/f/domain/b.dart'],
      );

      expect(result.missingFiles, ['app/lib/f/domain/b.dart']);
      expect(result.failures, [
        'app/lib/f/domain/b.dart: not in the report (no test loads it)',
      ]);
    });

    test('a missing source on the allow-list is only a warning', () {
      const lenient = CoverageRule(
        name: 'domain',
        include: 'app/lib/**/domain/**',
        minLinePercent: 90,
        allowMissing: ['app/lib/**/domain/exports.dart'],
      );
      final coverage = _parse(_record('lib/f/domain/a.dart', {1: 1}));

      final result = evaluateRule(
        lenient,
        coverage,
        sourceFiles: [
          'app/lib/f/domain/a.dart',
          'app/lib/f/domain/exports.dart',
        ],
      );

      expect(result.missingFiles, ['app/lib/f/domain/exports.dart']);
      expect(result.passed, isTrue);
      expect(
        formatResults([result]),
        contains('app/lib/f/domain/exports.dart: not in the report (allowed'),
      );
    });

    test('a per-file rule fails on a file no test loads, even when it is '
        'the only match', () {
      const strict = CoverageRule(
        name: 'Safety/ConfirmationPolicy',
        include: 'app/lib/**/{safety,confirmation}_policy.dart',
        minLinePercent: 100,
        minBranchPercent: 100,
        perFile: true,
        requireMatch: false,
        // Ignored for per-file rules.
        allowMissing: ['app/lib/**'],
      );

      const policy = 'app/lib/src/features/control/domain/safety_policy.dart';

      final result = evaluateRule(strict, const {}, sourceFiles: [policy]);

      expect(result.skipped, isFalse);
      expect(result.passed, isFalse);
      expect(result.failures, [
        '$policy: not in the report (no test loads it)',
      ]);
      expect(formatResults([result]), startsWith('FAIL'));
    });
  });

  test('formatPercent rounds down; formatRanges compacts runs', () {
    expect(formatPercent(89.99), '89.9%');
    expect(formatPercent(90), '90.0%');
    expect(formatRanges([1, 2, 3, 7, 9, 10]), '1-3, 7, 9-10');
  });

  test('the default gates match plan §17.2', () {
    final byName = {for (final r in defaultCoverageRules) r.name: r};
    expect(byName['gi_core_api']!.minLinePercent, 90);
    expect(byName['app domain']!.minLinePercent, 90);
    expect(byName['TransportPolicy']!.minLinePercent, 100);
    expect(byName['TransportPolicy']!.minBranchPercent, 100);
  });

  group('tools/check_coverage.dart', () {
    final root = findRepoRoot(from: Directory.current);
    late Directory temp;

    setUp(() => temp = Directory.systemTemp.createTempSync('check_coverage'));
    tearDown(() => temp.deleteSync(recursive: true));

    Future<ProcessResult> run(List<String> args) => Process.run(
      Platform.resolvedExecutable,
      ['run', '${root.path}/tools/check_coverage.dart', ...args],
      workingDirectory: root.path,
    );

    String lcov(String name, String text) {
      final file = File('${temp.path}/$name')..writeAsStringSync(text);
      return file.path;
    }

    const transport = 'lib/src/http/transport_policy.dart';

    test('exits 0 when every gate passes', () async {
      // Every source of the member is in the report: a missing one fails.
      const member = 'packages/gi_core_api/';
      final others = [
        for (final source in listSources(root, 'packages/gi_core_api'))
          source.substring(member.length),
      ].where((source) => source != transport);
      final path = lcov(
        'ok.info',
        _record(transport, {1: 1, 2: 4}) +
            [
              for (final source in others) _record(source, {1: 1}),
            ].join(),
      );

      final result = await run(['--report', 'packages/gi_core_api=$path']);

      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
      expect(result.stdout, contains('PASS  TransportPolicy'));
      // Only gi_core_api was given: the app gates do not run.
      expect(result.stdout, isNot(contains('app domain')));
    });

    test('exits 1 and names the shortfall when a gate fails', () async {
      final path = lcov('bad.info', _record(transport, {1: 1, 2: 0}));

      final result = await run(['--report', 'packages/gi_core_api=$path']);

      expect(result.exitCode, 1, reason: '${result.stdout}${result.stderr}');
      expect(result.stdout, contains('lines 50.0% (1/2)'));
      expect(result.stderr, contains('coverage gate(s) failed'));
    });

    test('exits 2 without the report and 64 on a bad option', () async {
      final missing = await run(['--report', 'app=${temp.path}/nothing.info']);
      expect(missing.exitCode, 2);
      expect(missing.stderr, contains('lcov report not found'));

      final usage = await run(['--report', 'no-equals-sign']);
      expect(usage.exitCode, 64);
    });
  });
}
