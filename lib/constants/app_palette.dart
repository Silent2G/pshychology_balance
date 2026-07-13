import 'package:flutter/material.dart';

/// Semantic, theme-aware colors for the whole app. Access via `context.palette`.
///
/// The brand purple accent (#BC91DB) stays the same across themes; surfaces,
/// text and backgrounds flip between the light and dark variants.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Brightness brightness;

  /// Base scaffold background color.
  final Color scaffold;

  /// Card / elevated surface color.
  final Color surface;

  /// Subtle border around cards / inputs.
  final Color surfaceBorder;

  /// Primary body text.
  final Color textPrimary;

  /// Secondary / supporting text.
  final Color textSecondary;

  /// Muted / hint text.
  final Color textMuted;

  /// Brand accent (buttons, highlights).
  final Color accent;

  /// Accent tuned for text/labels (slightly stronger for contrast per theme).
  final Color accentText;

  /// Gradient used for the app background in dark mode.
  final List<Color> backgroundGradient;

  const AppPalette({
    required this.brightness,
    required this.scaffold,
    required this.surface,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentText,
    required this.backgroundGradient,
  });

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    scaffold: Color(0xFFFDFDFD),
    surface: Colors.white,
    surfaceBorder: Color(0xFFEDE6F3),
    textPrimary: Color(0xFF272727),
    textSecondary: Color(0xFF757575),
    textMuted: Color(0xFFA3A3A3),
    accent: Color(0xFFBC91DB),
    accentText: Color(0xFF9557C2),
    backgroundGradient: [Color(0xFFFDFDFD), Color(0xFFFDFDFD)],
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    scaffold: Color(0xFF14111C),
    surface: Color(0xFF221D2E),
    surfaceBorder: Color(0xFF322B42),
    textPrimary: Color(0xFFF2EFF7),
    textSecondary: Color(0xFFB5AEC6),
    textMuted: Color(0xFF8A8299),
    accent: Color(0xFFBC91DB),
    accentText: Color(0xFFCBA6E8),
    backgroundGradient: [Color(0xFF1A1626), Color(0xFF0E0B14)],
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? scaffold,
    Color? surface,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentText,
    List<Color>? backgroundGradient,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      backgroundGradient: [
        Color.lerp(backgroundGradient.first, other.backgroundGradient.first, t)!,
        Color.lerp(backgroundGradient.last, other.backgroundGradient.last, t)!,
      ],
    );
  }
}

/// Convenient access: `context.palette.surface`, etc.
extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
