import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../helpers/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override void dispose() { _rotCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.center, radius: 0.7,
        colors: [Color(0xFF1A0A2E), AppColors.obsidian]))),
      Center(child: AnimatedBuilder(animation: _rotCtrl, builder: (_, __) =>
        Stack(alignment: Alignment.center, children: [
          ...List.generate(4, (i) => Transform.rotate(
            angle: _rotCtrl.value * 2 * pi * (i.isEven ? 1 : -1),
            child: Container(
              width: 80 + i * 60.0, height: 80 + i * 60.0,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: AppColors.purpleLight.withOpacity(0.04 + i * 0.03))),
            ),
          )),
        ]),
      )),
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: AppColors.purpleDark.withOpacity(0.4),
            border: Border.all(color: AppColors.purpleLight, width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.purpleLight.withOpacity(0.4), blurRadius: 28)]),
          child: const Icon(Icons.record_voice_over, color: AppColors.purpleLight, size: 38),
        ).animate().scale(begin: const Offset(0, 0), duration: 700.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        ShaderMask(shaderCallback: (b) => AppColors.purpleGradient.createShader(b),
          blendMode: BlendMode.srcIn,
          child: const Text('APEX SPEECH', style: TextStyle(
            fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 4))),
        const SizedBox(height: 6),
        const Text('IMPROVE YOUR SPEAKING CONFIDENCE', style: TextStyle(
          fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted, letterSpacing: 3)),
        const SizedBox(height: 50),
        const CircularProgressIndicator(color: AppColors.purpleLight, strokeWidth: 2),
      ])),
    ]),
  );
}
