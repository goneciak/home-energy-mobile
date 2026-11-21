// Launcher icons of the dev and beta flavors (plan §14): the app icon with a
// diagonal "DEV"/"BETA" ribbon across its lower-right corner.
//
// Run from app/, then generate the Android resources of both flavors:
//   dart run tool/make_flavor_icons.dart
//   dart run flutter_launcher_icons
// The second step reads flutter_launcher_icons-dev.yaml and -beta.yaml and
// writes android/app/src/{dev,beta}/res. Prod keeps the icons in
// android/app/src/main/res (from the pubspec config, generated before the
// flavor files existed). iOS per-flavor icons need Xcode schemes (macOS).
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final icon = _read('assets/icon/icon.png');
  final foreground = _read('assets/icon/icon_foreground.png');
  for (final ribbon in _Ribbon.values) {
    // The full icon: the ribbon crosses the corner of the square.
    _write(
      'assets/icon/icon_${ribbon.name}.png',
      ribbon.paint(icon, center: 0.78, thickness: 0.13),
    );
    // The adaptive foreground: launchers show only its middle 72/108 (and
    // may mask it to a circle), so the ribbon sits inside that area.
    _write(
      'assets/icon/icon_foreground_${ribbon.name}.png',
      ribbon.paint(foreground, center: 0.69, thickness: 0.085),
    );
  }
}

enum _Ribbon {
  dev('DEV', (0x4f, 0xd1, 0xae)),
  beta('BETA', (0xff, 0x6b, 0x6b));

  new(this.label, this.color);

  final String label;
  final (int, int, int) color;

  static const _text = (0x0a, 0x09, 0x08);

  /// [source] with the ribbon. The band runs from lower-left to upper-right
  /// at 45°; its middle is at ([center], [center]) and it is [thickness]
  /// thick, both as fractions of the icon size.
  img.Image paint(
    img.Image source, {
    required double center,
    required double thickness,
  }) {
    final size = source.width.toDouble();
    final out = source.clone();
    final band = thickness * size;
    // Across the band: n = (1, 1) / √2; along it: d = (1, -1) / √2.
    final middle = center * size * math.sqrt2;
    final label = _label();
    // Cap height of the label: 58% of the band.
    final scale = band * 0.58 / label.height;

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final px = x + 0.5;
        final py = y + 0.5;
        final across = (px + py) / math.sqrt2 - middle;
        final bandCover = (band / 2 - across.abs() + 0.5).clamp(0.0, 1.0);
        if (bandCover == 0) continue;
        final along = (px - py) / math.sqrt2;
        final textCover = _sample(
          label,
          along / scale + label.width / 2,
          across / scale + label.height / 2,
        );
        final pixel = out.getPixel(x, y);
        var rgba = (
          pixel.r.toDouble(),
          pixel.g.toDouble(),
          pixel.b.toDouble(),
          pixel.a.toDouble(),
        );
        rgba = _over(rgba, color, bandCover);
        rgba = _over(rgba, _text, bandCover * textCover);
        out.setPixelRgba(x, y, rgba.$1, rgba.$2, rgba.$3, rgba.$4);
      }
    }
    return out;
  }

  /// The label in white on transparent, cropped to its ink. The bitmap
  /// font is drawn three times, a pixel apart, to make it bolder.
  img.Image _label() {
    final font = img.arial48;
    final width = label.codeUnits.fold<int>(
      0,
      (sum, c) => sum + (font.characters[c]?.xAdvance ?? font.size),
    );
    final canvas = img.Image(
      width: width + 8,
      height: font.lineHeight + 8,
      numChannels: 4,
    );
    for (final dx in [3, 4, 5]) {
      img.drawString(
        canvas,
        label,
        font: font,
        x: dx,
        y: 4,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }
    var (left, top, right, bottom) = (canvas.width, canvas.height, 0, 0);
    for (final p in canvas) {
      if (p.a == 0) continue;
      left = math.min(left, p.x);
      top = math.min(top, p.y);
      right = math.max(right, p.x + 1);
      bottom = math.max(bottom, p.y + 1);
    }
    return img.copyCrop(
      canvas,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
  }
}

/// Bilinear coverage (0–1) of [label] at ([x], [y]); 0 outside it.
double _sample(img.Image label, double x, double y) {
  double at(int ix, int iy) {
    if (ix < 0 || iy < 0 || ix >= label.width || iy >= label.height) return 0;
    return label.getPixel(ix, iy).a / 255;
  }

  final fx = x - 0.5;
  final fy = y - 0.5;
  final x0 = fx.floor();
  final y0 = fy.floor();
  final tx = fx - x0;
  final ty = fy - y0;
  final top = at(x0, y0) * (1 - tx) + at(x0 + 1, y0) * tx;
  final bottom = at(x0, y0 + 1) * (1 - tx) + at(x0 + 1, y0 + 1) * tx;
  return top * (1 - ty) + bottom * ty;
}

/// [color] with [alpha] (0–1) painted over [dst] (0–255 channels).
(double, double, double, double) _over(
  (double, double, double, double) dst,
  (int, int, int) color,
  double alpha,
) {
  if (alpha <= 0) return dst;
  final dstA = dst.$4 / 255;
  final outA = alpha + dstA * (1 - alpha);
  double mix(int src, double dstC) =>
      (src * alpha + dstC * dstA * (1 - alpha)) / outA;
  return (
    mix(color.$1, dst.$1),
    mix(color.$2, dst.$2),
    mix(color.$3, dst.$3),
    outA * 255,
  );
}

img.Image _read(String path) {
  final decoded = img.decodePng(File(path).readAsBytesSync());
  if (decoded == null) throw StateError('$path is not a PNG');
  return decoded.convert(numChannels: 4);
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $path');
}
