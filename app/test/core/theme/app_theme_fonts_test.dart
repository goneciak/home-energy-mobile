import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/core/theme/font_licenses.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme fonts', () {
    final textTheme = AppTheme.dark().textTheme;

    test('display and headline styles use Fraunces at their optical size', () {
      final display = {
        'displayLarge': textTheme.displayLarge,
        'displayMedium': textTheme.displayMedium,
        'displaySmall': textTheme.displaySmall,
        'headlineLarge': textTheme.headlineLarge,
        'headlineMedium': textTheme.headlineMedium,
        'headlineSmall': textTheme.headlineSmall,
      };
      for (final MapEntry(key: name, value: style) in display.entries) {
        expect(style?.fontFamily, GiFonts.display, reason: name);
        expect(style?.fontWeight, FontWeight.w500, reason: name);
        final size = style!.fontSize;
        expect(size, isNotNull, reason: name);
        expect(style.fontVariations, [
          FontVariation('opsz', size!),
        ], reason: name);
      }
    });

    test('title, body and label styles use Manrope', () {
      final body = {
        'titleLarge': textTheme.titleLarge,
        'titleMedium': textTheme.titleMedium,
        'titleSmall': textTheme.titleSmall,
        'bodyLarge': textTheme.bodyLarge,
        'bodyMedium': textTheme.bodyMedium,
        'bodySmall': textTheme.bodySmall,
        'labelLarge': textTheme.labelLarge,
        'labelMedium': textTheme.labelMedium,
        'labelSmall': textTheme.labelSmall,
      };
      for (final MapEntry(key: name, value: style) in body.entries) {
        expect(style?.fontFamily, GiFonts.body, reason: name);
        expect(style?.fontSize, isNotNull, reason: name);
      }
    });

    test('technical values use JetBrains Mono with tabular figures', () {
      final mono = GiFonts.monospace(textTheme.bodySmall);

      expect(mono.fontFamily, GiFonts.mono);
      expect(mono.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(mono.fontSize, textTheme.bodySmall!.fontSize);
    });
  });

  testWidgets('the themed app renders all three families', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return Column(
                children: [
                  Text('GI Home', style: Theme.of(c).textTheme.headlineMedium),
                  const Text('Kotłownia'),
                  Text('10.0.2.2:3000', style: GiFonts.monospace()),
                ],
              );
            },
          ),
        ),
      ),
    );

    // Theme.of() is the localized theme the widgets actually get.
    final theme = Theme.of(context);
    expect(theme.textTheme.headlineMedium?.fontFamily, GiFonts.display);
    expect(theme.textTheme.bodyMedium?.fontFamily, GiFonts.body);
    expect(DefaultTextStyle.of(context).style.fontFamily, GiFonts.body);

    TextStyle? rendered(String text) =>
        tester.renderObject<RenderParagraph>(find.text(text)).text.style;
    expect(rendered('GI Home')?.fontFamily, GiFonts.display);
    expect(rendered('Kotłownia')?.fontFamily, GiFonts.body);
    expect(rendered('10.0.2.2:3000')?.fontFamily, GiFonts.mono);
  });

  group('bundled fonts', () {
    const files = {
      GiFonts.display: [
        'assets/fonts/Fraunces.ttf',
        'assets/fonts/Fraunces-Italic.ttf',
      ],
      GiFonts.body: ['assets/fonts/Manrope.ttf'],
      GiFonts.mono: ['assets/fonts/JetBrainsMono.ttf'],
    };

    test('are declared in the font manifest', () async {
      final manifest = (jsonDecode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List<Object?>).cast<Map<String, Object?>>();
      final declared = {
        for (final entry in manifest)
          entry['family']! as String: [
            for (final font
                in (entry['fonts']! as List<Object?>)
                    .cast<Map<String, Object?>>())
              font['asset']! as String,
          ],
      };

      for (final MapEntry(key: family, value: assets) in files.entries) {
        expect(declared[family], unorderedEquals(assets), reason: family);
      }
    });

    test('load from the asset bundle', () async {
      for (final MapEntry(key: family, value: assets) in files.entries) {
        final loader = FontLoader('test $family');
        for (final asset in assets) {
          final data = await rootBundle.load(asset);
          // TrueType files start with the 0x00010000 sfnt version.
          expect(data.getUint32(0), 0x00010000, reason: asset);
          loader.addFont(Future.value(data));
        }
        await loader.load();
      }
    });
  });

  test('font licences are registered with the licence registry', () async {
    LicenseRegistry.reset();
    addTearDown(LicenseRegistry.reset);

    registerFontLicenses();
    final licenses = await LicenseRegistry.licenses.toList();

    expect(
      licenses.expand((license) => license.packages),
      containsAll(GiFonts.families),
    );
    for (final license in licenses) {
      final text = license.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL Open Font License, Version 1.1'));
    }
  });
}
