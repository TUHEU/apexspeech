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

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardData(
      icon: Icons.visibility_outlined,
      iconColor: AppColors.accentBlueBright,
      title: 'AI Eyes\nOn Your Posture',
      subtitle: 'Real-time computer vision tracks your body language, gestures, and posture using your phone camera.',
      tag: 'COMPUTER VISION',
      tagColor: AppColors.accentBlueBright,
    ),
    _OnboardData(
      icon: Icons.graphic_eq,
      iconColor: AppColors.goldRoyal,
      title: 'Your Voice,\nAnalyzed Live',
      subtitle: 'AI listens as you speak. Filler words get flagged instantly. Your confidence, enthusiasm, and authority are scored in real-time.',
      tag: 'VOCAL AI',
      tagColor: AppColors.goldRoyal,
    ),
    _OnboardData(
      icon: Icons.auto_awesome,
      iconColor: AppColors.matrixGreen,
      title: 'Apex-Level\nScript Refinement',
      subtitle: 'Type your raw ideas. GPT-4o rewrites them with executive precision — sharper hooks, stronger impact, zero jargon.',
      tag: 'GPT-4o POWERED',
      tagColor: AppColors.matrixGreen,
    ),
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D0D14), AppColors.obsidian],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Skip button
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => context.go(AppRouter.login),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (ctx, i) => _OnboardPage(data: _pages[i]),
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageCtrl,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotColor: AppColors.borderDark,
                        activeDotColor: AppColors.goldRoyal,
                        dotHeight: 6,
                        dotWidth: 6,
                        expansionFactor: 4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GoldButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started' : 'Next',
                      onTap: _next,
                      prefixIcon: _currentPage == _pages.length - 1
                          ? Icons.rocket_launch_rounded : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;

  const _OnboardData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withOpacity(0.08),
              border: Border.all(color: data.iconColor.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(data.icon, color: data.iconColor, size: 52),
          ).animate().scale(
            begin: const Offset(0.7, 0.7),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 32),

          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: data.tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: data.tagColor.withOpacity(0.4)),
            ),
            child: Text(
              data.tag,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: data.tagColor,
                letterSpacing: 2,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0, delay: 300.ms),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
