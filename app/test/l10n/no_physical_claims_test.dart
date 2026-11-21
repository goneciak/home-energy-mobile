import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Plan §12.2, G2 and backend `docs/safety.md`: the firmware never confirms
/// the physical relay state, so no text may claim a relay switched or that
/// anything was physically confirmed. Negations ("nie potwierdza fizycznego
/// stanu", "is not verified") are fine; affirmative claims are not, so
/// each sentence or clause is checked unless it is negated.
void main() {
  Map<String, String> messages(String locale) => {
    for (final MapEntry(:key, :value) in (jsonDecode(
      File('lib/l10n/app_$locale.arb').readAsStringSync(),
    ) as Map<String, Object?>).entries)
      if (!key.startsWith('@') && value is String) key: value.toLowerCase(),
  };

  final negation = RegExp(r"\b(not|never|nie|nigdy)\b|n't");

  /// Sentences and clauses of [text] that are not negated.
  Iterable<String> affirmativeClauses(String text) => text
      .split(RegExp('[.;:–—]'))
      .where((clause) => !negation.hasMatch(clause));

  final forbidden = {
    'pl': [
      RegExp('przekaźnik (został )?(prze|w|wy)łączon'),
      RegExp('przełączono przekaźnik'),
      RegExp('(włączono|wyłączono) przekaźnik'),
      RegExp('przekaźnik (jest )?(włączony|wyłączony)'),
      RegExp('fizycznie (się )?(przełączy|włączy|wyłączy)'),
      RegExp(r'potwierdz\w* fizyczn'),
      RegExp('fizycznie potwierdz'),
    ],
    'en': [
      RegExp('relay (has |was )?(been )?switched'),
      RegExp(r'relay (is|was|turned) (now )?(on|off)\b'),
      RegExp('switched (on|off) successfully'),
      RegExp('physically (confirmed|verified|switched)'),
      RegExp('(confirmed|verified) physically'),
    ],
  };

  for (final MapEntry(key: locale, value: patterns) in forbidden.entries) {
    test('no $locale string implies a physically confirmed relay', () {
      final offending = [
        for (final MapEntry(:key, :value) in messages(locale).entries)
          for (final clause in affirmativeClauses(value))
            for (final pattern in patterns)
              if (pattern.hasMatch(clause))
                '$key: "$value" (${pattern.pattern})',
      ];
      expect(offending, isEmpty);
    });

    test('the $locale patterns catch an affirmative claim', () {
      final claim = locale == 'pl'
          ? 'przekaźnik został przełączony'
          : 'the relay was switched';
      final negated = locale == 'pl'
          ? 'aplikacja nie potwierdza, że przekaźnik został przełączony'
          : 'the app does not confirm that the relay was switched';
      expect(patterns.any((p) => p.hasMatch(claim)), isTrue);
      expect(affirmativeClauses(claim), isNotEmpty);
      expect(
        affirmativeClauses(negated)
            .where((c) => patterns.any((p) => p.hasMatch(c))),
        isEmpty,
      );
    });
  }
}
