// lib/presentation/screens/post_game/post_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';

class PostGameScreen extends StatelessWidget {
  final String sessionId;
  const PostGameScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // Mock session data
    const confidence = 78.5;
    const enthusiasm = 65.2;
    const authority = 82.1;
    const fillerCount = 4;
    const postureAlerts = 2;
    const duration = '12:34';
    const grade = 'A';

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.obsidian,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.goldRoyal, size: 18),
              onPressed: () => context.go(AppRouter.dashboard),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1200), AppColors.obsidian],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Grade circle
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.goldBright, AppColors.goldRoyal],
                            ),
                            boxShadow: [BoxShadow(color: AppColors.goldGlow, blurRadius: 30, spreadRadius: 5)],
                          ),
                          child: const Center(
                            child: Text('A',
                              style: TextStyle(fontFamily: 'Cinzel', fontSize: 36,
                                  fontWeight: FontWeight.w700, color: AppColors.obsidian)),
                          ),
                        ).animate().scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        const Text('EXCELLENT PERFORMANCE',
                          style: TextStyle(fontFamily: 'Cinzel', fontSize: 14,
                              color: AppColors.goldRoyal, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(
                          'Session: $duration  ·  Overall Score: ${((confidence * 0.4 + enthusiasm * 0.3 + authority * 0.3)).toInt()}%',
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Score Cards ────────────────────────────
                const ApexSectionHeader(title: 'AI Scores'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ScoreRing(score: confidence, label: 'CONFIDENCE', color: AppColors.matrixGreen, size: 90),
                    ScoreRing(score: enthusiasm, label: 'ENTHUSIASM', color: AppColors.goldRoyal, size: 90),
                    ScoreRing(score: authority, label: 'AUTHORITY', color: AppColors.accentBlueBright, size: 90),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),

                // ── Quick Stats ────────────────────────────
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.warning_rounded,
                      value: '$fillerCount',
                      label: 'Filler Words',
                      color: fillerCount <= 3 ? AppColors.matrixGreen : AppColors.amberWarning,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.accessibility_new,
                      value: '$postureAlerts',
                      label: 'Posture Alerts',
                      color: postureAlerts <= 1 ? AppColors.matrixGreen : AppColors.amberWarning,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.timer_outlined,
                      value: duration,
                      label: 'Duration',
                      color: AppColors.accentBlueBright,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),

                // ── Vocal Modulation Chart ─────────────────
                const ApexSectionHeader(title: 'Vocal Modulation', subtitle: 'Pitch over time'),
                const SizedBox(height: 12),
                Container(
                  height: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: _PitchChart(),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // ── AI Feedback ────────────────────────────
                const ApexSectionHeader(title: 'AI Coaching Tips'),
                const SizedBox(height: 12),
                ...[
                  _FeedbackItem(
                    type: 'strength',
                    icon: '💪',
                    title: 'Strong Authority',
                    body: 'Your authority score of 82% is exceptional. The consistent vocal depth and deliberate pacing commands attention.',
                  ),
                  _FeedbackItem(
                    type: 'improvement',
                    icon: '🎯',
                    title: 'Reduce Filler Words',
                    body: '4 filler words detected. Focus especially on the second paragraph — replace pauses with 2-second silence instead.',
                  ),
                  _FeedbackItem(
                    type: 'improvement',
                    icon: '🧍',
                    title: 'Posture Consistency',
                    body: '2 slouching alerts in minutes 3 and 8. Practice the "string from crown" mental model to maintain upright posture.',
                  ),
                  _FeedbackItem(
                    type: 'strength',
                    icon: '🔥',
                    title: 'Confident Gestures',
                    body: 'Open-palm gestures detected 6 times. This signals openness and authority to your audience.',
                  ),
                ].asMap().entries.map((e) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: e.value.animate()
                      .fadeIn(delay: Duration(milliseconds: 500 + e.key * 80))
                      .slideX(begin: 0.04, end: 0),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Filler Word Breakdown ──────────────────
                const ApexSectionHeader(title: 'Filler Word Breakdown'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      _FillerBar(word: '"um"', count: 2, total: 4),
                      const SizedBox(height: 8),
                      _FillerBar(word: '"like"', count: 1, total: 4),
                      const SizedBox(height: 8),
                      _FillerBar(word: '"you know"', count: 1, total: 4),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 28),

                // ── CTA buttons ────────────────────────────
                GoldButton(
                  label: '🔁 Practice Again',
                  onTap: () => context.push(AppRouter.livePractice, extra: <String, dynamic>{}),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 12),
                GoldOutlinedButton(
                  label: '✏️ Edit Script',
                  onTap: () => context.push(AppRouter.scriptEditor),
                ).animate().fadeIn(delay: 850.ms),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PITCH CHART
// ─────────────────────────────────────────────────────────────────────────────
class _PitchChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spots = List.generate(40, (i) =>
      FlSpot(i.toDouble(), 180 + 70 * (0.5 - (i % 7) / 14) + (i % 3) * 20.0),
    );

    return LineChart(
      LineChartData(
        minY: 80, maxY: 320,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 60,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.borderDark, strokeWidth: 0.5),
          drawVerticalLine: false,
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.goldRoyal,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.goldRoyal.withOpacity(0.25), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

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
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                  fontWeight: FontWeight.w800, color: color)),
            Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEEDBACK ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _FeedbackItem extends StatelessWidget {
  final String type, icon, title, body;

  const _FeedbackItem({
    required this.type, required this.icon,
    required this.title, required this.body,
  });

  bool get isStrength => type == 'strength';

  @override
  Widget build(BuildContext context) {
    final color = isStrength ? AppColors.matrixGreen : AppColors.amberWarning;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                          fontWeight: FontWeight.w700, color: color)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isStrength ? 'STRENGTH' : 'IMPROVE',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 9,
                            fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 12,
                      color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILLER BAR
// ─────────────────────────────────────────────────────────────────────────────
class _FillerBar extends StatelessWidget {
  final String word;
  final int count, total;

  const _FillerBar({required this.word, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(word,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: count / total,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppColors.warningGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('$count',
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 13,
              fontWeight: FontWeight.w700, color: AppColors.amberWarning)),
      ],
    );
  }
}
