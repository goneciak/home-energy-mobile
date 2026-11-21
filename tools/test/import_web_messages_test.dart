import 'dart:convert';
import 'dart:io';

import 'package:gi_tools/web_messages.dart';
import 'package:test/test.dart';

void main() {
  final sample = parseTsMessages(
    File('test/fixtures/web_messages_sample.ts').readAsStringSync(),
  );

  group('parseTsMessages', () {
    test('reads both locales with quotes, escapes and concatenation', () {
      final en = sample.locales['en-US']!;
      final pl = sample.locales['pl-PL']!;

      expect(sample.locales.keys, ['en-US', 'pl-PL']);
      expect(en['auth.signIn'], 'Sign in');
      expect(en['auth.password'], 'Password');
      expect(en['nav.devices'], 'Devices');
      expect(
        en['dashboard.deviceDiscoveredDescription'],
        'GI Home found "{name}" nearby.',
      );
      expect(
        en['dashboard.deviceDiscoveredDescriptionMultiple'],
        'GI Home found "{name}" and {count} more nearby.',
      );
      expect(en['device.long'], 'First part, second part.');
      expect(en['device.template'], 'Line one');
      expect(en['unquoted'], 'Bare key');
      expect(pl['device.long'], 'Pierwsza część, druga część.');
      expect(pl['unquoted'], 'Klucz bez cudzysłowu ą');
    });

    test('skips and reports what it does not evaluate', () {
      expect(sample.locales['en-US'], isNot(contains('device.computed')));
      expect(sample.locales['en-US'], isNot(contains('device.call')));
      expect(sample.skipped, [
        'en-US.device.computed: unsupported value',
        'en-US.device.call: unsupported value',
        'pl-PL.device.computed: unsupported value',
        'pl-PL.device.call: unsupported value',
      ]);
    });

    test('fails without a messages object', () {
      expect(
        () => parseTsMessages('export const other = {};'),
        throwsFormatException,
      );
    });
  });

  group('ARB mapping', () {
    test('web keys become Dart identifiers', () {
      expect(
        arbKeyFor('dashboard.deviceDiscoveredTitle'),
        'dashboardDeviceDiscoveredTitle',
      );
      expect(arbKeyFor('settings.mqtt-test.ok'), 'settingsMqttTestOk');
      expect(arbKeyFor('404.title'), 'web404Title');
      expect(arbKeyFor('default'), 'defaultText');
    });

    test('placeholders are found once, in order', () {
      expect(placeholdersOf('{name} and {count} ({name})'), ['name', 'count']);
    });

    test('plans statuses against the existing ARB files', () {
      final entries = planImport(
        pl: sample.locales['pl-PL']!,
        en: sample.locales['en-US']!,
        arbPl: {
          '@@locale': 'pl',
          'authSignIn': 'Zaloguj się',
          'authPassword': 'Hasło logowania',
          'navHome': 'Urządzenia',
        },
        arbEn: {'@@locale': 'en', 'authSignIn': 'Sign in'},
      );
      final byKey = {for (final e in entries) e.webKey: e};

      expect(byKey['auth.signIn']!.status, ImportStatus.exists);
      expect(byKey['auth.password']!.status, ImportStatus.differs);
      expect(byKey['auth.password']!.existingPl, 'Hasło logowania');
      expect(byKey['nav.devices']!.status, ImportStatus.sameText);
      expect(byKey['nav.devices']!.existingKey, 'navHome');
      expect(byKey['only.en']!.status, ImportStatus.incomplete);
      final multiple = byKey['dashboard.deviceDiscoveredDescriptionMultiple']!;
      expect(multiple.status, ImportStatus.missing);
      expect(multiple.arbKey, 'dashboardDeviceDiscoveredDescriptionMultiple');
      expect(multiple.placeholders, ['name', 'count']);
    });

    test('--only limits the import to key prefixes', () {
      final entries = planImport(
        pl: sample.locales['pl-PL']!,
        en: sample.locales['en-US']!,
        arbPl: const {},
        arbEn: const {},
        only: ['auth.'],
      );

      expect(
        [for (final e in entries) e.webKey],
        ['auth.signIn', 'auth.password'],
      );
    });
  });

  group('applyImport', () {
    final arbPl = <String, Object?>{
      '@@locale': 'pl',
      'authSignIn': 'Zaloguj',
      '@authSignIn': {'description': 'Kept.'},
    };
    final arbEn = <String, Object?>{'@@locale': 'en', 'authSignIn': 'Log in'};
    final entries = planImport(
      pl: sample.locales['pl-PL']!,
      en: sample.locales['en-US']!,
      arbPl: arbPl,
      arbEn: arbEn,
    );

    test('adds only missing keys and keeps existing translations', () {
      final merged = applyImport(entries, arbPl: arbPl, arbEn: arbEn);

      expect(merged.pl['authSignIn'], 'Zaloguj');
      expect(merged.pl['@authSignIn'], {'description': 'Kept.'});
      expect(merged.en['authSignIn'], 'Log in');
      expect(merged.pl.keys.take(3), ['@@locale', 'authSignIn', '@authSignIn']);
      expect(merged.pl['authPassword'], 'Hasło');
      expect(merged.en['authPassword'], 'Password');
      expect(merged.pl['@dashboardDeviceDiscoveredDescription'], {
        'description':
            'Imported from GI UI (dashboard.deviceDiscoveredDescription).',
        'placeholders': {
          'name': {'type': 'String'},
        },
      });
      expect(merged.pl, isNot(contains('onlyEn')));
      expect(merged.en, isNot(contains('onlyEn')));
      // pl and en get the same message keys.
      expect(
        merged.pl.keys.where((k) => !k.startsWith('@')).toSet(),
        merged.en.keys.where((k) => !k.startsWith('@')).toSet(),
      );
      // The inputs are not modified.
      expect(arbPl, hasLength(3));
    });

    test('is idempotent', () {
      final once = applyImport(entries, arbPl: arbPl, arbEn: arbEn);
      final again = planImport(
        pl: sample.locales['pl-PL']!,
        en: sample.locales['en-US']!,
        arbPl: once.pl,
        arbEn: once.en,
      );

      expect(again.where((e) => e.status == ImportStatus.missing), isEmpty);
    });

    test('appendToArb keeps the existing text byte for byte', () {
      const text =
          '{\r\n    "@@locale": "pl",\r\n    "authSignIn": "Zaloguj",'
          '\r\n    "@authSignIn": {"description": "Kept."}\r\n}\r\n';
      final merged = applyImport(
        entries,
        arbPl: jsonDecode(text) as Map<String, Object?>,
        arbEn: arbEn,
      );

      final appended = appendToArb(text, merged.pl);

      expect(appended, startsWith(text.substring(0, text.length - 5)));
      expect(appended, endsWith('\r\n}\r\n'));
      expect(appended, contains(',\r\n  "authPassword": "Hasło",\r\n'));
      expect(jsonDecode(appended), merged.pl);
      expect(appendToArb(appended, merged.pl), appended);
      expect(appendToArb('{}', {'a': 'b'}), '{\n  "a": "b"\n}\n');
    });

    test('the Markdown proposal lists the keys to add', () {
      final text = renderImportMarkdown(
        entries,
        source: 'sample.ts',
        skipped: sample.skipped,
      );

      expect(text, contains('| `authPassword` | `auth.password` | Hasło |'));
      expect(text, contains('| missing |'));
      expect(text, contains('en-US.device.computed: unsupported value'));
    });
  });
}
