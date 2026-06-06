import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscure       = true;

  @override void dispose() { _usernameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.purpleLight, size: 18),
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        const SizedBox(height: 10),
        const Text('Create Account', style: TextStyle(fontFamily: 'Outfit',
            fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Begin your Apex journey', style: TextStyle(fontFamily: 'Outfit',
            fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderDark)),
          child: Form(key: _formKey, child: Column(children: [
            TextFormField(controller: _usernameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter username';
                if (v.length < 6) return 'Min 6 characters';
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(v)) return 'Letters and numbers only';
                return null;
              },
              decoration: const InputDecoration(labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted))),
            const SizedBox(height: 14),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email';
                return null;
              },
              decoration: const InputDecoration(labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted))),
            const SizedBox(height: 14),
            TextFormField(controller: _passwordCtrl, obscureText: _obscure,
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter password';
                if (v.length < 6) return 'Min 6 characters';
                return null;
              },
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account Created Successfully'),
                      backgroundColor: AppColors.matrixGreen));
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: const Text('CREATE ACCOUNT', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)))),
          ])),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Already have an account? Login',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.purpleLight))),
        const SizedBox(height: 40),
      ]),
    ),
  );
}
