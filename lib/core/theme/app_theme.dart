import 'package:flutter/material.dart';

/// Central visual tokens for Pocketly. Widgets use these values rather than
/// defining colour literals locally.
abstract final class AppColors {
  static const yellow = Color(0xFFEEF52B);
  static const pink = Color(0xFFFF9F9F);
  static const red = Color(0xFFFF4A1C);
  static const ink = Color(0xFF0A0A0A);
  static const muted = Color(0xFF8E8E93);
  static const line = Color(0xFFE3E3E6);
  static const buttonGray = Color(0xFFEFEFF1);
  static const darkCard = Color(0xFF1C1C1E);
}

/// Defines the shared light and dark Material themes.
abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.ink : Colors.white;
    final foreground = dark ? Colors.white : AppColors.ink;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.yellow, brightness: brightness, surface: dark ? AppColors.darkCard : Colors.white),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(fontFamily: 'Outfit', bodyColor: foreground, displayColor: foreground),
      useMaterial3: true,
    );
  }
}
