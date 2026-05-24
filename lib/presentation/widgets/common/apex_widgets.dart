// lib/presentation/widgets/common/apex_widgets.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final double blurSigma;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.borderColor,
    this.blurSigma = 12,
    this.opacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.borderDark,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOLD GRADIENT BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class GoldButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final IconData? prefixIcon;

  const GoldButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52,
    this.prefixIcon,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldGlow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.obsidian, strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, color: AppColors.obsidian, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.obsidian,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OUTLINED GOLD BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class GoldOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final IconData? prefixIcon;

  const GoldOutlinedButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 52,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldRoyal, width: 1.5),
          color: AppColors.goldGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, color: AppColors.goldRoyal, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.goldRoyal,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE RING WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class ScoreRing extends StatelessWidget {
  final double score;
  final String label;
  final Color color;
  final double size;

  const ScoreRing({
    super.key,
    required this.score,
    required this.label,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  backgroundColor: AppColors.borderDark,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${score.toInt()}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APEX SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class ApexSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const ApexSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT TEXT
// ─────────────────────────────────────────────────────────────────────────────
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppColors.goldGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PULSE DOT (live indicator)
// ─────────────────────────────────────────────────────────────────────────────
class PulseDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulseDot({
    super.key,
    this.color = AppColors.errorRed,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.6), blurRadius: 6, spreadRadius: 2),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat())
      .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4),
             duration: 800.ms, curve: Curves.easeInOut)
      .then()
      .scale(begin: const Offset(1.4, 1.4), end: const Offset(1, 1),
             duration: 800.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APEX CHIP
// ─────────────────────────────────────────────────────────────────────────────
class ApexChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;

  const ApexChip({
    super.key,
    required this.label,
    this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.goldRoyal;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.15) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? c : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
