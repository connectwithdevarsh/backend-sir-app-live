import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTypography defines standardized font hierarchies across AIPE LAB.
class AppTypography {
  AppTypography._();

  // Display Typography (Space Grotesk)
  static TextStyle displayLarge({Color color = AppColors.textPrimaryDark}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2.0,
      );

  static TextStyle displayMedium({Color color = AppColors.textPrimaryDark}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.5,
      );

  static TextStyle displaySmall({Color color = AppColors.textPrimaryDark}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.0,
      );

  // Section Headers & Titles (Space Grotesk)
  static TextStyle sectionTitle({Color color = AppColors.primaryCyan}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.2,
      );

  static TextStyle titleMedium({Color color = AppColors.textPrimaryDark}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body Typography (Inter)
  static TextStyle bodyLarge({Color color = AppColors.textPrimaryDark}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondaryDark}) =>
      GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.35,
      );

  static TextStyle caption({Color color = AppColors.textMutedDark}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: color,
      );

  // Monospace Typography (Fira Code)
  static TextStyle codeMonospace({Color color = AppColors.primaryCyan}) =>
      GoogleFonts.firaCode(
        fontSize: 11.5,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );
}
