import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the React Native app
/// (`../carelog/src/constants/theme.ts`). Keep these values in sync with the
/// RN source so both apps render identically.

/// Brand + semantic colors.
abstract final class AppColors {
  static const primary = Color(0xFF1A6B8A);
  static const secondary = Color(0xFF2E9E6B);
  static const accent = Color(0xFFE67E22);
  static const error = Color(0xFFE53935);
  static const background = Color(0xFFF4F6FA);
  static const surface = Color(0xFFFFFFFF);

  /// Hairline border — kept very light so cards read as soft, modern surfaces
  /// rather than boxed-in wireframes. Use [borderStrong] for true dividers.
  static const border = Color(0xFFECEFF3);
  static const borderStrong = Color(0xFFDFE3E9);

  static const textPrimary = Color(0xFF1B2330);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFB4BBC6);

  /// Inactive bottom-nav tint.
  static const navInactive = Color(0xFF9AA3AF);
}

/// Spacing scale (logical pixels).
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;
}

/// Typography presets (mirror RN `Typography`).
abstract final class AppText {
  static const h1 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const h2 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const h3 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const label = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}

/// Elevation presets ported from the RN `Shadow` tokens. Spread to a
/// `BoxShadow` list on `Container.decoration`.
abstract final class AppShadow {
  /// Subtle lift for inline rows / chips.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D101828), // _shadowBase @ 5%
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// Default soft, diffuse card shadow — the modern "floating surface" look.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x12101828), // _shadowBase @ 7%
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// Pronounced elevation for sheets / FAB / modals.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F101828), // _shadowBase @ 12%
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];
}

/// Assembles the Material 3 [ThemeData] for the app.
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      // App bars are primary-filled with white foreground across the app.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.navInactive,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.navInactive,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      dividerColor: AppColors.borderStrong,
    );
  }
}
