// lib/presentation/screens/splash/splash_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _expandCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 10),
    )..repeat();

    _expandCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      _expandCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) context.go(AppRouter.onboarding);
    });
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // Background radial gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.7,
                  colors: [
                    Color(0xFF1A1400),
                    AppColors.obsidian,
                  ],
                ),
              ),
            ),
          ),

          // Rotating decorative rings
          Center(
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: List.generate(4, (i) {
                  final size = 120.0 + i * 70;
                  final opacity = 0.04 + i * 0.02;
                  return Transform.rotate(
                    angle: _rotateCtrl.value * 2 * pi * (i.isEven ? 1 : -1),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldRoyal.withOpacity(opacity),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF3A2E00), Color(0xFF1A1400)],
                    ),
                    border: Border.all(color: AppColors.goldRoyal, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldGlow,
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: AppColors.goldRoyal,
                    size: 36,
                  ),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  delay: 200.ms,
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 24),

                // App name
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    'APEX SPEECH',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 800.ms,
                          curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text(
                  'COMMAND EVERY ROOM',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 60),

                // Loading dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) =>
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.goldMuted,
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                      .fadeIn(delay: Duration(milliseconds: 1000 + i * 200), duration: 400.ms)
                      .then().fadeOut(duration: 400.ms)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
