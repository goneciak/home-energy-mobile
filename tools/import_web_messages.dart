// One-time vocabulary import (plan §13.1): reads GI UI's messages.ts (read
// only) and proposes ARB entries for the app.
//
//   dart run tools/import_web_messages.dart [--source <messages.ts>]
//       [--only auth.,nav.] [--out tools/out] [--apply]
//
// Without --apply it only writes the proposal: <out>/web_messages_import.json
// (every message with its suggested ARB key and status) and
// <out>/web_messages_import.md (the keys to add, wording that differs,
// duplicates). --apply also appends the "missing" entries to
// app/lib/l10n/app_pl.arb (with @metadata) and app_en.arb; existing keys and
// translations are never changed. Run `flutter gen-l10n` in app/ afterwards.
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gi_tools/web_messages.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'source',
      help:
          'GI UI messages.ts, only read (default: '
          'apps/gi-ui/src/shared/i18n/messages.ts under GI_BACKEND_DIR or '
          '../home-energy-poc).',
    )
    ..addOption(
      'arb-dir',
      help: 'Folder with app_pl.arb and app_en.arb (default: app/lib/l10n).',
    )
    ..addOption(
      'out',
      help: 'Folder for the proposal (default: tools/out, gitignored).',
    )
    ..addMultiOption(
      'only',
      help: 'Only web keys with one of these prefixes, e.g. auth.,nav.',
    )
    ..addFlag(
      'apply',
      negatable: false,
      help: 'Append the missing keys to the ARB files (keeps existing ones).',
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
      'Usage: dart run tools/import_web_messages.dart [options]\n\n'
      '${parser.usage}',
    );
    return;
  }

  final root = findRepoRoot();
  final parent = root.parent.path.replaceAll(RegExp(r'[\\/]+$'), '');
  final backend =
      Platform.environment['GI_BACKEND_DIR'] ?? '$parent/home-energy-poc';
  final source = File(
    options.option('source') ??
        '$backend/apps/gi-ui/src/shared/i18n/messages.ts',
  );
  final arbDir = options.option('arb-dir') ?? '${root.path}/app/lib/l10n';
  final outDir = Directory(options.option('out') ?? '${root.path}/tools/out');
  if (!source.existsSync()) {
    stderr.writeln('Not found: ${source.path} (set --source).');
    exit(2);
  }

  final TsMessages messages;
  try {
    messages = parseTsMessages(source.readAsStringSync());
  } on FormatException catch (e) {
    stderr.writeln('Cannot parse ${source.path}: ${e.message}');
    exit(2);
  }
  final plLocale = webLocaleFor(messages.locales.keys, 'pl');
  final enLocale = webLocaleFor(messages.locales.keys, 'en');
  if (plLocale == null || enLocale == null) {
    stderr.writeln(
      'Expected a pl and an en locale, found ${messages.locales.keys}.',
    );
    exit(2);
  }

  final plFile = File('$arbDir/app_pl.arb');
  final enFile = File('$arbDir/app_en.arb');
  final arbPl = _readArb(plFile);
  final arbEn = _readArb(enFile);
  final entries = planImport(
    pl: messages.locales[plLocale]!,
    en: messages.locales[enLocale]!,
    arbPl: arbPl,
    arbEn: arbEn,
    only: options.multiOption('only'),
  );

  outDir.createSync(recursive: true);
  final jsonFile = File('${outDir.path}/web_messages_import.json')
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
        'source': source.path,
        'locales': {'pl': plLocale, 'en': enLocale},
        'counts': importCounts(entries),
        'skipped': messages.skipped,
        'entries': [for (final e in entries) e.toJson()],
      })}\n',
    );
  final mdFile = File('${outDir.path}/web_messages_import.md')
    ..writeAsStringSync(
      renderImportMarkdown(
        entries,
        source: source.path,
        skipped: messages.skipped,
      ),
    );

  final counts = importCounts(entries);
  print(
    'Read ${entries.length} messages from ${source.path}: '
    '${counts.entries.map((e) => '${e.key} ${e.value}').join(', ')}.',
  );
  print('Proposal: ${jsonFile.path}\n          ${mdFile.path}');

  if (!options.flag('apply')) {
    print('ARB files unchanged (pass --apply to add the missing keys).');
    return;
  }
  final merged = applyImport(entries, arbPl: arbPl, arbEn: arbEn);
  final added = merged.en.length - arbEn.length;
  if (added == 0) {
    print('Nothing to add.');
    return;
  }
  plFile.writeAsStringSync(appendToArb(plFile.readAsStringSync(), merged.pl));
  enFile.writeAsStringSync(appendToArb(enFile.readAsStringSync(), merged.en));
  print(
    'Added $added keys to ${plFile.path} and ${enFile.path}. '
    'Run `flutter gen-l10n` in app/.',
  );
}

Map<String, Object?> _readArb(File file) {
  if (!file.existsSync()) {
    stderr.writeln('Not found: ${file.path} (set --arb-dir).');
    exit(2);
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}
