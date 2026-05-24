// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidian,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldRoyal,
        onPrimary: AppColors.obsidian,
        secondary: AppColors.accentBlueBright,
        onSecondary: Colors.white,
        surface: AppColors.cardDark,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorRed,
        outline: AppColors.borderDark,
      ),

      // ── Typography ──────────────────────────────────────
      textTheme: TextTheme(
        // Display — Cinzel for epic/executive headers
        displayLarge: GoogleFonts.cinzel(
          fontSize: 57, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: 4,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 45, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: 3,
        ),
        displaySmall: GoogleFonts.cinzel(
          fontSize: 36, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: 2,
        ),
        // Headline — Outfit for clean modern headings
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Title
        titleLarge: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary, letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary, letterSpacing: 0.1,
        ),
        // Body
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        // Label
        labelLarge: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: 1.5,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary, letterSpacing: 1.2,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textMuted, letterSpacing: 1.0,
        ),
      ),

      // ── AppBar ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.goldRoyal, letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldRoyal),
      ),

      // ── Cards ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ── Input Fields ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        hintStyle: GoogleFonts.outfit(
          color: AppColors.textMuted, fontSize: 14,
        ),
        labelStyle: GoogleFonts.outfit(
          color: AppColors.textSecondary, fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.goldRoyal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Elevated Button ─────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldRoyal,
          foregroundColor: AppColors.obsidian,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldRoyal,
          textStyle: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Divider ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ─────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // ── Bottom Nav ───────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.goldRoyal,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Chip ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        labelStyle: GoogleFonts.outfit(
          fontSize: 12, color: AppColors.textSecondary,
        ),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
