// Spec drift check (plan §6.2, §17.5). Compares GI Core's live OpenAPI spec
// (/docs-json) with the committed snapshot contract/openapi/core-<ref>.json,
// filtered to the operations of the client catalog (GiEndpoints.all).
//
//   dart run tools/spec_diff.dart --base-url http://127.0.0.1:<port>
//       [--snapshot contract/openapi/core-<ref>.json] [--json]
//   dart run tools/spec_diff.dart --spec-file live.json [--snapshot ...]
//   dart run tools/spec_diff.dart --base-url <url> --write-snapshot <file>
//
// Exit codes: 0 no breaking change (warnings allowed), 1 breaking changes,
// 2 the spec could not be read, 64 usage error. The backend is only read.
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_tools/spec_diff.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'base-url',
      help:
          'GI Core to read /docs-json from, e.g. the GI_CORE_URL printed by '
          'tools/dev-up.ps1 -Contract.',
    )
    ..addOption('spec-file', help: 'Read the live spec from a file instead.')
    ..addOption(
      'snapshot',
      help:
          'Committed snapshot (default: contract/openapi/core-<shortSha of '
          'contract/backend.lock>.json).',
    )
    ..addOption(
      'write-snapshot',
      help:
          'Write the live spec, canonicalized (sorted keys, 2-space indent), '
          'to this file and exit.',
    )
    ..addOption(
      'fixtures',
      help:
          'Recorded fixtures used to learn which response fields the client '
          'requires (default: packages/gi_core_api/test/fixtures/core/<ref>).',
    )
    ..addFlag('json', negatable: false, help: 'Print the report as JSON.')
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults options;
  try {
    options = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('${e.message}\n\n${parser.usage}');
    exit(64);
  }
  if (options.flag('help')) {
    print('Usage: dart run tools/spec_diff.dart [options]\n\n${parser.usage}');
    return;
  }
  final baseUrl = options.option('base-url');
  final specFile = options.option('spec-file');
  if ((baseUrl == null) == (specFile == null)) {
    stderr
      ..writeln('Give exactly one of --base-url or --spec-file.\n')
      ..writeln(parser.usage);
    exit(64);
  }

  final root = findRepoRoot();
  final ref = readBackendRef(root);

  final Map<String, Object?> live;
  final String liveSource;
  try {
    if (baseUrl != null) {
      final uri = docsJsonUri(baseUrl);
      liveSource = uri.toString();
      live = await fetchSpec(uri);
    } else {
      liveSource = specFile!;
      live = readSpecFile(File(specFile));
    }
  } on Object catch (e) {
    stderr.writeln('Could not read the live spec: $e');
    exit(2);
  }

  final writeTo = options.option('write-snapshot');
  if (writeTo != null) {
    File(writeTo)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(canonicalJson(live));
    print('Wrote $writeTo from $liveSource.');
    return;
  }

  final snapshotPath =
      options.option('snapshot') ??
      '${root.path}/contract/openapi/core-$ref.json';
  final Map<String, Object?> snapshot;
  try {
    snapshot = readSpecFile(File(snapshotPath));
  } on Object catch (e) {
    stderr.writeln('Could not read the snapshot $snapshotPath: $e');
    exit(2);
  }

  final fixtures = Directory(
    options.option('fixtures') ?? '${fixturesRoot(root).path}/$ref',
  );
  final report = diffSpecs(
    snapshot: snapshot,
    live: live,
    endpoints: GiEndpoints.all,
    clientShapes: clientShapesFromFixtures(fixtures),
  );

  if (options.flag('json')) {
    print(
      const JsonEncoder.withIndent('  ')
          .convert(report.toJson(live: liveSource, snapshot: snapshotPath)),
    );
  } else {
    stdout.write(report.format(live: liveSource, snapshot: snapshotPath));
  }
  exitCode = report.exitCode;
}
