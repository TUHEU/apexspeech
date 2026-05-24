// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.goldRoyal, size: 18),
          onPressed: () => context.go(AppRouter.dashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile header
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.goldBright, AppColors.goldRoyal],
                        ),
                        boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 20)],
                      ),
                      child: const Center(
                        child: Text('M',
                          style: TextStyle(fontFamily: 'Cinzel', fontSize: 36,
                              fontWeight: FontWeight.w700, color: AppColors.obsidian)),
                      ),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.obsidian,
                        border: Border.all(color: AppColors.goldRoyal, width: 2),
                      ),
                      child: const Icon(Icons.star, color: AppColors.goldRoyal, size: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Marcus Aurelius',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 20,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('marcus@executive.io',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.goldRoyal),
                  ),
                  child: const Text('⭐ LVL 6 — ORATOR',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
                        fontWeight: FontWeight.w700, color: AppColors.goldBright, letterSpacing: 1)),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 28),

            // Level progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1200), Color(0xFF0D0D14)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldDim, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress to Influencer',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                            fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const Text('68%',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                            fontWeight: FontWeight.w700, color: AppColors.goldRoyal)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.68,
                      backgroundColor: AppColors.borderDark,
                      valueColor: const AlwaysStoppedAnimation(AppColors.goldRoyal),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Complete 4 more sessions to level up',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                _ProfileStat('23', 'Sessions', Icons.play_circle_outline, AppColors.accentBlueBright),
                const SizedBox(width: 10),
                _ProfileStat('78%', 'Avg Score', Icons.trending_up, AppColors.matrixGreen),
                const SizedBox(width: 10),
                _ProfileStat('🔥 5', 'Day Streak', Icons.local_fire_department, AppColors.amberWarning),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 28),

            // Settings list
            _SettingsSection(
              title: 'PRACTICE',
              items: [
                _SettingItem(Icons.mic_outlined, 'Audio Settings', () {}),
                _SettingItem(Icons.videocam_outlined, 'Camera & Posture', () {}),
                _SettingItem(Icons.notifications_outlined, 'Practice Reminders', () {}),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            _SettingsSection(
              title: 'ACCOUNT',
              items: [
                _SettingItem(Icons.person_outline, 'Edit Profile', () {}),
                _SettingItem(Icons.lock_outline, 'Change Password', () {}),
                _SettingItem(Icons.card_membership, 'Apex Premium', () {}),
              ],
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 16),

            _SettingsSection(
              title: 'SUPPORT',
              items: [
                _SettingItem(Icons.help_outline, 'Help Center', () {}),
                _SettingItem(Icons.logout_rounded, 'Sign Out', () => context.go(AppRouter.login),
                    color: AppColors.errorRed),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _ProfileStat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 11,
                fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              final item = e.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Icon(item.icon, color: item.color ?? AppColors.textSecondary, size: 20),
                    title: Text(item.label,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: item.color ?? AppColors.textPrimary)),
                    trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.only(left: 52),
                      child: Divider(color: AppColors.borderDark, height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingItem(this.icon, this.label, this.onTap, {this.color});
}
