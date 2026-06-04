// lib/presentation/screens/post_game/post_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/common/apex_widgets.dart';
import '../../widgets/vibe_meter/vibe_meter.dart';

class PostGameScreen extends StatefulWidget {
  final int sessionId;
  const PostGameScreen({super.key, required this.sessionId});
  @override State<PostGameScreen> createState() => _PostGameScreenState();
}

class _PostGameScreenState extends State<PostGameScreen>
    with SingleTickerProviderStateMixin {
  final _repo = SessionRepository();
  SessionReportEntity? _report;
  bool _loading = true;
  late AnimationController _scoreCtrl;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))
      ..forward();
    _load();
  }

  @override void dispose() { _scoreCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final r = await _repo.getReport(widget.sessionId);
    r.fold(
      (_) => setState(() => _loading = false),
      (report) => setState(() { _report = report; _loading = false; }),
    );
  }

  // Letter grade → color
  Color _gradeColor(String grade) => switch (grade) {
    'S+' => AppColors.goldBright,
    'A'  => AppColors.matrixGreen,
    'B'  => AppColors.accentBlue,
    'C'  => AppColors.amberWarning,
    _    => AppColors.errorRed,
  };

  // Letter grade → message
  String _gradeMsg(String grade) => switch (grade) {
    'S+' => 'APEX PERFORMANCE',
    'A'  => 'EXCELLENT WORK',
    'B'  => 'SOLID DELIVERY',
    'C'  => 'ROOM TO GROW',
    _    => 'KEEP PRACTICING',
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(backgroundColor: AppColors.obsidian,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppColors.goldRoyal),
          const SizedBox(height: 14),
          const Text('Loading your report…',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                color: AppColors.textMuted)),
        ])));
    }

    if (_report == null) {
      return Scaffold(backgroundColor: AppColors.obsidian,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
          const SizedBox(height: 14),
          const Text('Could not load report.',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GoldOutlinedButton(label: 'Go to Dashboard',
            onTap: () => context.go(AppRouter.dashboard)),
        ])));
    }

    final s     = _report!.session;
    final tips  = _report!.coachingTips;
    final grade = s.grade;
    final gColor= _gradeColor(grade);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: CustomScrollView(slivers: [

        // ── Hero header ──────────────────────────────────
        SliverToBoxAdapter(child: Stack(children: [
          // Background
          Container(height: 260, decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gColor.withOpacity(0.12), AppColors.obsidian],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
          )),
          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(children: [
              // App bar row
              Row(children: [
                GestureDetector(onTap: () => context.go(AppRouter.dashboard),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: AppColors.surfaceDark,
                      border: Border.all(color: AppColors.borderDark)),
                    child: const Icon(Icons.close, color: AppColors.textMuted, size: 17))),
                const Spacer(),
                Text('SESSION REPORT', style: const TextStyle(fontFamily: 'Outfit',
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.textMuted, letterSpacing: 1.5)),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
              const SizedBox(height: 22),

              // Grade badge + overall
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedBuilder(animation: _scoreCtrl, builder: (_, __) {
                  final v = Curves.elasticOut.transform(_scoreCtrl.value.clamp(0.0, 1.0));
                  return Transform.scale(scale: v.clamp(0.0, 1.2),
                    child: Container(width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: gColor.withOpacity(0.12),
                        border: Border.all(color: gColor, width: 2.5),
                        boxShadow: [BoxShadow(color: gColor.withOpacity(0.3),
                            blurRadius: 28, spreadRadius: 4)]),
                      child: Center(child: Text(grade, style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 30,
                        fontWeight: FontWeight.w900, color: gColor)))),
                  );
                }),
                const SizedBox(width: 24),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_gradeMsg(grade), style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: gColor, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  AnimatedBuilder(animation: _scoreCtrl, builder: (_, __) {
                    final displayed = (s.overallScore * _scoreCtrl.value).toStringAsFixed(1);
                    return Text('$displayed%', style: const TextStyle(fontFamily: 'Outfit',
                        fontSize: 38, fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary, height: 1));
                  }),
                  Text('${s.durationLabel}  ·  ${s.createdAt.substring(0, 10)}',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 11,
                        color: AppColors.textMuted)),
                ]),
              ]),
            ]),
          )),
        ])),

        // ── Score rings ──────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ScoreRing(score: s.confidenceScore, label: 'CONFIDENCE',
                  color: AppColors.matrixGreen,  size: 80),
              ScoreRing(score: s.enthusiasmScore, label: 'ENTHUSIASM',
                  color: AppColors.goldRoyal,    size: 80),
              ScoreRing(score: s.authorityScore,  label: 'AUTHORITY',
                  color: AppColors.accentBlue,   size: 80),
            ]),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
        )),

        // ── Quick stats ──────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(children: [
            _QuickStat(
              icon:  Icons.warning_amber_rounded,
              value: '${s.fillerWordCount}',
              label: 'Filler Words',
              color: s.fillerWordCount > 5 ? AppColors.errorRed
                   : s.fillerWordCount > 2 ? AppColors.amberWarning
                   : AppColors.matrixGreen,
            ),
            const SizedBox(width: 10),
            _QuickStat(
              icon:  Icons.accessibility_new,
              value: '${s.postureAlerts}',
              label: 'Posture Alerts',
              color: s.postureAlerts > 3 ? AppColors.amberWarning : AppColors.matrixGreen,
            ),
            const SizedBox(width: 10),
            _QuickStat(
              icon:  Icons.timer_outlined,
              value: s.durationLabel,
              label: 'Duration',
              color: AppColors.accentBlue,
            ),
          ]).animate().fadeIn(delay: 320.ms),
        )),

        // ── Coaching tips ────────────────────────────────
        if (tips.isNotEmpty) ...[
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
            child: SectionHeader(
              title: 'AI Coaching Tips',
              sub: '${tips.where((t) => t.isStrength).length} strengths · '
                   '${tips.where((t) => !t.isStrength).length} improvements',
            ),
          )),
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final tip = tips[i];
              return Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18,
                    i == tips.length - 1 ? 0 : 10),
                child: _TipCard(tip: tip)
                  .animate().fadeIn(delay: Duration(milliseconds: 400 + i * 80))
                  .slideX(begin: 0.04, end: 0),
              );
            },
            childCount: tips.length,
          )),
        ],

        // ── Transcription ────────────────────────────────
        if (s.transcription != null && s.transcription!.isNotEmpty)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader(title: 'Transcription'),
              const SizedBox(height: 10),
              GlassCard(padding: const EdgeInsets.all(14),
                child: Text(s.transcription!,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 13,
                      color: AppColors.textSecondary, height: 1.75))),
            ]).animate().fadeIn(delay: 600.ms),
          )),

        // ── CTA buttons ──────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 50),
          child: Column(children: [
            GoldButton(
              label: 'PRACTICE AGAIN',
              icon:  Icons.replay_rounded,
              onTap: () => context.go(AppRouter.livePractice),
            ),
            const SizedBox(height: 12),
            GoldOutlinedButton(
              label: 'BACK TO DASHBOARD',
              icon:  Icons.home_outlined,
              onTap: () => context.go(AppRouter.dashboard),
            ),
          ]).animate().fadeIn(delay: 700.ms),
        )),
      ]),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _QuickStat({required this.icon, required this.value,
      required this.label, required this.color});
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.25))),
    child: Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
          fontWeight: FontWeight.w800, color: color)),
      Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Outfit', fontSize: 9,
            color: AppColors.textMuted, height: 1.3)),
    ]),
  ));
}

class _TipCard extends StatelessWidget {
  final CoachingTipEntity tip;
  const _TipCard({required this.tip});
  @override Widget build(BuildContext context) {
    final isStrength = tip.isStrength;
    final color = isStrength ? AppColors.matrixGreen : AppColors.goldRoyal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.3))),
          child: Center(child: Text(tip.iconEmoji,
              style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(tip.title, style: const TextStyle(fontFamily: 'Outfit',
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6)),
              child: Text(isStrength ? 'STRENGTH' : 'IMPROVE',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 8,
                    fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8))),
          ]),
          const SizedBox(height: 5),
          Text(tip.body, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12,
              color: AppColors.textSecondary, height: 1.6)),
        ])),
      ]),
    );
  }
}
