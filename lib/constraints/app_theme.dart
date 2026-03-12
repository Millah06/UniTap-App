// lib/constants/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color accent = Color(0xFF177E85);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
      ),
    );
  }
}