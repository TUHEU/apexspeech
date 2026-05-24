// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Mock data
  final _user = _MockUser(
    name: 'Marcus Aurelius',
    level: 6,
    levelName: 'Orator',
    totalSessions: 23,
    avgConfidence: 78.4,
    streak: 5,
  );

  final _recentSessions = [
    _MockSession('Business Pitch', 82, 'A', '12:34', '2h ago'),
    _MockSession('Team Update', 71, 'B', '08:21', 'Yesterday'),
    _MockSession('TEDx Practice', 90, 'S+', '15:02', '3 days ago'),
  ];

  final _scripts = [
    _MockScript('Q3 Investor Pitch', 'Venture Capitalists', true, '8m'),
    _MockScript('Product Launch', 'General Audience', true, '5m'),
    _MockScript('Leadership Summit', 'Executives', false, '12m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(user: _user, sessions: _recentSessions, scripts: _scripts),
          _ScriptsTab(scripts: _scripts),
          const _AnalyticsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _ApexBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final _MockUser user;
  final List<_MockSession> sessions;
  final List<_MockScript> scripts;

  const _HomeTab({
    required this.user,
    required this.sessions,
    required this.scripts,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          collapsedHeight: 60,
          pinned: true,
          backgroundColor: AppColors.obsidian,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Gradient header
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A1200), AppColors.obsidian],
                    ),
                  ),
                ),
                // Decorative circles
                Positioned(
                  top: -30, right: -20,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldDim, width: 1),
                    ),
                  ),
                ),
                // User greeting
                Positioned(
                  bottom: 16, left: 20, right: 20,
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.goldRoyal, AppColors.goldMuted],
                          ),
                          boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 12)],
                        ),
                        child: Center(
                          child: Text(
                            user.name.substring(0, 1),
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.obsidian,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning,',
                              style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.goldRoyal, width: 1),
                          boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 8)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppColors.goldBright, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'LVL ${user.level} ${user.levelName.toUpperCase()}',
                              style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldBright,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Quick Stats Row
              _QuickStatsRow(user: user).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // START PRACTICE CTA
              _StartPracticeCard().animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              // Recent Sessions
              ApexSectionHeader(
                title: 'Recent Sessions',
                subtitle: '${sessions.length} total this week',
                action: TextButton(
                  onPressed: () {},
                  child: const Text('See All',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.goldRoyal)),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              ...sessions.asMap().entries.map((e) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(session: e.value)
                    .animate().fadeIn(delay: Duration(milliseconds: 350 + e.key * 80))
                    .slideX(begin: 0.05, end: 0),
                ),
              ),

              const SizedBox(height: 28),

              // Scripts
              ApexSectionHeader(
                title: 'My Scripts',
                subtitle: '${scripts.length} scripts saved',
                action: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.goldRoyal, size: 20),
                  onPressed: () => context.push(AppRouter.scriptEditor),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: scripts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) => _ScriptCard(script: scripts[i])
                    .animate().fadeIn(delay: Duration(milliseconds: 550 + i * 80)),
                ),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK STATS ROW
// ─────────────────────────────────────────────────────────────────────────────
class _QuickStatsRow extends StatelessWidget {
  final _MockUser user;
  const _QuickStatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          value: '${user.totalSessions}',
          label: 'Sessions',
          icon: Icons.play_circle_outline,
          color: AppColors.accentBlueBright,
        ),
        const SizedBox(width: 10),
        _StatTile(
          value: '${user.avgConfidence.toInt()}%',
          label: 'Avg Confidence',
          icon: Icons.trending_up,
          color: AppColors.matrixGreen,
        ),
        const SizedBox(width: 10),
        _StatTile(
          value: '🔥 ${user.streak}',
          label: 'Day Streak',
          icon: Icons.local_fire_department,
          color: AppColors.amberWarning,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value, required this.label,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit', fontSize: 18,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit', fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// START PRACTICE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StartPracticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.livePractice, extra: <String, dynamic>{}),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1E00), Color(0xFF1A1200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.goldDim, width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 20)],
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(right: -20, bottom: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldDim.withOpacity(0.3),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldGlow,
                      border: Border.all(color: AppColors.goldRoyal, width: 1.5),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: AppColors.goldBright, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'START PRACTICE',
                          style: TextStyle(
                            fontFamily: 'Cinzel', fontSize: 18,
                            fontWeight: FontWeight.w700, color: AppColors.goldBright,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Live posture + vocal AI feedback',
                          style: TextStyle(
                            fontFamily: 'Outfit', fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: AppColors.goldRoyal, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final _MockSession session;
  const _SessionCard({required this.session});

  Color get _gradeColor {
    switch (session.grade) {
      case 'S+': return AppColors.goldBright;
      case 'A': return AppColors.matrixGreen;
      case 'B': return AppColors.accentBlueBright;
      default: return AppColors.amberWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.postGame, extra: 'mock_id'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            // Grade circle
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gradeColor.withOpacity(0.1),
                border: Border.all(color: _gradeColor.withOpacity(0.4), width: 1.5),
              ),
              child: Center(
                child: Text(
                  session.grade,
                  style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 13,
                    fontWeight: FontWeight.w800, color: _gradeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${session.score}% confidence  ·  ${session.duration}',
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              session.timeAgo,
              style: const TextStyle(
                fontFamily: 'Outfit', fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCRIPT CARD (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────
class _ScriptCard extends StatelessWidget {
  final _MockScript script;
  const _ScriptCard({required this.script});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.scriptEditor, extra: 'mock_id'),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E28), Color(0xFF14141C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    script.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 13,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              script.audience,
              style: const TextStyle(
                fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (script.isApexified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('⚡ APEX',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 9,
                          fontWeight: FontWeight.w700, color: AppColors.goldBright)),
                  ),
                const Spacer(),
                Text(script.duration,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTHER TABS (stubs)
// ─────────────────────────────────────────────────────────────────────────────
class _ScriptsTab extends StatelessWidget {
  final List<_MockScript> scripts;
  const _ScriptsTab({required this.scripts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('MY SCRIPTS'),
        backgroundColor: AppColors.obsidian,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.goldRoyal),
            onPressed: () => context.push(AppRouter.scriptEditor),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: scripts.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scripts[i].title,
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 15,
                            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('${scripts[i].audience}  ·  ${scripts[i].duration}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (scripts[i].isApexified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⚡ APEX',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 10,
                          fontWeight: FontWeight.w700, color: AppColors.goldBright)),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideX(begin: 0.05, end: 0),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.scriptEditor),
        backgroundColor: AppColors.goldRoyal,
        foregroundColor: AppColors.obsidian,
        icon: const Icon(Icons.add),
        label: const Text('NEW SCRIPT',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, letterSpacing: 1)),
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('ANALYTICS'),
        backgroundColor: AppColors.obsidian,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ApexSectionHeader(title: 'Performance Overview'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ScoreRing(score: 78.4, label: 'CONFIDENCE', color: AppColors.matrixGreen, size: 90)),
                Expanded(child: ScoreRing(score: 65.2, label: 'ENTHUSIASM', color: AppColors.goldRoyal, size: 90)),
                Expanded(child: ScoreRing(score: 82.1, label: 'AUTHORITY', color: AppColors.accentBlueBright, size: 90)),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            const ApexSectionHeader(title: 'Weekly Progress'),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: const Center(
                child: Text('Progress Chart\n(fl_chart integration)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted)),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text('PROFILE'),
        backgroundColor: AppColors.obsidian,
      ),
      body: const Center(
        child: Text('Profile Screen', style: TextStyle(color: AppColors.textMuted)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────────────────────────────────────
class _ApexBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ApexBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.description_outlined, Icons.description_rounded, 'Scripts'),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
      (Icons.person_outline, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: items.asMap().entries.map((e) {
              final isSelected = selectedIndex == e.key;
              final (outlineIcon, filledIcon, label) = e.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(e.key),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? filledIcon : outlineIcon,
                          color: isSelected ? AppColors.goldRoyal : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.goldRoyal : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _MockUser {
  final String name, levelName;
  final int level, totalSessions, streak;
  final double avgConfidence;
  const _MockUser({required this.name, required this.level, required this.levelName,
    required this.totalSessions, required this.avgConfidence, required this.streak});
}

class _MockSession {
  final String title, grade, duration, timeAgo;
  final int score;
  const _MockSession(this.title, this.score, this.grade, this.duration, this.timeAgo);
}

class _MockScript {
  final String title, audience, duration;
  final bool isApexified;
  const _MockScript(this.title, this.audience, this.isApexified, this.duration);
}
