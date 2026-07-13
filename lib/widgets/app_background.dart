import 'package:flutter/material.dart';
import '../constants/app_palette.dart';

/// Full-screen app background: the existing light image in light mode, and a
/// soft brand-dark gradient in dark mode. Replaces the per-screen
/// `Container(decoration: DecorationImage(...))` so theming is centralized.
class AppBackground extends StatelessWidget {
  final Widget child;
  final String lightImage;

  const AppBackground({
    super.key,
    required this.child,
    this.lightImage = 'assets/background_main.png',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: palette.isDark
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.backgroundGradient,
              ),
            )
          : BoxDecoration(
              image: DecorationImage(image: AssetImage(lightImage), fit: BoxFit.cover),
            ),
      child: child,
    );
  }
}
