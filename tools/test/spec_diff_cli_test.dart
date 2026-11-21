@Timeout(Duration(minutes: 2))
library;

import 'dart:convert';
import 'dart:io';

import 'package:gi_tools/spec_diff.dart';
import 'package:test/test.dart';

/// `tools/spec_diff.dart` end to end, on spec files (no network).
void main() {
  final root = findRepoRoot(from: Directory.current);
  final snapshot =
      '${root.path}/contract/openapi/core-'
      '${readBackendRef(root)}.json';
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('spec_diff_cli'));
  tearDown(() => temp.deleteSync(recursive: true));

  Future<ProcessResult> specDiff(List<String> args) => Process.run(
    Platform.resolvedExecutable,
    ['run', '${root.path}/tools/spec_diff.dart', ...args],
    workingDirectory: root.path,
  );

  test('the snapshot against itself exits 0', () async {
    final result = await specDiff([
      '--spec-file',
      snapshot,
      '--snapshot',
      snapshot,
    ]);

    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    expect(result.stdout, contains('OK: no breaking change'));
  });

  test('a removed catalog endpoint exits 1 (and --json reports it)', () async {
    final spec =
        jsonDecode(File(snapshot).readAsStringSync()) as Map<String, dynamic>;
    (spec['paths'] as Map<String, dynamic>).remove('/api/v1/auth/login');
    final live = File('${temp.path}/live.json')
      ..writeAsStringSync(jsonEncode(spec));

    final result = await specDiff([
      '--spec-file',
      live.path,
      '--snapshot',
      snapshot,
      '--json',
    ]);

    expect(result.exitCode, 1, reason: '${result.stdout}${result.stderr}');
    final report = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(report['errors'], 1);
    expect(
      (report['findings'] as List).cast<Map<String, dynamic>>().single,
      containsPair('kind', 'endpoint-removed'),
    );
  });

  test('a usage error exits 64', () async {
    final result = await specDiff([]);

    expect(result.exitCode, 64);
  });
}
