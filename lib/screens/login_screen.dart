import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../helpers/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscure       = true;

  @override void dispose() { _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        const SizedBox(height: 60),
        Container(width: 70, height: 70,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: AppColors.purpleDark.withOpacity(0.4),
            border: Border.all(color: AppColors.purpleLight, width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.purpleLight.withOpacity(0.3), blurRadius: 20)]),
          child: const Icon(Icons.mic_rounded, color: AppColors.purpleLight, size: 32),
        ).animate().scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        const Text('APEX SPEECH', style: TextStyle(fontFamily: 'Outfit',
            fontSize: 22, fontWeight: FontWeight.w900,
            color: AppColors.purpleLight, letterSpacing: 3)),
        const SizedBox(height: 4),
        const Text('Welcome back', style: TextStyle(fontFamily: 'Outfit',
            fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 40),
        Container(padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderDark)),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sign In', style: TextStyle(fontFamily: 'Outfit',
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted))),
            const SizedBox(height: 14),
            TextFormField(controller: _passwordCtrl, obscureText: _obscure,
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleLight,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: const Text('SIGN IN', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)))),
          ])),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 20),
        TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
          child: const Text("Don't have an account? Sign up",
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.purpleLight))),
        const SizedBox(height: 40),
      ]),
    )),
  );
}
