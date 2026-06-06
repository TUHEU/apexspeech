import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color obsidian      = Color(0xFF080810);
  static const Color surfaceDark   = Color(0xFF111118);
  static const Color cardDark      = Color(0xFF181820);
  static const Color borderDark    = Color(0xFF252530);
  static const Color goldBright    = Color(0xFFFFD700);
  static const Color goldRoyal     = Color(0xFFD4AF37);
  static const Color goldMuted     = Color(0xFFA8892A);
  static const Color goldDim       = Color(0xFF2A1E00);
  static const Color goldGlow      = Color(0x40D4AF37);
  static const Color matrixGreen   = Color(0xFF00FF41);
  static const Color amberWarning  = Color(0xFFFFBF00);
  static const Color errorRed      = Color(0xFFFF1744);
  static const Color accentBlue    = Color(0xFF2979FF);
  static const Color textPrimary   = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFAAAAAF);
  static const Color textMuted     = Color(0xFF606068);
  static const Color purple        = Color(0xFF9C27B0);
  static const Color purpleLight   = Color(0xFFCE93D8);
  static const Color purpleDark    = Color(0xFF4A148C);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldBright, goldRoyal, goldMuted],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9E8AC0), Color(0xFFB88AC8)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
