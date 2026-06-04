// lib/presentation/screens/splash/splash_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rot;
  @override void initState() { super.initState();
    _rot = AnimationController(vsync:this, duration:const Duration(seconds:10))..repeat();
    Future.delayed(const Duration(milliseconds:2800), () async {
      if (!mounted) return;
      final loggedIn = await AuthRepository().isLoggedIn();
      if (!mounted) return;
      context.go(loggedIn ? AppRouter.dashboard : AppRouter.onboarding);
    });
  }
  @override void dispose() { _rot.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.center, radius: 0.65,
        colors: [Color(0xFF1A1400), AppColors.obsidian]))),
      Center(child: AnimatedBuilder(animation: _rot, builder:(_, __) => Stack(
        alignment: Alignment.center,
        children: List.generate(4, (i) => Transform.rotate(
          angle: _rot.value*2*pi*(i.isEven?1:-1),
          child: Container(width:100+i*70.0, height:100+i*70.0,
            decoration: BoxDecoration(shape:BoxShape.circle,
              border: Border.all(color: AppColors.goldRoyal.withOpacity(0.04+i*0.02)))),
        )),
      ))),
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width:72, height:72,
          decoration: BoxDecoration(shape:BoxShape.circle, color:AppColors.goldDim,
            border: Border.all(color:AppColors.goldRoyal, width:1.5),
            boxShadow:[BoxShadow(color:AppColors.goldGlow, blurRadius:28)]),
          child: const Icon(Icons.mic_rounded, color:AppColors.goldRoyal, size:34),
        ).animate().scale(begin:const Offset(0,0), duration:600.ms, curve:Curves.elasticOut),
        const SizedBox(height:22),
        ShaderMask(shaderCallback:(b)=>AppColors.goldGradient.createShader(b),
          blendMode:BlendMode.srcIn,
          child: const Text('APEX SPEECH', style: TextStyle(
            fontFamily:'Outfit', fontSize:32, fontWeight:FontWeight.w900, letterSpacing:5))),
        const SizedBox(height:6),
        Text('COMMAND EVERY ROOM', style: const TextStyle(
          fontFamily:'Outfit', fontSize:11, color:AppColors.textMuted, letterSpacing:4)),
        const SizedBox(height:50),
        Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
          Container(width:6, height:6, margin:const EdgeInsets.symmetric(horizontal:3),
            decoration:const BoxDecoration(shape:BoxShape.circle, color:AppColors.goldMuted),
          ).animate(onPlay:(c)=>c.repeat())
           .fadeIn(delay:Duration(milliseconds:900+i*180), duration:350.ms)
           .then().fadeOut(duration:350.ms)
        )),
      ])),
    ]),
  );
}
