import 'package:material_ui/material_ui.dart';

/// Design tokens of the "Ember Control Room" look (plan §14), taken from the
/// GI web panel. Read them with `GiTokens.of(context)`.
///
/// [warning] has the same colour as [emberHot], so warning chips must always
/// carry an icon and an outline as well.
@immutable
class GiTokens extends ThemeExtension<GiTokens> {
  const new({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.text,
    required this.textMuted,
    required this.ember,
    required this.emberHot,
    required this.emberDeep,
    required this.teal,
    required this.danger,
    required this.warning,
    required this.radius,
    required this.gap,
  });

  static const dark = GiTokens(
    background: Color(0xFF0A0908),
    surface: Color(0xFF171310),
    surfaceRaised: Color(0xFF1E1815),
    text: Color(0xFFF5EFE7),
    textMuted: Color(0xFFA89A8A),
    ember: Color(0xFFFF8A3D),
    emberHot: Color(0xFFFFB457),
    emberDeep: Color(0xFFC85A1E),
    teal: Color(0xFF4FD1AE),
    danger: Color(0xFFFF6B6B),
    warning: Color(0xFFFFB457),
    radius: 16,
    gap: 16,
  );

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color text;
  final Color textMuted;
  final Color ember;
  final Color emberHot;
  final Color emberDeep;
  final Color teal;
  final Color danger;
  final Color warning;

  /// Corner radius of cards, sheets and inputs.
  final double radius;

  /// Base spacing unit between blocks.
  final double gap;

  static GiTokens of(BuildContext context) =>
      Theme.of(context).extension<GiTokens>() ?? dark;

  @override
  GiTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? text,
    Color? textMuted,
    Color? ember,
    Color? emberHot,
    Color? emberDeep,
    Color? teal,
    Color? danger,
    Color? warning,
    double? radius,
    double? gap,
  }) => GiTokens(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    ember: ember ?? this.ember,
    emberHot: emberHot ?? this.emberHot,
    emberDeep: emberDeep ?? this.emberDeep,
    teal: teal ?? this.teal,
    danger: danger ?? this.danger,
    warning: warning ?? this.warning,
    radius: radius ?? this.radius,
    gap: gap ?? this.gap,
  );

  @override
  GiTokens lerp(GiTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => a + (b - a) * t;
    return GiTokens(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      ember: c(ember, other.ember),
      emberHot: c(emberHot, other.emberHot),
      emberDeep: c(emberDeep, other.emberDeep),
      teal: c(teal, other.teal),
      danger: c(danger, other.danger),
      warning: c(warning, other.warning),
      radius: d(radius, other.radius),
      gap: d(gap, other.gap),
    );
  }
}

/// Font families bundled in `assets/fonts/` (plan §14), mirroring the web
/// panel's `--font-display` / `--font-body` / `--font-mono`. Nothing is
/// downloaded at runtime.
///
/// All three are variable fonts. On the pinned Flutter version the engine
/// sets the `wght` axis from [TextStyle.fontWeight] itself (also when other
/// axes are set through [TextStyle.fontVariations]), so plain [FontWeight]s
/// render at their real weight; do not add a `wght` [FontVariation] by hand.
abstract final class GiFonts {
  /// Fraunces: display and headline styles (web `h1`–`h3`, `.brand`).
  static const display = 'Fraunces';

  /// Manrope: body, title and label styles (web `body`).
  static const body = 'Manrope';

  /// JetBrains Mono: technical values such as addresses, versions, request
  /// IDs and readings (web `.metric strong`, `.eyebrow`, `.version-badge`).
  static const mono = 'JetBrains Mono';

  static const List<String> families = [display, body, mono];

  /// [base] restyled for a technical value: JetBrains Mono with tabular
  /// figures, so digits keep their width while a reading updates.
  static TextStyle monospace([TextStyle? base]) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: mono,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
