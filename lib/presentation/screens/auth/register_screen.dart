// lib/presentation/screens/auth/register_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../widgets/common/apex_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _form   = GlobalKey<FormState>();
  final _name   = TextEditingController();
  final _email  = TextEditingController();
  final _pass   = TextEditingController();
  final _auth   = AuthRepository();
  bool _obscure = true, _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading=true; _error=null; });
    final r = await _auth.register(_name.text.trim(), _email.text.trim(), _pass.text);
    if (!mounted) return;
    r.fold(
      (f) => setState(() { _loading=false; _error=f.message; }),
      (_) { setState(()=>_loading=false); context.go(AppRouter.dashboard); },
    );
  }

  @override void dispose() { _name.dispose(); _email.dispose(); _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(backgroundColor: Colors.transparent,
      leading: IconButton(icon:const Icon(Icons.arrow_back_ios, color:AppColors.goldRoyal, size:18),
        onPressed:()=>context.pop())),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal:24),
      child: Column(children: [
        const SizedBox(height:8),
        ShaderMask(shaderCallback:(b)=>AppColors.goldGradient.createShader(b), blendMode:BlendMode.srcIn,
          child: const Text('Create Account', style: TextStyle(fontFamily:'Outfit',
              fontSize:26, fontWeight:FontWeight.w800))),
        const SizedBox(height:4),
        const Text('Begin your Apex journey.', style: TextStyle(
          fontFamily:'Outfit', fontSize:13, color:AppColors.textMuted)),
        const SizedBox(height:32),
        ClipRRect(borderRadius:BorderRadius.circular(18), child: BackdropFilter(
          filter:ImageFilter.blur(sigmaX:14, sigmaY:14),
          child: Container(padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color:Colors.white.withOpacity(0.04),
              borderRadius:BorderRadius.circular(18), border:Border.all(color:AppColors.borderDark)),
            child: Form(key:_form, child: Column(children: [
              if (_error!=null) ...[
                Container(padding:const EdgeInsets.all(10),
                  decoration:BoxDecoration(color:AppColors.errorRed.withOpacity(0.1),
                    borderRadius:BorderRadius.circular(10),
                    border:Border.all(color:AppColors.errorRed.withOpacity(0.4))),
                  child:Text(_error!, style:const TextStyle(fontFamily:'Outfit', fontSize:12, color:AppColors.errorRed))),
                const SizedBox(height:14),
              ],
              ApexField(controller:_name, label:'Full Name', hint:'Your name',
                icon:Icons.person_outline,
                validator:(v){if(v==null||v.trim().length<2)return 'Enter your name';return null;}),
              const SizedBox(height:14),
              ApexField(controller:_email, label:'Email Address', hint:'you@domain.com',
                icon:Icons.alternate_email, keyboardType:TextInputType.emailAddress,
                validator:(v){if(v==null||!v.contains('@'))return 'Enter valid email';return null;}),
              const SizedBox(height:14),
              ApexField(controller:_pass, label:'Password', hint:'Min 6 characters',
                icon:Icons.lock_outline, obscure:_obscure,
                suffix:IconButton(icon:Icon(_obscure?Icons.visibility_outlined:Icons.visibility_off_outlined,
                    color:AppColors.textMuted, size:18),
                  onPressed:()=>setState(()=>_obscure=!_obscure)),
                validator:(v){if(v==null||v.length<6)return 'Min 6 characters';return null;}),
              const SizedBox(height:22),
              GoldButton(label:'Create Account', icon:Icons.rocket_launch_rounded,
                  isLoading:_loading, onTap:_register),
            ])),
          ),
        )).animate().fadeIn(delay:100.ms),
        const SizedBox(height:40),
      ]),
    ),
  );
}
