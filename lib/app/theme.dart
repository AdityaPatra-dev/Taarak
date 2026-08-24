import 'package:flutter/material.dart';
import 'package:taarak/app/spacing.dart';

/// Shared light/dark themes. Roles reuse the same app shell (blueprint
/// section 2), so theming lives in one place rather than per-feature.
///
/// Deliberately doesn't reach for a custom font — `google_fonts` would add
/// a network dependency at odds with this app's offline-first purpose (or
/// a bundled font asset that adds bytes for no functional gain). The
/// platform's own system font is fully legible and free; what actually
/// makes a UI feel considered is a defined type *scale* and consistent
/// component theming, both of which were missing before this pass, not
/// the specific glyphs.
class AppTheme {
  AppTheme._();

  /// A deliberately deep, muted teal — reads as institutional/trustworthy
  /// rather than the brighter, more generic teal Material's own examples
  /// default to. Kept clearly distinct from every severity/risk color
  /// (`severityColor`, `riskClassColor`) so the brand color is never
  /// mistaken for a status.
  static const _seedColor = Color(0xFF0B6B65);

  static ThemeData get light => _themeFrom(
    ColorScheme.fromSeed(
      seedColor: _seedColor,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  static ThemeData get dark => _themeFrom(
    ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  static ThemeData _themeFrom(ColorScheme scheme) {
    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        // A real default rather than zero: screens that stack Cards
        // without their own explicit gap (not every screen in this pass
        // was rewritten to add one) still get breathing room between
        // them instead of edges touching.
        margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// A defined type scale, not the framework default left untouched — the
  /// sizes/weights below are what every screen title, card header and
  /// body of text in the app draws from.
  static TextTheme _textTheme(ColorScheme scheme) {
    final base = Typography.material2021().black.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(
        letterSpacing: 0.4,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
