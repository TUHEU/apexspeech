// lib/presentation/screens/auth/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRouter.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.5),
                  radius: 0.8,
                  colors: [Color(0xFF1A1200), AppColors.obsidian],
                ),
              ),
            ),
          ),

          // Decorative corner elements
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDim, width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDim, width: 0.5),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldDim,
                            border: Border.all(color: AppColors.goldRoyal, width: 1.5),
                            boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 20)],
                          ),
                          child: const Icon(Icons.mic, color: AppColors.goldRoyal, size: 28),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'APEX SPEECH',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Welcome back, Executive.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 48),

                  // Form card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              _ApexField(
                                controller: _emailCtrl,
                                label: 'Email Address',
                                hint: 'you@domain.com',
                                icon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _ApexField(
                                controller: _passCtrl,
                                label: 'Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePass,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  if (v.length < 6) return 'Minimum 6 characters';
                                  return null;
                                },
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: AppColors.goldRoyal,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              GoldButton(
                                label: 'Sign In',
                                onTap: _login,
                                isLoading: _isLoading,
                                prefixIcon: Icons.login_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, delay: 200.ms),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.borderDark)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: AppColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.borderDark)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GoldOutlinedButton(
                    label: 'Create New Account',
                    onTap: () => context.go(AppRouter.register),
                    prefixIcon: Icons.person_add_outlined,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.goldRoyal, size: 20),
          onPressed: () => context.go(AppRouter.login),
        ),
        title: const Text('CREATE ACCOUNT',
          style: TextStyle(fontFamily: 'Cinzel', fontSize: 16, color: AppColors.goldRoyal, letterSpacing: 2)),
      ),
      body: const Center(
        child: Text('Register Screen', style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}

class _ApexField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ApexField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.goldRoyal, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
