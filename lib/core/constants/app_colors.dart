// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Core Palette ──────────────────────────────────────
  static const Color obsidian      = Color(0xFF080810);
  static const Color deepBlack     = Color(0xFF0A0A0F);
  static const Color surfaceDark   = Color(0xFF111118);
  static const Color cardDark      = Color(0xFF181820);
  static const Color borderDark    = Color(0xFF252530);

  // ── Gold Spectrum ─────────────────────────────────────
  static const Color goldBright    = Color(0xFFFFD700);
  static const Color goldRoyal     = Color(0xFFD4AF37);
  static const Color goldMuted     = Color(0xFFA8892A);
  static const Color goldDim       = Color(0xFF5C4B15);
  static const Color goldGlow      = Color(0x40D4AF37);
  static const Color goldGlowBright= Color(0x80FFD700);

  // ── Feedback Colors ───────────────────────────────────
  static const Color matrixGreen   = Color(0xFF00FF41);
  static const Color greenSoft     = Color(0xFF00C853);
  static const Color greenGlow     = Color(0x4000FF41);

  static const Color amberWarning  = Color(0xFFFFBF00);
  static const Color amberSoft     = Color(0xFFFF8F00);
  static const Color amberGlow     = Color(0x40FFBF00);

  static const Color errorRed      = Color(0xFFFF1744);
  static const Color errorGlow     = Color(0x40FF1744);

  // ── Accent Blue ────────────────────────────────────────
  static const Color accentBlue    = Color(0xFF1A3C6E);
  static const Color accentBlueBright = Color(0xFF2979FF);
  static const Color accentBlueGlow = Color(0x402979FF);

  // ── Energy Colors (Vibe Meter) ────────────────────────
  static const Color vibeCalm      = Color(0xFF1565C0);   // deep blue
  static const Color vibeFocus     = Color(0xFF6200EA);   // violet
  static const Color vibeEnergized = Color(0xFFFF6D00);   // orange
  static const Color vibeApex      = Color(0xFFFFD700);   // gold

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFAAAAAF);
  static const Color textMuted     = Color(0xFF606068);
  static const Color textGold      = Color(0xFFD4AF37);

  // ── Gradients ─────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldBright, goldRoyal, goldMuted],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradientVertical = LinearGradient(
    colors: [goldBright, goldRoyal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [obsidian, surfaceDark, cardDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E28), Color(0xFF14141C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFFD600)],
  );

  static const RadialGradient goldRadial = RadialGradient(
    colors: [goldGlowBright, Colors.transparent],
    radius: 0.8,
  );
}
