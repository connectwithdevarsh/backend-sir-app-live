import 'package:flutter/material.dart';

/// AppColors defines the central color palette for the AIPE LAB educational application.
class AppColors {
  AppColors._();

  // Dark Theme Background & Canvas Palette
  static const Color bgDark = Color(0xFF070B15); // Deep Midnight Space
  static const Color bgDarkElevated = Color(0xFF0F172A); // Slate Dark
  static const Color bgDarkCard = Color(0xFF1E293B); // Elevated Card Surface

  // Light Theme Palette
  static const Color bgLight = Color(0xFFF8FAFC); // Very Soft Slate Light
  static const Color bgLightElevated = Color(0xFFFFFFFF); // Pure White Surface
  static const Color bgLightCard = Color(0xFFF1F5F9); // Light Card Surface

  // Brand & Accent Colors
  static const Color primaryCyan = Color(0xFF00F2FE); // Electric Cyan Accent
  static const Color secondaryTeal = Color(0xFF4FACFE); // Vibrant Teal
  static const Color accentViolet = Color(0xFF8B5CF6); // Cyber Violet
  static const Color academicGold = Color(0xFFF59E0B); // Gold Accent Badge

  // Surface Translucency & Borders
  static const Color surfaceCardDark = Color(0x1A1E293B); // Translucent Dark Slate
  static const Color borderGlowCyan = Color(0x4000F2FE); // Cyan Border Glow
  static const Color borderSubtle = Color(0x1EFFFFFF); // Subtle Translucent Border

  // High Contrast Text Colors (Dark Theme)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // High Contrast White
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Soft Blue-Grey
  static const Color textMutedDark = Color(0xFF64748B); // Muted Subtitle

  // High Contrast Text Colors (Light Theme)
  static const Color textPrimaryLight = Color(0xFF0F172A); // High Contrast Deep Navy
  static const Color textSecondaryLight = Color(0xFF334155); // Slate Secondary
  static const Color textMutedLight = Color(0xFF64748B); // Muted Subtitle Light

  // Gradients
  static const LinearGradient logoGradient = LinearGradient(
    colors: [primaryCyan, secondaryTeal, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient titleGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), primaryCyan],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgDark, Color(0xFF0D1527), bgDarkElevated],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
