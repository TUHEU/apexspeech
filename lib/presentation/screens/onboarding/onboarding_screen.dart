// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page   = 0;
  static const _pages = [
    (Icons.visibility_outlined,   AppColors.accentBlue,   'AI Eyes\nOn Your Posture',
     'Real-time computer vision tracks your body language and gestures using your camera.',
     'COMPUTER VISION'),
    (Icons.graphic_eq,            AppColors.goldRoyal,    'Your Voice,\nAnalyzed Live',
     'Filler words flagged instantly. Confidence, enthusiasm and authority scored in real-time.',
     'VOCAL AI'),
    (Icons.auto_awesome,          AppColors.matrixGreen,  'Apex-Level\nScript Refinement',
     'Type your ideas. GPT-4o rewrites them with executive precision — sharper hooks, zero jargon.',
     'GPT-4o POWERED'),
  ];
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: Column(children: [
      SafeArea(child: Align(alignment: Alignment.topRight,
        child: TextButton(onPressed:()=>context.go(AppRouter.login),
          child: const Text('SKIP', style: TextStyle(fontFamily:'Outfit',
              fontSize:11, color:AppColors.textMuted, letterSpacing:1.5))))),
      Expanded(child: PageView.builder(
        controller: _ctrl,
        onPageChanged: (i) => setState(() => _page = i),
        itemCount: _pages.length,
        itemBuilder: (ctx, i) {
          final (icon, color, title, sub, tag) = _pages[i];
          return Padding(padding: const EdgeInsets.symmetric(horizontal:32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width:110, height:110,
                decoration: BoxDecoration(shape:BoxShape.circle,
                  color: color.withOpacity(0.08),
                  border: Border.all(color:color.withOpacity(0.3), width:1.5),
                  boxShadow:[BoxShadow(color:color.withOpacity(0.18), blurRadius:36, spreadRadius:8)]),
                child: Icon(icon, color:color, size:48),
              ).animate().scale(begin:const Offset(0.7,0.7), duration:600.ms, curve:Curves.elasticOut),
              const SizedBox(height:28),
              Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:4),
                decoration: BoxDecoration(color:color.withOpacity(0.1),
                  borderRadius:BorderRadius.circular(20),
                  border:Border.all(color:color.withOpacity(0.4))),
                child: Text(tag, style: TextStyle(fontFamily:'Outfit', fontSize:10,
                    fontWeight:FontWeight.w600, color:color, letterSpacing:2)),
              ).animate().fadeIn(delay:200.ms),
              const SizedBox(height:18),
              Text(title, textAlign:TextAlign.center, style: const TextStyle(
                fontFamily:'Outfit', fontSize:28, fontWeight:FontWeight.w800,
                color:AppColors.textPrimary, height:1.25),
              ).animate().fadeIn(delay:300.ms).slideY(begin:0.1, end:0, delay:300.ms),
              const SizedBox(height:14),
              Text(sub, textAlign:TextAlign.center, style: const TextStyle(
                fontFamily:'Outfit', fontSize:14, color:AppColors.textSecondary, height:1.6),
              ).animate().fadeIn(delay:400.ms),
            ]));
        },
      )),
      Padding(padding: const EdgeInsets.fromLTRB(24,0,24,40), child: Column(children: [
        SmoothPageIndicator(controller:_ctrl, count:3,
          effect: ExpandingDotsEffect(dotColor:AppColors.borderDark,
            activeDotColor:AppColors.goldRoyal, dotHeight:6, dotWidth:6, expansionFactor:4)),
        const SizedBox(height:28),
        GoldButton(
          label: _page==2 ? 'Get Started' : 'Next',
          icon:  _page==2 ? Icons.rocket_launch_rounded : null,
          onTap: () {
            if (_page < 2) _ctrl.nextPage(duration:const Duration(milliseconds:400), curve:Curves.easeOutCubic);
            else context.go(AppRouter.login);
          },
        ),
      ])),
    ]),
  );
}
