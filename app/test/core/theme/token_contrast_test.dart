import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/theme/app_theme.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/wcag.dart';

/// WCAG 2.x AA contrast of every token pair the app paints text or a glyph
/// with (plan §14 "Dostępność kolorów"). The golden tests check the
/// rendered screens on top of this with `textContrastGuideline`.
void main() {
  const tokens = GiTokens.dark;
  final scheme = AppTheme.dark().colorScheme;

  /// Page, card and raised surfaces (sheets, dialogs, snack bars).
  final surfaces = {
    'background': tokens.background,
    'surface': tokens.surface,
    'surfaceRaised': tokens.surfaceRaised,
  };

  /// Status colours of StatusChip, GiBadge and MessageBanner.
  final tones = {
    'teal': tokens.teal,
    'textMuted': tokens.textMuted,
    'ember': tokens.ember,
    'warning': tokens.warning,
    'danger': tokens.danger,
  };

  /// A chip or banner fill: its tone at 12% over a surface.
  Map<String, Color> tintsOf(String tone) => {
    for (final MapEntry(key: name, value: surface) in surfaces.entries)
      '$tone 12% over $name': blendOver(
        tones[tone]!.withValues(alpha: 0.12),
        surface,
      ),
  };

  /// Pairs below [minimum], as readable lines.
  List<String> failing(
    double minimum,
    Iterable<(String, Color, String, Color)> pairs,
  ) => [
    for (final (fgName, fg, bgName, bg) in pairs)
      if (contrastRatio(fg, bg) < minimum)
        '$fgName on $bgName: ${contrastRatio(fg, bg).toStringAsFixed(2)}:1',
  ];

  group('normal text (4.5:1)', () {
    test('body and muted text on every surface', () {
      expect(
        failing(WcagAa.normalText, [
          for (final MapEntry(key: name, value: bg) in surfaces.entries) ...[
            ('text', tokens.text, name, bg),
            ('textMuted', tokens.textMuted, name, bg),
          ],
        ]),
        isEmpty,
      );
    });

    test('accent text on every surface (headings, buttons, errors)', () {
      final accents = {
        'ember': tokens.ember,
        'emberHot': tokens.emberHot,
        'teal': tokens.teal,
        'warning': tokens.warning,
        'danger': tokens.danger,
      };
      expect(
        failing(WcagAa.normalText, [
          for (final MapEntry(key: fgName, value: fg) in accents.entries)
            for (final MapEntry(key: bgName, value: bg) in surfaces.entries)
              (fgName, fg, bgName, bg),
        ]),
        isEmpty,
      );
    });

    test('chip labels and banner text on their tinted fills', () {
      expect(
        failing(WcagAa.normalText, [
          for (final tone in tones.keys)
            for (final MapEntry(key: bgName, value: bg) in tintsOf(
              tone,
            ).entries) ...[
              ('text', tokens.text, bgName, bg),
              ('textMuted', tokens.textMuted, bgName, bg),
            ],
        ]),
        isEmpty,
      );
    });

    test('dark text on filled tones (GiBadge, filled buttons)', () {
      expect(
        failing(WcagAa.normalText, [
          for (final MapEntry(key: name, value: fill) in tones.entries)
            ('background', tokens.background, name, fill),
        ]),
        isEmpty,
      );
    });

    test('Material colour scheme roles', () {
      expect(
        failing(WcagAa.normalText, [
          ('onPrimary', scheme.onPrimary, 'primary', scheme.primary),
          ('onSecondary', scheme.onSecondary, 'secondary', scheme.secondary),
          ('onError', scheme.onError, 'error', scheme.error),
          (
            'onPrimaryContainer',
            scheme.onPrimaryContainer,
            'primaryContainer',
            scheme.primaryContainer,
          ),
          (
            'onSecondaryContainer',
            scheme.onSecondaryContainer,
            'secondaryContainer',
            scheme.secondaryContainer,
          ),
          (
            'onTertiaryContainer',
            scheme.onTertiaryContainer,
            'tertiaryContainer',
            scheme.tertiaryContainer,
          ),
          (
            'onErrorContainer',
            scheme.onErrorContainer,
            'errorContainer',
            scheme.errorContainer,
          ),
          for (final (name, bg) in [
            ('surface', scheme.surface),
            ('surfaceContainerLowest', scheme.surfaceContainerLowest),
            ('surfaceContainerLow', scheme.surfaceContainerLow),
            ('surfaceContainer', scheme.surfaceContainer),
            ('surfaceContainerHigh', scheme.surfaceContainerHigh),
            ('surfaceContainerHighest', scheme.surfaceContainerHighest),
          ]) ...[
            ('onSurface', scheme.onSurface, name, bg),
            ('onSurfaceVariant', scheme.onSurfaceVariant, name, bg),
            // Text and outlined button labels, focused field labels.
            ('primary', scheme.primary, name, bg),
            // Form field errors.
            ('error', scheme.error, name, bg),
          ],
        ]),
        isEmpty,
      );
    });
  });

  group('large text and glyphs (3:1)', () {
    test('status icons on surfaces and on their own tint', () {
      expect(
        failing(WcagAa.largeTextOrGlyph, [
          for (final MapEntry(key: fgName, value: fg) in tones.entries) ...[
            for (final MapEntry(key: bgName, value: bg) in surfaces.entries)
              (fgName, fg, bgName, bg),
            for (final MapEntry(key: bgName, value: bg) in tintsOf(
              fgName,
            ).entries)
              (fgName, fg, bgName, bg),
          ],
        ]),
        isEmpty,
      );
    });

    test('the selected navigation destination on its indicator', () {
      final theme = AppTheme.dark();
      final indicator = blendOver(
        theme.navigationBarTheme.indicatorColor!,
        theme.navigationBarTheme.backgroundColor!,
      );
      expect(
        failing(WcagAa.largeTextOrGlyph, [
          (
            'onSecondaryContainer',
            scheme.onSecondaryContainer,
            'indicator',
            indicator,
          ),
        ]),
        isEmpty,
      );
    });
  });

  group('contrastRatio', () {
    test('matches the WCAG reference values', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.001),
      );
      expect(
        contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
        closeTo(4.48, 0.01),
      );
      expect(
        contrastRatio(const Color(0xFF123456), const Color(0xFF123456)),
        1,
      );
    });
  });
}
