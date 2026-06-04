// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/common/apex_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepo = ProfileRepository();
  final _authRepo    = AuthRepository();
  final _nameCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();

  UserEntity? _user;
  bool _loading     = true;
  bool _saving      = false;
  bool _editMode    = false;
  bool _obscurePass = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await _profileRepo.getProfile();
    r.fold((_) {}, (u) {
      _user = u;
      _nameCtrl.text = u.fullName;
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final data = <String, dynamic>{'full_name': _nameCtrl.text.trim()};
    if (_passCtrl.text.isNotEmpty) data['password'] = _passCtrl.text;
    final r = await _profileRepo.updateProfile(data);
    r.fold(
      (f) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(f.message), backgroundColor: AppColors.errorRed));
      },
      (u) {
        _user = u; _editMode = false; _passCtrl.clear();
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppColors.matrixGreen));
      },
    );
  }

  Future<void> _logout() async {
    await _authRepo.logout();
    if (mounted) context.go(AppRouter.login);
  }

  String get _levelName {
    final lvl = _user?.apexLevel ?? 1;
    final idx  = (lvl - 1).clamp(0, AppConstants.levelNames.length - 1);
    return AppConstants.levelNames[idx];
  }

  double get _levelProgress {
    final sessions = _user?.totalSessions ?? 0;
    return ((sessions % 4) / 4).clamp(0.0, 1.0);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.goldRoyal, size: 18),
        onPressed: () => context.pop()),
      title: const Text('PROFILE'),
      actions: [
        TextButton(
          onPressed: () => setState(() => _editMode = !_editMode),
          child: Text(_editMode ? 'CANCEL' : 'EDIT',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 11,
                fontWeight: FontWeight.w700, color: AppColors.goldRoyal, letterSpacing: 1))),
      ],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator(color: AppColors.goldRoyal))
      : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            // ── Avatar + Name ────────────────────────────
            Column(children: [
              Container(width: 88, height: 88,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 24, spreadRadius: 4)]),
                child: Center(child: Text(
                  (_user?.fullName.isNotEmpty == true)
                      ? _user!.fullName[0].toUpperCase() : 'A',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 36,
                      fontWeight: FontWeight.w800, color: AppColors.obsidian))),
              ).animate().scale(begin: const Offset(0.8, 0.8),
                  duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text(_user?.fullName ?? '…', style: const TextStyle(fontFamily: 'Outfit',
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_user?.email ?? '…', style: const TextStyle(fontFamily: 'Outfit',
                  fontSize: 12, color: AppColors.textMuted)),
            ]).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 24),

            // ── Level card ───────────────────────────────
            GlassCard(padding: const EdgeInsets.all(16),
              borderColor: AppColors.goldDim,
              child: Column(children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldMuted)),
                    child: Text('LVL ${_user?.apexLevel ?? 1}',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 11,
                          fontWeight: FontWeight.w800, color: AppColors.goldBright,
                          letterSpacing: 1))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    GoldText(_levelName, style: const TextStyle(fontFamily: 'Outfit',
                        fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    const Text('Your Apex title', style: TextStyle(fontFamily: 'Outfit',
                        fontSize: 10, color: AppColors.textMuted)),
                  ])),
                  ShaderMask(shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                    child: const Icon(Icons.military_tech_rounded,
                        color: Colors.white, size: 28)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                  value: _levelProgress,
                  backgroundColor: AppColors.borderDark,
                  valueColor: const AlwaysStoppedAnimation(AppColors.goldRoyal),
                  minHeight: 6,
                )),
                const SizedBox(height: 6),
                Text(
                  '${((_levelProgress) * 4).toInt()} / 4 sessions to next level',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 10,
                      color: AppColors.textMuted)),
              ]),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // ── Stats row ────────────────────────────────
            Row(children: [
              _StatCard('${_user?.totalSessions ?? 0}',
                  'Sessions', Icons.play_circle_outline, AppColors.accentBlue),
              const SizedBox(width: 10),
              _StatCard('${(_user?.avgConfidence ?? 0).toInt()}%',
                  'Avg Score', Icons.trending_up, AppColors.matrixGreen),
              const SizedBox(width: 10),
              _StatCard('${_user?.streakDays ?? 0} 🔥',
                  'Day Streak', Icons.local_fire_department, AppColors.amberWarning),
            ]).animate().fadeIn(delay: 220.ms),

            const SizedBox(height: 24),

            // ── Edit form ────────────────────────────────
            if (_editMode) ...[
              Container(padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('EDIT PROFILE', style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppColors.textMuted, letterSpacing: 1.5)),
                  const SizedBox(height: 18),
                  ApexField(controller: _nameCtrl, label: 'Display Name',
                    hint: 'Your full name', icon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 14),
                  ApexField(controller: _passCtrl, label: 'New Password (optional)',
                    hint: 'Leave blank to keep current', icon: Icons.lock_outline,
                    obscure: _obscurePass,
                    suffix: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass))),
                  const SizedBox(height: 20),
                  GoldButton(label: _saving ? 'Saving…' : 'SAVE CHANGES',
                    isLoading: _saving, onTap: _saving ? null : _save),
                ]),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: 20),
            ],

            // ── Settings list ────────────────────────────
            Container(decoration: BoxDecoration(color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark)),
              child: Column(children: [
                _SettingRow(
                  icon: Icons.notifications_outlined, label: 'Practice Reminders',
                  color: AppColors.accentBlue,
                  onTap: () {},
                  trailing: Switch(value: true, onChanged: (_) {},
                    activeColor: AppColors.goldRoyal),
                ),
                const Divider(height: 1, color: AppColors.borderDark, indent: 16, endIndent: 16),
                _SettingRow(
                  icon: Icons.info_outline, label: 'About Apex Speech',
                  color: AppColors.textMuted, onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderDark, indent: 16, endIndent: 16),
                _SettingRow(
                  icon: Icons.star_outline, label: 'Rate the App',
                  color: AppColors.amberWarning, onTap: () {},
                ),
              ]),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // ── Sign out ─────────────────────────────────
            GestureDetector(
              onTap: _logout,
              child: Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 17),
                  SizedBox(width: 8),
                  Text('SIGN OUT', style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.errorRed, letterSpacing: 1.2)),
                ])),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ]),
        ),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label; final IconData icon; final Color color;
  const _StatCard(this.value, this.label, this.icon, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 16,
          fontWeight: FontWeight.w800, color: color)),
      Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Outfit', fontSize: 9,
            color: AppColors.textMuted, height: 1.3)),
    ]),
  ));
}

class _SettingRow extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final VoidCallback onTap; final Widget? trailing;
  const _SettingRow({required this.icon, required this.label,
      required this.color, required this.onTap, this.trailing});
  @override Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    leading: Container(width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle,
        color: color.withOpacity(0.12)),
      child: Icon(icon, color: color, size: 15)),
    title: Text(label, style: const TextStyle(fontFamily: 'Outfit',
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    trailing: trailing ?? const Icon(Icons.chevron_right,
        color: AppColors.textMuted, size: 17),
  );
}
