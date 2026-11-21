import 'package:flutter/foundation.dart';
import 'package:gi_home/src/core/theme/gi_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Material 3 theme built from [GiTokens]. v1 ships the dark theme only
/// (plan §14, D11).
abstract final class AppTheme {
  static ThemeData dark([GiTokens tokens = GiTokens.dark]) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: tokens.ember,
          brightness: Brightness.dark,
        ).copyWith(
          primary: tokens.ember,
          onPrimary: tokens.background,
          secondary: tokens.teal,
          onSecondary: tokens.background,
          tertiary: tokens.emberHot,
          error: tokens.danger,
          onError: tokens.background,
          surface: tokens.background,
          onSurface: tokens.text,
          onSurfaceVariant: tokens.textMuted,
          surfaceContainerLowest: tokens.background,
          surfaceContainerLow: tokens.surface,
          surfaceContainer: tokens.surface,
          surfaceContainerHigh: tokens.surfaceRaised,
          surfaceContainerHighest: tokens.surfaceRaised,
          outline: tokens.textMuted,
          outlineVariant: tokens.surfaceRaised,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
    );
    final inputRadius = BorderRadius.circular(tokens.radius * 0.75);
    final typography = Typography.material2021(
      platform: defaultTargetPlatform,
      colorScheme: scheme,
    );
    final textTheme = _textTheme(typography);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      typography: typography,
      // Not `fontFamily:`: ThemeData would apply it over the display styles.
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: tokens.emberDeep.withValues(alpha: 0.45),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        border: OutlineInputBorder(borderRadius: inputRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: tokens.surfaceRaised),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: tokens.ember, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: shape,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surfaceRaised,
        contentTextStyle: TextStyle(color: tokens.text),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
    );
  }

  /// The Material 3 type scale in the bundled families (plan §14): Fraunces
  /// for display and headline, Manrope for everything else.
  ///
  /// The sizes are taken from the typography's geometry up front because
  /// Fraunces' optical-size axis is set from them.
  static TextTheme _textTheme(Typography typography) {
    final base = typography.englishLike
        .merge(typography.white)
        .apply(fontFamily: GiFonts.body);
    return base.copyWith(
      displayLarge: _display(base.displayLarge),
      displayMedium: _display(base.displayMedium),
      displaySmall: _display(base.displaySmall),
      headlineLarge: _display(base.headlineLarge),
      headlineMedium: _display(base.headlineMedium),
      headlineSmall: _display(base.headlineSmall),
    );
  }

  /// A Fraunces style as the web panel uses it: medium weight, tightened
  /// tracking (`letter-spacing: -0.01em`) and the optical size matching the
  /// font size, like the browser's `font-optical-sizing: auto`. Without
  /// `opsz` Fraunces falls back to its 9 pt default cut.
  static TextStyle? _display(TextStyle? style) {
    if (style == null) return null;
    final size = style.fontSize ?? 14;
    return style.copyWith(
      fontFamily: GiFonts.display,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.01 * size,
      fontVariations: [FontVariation('opsz', size.clamp(9, 144).toDouble())],
    );
  }
}
