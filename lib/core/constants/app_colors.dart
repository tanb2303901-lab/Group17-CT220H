import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF006E1C);
  static const Color primaryContainer = Color(0xFF4CAF50);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF003C0B);

  static const Color secondary = Color(0xFF705D00);
  static const Color secondaryContainer = Color(0xFFFCD400); // Gold Accent
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF6E5C00);

  // Neutral colors
  static const Color background = Color(0xFFF3FCF4); // Soft Mint
  static const Color onBackground = Color(0xFF151D19);
  static const Color surface = Color(0xFFF3FCF4);
  static const Color onSurface = Color(0xFF151D19);
  static const Color surfaceVariant = Color(0xFFDCE5DD);
  static const Color onSurfaceVariant = Color(0xFF3F4A3C);
  
  static const Color surfaceContainerLow = Color(0xFFEDF6EE);
  static const Color surfaceContainer = Color(0xFFE7F0E8);
  static const Color surfaceContainerHigh = Color(0xFFE1EAE3);
  static const Color surfaceContainerHighest = Color(0xFFDCE5DD);
  static const Color white = Color(0xFFFFFFFF);

  // Functional colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color outline = Color(0xFF6F7A6B);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF006E1C),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFFFE16D),
    Color(0xFFFCD400),
  ];
}
