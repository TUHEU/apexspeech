// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color obsidian       = Color(0xFF080810);
  static const Color surfaceDark    = Color(0xFF111118);
  static const Color cardDark       = Color(0xFF181820);
  static const Color borderDark     = Color(0xFF252530);
  static const Color goldBright     = Color(0xFFFFD700);
  static const Color goldRoyal      = Color(0xFFD4AF37);
  static const Color goldMuted      = Color(0xFFA8892A);
  static const Color goldDim        = Color(0xFF2A1E00);
  static const Color goldGlow       = Color(0x40D4AF37);
  static const Color matrixGreen    = Color(0xFF00FF41);
  static const Color greenSoft      = Color(0xFF00C853);
  static const Color greenGlow      = Color(0x3000FF41);
  static const Color amberWarning   = Color(0xFFFFBF00);
  static const Color amberGlow      = Color(0x40FFBF00);
  static const Color errorRed       = Color(0xFFFF1744);
  static const Color errorGlow      = Color(0x40FF1744);
  static const Color accentBlue     = Color(0xFF2979FF);
  static const Color accentBlueGlow = Color(0x402979FF);
  static const Color textPrimary    = Color(0xFFF0F0F5);
  static const Color textSecondary  = Color(0xFFAAAAAF);
  static const Color textMuted      = Color(0xFF606068);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldBright, goldRoyal, goldMuted],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E28), Color(0xFF14141C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1200), obsidian],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
