import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color pressedBlue = Color(0xFF3A7BC8); // Pressed state color

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFF5F5F5);

  // Accent colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentYellow = Color(0xFFFFEB3B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Emoji scale colors
  static const List<Color> emojiColors = [
    accentRed, // Very bad
    accentOrange, // Bad
    accentYellow, // Neutral
    Color(0xFFFFC107), // Good
    accentGreen, // Great
  ];
}
