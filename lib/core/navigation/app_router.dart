// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/script_editor/script_editor_screen.dart';
import '../../presentation/screens/live_practice/live_practice_screen.dart';
import '../../presentation/screens/post_game/post_game_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash       = '/';
  static const String onboarding   = '/onboarding';
  static const String login        = '/login';
  static const String register     = '/register';
  static const String dashboard    = '/dashboard';
  static const String scriptEditor = '/script-editor';
  static const String livePractice = '/live-practice';
  static const String postGame     = '/post-game';
  static const String profile      = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (ctx, state) => _fade(const SplashScreen(), state),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (ctx, state) => _slide(const OnboardingScreen(), state),
      ),
      GoRoute(
        path: login,
        pageBuilder: (ctx, state) => _fade(const LoginScreen(), state),
      ),
      GoRoute(
        path: register,
        pageBuilder: (ctx, state) => _slide(const RegisterScreen(), state),
      ),
      GoRoute(
        path: dashboard,
        pageBuilder: (ctx, state) => _fade(const DashboardScreen(), state),
      ),
      GoRoute(
        path: scriptEditor,
        pageBuilder: (ctx, state) => _slide(
          ScriptEditorScreen(scriptId: state.extra as String?), state,
        ),
      ),
      GoRoute(
        path: livePractice,
        pageBuilder: (ctx, state) => _scale(
          LivePracticeScreen(sessionData: state.extra as Map<String, dynamic>?), state,
        ),
      ),
      GoRoute(
        path: postGame,
        pageBuilder: (ctx, state) => _slide(
          PostGameScreen(sessionId: state.extra as String), state,
        ),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (ctx, state) => _slide(const ProfileScreen(), state),
      ),
    ],
  );

  static CustomTransitionPage _fade(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (ctx, anim, _, child) =>
        FadeTransition(opacity: anim, child: child),
    );

  static CustomTransitionPage _slide(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (ctx, anim, _, child) =>
        SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
    );

  static CustomTransitionPage _scale(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (ctx, anim, _, child) =>
        ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        ),
    );
}
