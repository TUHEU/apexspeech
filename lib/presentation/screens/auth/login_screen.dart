// lib/presentation/screens/auth/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../widgets/common/apex_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _form    = GlobalKey<FormState>();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _auth    = AuthRepository();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading=true; _error=null; });
    final r = await _auth.login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    r.fold(
      (f) => setState(() { _loading=false; _error=f.message; }),
      (_) { setState(() => _loading=false); context.go(AppRouter.dashboard); },
    );
  }

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment(-0.3,-0.5), radius:0.75,
        colors:[Color(0xFF1A1200), AppColors.obsidian]))),
      SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal:24),
        child: Column(children: [
          const SizedBox(height:36),
          Column(children: [
            Container(width:56, height:56,
              decoration: BoxDecoration(shape:BoxShape.circle, color:AppColors.goldDim,
                border:Border.all(color:AppColors.goldRoyal, width:1.5),
                boxShadow:[BoxShadow(color:AppColors.goldGlow, blurRadius:20)]),
              child: const Icon(Icons.mic_rounded, color:AppColors.goldRoyal, size:26)),
            const SizedBox(height:14),
            ShaderMask(shaderCallback:(b)=>AppColors.goldGradient.createShader(b), blendMode:BlendMode.srcIn,
              child: const Text('APEX SPEECH', style: TextStyle(fontFamily:'Outfit',
                  fontSize:24, fontWeight:FontWeight.w900, letterSpacing:4))),
            const SizedBox(height:5),
            const Text('Welcome back, Executive.', style: TextStyle(
              fontFamily:'Outfit', fontSize:13, color:AppColors.textMuted)),
          ]).animate().fadeIn(duration:600.ms),
          const SizedBox(height:40),
          ClipRRect(borderRadius: BorderRadius.circular(18), child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX:14, sigmaY:14),
            child: Container(padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color:Colors.white.withOpacity(0.04),
                borderRadius:BorderRadius.circular(18),
                border:Border.all(color:AppColors.borderDark)),
              child: Form(key:_form, child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                const Text('Sign In', style: TextStyle(fontFamily:'Outfit', fontSize:20,
                    fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
                const SizedBox(height:20),
                if (_error != null) ...[
                  Container(padding:const EdgeInsets.all(10),
                    decoration:BoxDecoration(color:AppColors.errorRed.withOpacity(0.1),
                      borderRadius:BorderRadius.circular(10),
                      border:Border.all(color:AppColors.errorRed.withOpacity(0.4))),
                    child:Row(children:[const Icon(Icons.error_outline, color:AppColors.errorRed, size:16),
                      const SizedBox(width:8),
                      Expanded(child:Text(_error!, style:const TextStyle(
                        fontFamily:'Outfit', fontSize:12, color:AppColors.errorRed)))])),
                  const SizedBox(height:14),
                ],
                ApexField(controller:_email, label:'Email Address', hint:'you@domain.com',
                  icon:Icons.alternate_email, keyboardType:TextInputType.emailAddress,
                  validator:(v){if(v==null||!v.contains('@'))return 'Enter valid email';return null;}),
                const SizedBox(height:14),
                ApexField(controller:_pass, label:'Password', hint:'••••••••',
                  icon:Icons.lock_outline, obscure:_obscure,
                  suffix:IconButton(icon:Icon(_obscure?Icons.visibility_outlined:Icons.visibility_off_outlined,
                      color:AppColors.textMuted, size:18),
                    onPressed:()=>setState(()=>_obscure=!_obscure)),
                  validator:(v){if(v==null||v.length<6)return 'Min 6 characters';return null;}),
                Align(alignment:Alignment.centerRight, child:TextButton(onPressed:(){},
                  child:const Text('Forgot Password?', style:TextStyle(
                    fontFamily:'Outfit', fontSize:11, color:AppColors.goldRoyal)))),
                GoldButton(label:'Sign In', icon:Icons.login_rounded, isLoading:_loading, onTap:_login),
              ])),
            ),
          )).animate().fadeIn(delay:200.ms).slideY(begin:0.08, end:0, delay:200.ms),
          const SizedBox(height:22),
          Row(children:[const Expanded(child:Divider(color:AppColors.borderDark)),
            const Padding(padding:EdgeInsets.symmetric(horizontal:12),
              child:Text('OR', style:TextStyle(fontFamily:'Outfit', fontSize:11,
                  color:AppColors.textMuted, letterSpacing:1))),
            const Expanded(child:Divider(color:AppColors.borderDark))]),
          const SizedBox(height:22),
          GoldOutlinedButton(label:'Create New Account', icon:Icons.person_add_outlined,
            onTap:()=>context.push(AppRouter.register),
          ).animate().fadeIn(delay:400.ms),
          const SizedBox(height:40),
        ]),
      )),
    ]),
  );
}
