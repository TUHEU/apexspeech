// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/script_editor/script_editor_screen.dart';
import '../../presentation/screens/live_practice/live_practice_screen.dart';
import '../../presentation/screens/post_game/post_game_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../data/repositories/repositories.dart';

class AppRouter {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const scriptEditor = '/script-editor';
  static const livePractice = '/live-practice';
  static const postGame = '/post-game';
  static const profile = '/profile';

  /// Safely parse GoRouter extra to int — returns null if not set or wrong type
  static int? _toIntExtra(dynamic extra) {
    if (extra == null) return null;
    if (extra is int) return extra;
    if (extra is String) return int.tryParse(extra);
    return null;
  }

  static final router = GoRouter(
    initialLocation: splash,
    redirect: (ctx, state) async {
      final isAuth = await AuthRepository().isLoggedIn();
      final protected = [
        dashboard,
        scriptEditor,
        livePractice,
        postGame,
        profile,
      ];
      if (!isAuth &&
          protected.any((r) => state.fullPath?.startsWith(r) == true)) {
        return login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (c, s) => _fade(const SplashScreen(), s),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (c, s) => _fade(const OnboardingScreen(), s),
      ),
      GoRoute(
        path: login,
        pageBuilder: (c, s) => _fade(const LoginScreen(), s),
      ),
      GoRoute(
        path: register,
        pageBuilder: (c, s) => _slide(const RegisterScreen(), s),
      ),
      GoRoute(
        path: dashboard,
        pageBuilder: (c, s) => _fade(const DashboardScreen(), s),
      ),
      GoRoute(
        path: scriptEditor,
        pageBuilder: (c, s) =>
            _slide(ScriptEditorScreen(scriptId: _toIntExtra(s.extra)), s),
      ),
      GoRoute(
        path: livePractice,
        pageBuilder: (c, s) =>
            _scale(LivePracticeScreen(scriptId: _toIntExtra(s.extra)), s),
      ),
      GoRoute(
        path: postGame,
        pageBuilder: (c, s) =>
            _slide(PostGameScreen(sessionId: _toIntExtra(s.extra) ?? 0), s),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (c, s) => _slide(const ProfileScreen(), s),
      ),
    ],
  );

  static CustomTransitionPage _fade(Widget w, GoRouterState s) =>
      CustomTransitionPage(
        key: s.pageKey,
        child: w,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (c, a, _, ch) =>
            FadeTransition(opacity: a, child: ch),
      );
  static CustomTransitionPage _slide(Widget w, GoRouterState s) =>
      CustomTransitionPage(
        key: s.pageKey,
        child: w,
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (c, a, _, ch) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: ch,
        ),
      );
  static CustomTransitionPage _scale(Widget w, GoRouterState s) =>
      CustomTransitionPage(
        key: s.pageKey,
        child: w,
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (c, a, _, ch) => ScaleTransition(
          scale: Tween(
            begin: 0.93,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: a, child: ch),
        ),
      );
}
