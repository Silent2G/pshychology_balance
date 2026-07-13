import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Light and dark [ThemeData] for the app. Screens read theme-aware colors from
/// `context.palette` (the [AppPalette] extension attached below).
class AppTheme {
  static const Color _seed = Color(0xFFBC91DB);

  static ThemeData get light => _base(AppPalette.light, Brightness.light);
  static ThemeData get dark => _base(AppPalette.dark, Brightness.dark);

  static ThemeData _base(AppPalette palette, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: palette.scaffold,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness).copyWith(
        surface: palette.scaffold,
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.surface),
      extensions: [palette],
    );
  }
}
