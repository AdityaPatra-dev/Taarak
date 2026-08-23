import 'package:flutter/material.dart';

/// Shared light/dark themes. Roles reuse the same app shell (blueprint
/// section 2), so theming lives in one place rather than per-feature.
class AppTheme {
  AppTheme._();

  static const _seedColor = Colors.teal;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );
}
