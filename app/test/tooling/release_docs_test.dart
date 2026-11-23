import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The release docs are the hand-over for the people who run the store and
/// device steps. These checks keep their links, the screen-reader paths and
/// the quoted Polish labels from drifting away from the app.
void main() {
  // `flutter test` runs from app/; a Windows checkout may have CRLF.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  final checklist = read('../docs/release-checklist.md');

  test('the checklist has the screen-reader path headings', () {
    for (final heading in [
      'logowanie',
      'wstrzymanie ogrzewania',
      'zmiana celu',
      'odczyt historii',
      'połączenie z urządzeniem',
      'lista „Uwaga”',
    ]) {
      expect(checklist, contains(RegExp('### Ścieżka [1-6]: $heading')));
    }
  });

  test('the exit checklist exists and names every M4 criterion', () {
    final exit = read('../docs/templates/m4-exit-checklist.md');
    for (final criterion in [
      'Zimny start',
      'Budżet obciążenia',
      'CPU gi-core',
      'VoiceOver',
      'TalkBack',
      '200%',
      'Sesje bez awarii',
      'ponowne logowanie',
      '16 KB',
      'PrivacyInfo.xcprivacy',
      'Google Play zaakceptowane',
      'App Store zaakceptowane',
    ]) {
      expect(exit, contains(criterion));
    }
  });

  test('relative links in the release docs resolve', () {
    final files = <File>[
      File('../docs/release-runbook.md'),
      File('../docs/release-checklist.md'),
      ...Directory('../docs/templates')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md')),
    ];
    final link = RegExp(r'\]\(([^)\s]+)\)');
    for (final file in files) {
      for (final line in read(file.path).split('\n')) {
        if (line.contains('planned')) continue;
        for (final m in link.allMatches(line)) {
          final target = m.group(1)!.split('#').first;
          if (target.isEmpty || target.contains('://')) continue;
          final resolved = File.fromUri(file.uri.resolve(target));
          expect(
            resolved.existsSync() ||
                Directory.fromUri(resolved.uri).existsSync(),
            isTrue,
            reason: '${file.path} links to missing $target',
          );
        }
      }
    }
  });

  test('quoted Polish labels in the checklist match the ARB file', () {
    final arb = jsonDecode(read('lib/l10n/app_pl.arb')) as Map<String, dynamic>;
    final pair = RegExp(r'„([^”]+)”\s*\(`([A-Za-z0-9]+)`\)');
    final matches = pair.allMatches(checklist).toList();
    expect(matches.length, greaterThan(20));
    for (final m in matches) {
      final key = m.group(2)!;
      expect(arb.containsKey(key), isTrue, reason: 'unknown key $key');
      expect(arb[key], m.group(1), reason: 'label of $key differs');
    }
  });

  test('README stays a plain project overview', () {
    final readme = read('../README.md').toLowerCase();
    for (final phrase in [
      'you must',
      'step 1:',
      'as an ai',
      'musisz koniecznie',
    ]) {
      expect(readme, isNot(contains(phrase)));
    }
    expect(readme, isNot(contains('§')));
  });
}
