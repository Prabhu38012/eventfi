import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ─── Color Scheme ────────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      primary:        AppColors.accent,
      onPrimary:      AppColors.dark,
      secondary:      AppColors.accent,
      onSecondary:    AppColors.dark,
      surface:        AppColors.surface1,
      onSurface:      AppColors.textPrimary,
      error:          AppColors.error,
      onError:        AppColors.light,
    ),

    scaffoldBackgroundColor: AppColors.dark,
    primaryColor: AppColors.accent,

    // ─── Text Theme (Manrope as base) ────────────────────────
    textTheme: GoogleFonts.manropeTextTheme(
      const TextTheme(
        displayLarge:   TextStyle(color: AppColors.textPrimary),
        displayMedium:  TextStyle(color: AppColors.textPrimary),
        displaySmall:   TextStyle(color: AppColors.textPrimary),
        headlineLarge:  TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall:  TextStyle(color: AppColors.textPrimary),
        titleLarge:     TextStyle(color: AppColors.textPrimary),
        titleMedium:    TextStyle(color: AppColors.textPrimary),
        titleSmall:     TextStyle(color: AppColors.textSecondary),
        bodyLarge:      TextStyle(color: AppColors.textPrimary),
        bodyMedium:     TextStyle(color: AppColors.textSecondary),
        bodySmall:      TextStyle(color: AppColors.textHint),
        labelLarge:     TextStyle(color: AppColors.textPrimary),
        labelMedium:    TextStyle(color: AppColors.textSecondary),
        labelSmall:     TextStyle(color: AppColors.textHint),
      ),
    ),

    // ─── AppBar ──────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor:     AppColors.dark,
      foregroundColor:     AppColors.light,
      elevation:           0,
      centerTitle:         false,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
      ),
      titleTextStyle: AppFonts.appLogo.copyWith(fontSize: 22),
      iconTheme: const IconThemeData(color: AppColors.light, size: 22),
    ),

    // ─── ElevatedButton (Primary — Ember Orange) ─────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.dark,
        minimumSize:     const Size(double.infinity, AppSizes.buttonHeight),
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: AppFonts.buttonText,
        elevation: 0,
      ),
    ),

    // ─── OutlinedButton ──────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize:     const Size(double.infinity, AppSizes.buttonHeight),
        side:            const BorderSide(color: AppColors.accent, width: 1.5),
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: AppFonts.buttonText.copyWith(color: AppColors.accent),
      ),
    ),

    // ─── TextButton ──────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle:       AppFonts.labelLarge,
      ),
    ),

    // ─── Input Decoration ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     AppColors.surface3,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      hintStyle:  AppFonts.hintText,
      labelStyle: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // ─── Card ────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color:     AppColors.surface1,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      margin: const EdgeInsets.only(bottom: AppSizes.md),
    ),

    // ─── Bottom Navigation Bar ───────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.surface1,
      selectedItemColor:   AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      elevation:           0,
      type:                BottomNavigationBarType.fixed,
      selectedLabelStyle:  TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),

    // ─── Bottom Sheet ────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface1,
      shape:           RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
    ),

    // ─── Chip ────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor:    AppColors.surface2,
      selectedColor:      AppColors.accent,
      labelStyle:         AppFonts.labelSmall,
      side:               BorderSide.none,
      shape:              RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    ),

    // ─── Divider ─────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color:     AppColors.divider,
      thickness: 1,
      space:     1,
    ),

    // ─── Icon ────────────────────────────────────────────────
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size:  22,
    ),

    // ─── Snackbar ────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface2,
      contentTextStyle: AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    ),

    // ─── Progress Indicator ──────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),

    // ─── Switch ──────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent.withOpacity(0.3)
            : AppColors.surface3,
      ),
    ),
  );
}
