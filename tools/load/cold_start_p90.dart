// p90 of cold start runs (milliseconds), against the 5 s budget.
//
//   dart run tools/load/cold_start_p90.dart runs.txt [--limit-ms 5000]
//
// `runs.txt` holds one figure per line (or `COLD_START_MS=<n>` log lines,
// as the benchmark in app/integration_test/perf prints them). Exit code 0
// when there are at least 20 runs and the p90 is within the limit.
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/src/load/cold_start.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'limit-ms',
      defaultsTo: '${coldStartLimit.inMilliseconds}',
      help: 'p90 budget in milliseconds.',
    )
    ..addOption(
      'min-runs',
      defaultsTo: '$coldStartMinRuns',
      help: 'Runs needed for the figure to count.',
    );
  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exit(64);
  }
  if (args.rest.length != 1) {
    stderr
      ..writeln('Usage: dart run tools/load/cold_start_p90.dart <runs.txt>')
      ..writeln(parser.usage);
    exit(64);
  }
  final file = File(args.rest.single);
  if (!file.existsSync()) {
    stderr.writeln('No such file: ${file.path}');
    exit(66);
  }
  final runs = parseColdStartRuns(file.readAsStringSync());
  if (runs.isEmpty) {
    stderr.writeln('No figures found in ${file.path}.');
    exit(65);
  }
  final limit = Duration(milliseconds: int.parse(args.option('limit-ms')!));
  final minRuns = int.parse(args.option('min-runs')!);
  final summary = ColdStartSummary.of(runs);
  stdout.writeln(summary.toMarkdown(limit: limit, minRuns: minRuns));
  exit(summary.passes(limit: limit, minRuns: minRuns) ? 0 : 1);
}
