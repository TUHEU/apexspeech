// lib/presentation/widgets/vibe_meter/vibe_meter.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class VibeMeter extends StatefulWidget {
  final double confidenceScore;   // 0-100
  final double enthusiasmScore;   // 0-100
  final bool isActive;
  final double size;

  const VibeMeter({
    super.key,
    required this.confidenceScore,
    required this.enthusiasmScore,
    this.isActive = false,
    this.size = 200,
  });

  @override
  State<VibeMeter> createState() => _VibeMeterState();
}

class _VibeMeterState extends State<VibeMeter>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  Color get _vibeColor {
    final energy = (widget.confidenceScore + widget.enthusiasmScore) / 2;
    if (energy < 30) return AppColors.vibeCalm;
    if (energy < 55) return AppColors.vibeFocus;
    if (energy < 80) return AppColors.vibeEnergized;
    return AppColors.vibeApex;
  }

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = (widget.confidenceScore + widget.enthusiasmScore) / 2;
    final color = _vibeColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotateCtrl, _pulseCtrl]),
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings
            if (widget.isActive) ...[
              _GlowRing(
                size: widget.size,
                color: color,
                opacity: 0.08,
                scale: _pulseAnim.value * 1.15,
              ),
              _GlowRing(
                size: widget.size,
                color: color,
                opacity: 0.12,
                scale: _pulseAnim.value * 1.06,
              ),
            ],

            // Rotating arcs background
            Transform.rotate(
              angle: _rotateCtrl.value * 2 * pi,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _VibeMeterArcPainter(
                  score: score / 100,
                  color: color,
                  isActive: widget.isActive,
                ),
              ),
            ),

            // Static progress ring
            SizedBox(
              width: widget.size * 0.78,
              height: widget.size * 0.78,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 6,
                backgroundColor: AppColors.borderDark,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Inner content
            Transform.scale(
              scale: widget.isActive ? _pulseAnim.value : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildVibeLabel(score, color),
                  const SizedBox(height: 4),
                  Text(
                    '${score.toInt()}%',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: widget.size * 0.16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ENERGY',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: widget.size * 0.065,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibeLabel(double score, Color color) {
    String label;
    if (score < 30) label = '😶 Calm';
    else if (score < 55) label = '🎯 Focused';
    else if (score < 80) label = '🔥 Energized';
    else label = '⚡ APEX';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: widget.size * 0.06,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double scale;

  const _GlowRing({
    required this.size,
    required this.color,
    required this.opacity,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity * 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class _VibeMeterArcPainter extends CustomPainter {
  final double score;
  final Color color;
  final bool isActive;

  const _VibeMeterArcPainter({
    required this.score,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (!isActive) return;

    // Draw decorative dashes around the outer ring
    final dashPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final int dashCount = 36;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * 2 * pi - pi / 2;
      final shouldShow = i % 3 != 0;
      if (!shouldShow) continue;
      final innerR = radius * 0.88;
      final outerR = radius * 0.95;
      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
        Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle)),
        dashPaint,
      );
    }

    // Draw active arc glow
    if (score > 0) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.78),
        -pi / 2,
        score * 2 * pi,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_VibeMeterArcPainter old) =>
    old.score != score || old.color != color || old.isActive != isActive;
}
