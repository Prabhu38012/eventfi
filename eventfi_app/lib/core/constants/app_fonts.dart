import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// EventFi Typography System
/// ──────────────────────────────────────────────────────────
/// Title   → Tanker          Bold display — event names, hero text, app logo
/// Heading → Space Grotesk   Modern UI   — section headers, prices, buttons
/// Body    → Manrope         Readable    — descriptions, inputs, labels
class AppFonts {
  AppFonts._();

  // ─── Raw Font Accessors ──────────────────────────────────
  static TextStyle tanker({
    double fontSize = 24,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? letterSpacing,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        letterSpacing: letterSpacing,
      );

  static TextStyle spaceGrotesk({
    double fontSize = 16,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        letterSpacing: letterSpacing,
      );

  static TextStyle manrope({
    double fontSize = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textSecondary,
        height: height,
      );

  // ─── Display / Title Styles (Tanker) ─────────────────────
  static TextStyle get appLogo =>
      tanker(fontSize: 30, color: AppColors.light);

  static TextStyle get heroTitle =>
      tanker(fontSize: 42, color: AppColors.textPrimary);

  static TextStyle get eventTitle =>
      tanker(fontSize: 28, color: AppColors.textPrimary);

  static TextStyle get cardTitle =>
      tanker(fontSize: 22, color: AppColors.textPrimary);

  static TextStyle get sectionTitle =>
      tanker(fontSize: 18, color: AppColors.textPrimary);

  // ─── Heading Styles (Space Grotesk) ──────────────────────
  static TextStyle get headlineLarge =>
      spaceGrotesk(fontSize: 24, weight: FontWeight.w700);

  static TextStyle get headlineMedium =>
      spaceGrotesk(fontSize: 20, weight: FontWeight.w600);

  static TextStyle get headlineSmall =>
      spaceGrotesk(fontSize: 16, weight: FontWeight.w600);

  static TextStyle get labelLarge =>
      spaceGrotesk(fontSize: 14, weight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get labelMedium =>
      spaceGrotesk(fontSize: 13, weight: FontWeight.w500, color: AppColors.textPrimary);

  static TextStyle get labelSmall =>
      spaceGrotesk(fontSize: 11, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get priceText =>
      spaceGrotesk(fontSize: 20, weight: FontWeight.w700, color: AppColors.accent);

  static TextStyle get priceLarge =>
      spaceGrotesk(fontSize: 28, weight: FontWeight.w700, color: AppColors.accent);

  static TextStyle get buttonText =>
      spaceGrotesk(fontSize: 15, weight: FontWeight.w700, color: AppColors.dark);

  static TextStyle get tabLabel =>
      spaceGrotesk(fontSize: 12, weight: FontWeight.w600, color: AppColors.textSecondary);

  // ─── Body Styles (Manrope) ───────────────────────────────
  static TextStyle get bodyLarge =>
      manrope(fontSize: 16, color: AppColors.textPrimary, height: 1.6);

  static TextStyle get bodyMedium =>
      manrope(fontSize: 14, height: 1.6);

  static TextStyle get bodySmall =>
      manrope(fontSize: 13, height: 1.5);

  static TextStyle get caption =>
      manrope(fontSize: 11, color: AppColors.textHint);

  static TextStyle get inputText =>
      manrope(fontSize: 15, color: AppColors.textPrimary);

  static TextStyle get hintText =>
      manrope(fontSize: 14, color: AppColors.textHint);

  static TextStyle get badgeText =>
      manrope(fontSize: 10, weight: FontWeight.w700);
}
