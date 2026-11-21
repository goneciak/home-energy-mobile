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
}
