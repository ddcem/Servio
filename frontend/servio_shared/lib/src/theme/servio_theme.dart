import 'package:flutter/material.dart';

import 'servio_colors.dart';

abstract final class ServioTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: ServioColors.primary, primary: ServioColors.primary, surface: Colors.white);
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ServioColors.background,
      appBarTheme: const AppBarTheme(backgroundColor: ServioColors.primary, foregroundColor: Colors.white, elevation: 0),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ServioColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ServioColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: rounded,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: rounded),
      ),
      dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
