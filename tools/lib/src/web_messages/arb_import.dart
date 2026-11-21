import 'dart:convert';

/// The status of one GI UI message against the app's ARB files.
enum ImportStatus {
  /// No ARB key of that name and no ARB text equal to it: `--apply` adds it.
  missing,

  /// The ARB key exists with the same Polish text.
  exists,

  /// The ARB key exists with other text; the app's wording is kept.
  differs,

  /// Not under that key, but an ARB entry already has the same Polish text
  /// ([ImportEntry.existingKey]); reuse it instead of adding a duplicate.
  sameText,

  /// The web file lacks the Polish or the English text; not added.
  incomplete,
}

/// One web message mapped to a suggested ARB entry.
final class ImportEntry {
  const new({
    required this.webKey,
    required this.arbKey,
    required this.status,
    required this.pl,
    required this.en,
    required this.placeholders,
    this.existingKey,
    this.existingPl,
  });

  final String webKey;
  final String arbKey;
  final ImportStatus status;
  final String? pl;
  final String? en;
  final List<String> placeholders;

  /// For [ImportStatus.sameText]: the ARB key with the same text.
  final String? existingKey;

  /// For [ImportStatus.differs]: the app's current Polish text.
  final String? existingPl;

  Map<String, Object?> toJson() => {
    'webKey': webKey,
    'arbKey': arbKey,
    'status': status.name,
    'pl': pl,
    'en': en,
    if (placeholders.isNotEmpty) 'placeholders': placeholders,
    'existingKey': ?existingKey,
    'existingPl': ?existingPl,
  };
}

const _dartReserved = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

/// The ARB key (a Dart identifier) for a web key:
/// `dashboard.deviceDiscoveredTitle` -> `dashboardDeviceDiscoveredTitle`,
/// `settings.mqtt-test.ok` -> `settingsMqttTestOk`.
String arbKeyFor(String webKey) {
  final words = webKey
      .split(RegExp('[^A-Za-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'webMessage';
  final buffer = StringBuffer(
    words.first[0].toLowerCase() + words.first.substring(1),
  );
  for (final word in words.skip(1)) {
    buffer.write(word[0].toUpperCase() + word.substring(1));
  }
  var key = buffer.toString();
  if (RegExp('^[0-9]').hasMatch(key)) key = 'web$key';
  if (_dartReserved.contains(key)) key = '${key}Text';
  return key;
}

/// `{name}` placeholders of an ICU message, in order of appearance.
List<String> placeholdersOf(String text) =>
    {for (final match in RegExp(r'\{(\w+)\}').allMatches(text)) match[1]!}
        .toList();

/// The locale of the web file that matches an ARB language (`pl-PL` for
/// `pl`).
String? webLocaleFor(Iterable<String> webLocales, String language) {
  for (final locale in webLocales) {
    if (locale.toLowerCase().split(RegExp('[-_]')).first == language) {
      return locale;
    }
  }
  return null;
}

/// Maps the web messages onto the ARB files. [pl] and [en] are the web
/// messages of each language; [arbPl] and [arbEn] the decoded ARB files.
/// Only web keys starting with one of [only] are considered (all when
/// empty).
List<ImportEntry> planImport({
  required Map<String, String> pl,
  required Map<String, String> en,
  required Map<String, Object?> arbPl,
  required Map<String, Object?> arbEn,
  List<String> only = const [],
}) {
  final textToKey = <String, String>{};
  for (final MapEntry(:key, :value) in arbPl.entries) {
    if (key.startsWith('@') || value is! String) continue;
    textToKey.putIfAbsent(value, () => key);
  }

  final webKeys = <String>{
    ...pl.keys,
    ...en.keys,
  }.where((key) => only.isEmpty || only.any(key.startsWith));
  final entries = <ImportEntry>[];
  final taken = <String, String>{};
  for (final webKey in webKeys) {
    var arbKey = arbKeyFor(webKey);
    // Two web keys that camel-case alike get distinct ARB keys.
    for (var n = 2; taken.containsKey(arbKey) && taken[arbKey] != webKey; n++) {
      arbKey = '${arbKeyFor(webKey)}$n';
    }
    taken[arbKey] = webKey;

    final plText = pl[webKey];
    final enText = en[webKey];
    final placeholders = placeholdersOf('${plText ?? ''} ${enText ?? ''}');
    final existing = arbPl[arbKey];
    final ImportStatus status;
    String? existingKey;
    String? existingPl;
    if (existing is String) {
      status = existing == plText ? ImportStatus.exists : ImportStatus.differs;
      if (status == ImportStatus.differs) existingPl = existing;
    } else if (plText == null || enText == null) {
      status = ImportStatus.incomplete;
    } else if (textToKey[plText] case final key?) {
      status = ImportStatus.sameText;
      existingKey = key;
    } else {
      status = ImportStatus.missing;
    }
    entries.add(
      ImportEntry(
        webKey: webKey,
        arbKey: arbKey,
        status: status,
        pl: plText,
        en: enText,
        placeholders: placeholders,
        existingKey: existingKey,
        existingPl: existingPl,
      ),
    );
  }
  return entries;
}

/// The ARB files with the [ImportStatus.missing] entries appended: the
/// Polish template gets the text plus `@key` metadata (description with the
/// web key, String placeholders), the English file the text. Existing keys
/// and their order are untouched; a key present in either file is never
/// overwritten.
({Map<String, Object?> pl, Map<String, Object?> en}) applyImport(
  List<ImportEntry> entries, {
  required Map<String, Object?> arbPl,
  required Map<String, Object?> arbEn,
}) {
  final pl = {...arbPl};
  final en = {...arbEn};
  for (final entry in entries) {
    if (entry.status != ImportStatus.missing) continue;
    if (pl.containsKey(entry.arbKey) || en.containsKey(entry.arbKey)) continue;
    pl[entry.arbKey] = entry.pl;
    pl['@${entry.arbKey}'] = {
      'description': 'Imported from GI UI (${entry.webKey}).',
      if (entry.placeholders.isNotEmpty)
        'placeholders': {
          for (final name in entry.placeholders) name: {'type': 'String'},
        },
    };
    en[entry.arbKey] = entry.en;
  }
  return (pl: pl, en: en);
}

/// [text] of an ARB file with the entries of [merged] that it lacks
/// appended before the closing brace, two-space indented. Everything already
/// in [text] stays byte for byte (formatting, order, line endings).
String appendToArb(String text, Map<String, Object?> merged) {
  final existing = jsonDecode(text) as Map<String, Object?>;
  final additions = [
    for (final MapEntry(:key, :value) in merged.entries)
      if (!existing.containsKey(key)) (key, value),
  ];
  if (additions.isEmpty) return text;

  final newline = text.contains('\r\n') ? '\r\n' : '\n';
  final trimmed = text.trimRight();
  if (!trimmed.endsWith('}')) {
    throw const FormatException('An ARB file must be a JSON object');
  }
  final body = trimmed.substring(0, trimmed.length - 1).trimRight();
  const encoder = JsonEncoder.withIndent('  ');
  final out = StringBuffer(body);
  var first = body.endsWith('{');
  for (final (key, value) in additions) {
    final encoded = encoder
        .convert(value)
        .split('\n')
        .join('$newline  '); // Nested lines one level deeper.
    out
      ..write(first ? '' : ',')
      ..write('$newline  ${jsonEncode(key)}: $encoded');
    first = false;
  }
  out.write('$newline}$newline');
  return out.toString();
}

/// Counts per status.
Map<String, int> importCounts(List<ImportEntry> entries) => {
  for (final status in ImportStatus.values)
    status.name: entries.where((e) => e.status == status).length,
};

/// The merge proposal as Markdown: counts, then a table per status that
/// needs a decision (keys to add, wording that differs, duplicates).
String renderImportMarkdown(
  List<ImportEntry> entries, {
  required String source,
  required List<String> skipped,
}) {
  String cell(String? text) =>
      text == null ? '—' : text.replaceAll('|', r'\|').replaceAll('\n', '<br>');
  final counts = importCounts(entries);
  final out = StringBuffer()
    ..writeln('# Import słownictwa GI UI → ARB (propozycja)')
    ..writeln()
    ..writeln(
      'Źródło: `$source` (tylko odczyt). Wygenerowane przez '
      '`tools/import_web_messages.dart`; pliki ARB zmienia dopiero `--apply` '
      '(dodaje wyłącznie wiersze „missing”).',
    )
    ..writeln()
    ..writeln('| Status | Liczba |')
    ..writeln('|---|---|');
  for (final MapEntry(:key, :value) in counts.entries) {
    out.writeln('| $key | $value |');
  }
  if (skipped.isNotEmpty) {
    out
      ..writeln()
      ..writeln('Pominięte przy parsowaniu: ${skipped.length}')
      ..writeln();
    for (final line in skipped) {
      out.writeln('- `$line`');
    }
  }

  void table(
    ImportStatus status,
    String title,
    List<String> header,
    List<String> Function(ImportEntry) row,
  ) {
    final rows = entries.where((e) => e.status == status).toList();
    if (rows.isEmpty) return;
    out
      ..writeln()
      ..writeln('## $title (${rows.length})')
      ..writeln()
      ..writeln('| ${header.join(' | ')} |')
      ..writeln('|${List.filled(header.length, '---').join('|')}|');
    for (final entry in rows) {
      out.writeln('| ${row(entry).join(' | ')} |');
    }
  }

  table(ImportStatus.missing, 'Nowe klucze (`--apply` je doda)', [
    'Klucz ARB',
    'Klucz web',
    'pl',
    'en',
  ], (e) => ['`${e.arbKey}`', '`${e.webKey}`', cell(e.pl), cell(e.en)]);
  table(
    ImportStatus.differs,
    'Klucz istnieje z innym tekstem (zostaje tekst aplikacji)',
    ['Klucz ARB', 'Aplikacja (pl)', 'Web (pl)'],
    (e) => ['`${e.arbKey}`', cell(e.existingPl), cell(e.pl)],
  );
  table(
    ImportStatus.sameText,
    'Ten sam tekst pod innym kluczem (użyj istniejącego)',
    ['Klucz web', 'Istniejący klucz ARB', 'pl'],
    (e) => ['`${e.webKey}`', '`${e.existingKey}`', cell(e.pl)],
  );
  table(ImportStatus.incomplete, 'Brak tłumaczenia w GI UI (nie dodawane)', [
    'Klucz web',
    'pl',
    'en',
  ], (e) => ['`${e.webKey}`', cell(e.pl), cell(e.en)]);
  return out.toString();
}
