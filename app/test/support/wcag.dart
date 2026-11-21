import 'dart:math' as math;
import 'dart:ui' show Color;

/// WCAG 2.x minimum contrast (success criteria 1.4.3 and 1.4.11, level AA).
abstract final class WcagAa {
  /// Normal text.
  static const normalText = 4.5;

  /// Large text (18 pt, or 14 pt bold) and graphical objects such as icons.
  static const largeTextOrGlyph = 3.0;
}

/// Relative luminance of an opaque [color] (WCAG 2.x definition).
double relativeLuminance(Color color) {
  assert(color.a == 1, 'blend a translucent colour first (blendOver)');
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Contrast ratio between two opaque colours, from 1:1 to 21:1.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [foreground] (possibly translucent) painted over an opaque [background].
Color blendOver(Color foreground, Color background) =>
    Color.alphaBlend(foreground, background);
