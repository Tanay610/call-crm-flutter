import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5));
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}

