import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// AppTheme manages darkTheme and lightTheme Material 3 configurations for AIPE LAB.
class AppTheme {
  AppTheme._();

  // Backward compatibility alias constants
  static const Color bgDark = AppColors.bgDark;
  static const Color backgroundBlack = AppColors.bgDark;
  static const Color bgGradientEnd = AppColors.bgDarkElevated;
  static const Color surfaceDark = AppColors.bgDarkElevated;
  static const Color primaryCyan = AppColors.primaryCyan;
  static const Color secondaryTeal = AppColors.secondaryTeal;
  static const Color accentViolet = AppColors.accentViolet;
  static const Color accentPurple = AppColors.accentViolet;
  static const Color academicGold = AppColors.academicGold;
  static const Color surfaceCard = AppColors.surfaceCardDark;
  static const Color cardBackground = Color(0xFF131C31);
  static const Color borderGlow = AppColors.borderGlowCyan;
  static const Color textPrimary = AppColors.textPrimaryDark;
  static const Color textSecondary = AppColors.textSecondaryDark;
  static const Color textMuted = AppColors.textMutedDark;

  static const LinearGradient logoGradient = AppColors.logoGradient;
  static const LinearGradient titleGradient = AppColors.titleGradient;
  static const LinearGradient backgroundGradient = AppColors.backgroundGradient;

  /// Primary Dark Material 3 Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        secondary: AppColors.secondaryTeal,
        tertiary: AppColors.accentViolet,
        surface: AppColors.bgDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.textPrimaryDark),
        displayMedium: AppTypography.displayMedium(color: AppColors.textPrimaryDark),
        displaySmall: AppTypography.displaySmall(color: AppColors.textPrimaryDark),
        titleLarge: AppTypography.titleMedium(color: AppColors.textPrimaryDark),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.textPrimaryDark),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.textSecondaryDark),
        labelLarge: AppTypography.sectionTitle(color: AppColors.primaryCyan),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCardDark,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
      ),
    );
  }

  /// Refined Light Material 3 Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0284C7),
        secondary: Color(0xFF0D9488),
        tertiary: Color(0xFF7C3AED),
        surface: AppColors.bgLightElevated,
        onSurface: AppColors.textPrimaryLight,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.textPrimaryLight),
        displayMedium: AppTypography.displayMedium(color: AppColors.textPrimaryLight),
        displaySmall: AppTypography.displaySmall(color: AppColors.textPrimaryLight),
        titleLarge: AppTypography.titleMedium(color: AppColors.textPrimaryLight),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.textPrimaryLight),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.textSecondaryLight),
        labelLarge: AppTypography.sectionTitle(color: const Color(0xFF0284C7)),
      ),
    );
  }
}
