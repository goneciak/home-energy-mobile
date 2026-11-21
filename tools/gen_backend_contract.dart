// Generates docs/backend-contract.md from GiEndpoints.all (plan §6.2): id,
// method, path, auth, milestone and feature, fixture cases, decode tests and
// live contract test coverage.
//
//   dart run tools/gen_backend_contract.dart            # rewrite the file
//   dart run tools/gen_backend_contract.dart --check    # exit 1 when stale
//
// tools/test/backend_contract_test.dart runs the same check in CI.
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/backend_contract.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Target file (default: docs/backend-contract.md in the repo).',
    )
    ..addFlag(
      'check',
      negatable: false,
      help: 'Do not write; exit 1 when the file differs from the catalog.',
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults options;
  try {
    options = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('${e.message}\n\n${parser.usage}');
    exit(64);
  }
  if (options.flag('help')) {
    print(
      'Usage: dart run tools/gen_backend_contract.dart [options]\n\n'
      '${parser.usage}',
    );
    return;
  }

  final root = findRepoRoot();
  final target = File(
    options.option('output') ?? '${root.path}/docs/backend-contract.md',
  );
  final text = renderBackendContract(ContractSources.read(root));

  if (options.flag('check')) {
    final current = target.existsSync()
        ? normalizeNewlines(target.readAsStringSync())
        : null;
    if (current == text) {
      print('${target.path} is up to date.');
      return;
    }
    stderr.writeln(
      '${target.path} is stale; run dart run tools/gen_backend_contract.dart',
    );
    exitCode = 1;
    return;
  }

  target
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(text);
  print('Wrote ${target.path}.');
}
