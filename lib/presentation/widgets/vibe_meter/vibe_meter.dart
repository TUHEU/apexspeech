// lib/presentation/widgets/vibe_meter/vibe_meter.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class VibeMeter extends StatefulWidget {
  final double confidence, enthusiasm;
  final bool isActive; final double size;
  const VibeMeter({super.key, required this.confidence, required this.enthusiasm,
      this.isActive=false, this.size=180});
  @override State<VibeMeter> createState() => _VibeMeterState();
}
class _VibeMeterState extends State<VibeMeter> with TickerProviderStateMixin {
  late AnimationController _rot, _pulse;
  late Animation<double> _pulseAnim;
  @override void initState() { super.initState();
    _rot   = AnimationController(vsync:this, duration:const Duration(seconds:9))..repeat();
    _pulse = AnimationController(vsync:this, duration:const Duration(milliseconds:1400))..repeat(reverse:true);
    _pulseAnim = Tween(begin:0.96, end:1.04).animate(CurvedAnimation(parent:_pulse, curve:Curves.easeInOut));
  }
  @override void dispose() { _rot.dispose(); _pulse.dispose(); super.dispose(); }

  Color get _color {
    final e = (widget.confidence + widget.enthusiasm) / 2;
    if (e < 30) return AppColors.accentBlue;
    if (e < 55) return const Color(0xFF6200EA);
    if (e < 80) return const Color(0xFFFF6D00);
    return AppColors.goldBright;
  }

  String get _label {
    final e = (widget.confidence + widget.enthusiasm) / 2;
    if (e < 30) return '😶 Calm';
    if (e < 55) return '🎯 Focused';
    if (e < 80) return '🔥 Energized';
    return '⚡ APEX';
  }

  @override
  Widget build(BuildContext context) {
    final score = (widget.confidence + widget.enthusiasm) / 2;
    final color = _color;
    return SizedBox(width: widget.size, height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rot, _pulse]),
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          if (widget.isActive) ...[
            _ring(widget.size, color, 0.06, _pulseAnim.value * 1.16),
            _ring(widget.size, color, 0.11, _pulseAnim.value * 1.07),
          ],
          Transform.rotate(angle: _rot.value * 2 * pi,
            child: CustomPaint(size: Size(widget.size, widget.size),
              painter: _ArcDashPainter(score/100, color, widget.isActive))),
          SizedBox(width: widget.size*0.78, height: widget.size*0.78,
            child: CircularProgressIndicator(
              value: (score/100).clamp(0.0,1.0), strokeWidth: 5.5,
              backgroundColor: AppColors.borderDark,
              valueColor: AlwaysStoppedAnimation(color), strokeCap: StrokeCap.round,
            )),
          Transform.scale(scale: widget.isActive ? _pulseAnim.value : 1.0,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:2),
                decoration: BoxDecoration(color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.4))),
                child: Text(_label, style: TextStyle(fontFamily:'Outfit',
                    fontSize: widget.size*0.062, fontWeight:FontWeight.w600, color:color))),
              Text('${score.toInt()}%', style: TextStyle(fontFamily:'Outfit',
                  fontSize: widget.size*0.165, fontWeight:FontWeight.w800,
                  color:AppColors.textPrimary)),
              Text('ENERGY', style: TextStyle(fontFamily:'Outfit',
                  fontSize: widget.size*0.062, color:AppColors.textMuted, letterSpacing:1.5)),
            ]),
          ),
        ]),
      ),
    );
  }
  Widget _ring(double s, Color c, double opacity, double scale) =>
    Transform.scale(scale: scale, child: Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: c.withOpacity(opacity)),
        boxShadow: [BoxShadow(color: c.withOpacity(opacity*0.4), blurRadius:18, spreadRadius:4)])));
}

class _ArcDashPainter extends CustomPainter {
  final double score; final Color color; final bool active;
  const _ArcDashPainter(this.score, this.color, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final center = Offset(size.width/2, size.height/2);
    final r      = size.width/2;
    final paint  = Paint()..color=color.withOpacity(0.22)..strokeWidth=1.5
                            ..style=PaintingStyle.stroke..strokeCap=StrokeCap.round;
    for (int i=0; i<36; i++) {
      if (i%3==0) continue;
      final a = (i/36)*2*pi - pi/2;
      canvas.drawLine(
        Offset(center.dx+(r*0.87)*cos(a), center.dy+(r*0.87)*sin(a)),
        Offset(center.dx+(r*0.95)*cos(a), center.dy+(r*0.95)*sin(a)), paint);
    }
    if (score > 0) {
      canvas.drawArc(Rect.fromCircle(center:center, radius:r*0.78),
        -pi/2, score*2*pi, false,
        Paint()..color=color.withOpacity(0.12)..strokeWidth=16
                ..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    }
  }
  @override bool shouldRepaint(_ArcDashPainter o) => o.score!=score||o.color!=color;
}
