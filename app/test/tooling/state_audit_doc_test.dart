import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `docs/state-audit.md` is the map from every screen to the PRD 6.4 states
/// (plus dry-run and suspended). These checks keep it honest: the states are
/// all named, no cell is an open gap, and every text key and golden or test
/// it points to exists.
void main() {
  // `flutter test` runs from app/; a Windows checkout may have CRLF.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  final doc = read('../docs/state-audit.md');

  test('the document names every state', () {
    const states = [
      'loading',
      'no data yet',
      'waiting for telemetry',
      'offline',
      'stale',
      'unknown',
      'error',
      'maintenance',
      'resolved',
      'dry-run',
      'suspended',
    ];
    final header = doc
        .split('\n')
        .firstWhere((line) => line.startsWith('| Ekran |'));
    for (final state in states) {
      expect(header, contains(state), reason: 'matrix column "$state"');
      expect(doc, contains('### $state'), reason: 'section "$state"');
    }
  });

  test('no cell of the matrix is an open gap', () {
    final rows = doc
        .split('\n')
        .where((line) => line.startsWith('| ') && !line.startsWith('| ---'))
        .skip(1);
    expect(rows, isNotEmpty);
    for (final row in rows) {
      final cells = row.split('|').map((cell) => cell.trim()).toList()
        ..removeWhere((cell) => cell.isEmpty);
      expect(cells, hasLength(12), reason: row);
      for (final cell in cells.skip(1)) {
        expect(
          cell == 'tak' || cell.startsWith('nie dotyczy'),
          isTrue,
          reason:
              'cell "$cell" in "${cells.first}" is neither a state '
              'shown nor a justified "nie dotyczy"',
        );
      }
    }
  });

  test('every text key exists in both languages', () {
    Map<String, Object?> arb(String language) =>
        jsonDecode(read('lib/l10n/app_$language.arb')) as Map<String, Object?>;
    final pl = arb('pl');
    final en = arb('en');
    final keys = {
      for (final match in RegExp(r'`l10n\.(\w+)`').allMatches(doc))
        match.group(1)!,
    };
    expect(keys, isNotEmpty);
    for (final key in keys) {
      expect(pl, contains(key), reason: 'app_pl.arb has no "$key"');
      expect(en, contains(key), reason: 'app_en.arb has no "$key"');
    }
  });

  test('every golden and test the document names exists', () {
    final goldens = Directory('test/golden/goldens/ci')
        .listSync()
        .map((entity) => entity.uri.pathSegments.last)
        .toList();
    final tests = Directory('test')
        .listSync(recursive: true)
        .map((entity) => entity.uri.pathSegments.last)
        .toSet();
    final names = {
      for (final match in RegExp(
        '`([a-z0-9]+(?:_[a-z0-9]+)+)`',
      ).allMatches(doc))
        match.group(1)!,
    };
    expect(names, isNotEmpty);
    for (final name in names) {
      final isGolden = goldens.any((file) => file.startsWith('${name}_'));
      final isTest = tests.contains('$name.dart');
      expect(
        isGolden || isTest,
        isTrue,
        reason: '`$name` is neither a golden nor a test file',
      );
    }
  });

  test('no text is a dead-end "not reported" label', () {
    for (final language in ['pl', 'en']) {
      final arb = jsonDecode(
        read('lib/l10n/app_$language.arb'),
      ) as Map<String, Object?>;
      for (final MapEntry(:key, :value) in arb.entries) {
        if (key.startsWith('@') || value is! String) continue;
        expect(
          value.toLowerCase(),
          isNot(anyOf(contains('nie zgłoszono'), contains('not reported'))),
          reason: '$language "$key" is a dead-end label',
        );
      }
    }
  });
}
