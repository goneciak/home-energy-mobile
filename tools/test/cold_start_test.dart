import 'dart:io';

import 'package:gi_tools/src/load/cold_start.dart';
import 'package:test/test.dart';

void main() {
  group('parsing', () {
    test('reads figures one per line, comma separated and in log lines', () {
      const text = '''
# Pi in the LAN, release build
3200
3400, 3100;3300
I/flutter: COLD_START_MS=4100 and COLD_START_MS=2900
not a number
-5
''';
      expect(parseColdStartRuns(text), [3200, 3400, 3100, 3300, 4100, 2900]);
    });

    test('an empty file has no runs', () {
      expect(parseColdStartRuns('\n# nothing\n'), isEmpty);
    });
  });

  group('summary', () {
    test('p90 is the nearest rank of the sorted runs', () {
      final summary = ColdStartSummary.of([
        for (var i = 1; i <= 20; i++) i * 100,
      ]);
      expect(summary.runs, 20);
      expect(summary.min, 100);
      expect(summary.median, 1000);
      expect(summary.p90, 1800);
      expect(summary.max, 2000);
      expect(summary.mean, 1050);
    });

    test('the order of the runs does not matter', () {
      expect(ColdStartSummary.of([5000, 1000, 3000, 2000, 4000]).p90, 5000);
      expect(ColdStartSummary.of([7]).p90, 7);
    });

    test('passes with 20 runs and a p90 within 5 s', () {
      final fast = ColdStartSummary.of([for (var i = 0; i < 20; i++) 4000]);
      expect(fast.passes(), isTrue);
      expect(fast.toMarkdown(), contains('PASS'));
    });

    test('fails above 5 s, and with too few runs', () {
      final slow = ColdStartSummary.of([
        ...List.filled(17, 3000),
        ...List.filled(3, 6000),
      ]);
      expect(slow.p90, 6000);
      expect(slow.passes(), isFalse);
      expect(slow.toMarkdown(), contains('FAIL'));

      final few = ColdStartSummary.of([1000, 1200]);
      expect(few.passes(), isFalse);
      expect(few.toMarkdown(), contains('NOT ENOUGH RUNS (2 of 20)'));
    });

    test('exactly 5000 ms is within the budget', () {
      expect(
        ColdStartSummary.of([for (var i = 0; i < 20; i++) 5000]).passes(),
        isTrue,
      );
    });

    test('no runs is an error', () {
      expect(() => ColdStartSummary.of([]), throwsArgumentError);
    });
  });

  test('the script prints the table and sets the exit code', () async {
    final dir = Directory.systemTemp.createTempSync('cold_start');
    addTearDown(() => dir.deleteSync(recursive: true));
    final good = File('${dir.path}/good.txt')
      ..writeAsStringSync(List.filled(20, 3000).join('\n'));
    final bad = File('${dir.path}/bad.txt')
      ..writeAsStringSync(List.filled(20, 9000).join('\n'));

    final ok = await Process.run(Platform.resolvedExecutable, [
      'run',
      'load/cold_start_p90.dart',
      good.path,
    ]);
    final fail = await Process.run(Platform.resolvedExecutable, [
      'run',
      'load/cold_start_p90.dart',
      bad.path,
    ]);

    expect(ok.exitCode, 0, reason: '${ok.stdout}${ok.stderr}');
    expect(ok.stdout, contains('PASS'));
    expect(fail.exitCode, 1);
    expect(fail.stdout, contains('FAIL'));
  });
}
