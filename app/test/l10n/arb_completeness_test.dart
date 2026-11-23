import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CI check that pl and en are complete (plan §13.1, §19.1). `gen-l10n`
/// only warns about a key missing from `app_en.arb` and falls back to the
/// Polish text, so the build alone would not catch it.
void main() {
  Map<String, Object?> arb(String locale) =>
      jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, Object?>;

  Map<String, Object?> messages(Map<String, Object?> file) => {
    for (final MapEntry(:key, :value) in file.entries)
      if (!key.startsWith('@')) key: value,
  };

  final template = arb('pl');
  final pl = messages(template);
  final en = messages(arb('en'));

  /// Placeholders declared for [key] in the template.
  Set<String> placeholders(String key) => switch (template['@$key']) {
    {'placeholders': final Map<String, Object?> declared} =>
      declared.keys.toSet(),
    _ => const {},
  };

  test('app_en.arb has every key of app_pl.arb and nothing else', () {
    expect(
      pl.keys.toSet().difference(en.keys.toSet()),
      isEmpty,
      reason: 'missing in app_en.arb',
    );
    expect(
      en.keys.toSet().difference(pl.keys.toSet()),
      isEmpty,
      reason: 'not in the template app_pl.arb',
    );
  });

  test('every message is a non-empty text using its placeholders', () {
    final text = isA<String>().having((s) => s.trim(), 'text', isNotEmpty);
    for (final key in pl.keys) {
      expect(pl[key], text, reason: key);
      expect(en[key], text, reason: key);
      for (final name in placeholders(key)) {
        for (final (locale, message) in [('pl', pl[key]), ('en', en[key])]) {
          expect(
            '$message',
            anyOf(contains('{$name}'), contains('{$name,')),
            reason: '$key ($locale) does not use {$name}',
          );
        }
      }
    }
  });

  test('pl and en use the same placeholders and the same ICU structure', () {
    // Placeholder names are the identifiers right after "{": the names of
    // the arguments, plural and select included ("{count, plural, ...}").
    // Names inside plural branches are arguments as well.
    Set<String> arguments(Object? message) => {
      for (final match in RegExp(r'\{\s*(\w+)\s*[,}]').allMatches('$message'))
        match.group(1)!,
    };

    String structure(Object? message) => [
      for (final match in RegExp(
        r'\{\s*\w+\s*,\s*(plural|select|selectordinal)',
      ).allMatches('$message'))
        match.group(1),
    ].join(',');

    for (final key in pl.keys) {
      final declared = placeholders(key);
      expect(
        structure(en[key]),
        structure(pl[key]),
        reason: '$key: plural/select used differently in pl and en',
      );
      for (final name in arguments(en[key])) {
        expect(
          declared.contains(name) || _isIcuBranch(name),
          isTrue,
          reason:
              '$key (en) uses {$name}, which the template does not '
              'declare',
        );
      }
    }
  });

  test('plural messages cover the "other" case in both languages', () {
    for (final key in pl.keys) {
      for (final (locale, message) in [('pl', pl[key]), ('en', en[key])]) {
        if ('$message'.contains(', plural,')) {
          expect('$message', contains('other{'), reason: '$key ($locale)');
        }
      }
    }
  });

  test('screens contain no hard-coded user-visible text', () {
    // `Text('...')`, tooltips, hints and labels must come from the ARB
    // files; the exceptions are neutral literals (formats, commands).
    final literal = RegExp(
      r"""(Text|SelectableText)\(\s*'[^'$]*[A-Za-ząćęłńóśźż]{3,}[^']*'|"""
      '''(tooltip|semanticLabel|labelText|hintText|helperText|'''
      r"""semanticsLabel|label|title): '[^'$]*[A-Za-ząćęłńóśźż]{3,}""",
    );
    const neutral = {'XXXX-XXXX-XXXX-XXXX-…'};
    final offenders = <String>[];
    for (final file in Directory('lib/src').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.contains('.g.dart') || file.path.contains('.freezed.')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (literal.hasMatch(line) && !neutral.any(line.contains)) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: 'move these to app_pl.arb/app_en.arb');
  });
}

/// Branch labels of an ICU plural/select that the argument pattern also
/// catches (`one{`, `other{`, ...).
bool _isIcuBranch(String name) =>
    const {'zero', 'one', 'two', 'few', 'many', 'other'}.contains(name);
