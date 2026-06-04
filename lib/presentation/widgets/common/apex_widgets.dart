// lib/presentation/widgets/common/apex_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

// ── Gold Gradient Button ──────────────────────────────────
class GoldButton extends StatefulWidget {
  final String label; final VoidCallback? onTap;
  final bool isLoading, isFullWidth; final double height;
  final IconData? icon;
  const GoldButton({super.key, required this.label, this.onTap,
      this.isLoading=false, this.isFullWidth=true, this.height=52, this.icon});
  @override State<GoldButton> createState() => _GoldButtonState();
}
class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double>   _s;
  @override void initState() { super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _s = Tween(begin:1.0, end:0.96).animate(CurvedAnimation(parent:_c, curve:Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:(_)=>_c.forward(), onTapCancel:()=>_c.reverse(),
    onTapUp:(_){ _c.reverse(); widget.onTap?.call(); },
    child: ScaleTransition(scale: _s, child: Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 18, offset: const Offset(0,5))],
      ),
      child: widget.isLoading
        ? const Center(child: SizedBox(width:20, height:20,
            child: CircularProgressIndicator(color: AppColors.obsidian, strokeWidth: 2.5)))
        : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: AppColors.obsidian, size: 18), const SizedBox(width:8)],
            Text(widget.label.toUpperCase(), style: const TextStyle(
              fontFamily:'Outfit', fontSize:14, fontWeight:FontWeight.w700,
              color:AppColors.obsidian, letterSpacing:1.5)),
          ]),
    )),
  );
}

// ── Outlined Gold Button ──────────────────────────────────
class GoldOutlinedButton extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  final double height; final IconData? icon;
  const GoldOutlinedButton({super.key, required this.label,
      this.onTap, this.height=52, this.icon});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldRoyal, width: 1.5),
        color: AppColors.goldGlow,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[Icon(icon, color: AppColors.goldRoyal, size:18), const SizedBox(width:8)],
        Text(label.toUpperCase(), style: const TextStyle(
          fontFamily:'Outfit', fontSize:14, fontWeight:FontWeight.w700,
          color:AppColors.goldRoyal, letterSpacing:1.5)),
      ]),
    ),
  );
}

// ── Glass Card ────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child; final EdgeInsetsGeometry? padding;
  final double borderRadius; final Color? borderColor;
  const GlassCard({super.key, required this.child, this.padding,
      this.borderRadius=16, this.borderColor});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColors.borderDark),
        ),
        child: child,
      ),
    ),
  );
}

// ── Score Ring ────────────────────────────────────────────
class ScoreRing extends StatelessWidget {
  final double score; final String label; final Color color; final double size;
  const ScoreRing({super.key, required this.score, required this.label,
      required this.color, this.size=80});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [
      SizedBox(width: size, height: size, child: CircularProgressIndicator(
        value: (score/100).clamp(0.0, 1.0), strokeWidth: 5,
        backgroundColor: AppColors.borderDark,
        valueColor: AlwaysStoppedAnimation(color), strokeCap: StrokeCap.round,
      )),
      Text('${score.toInt()}', style: TextStyle(
        fontFamily:'Outfit', fontSize: size*0.26,
        fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    ])),
    const SizedBox(height: 5),
    Text(label, style: const TextStyle(fontFamily:'Outfit', fontSize:10,
        fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing:0.8)),
  ]);
}

// ── Section Header ────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title; final String? sub; final Widget? action;
  const SectionHeader({super.key, required this.title, this.sub, this.action});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontFamily:'Outfit', fontSize:17,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      if (sub != null) ...[const SizedBox(height:2),
        Text(sub!, style: const TextStyle(fontFamily:'Outfit', fontSize:11, color:AppColors.textMuted))],
    ])),
    if (action != null) action!,
  ]);
}

// ── Gold Text ─────────────────────────────────────────────
class GoldText extends StatelessWidget {
  final String text; final TextStyle style;
  const GoldText(this.text, {super.key, required this.style});
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (b) => AppColors.goldGradient.createShader(b),
    child: Text(text, style: style),
  );
}

// ── Pulse Dot ─────────────────────────────────────────────
class PulseDot extends StatelessWidget {
  final Color color; final double size;
  const PulseDot({super.key, this.color=AppColors.errorRed, this.size=8});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius:6, spreadRadius:2)]),
  ).animate(onPlay:(c)=>c.repeat())
   .scale(begin:const Offset(1,1), end:const Offset(1.5,1.5), duration:800.ms, curve:Curves.easeInOut)
   .then().scale(begin:const Offset(1.5,1.5), end:const Offset(1,1), duration:800.ms, curve:Curves.easeInOut);
}

// ── Apex Field ────────────────────────────────────────────
class ApexField extends StatelessWidget {
  final TextEditingController controller; final String label, hint;
  final IconData icon; final bool obscure; final Widget? suffix;
  final TextInputType? keyboardType; final String? Function(String?)? validator;
  const ApexField({super.key, required this.controller, required this.label,
      required this.hint, required this.icon, this.obscure=false,
      this.suffix, this.keyboardType, this.validator});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily:'Outfit', fontSize:12,
        fontWeight:FontWeight.w500, color:AppColors.textSecondary, letterSpacing:0.4)),
    const SizedBox(height:6),
    TextFormField(
      controller: controller, obscureText: obscure,
      keyboardType: keyboardType, validator: validator,
      style: const TextStyle(fontFamily:'Outfit', fontSize:15, color:AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color:AppColors.textMuted, size:18),
        suffixIcon: suffix,
      ),
    ),
  ]);
}

// ── Grade Badge ───────────────────────────────────────────
class GradeBadge extends StatelessWidget {
  final String grade; final double size;
  const GradeBadge({super.key, required this.grade, this.size=44});
  Color get _color => switch(grade) {
    'S+' => AppColors.goldBright,
    'A'  => AppColors.matrixGreen,
    'B'  => AppColors.accentBlue,
    'C'  => AppColors.amberWarning,
    _    => AppColors.errorRed,
  };
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle,
      color: _color.withOpacity(0.12),
      border: Border.all(color: _color.withOpacity(0.5), width: 1.5)),
    child: Center(child: Text(grade, style: TextStyle(
      fontFamily:'Outfit', fontSize: size*0.3,
      fontWeight: FontWeight.w800, color: _color))),
  );
}
