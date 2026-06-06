import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _goalCtrl  = TextEditingController();
  int? _profileId;
  bool _saving = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await DatabaseHelper.instance.getProfile();
    if (p != null && mounted) setState(() {
      _profileId = p['id'];
      _nameCtrl.text  = p['name']  ?? '';
      _emailCtrl.text = p['email'] ?? '';
      _goalCtrl.text  = p['goal']  ?? '';
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final data = {'name': _nameCtrl.text, 'email': _emailCtrl.text, 'goal': _goalCtrl.text};
    if (_profileId != null) {
      await DatabaseHelper.instance.updateProfile(_profileId!, data);
    } else {
      final id = await DatabaseHelper.instance.insertProfile(data);
      setState(() => _profileId = id);
    }
    setState(() => _saving = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Profile saved ✓', style: TextStyle(fontFamily: 'Outfit')),
      backgroundColor: AppColors.matrixGreen, behavior: SnackBarBehavior.floating));
  }

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _goalCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(title: const Text('MY PROFILE')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Column(children: [
      const SizedBox(height: 10),
      Container(width: 84, height: 84,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: AppColors.purpleDark.withOpacity(0.4),
          border: Border.all(color: AppColors.purpleLight, width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.purpleLight.withOpacity(0.3), blurRadius: 22)]),
        child: const Icon(Icons.person, size: 44, color: AppColors.purpleLight)),
      const SizedBox(height: 28),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark)),
        child: Column(children: [
          _field(_nameCtrl,  'Full Name',     Icons.person_outline),
          const SizedBox(height: 14),
          _field(_emailCtrl, 'Email',         Icons.email_outlined, type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field(_goalCtrl,  'My Speech Goal', Icons.flag_outlined, maxLines: 3,
            hint: 'e.g. Reduce filler words, speak confidently…'),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: _saving ? null : _save,
            child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('SAVE PROFILE', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)))),
        ])),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.errorRed),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 16),
        label: const Text('Sign Out', style: TextStyle(fontFamily: 'Outfit', color: AppColors.errorRed)),
        onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
      const SizedBox(height: 40),
    ])),
  );

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, int maxLines = 1, String? hint}) =>
    TextField(controller: ctrl, keyboardType: type, maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18)));
}
