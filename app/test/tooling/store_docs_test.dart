import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Documents that must not drift from the files they describe: the backend
/// pin in docs/compatibility.md and the draft status of site/.
void main() {
  // `flutter test` runs from app/.
  String read(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  group('compatibility declaration', () {
    final lock = read('../contract/backend.lock');
    String lockValue(String key) =>
        RegExp('^$key=(.+)\$', multiLine: true).firstMatch(lock)!.group(1)!;
    final doc = read('../docs/compatibility.md');

    test('names the sha, short sha and pin date of contract/backend.lock', () {
      expect(doc, contains(lockValue('sha')));
      expect(doc, contains(lockValue('shortSha')));
      expect(doc, contains(lockValue('pinnedAt')));
    });
  });

  group('store screenshots', () {
    final matrix = read('../docs/store/screenshot-matrix.md');
    final scenarios = RegExp('`golden/([a-z0-9_]+)`')
        .allMatches(matrix)
        .map((m) => m.group(1)!)
        .toSet();

    test('every scenario has a golden in the three sizes, tablet included', () {
      expect(scenarios, hasLength(greaterThanOrEqualTo(8)));
      for (final scenario in scenarios) {
        for (final size in ['small_phone', 'large_phone', 'tablet_landscape']) {
          expect(
            File('test/golden/goldens/ci/${scenario}_$size.png').existsSync(),
            isTrue,
            reason: '$scenario at $size',
          );
        }
      }
    });
  });

  group('site pages', () {
    final pages = [
      for (final f in Directory('../site').listSync().whereType<File>())
        if (f.path.endsWith('.md')) f,
    ];
    final placeholder = RegExp(r'\[\[[A-Z_]+\]\]');

    test('lists the placeholders still to fill in (informational)', () {
      final open = <String, Set<String>>{};
      for (final page in pages) {
        final name = page.uri.pathSegments.last;
        for (final m in placeholder.allMatches(read(page.path))) {
          (open[m.group(0)!] ??= {}).add(name);
        }
      }
      final lines = [
        for (final e in open.entries)
          '  ${e.key}: ${(e.value.toList()..sort()).join(', ')}',
      ];
      // Informational: shown in the test log.
      // ignore: avoid_print, the output is the purpose of this test.
      print(
        'Open site placeholders (the owner fills them in):\n'
        '${lines.join('\n')}',
      );
      expect(open.keys, isNotEmpty, reason: 'pages are still drafts');
    });

    test('every content page is marked DRAFT and none claims publication', () {
      expect(pages, isNotEmpty);
      for (final page in pages) {
        final text = read(page.path);
        final name = page.uri.pathSegments.last;
        expect(text, contains('DRAFT'), reason: name);
        expect(
          text,
          isNot(
            matches(
              RegExp(r'opublikowan[aey]\b|published at', caseSensitive: false),
            ),
          ),
          reason: name,
        );
      }
    });

    test('the README stays a draft with the placeholders documented', () {
      final readme = read('../site/README.md');
      expect(readme, contains('DRAFT'));
      final used = <String>{
        for (final page in pages)
          for (final m in placeholder.allMatches(read(page.path))) m.group(0)!,
      };
      for (final p in used) {
        expect(readme, contains(p), reason: 'README documents $p');
      }
    });

    test('internal links point at existing pages', () {
      final link = RegExp(r'\]\(([a-z\-]+\.md)(#[^)]*)?\)');
      for (final page in pages) {
        for (final m in link.allMatches(read(page.path))) {
          expect(
            File('../site/${m.group(1)}').existsSync(),
            isTrue,
            reason: '${page.path} -> ${m.group(1)}',
          );
        }
      }
    });
  });
}
