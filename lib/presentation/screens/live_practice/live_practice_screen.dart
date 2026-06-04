// lib/presentation/screens/live_practice/live_practice_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/repositories/repositories.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/common/apex_widgets.dart';
import '../../widgets/vibe_meter/vibe_meter.dart';
import '../../widgets/vibe_meter/modulation_graph.dart';

class LivePracticeScreen extends StatefulWidget {
  final int? scriptId;
  const LivePracticeScreen({super.key, this.scriptId});
  @override State<LivePracticeScreen> createState() => _LivePracticeScreenState();
}

class _LivePracticeScreenState extends State<LivePracticeScreen>
    with TickerProviderStateMixin {
  // ── Repositories ──────────────────────────────────────
  final _sessionRepo = SessionRepository();

  // ── Session state ──────────────────────────────────────
  int?   _sessionId;
  bool   _isRecording   = false;
  bool   _isPaused      = false;
  bool   _starting      = false;
  bool   _finishing     = false;
  int    _elapsedSeconds = 0;

  // ── Live scores ────────────────────────────────────────
  double _confidence    = 0;
  double _enthusiasm    = 0;
  double _authority     = 0;
  int    _fillerCount   = 0;
  int    _postureAlerts = 0;
  String _transcription = '';
  String? _lastFiller;
  bool   _isSlouching   = false;
  List<double> _pitchHistory = [];

  // ── Timers ────────────────────────────────────────────
  Timer? _clockTimer;
  Timer? _audioTimer;   // simulates periodic audio upload
  Timer? _postureTimer; // simulates posture checks
  Timer? _fillerFlash;

  // ── Animation controllers ──────────────────────────────
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  // ── Mock data generator ────────────────────────────────
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _audioTimer?.cancel();
    _postureTimer?.cancel();
    _fillerFlash?.cancel();
    _waveCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Start session ──────────────────────────────────────
  Future<void> _startSession() async {
    setState(() => _starting = true);
    final r = await _sessionRepo.start(widget.scriptId);
    r.fold(
      (f) {
        setState(() => _starting = false);
        _showError(f.message);
      },
      (id) {
        _sessionId = id;
        setState(() { _starting = false; _isRecording = true; });
        _startTimers();
      },
    );
  }

  void _startTimers() {
    // Clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _elapsedSeconds++);
    });

    // Simulate audio feedback every 3s (in production: real mic bytes)
    _audioTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isPaused || _sessionId == null) return;
      _simulateLiveFeedback();
    });

    // Simulate posture events every 5s
    _postureTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isPaused || _sessionId == null) return;
      _simulatePosture();
    });
  }

  /// Simulates live AI feedback (replace with real audio in production)
  void _simulateLiveFeedback() {
    final newConf = (50 + _rng.nextDouble() * 45).clamp(0.0, 100.0);
    final newEnth = (40 + _rng.nextDouble() * 50).clamp(0.0, 100.0);
    final newAuth = (55 + _rng.nextDouble() * 40).clamp(0.0, 100.0);

    setState(() {
      // Rolling average
      final n = max(1, _elapsedSeconds ~/ 3);
      _confidence = ((_confidence * (n - 1) + newConf) / n);
      _enthusiasm = ((_enthusiasm * (n - 1) + newEnth) / n);
      _authority  = ((_authority  * (n - 1) + newAuth) / n);

      // Pitch history for graph
      _pitchHistory.add(180 + 70 * (newConf / 100) + _rng.nextDouble() * 20);
      if (_pitchHistory.length > 36) _pitchHistory.removeAt(0);

      // Random filler word
      if (_rng.nextInt(8) == 0) {
        final fillers = ['um', 'uh', 'like', 'you know', 'basically', 'literally'];
        _fillerCount++;
        _lastFiller = fillers[_rng.nextInt(fillers.length)];
        _fillerFlash?.cancel();
        _fillerFlash = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _lastFiller = null);
        });
      }
    });
  }

  void _simulatePosture() {
    final types = ['slouch', 'confident_gesture', 'eye_contact', 'crossed_arms'];
    final type  = types[_rng.nextInt(types.length)];
    final ts    = _elapsedSeconds.toDouble();

    // Save to backend
    _sessionRepo.savePosture(_sessionId!, {
      'event_type': type, 'timestamp_seconds': ts,
    });

    if (type == 'slouch' || type == 'crossed_arms') {
      setState(() { _isSlouching = true; _postureAlerts++; });
      Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isSlouching = false);
      });
    }
  }

  // ── Pause / resume ──────────────────────────────────────
  void _togglePause() => setState(() => _isPaused = !_isPaused);

  // ── Finish session ──────────────────────────────────────
  Future<void> _finish() async {
    if (_sessionId == null) return;
    setState(() { _finishing = true; _isRecording = false; });
    _clockTimer?.cancel();
    _audioTimer?.cancel();
    _postureTimer?.cancel();

    final r = await _sessionRepo.finish(_sessionId!, _elapsedSeconds);
    if (!mounted) return;
    r.fold(
      (f) { setState(() => _finishing = false); _showError(f.message); },
      (session) => context.pushReplacement(AppRouter.postGame, extra: session.id),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Outfit')),
      backgroundColor: AppColors.errorRed,
    ));
  }

  // ── Format timer ──────────────────────────────────────
  String get _timerLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(children: [
        // Background gradient
        Container(decoration: const BoxDecoration(gradient: RadialGradient(
          center: Alignment(0, -0.3), radius: 0.7,
          colors: [Color(0xFF140E00), AppColors.obsidian],
        ))),

        SafeArea(child: Column(children: [
          _buildTopBar(context),
          Expanded(child: _isRecording
            ? _buildRecordingUI()
            : _buildPreLaunchUI()),
          _buildBottomBar(),
        ])),

        // Filler word flash overlay
        if (_lastFiller != null)
          Positioned(top: 100, right: 16,
            child: _FillerFlash(word: _lastFiller!)
              .animate().fadeIn(duration: 200.ms).slideX(begin: 0.3, end: 0)),

        // Slouch alert overlay
        if (_isSlouching)
          Positioned(top: 100, left: 16,
            child: _PostureAlert()
              .animate().fadeIn(duration: 200.ms).slideX(begin: -0.3, end: 0)),

        // Finishing overlay
        if (_finishing)
          Container(color: Colors.black87,
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: AppColors.goldRoyal),
              SizedBox(height: 16),
              Text('Generating your report…',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                    color: AppColors.textSecondary)),
            ]))),
      ]),
    );
  }

  // ── Top bar ────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      GestureDetector(
        onTap: _isRecording ? null : () => context.pop(),
        child: Container(width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: AppColors.surfaceDark,
            border: Border.all(color: AppColors.borderDark)),
          child: Icon(_isRecording ? Icons.close : Icons.arrow_back_ios_new,
              color: AppColors.textMuted, size: 15)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LIVE PRACTICE', style: TextStyle(fontFamily: 'Outfit',
            fontSize: 13, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: 1.5)),
        Text(_isRecording ? _timerLabel : 'Ready to begin',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
              color: _isRecording ? AppColors.goldRoyal : AppColors.textMuted)),
      ])),
      if (_isRecording) Row(children: [
        PulseDot(color: AppColors.errorRed, size: 7),
        const SizedBox(width: 6),
        const Text('LIVE', style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
            fontWeight: FontWeight.w700, color: AppColors.errorRed, letterSpacing: 1.5)),
      ]),
    ]),
  );

  // ── Pre-launch UI ──────────────────────────────────────
  Widget _buildPreLaunchUI() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Mic icon with glow
      AnimatedBuilder(animation: _glowAnim, builder: (_, __) =>
        Container(width: 120, height: 120,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: AppColors.goldDim,
            border: Border.all(color: AppColors.goldRoyal, width: 1.5),
            boxShadow: [BoxShadow(
              color: AppColors.goldGlow.withOpacity(_glowAnim.value * 0.5),
              blurRadius: 40, spreadRadius: 10)]),
          child: const Icon(Icons.mic_rounded, color: AppColors.goldBright, size: 54)),
      ).animate().scale(begin: const Offset(0.8, 0.8),
          duration: 700.ms, curve: Curves.elasticOut),

      const SizedBox(height: 28),
      ShaderMask(shaderCallback: (b) => AppColors.goldGradient.createShader(b),
        blendMode: BlendMode.srcIn,
        child: const Text('Ready to Perform?',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Outfit', fontSize: 24,
              fontWeight: FontWeight.w800))),
      const SizedBox(height: 10),
      const Text(
        'AI will track your posture, detect filler words,\nand score your confidence in real-time.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
            color: AppColors.textMuted, height: 1.65)),
      const SizedBox(height: 32),

      // Feature badges
      Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
        _FeatureBadge('🎤 Vocal AI',     AppColors.goldRoyal),
        _FeatureBadge('👁 Posture',       AppColors.accentBlue),
        _FeatureBadge('⚡ Filler Detect', AppColors.amberWarning),
        _FeatureBadge('📊 Live Score',    AppColors.matrixGreen),
      ]).animate().fadeIn(delay: 200.ms),
    ]),
  );

  // ── Recording UI ──────────────────────────────────────
  Widget _buildRecordingUI() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Column(children: [
      const SizedBox(height: 8),

      // Vibe Meter
      VibeMeter(
        confidence: _confidence,
        enthusiasm: _enthusiasm,
        isActive:   !_isPaused,
        size:       200,
      ).animate().scale(begin: const Offset(0.85, 0.85),
          duration: 600.ms, curve: Curves.elasticOut),

      const SizedBox(height: 20),

      // Three score rings
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ScoreRing(score: _confidence, label: 'CONF.',   color: AppColors.matrixGreen,  size: 72),
        ScoreRing(score: _enthusiasm, label: 'ENTHU.',  color: AppColors.goldRoyal,    size: 72),
        ScoreRing(score: _authority,  label: 'AUTH.',   color: AppColors.accentBlue,   size: 72),
      ]).animate().fadeIn(delay: 150.ms),

      const SizedBox(height: 20),

      // Pitch graph
      GlassCard(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VOICE MODULATION', style: TextStyle(fontFamily: 'Outfit',
              fontSize: 9, fontWeight: FontWeight.w600,
              color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ModulationGraph(data: _pitchHistory, height: 72),
        ],
      )).animate().fadeIn(delay: 200.ms),

      const SizedBox(height: 14),

      // Stats row: filler + posture
      Row(children: [
        Expanded(child: _StatPill(
          icon: Icons.warning_amber_rounded,
          label: 'FILLERS',
          value: '$_fillerCount',
          color: _fillerCount > 5 ? AppColors.errorRed
               : _fillerCount > 2 ? AppColors.amberWarning
               : AppColors.matrixGreen,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatPill(
          icon: Icons.accessibility_new,
          label: 'POSTURE',
          value: _postureAlerts > 0 ? '⚠ $_postureAlerts' : '✓ Good',
          color: _postureAlerts > 2 ? AppColors.amberWarning : AppColors.matrixGreen,
        )),
      ]).animate().fadeIn(delay: 250.ms),

      const SizedBox(height: 14),

      // Transcription preview
      if (_transcription.isNotEmpty || _elapsedSeconds > 3)
        GlassCard(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.record_voice_over, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 6),
              const Text('LIVE TRANSCRIPT', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 9, fontWeight: FontWeight.w600,
                  color: AppColors.textMuted, letterSpacing: 1.5)),
              const Spacer(),
              AnimatedBuilder(animation: _waveCtrl, builder: (_, __) => Row(
                children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2.5,
                  height: 8 + 10 * sin((_waveCtrl.value + i * 0.4) * pi),
                  decoration: BoxDecoration(
                    color: AppColors.matrixGreen.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2)),
                )),
              )),
            ]),
            const SizedBox(height: 8),
            Text(
              _transcription.isEmpty
                ? 'Listening to your voice…'
                : _transcription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                color: _transcription.isEmpty
                    ? AppColors.textMuted : AppColors.textSecondary,
                height: 1.6, fontStyle: _transcription.isEmpty
                    ? FontStyle.italic : FontStyle.normal),
            ),
          ],
        )).animate().fadeIn(delay: 300.ms),

      const SizedBox(height: 90),
    ]),
  );

  // ── Bottom bar ────────────────────────────────────────
  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    decoration: const BoxDecoration(
      color: AppColors.surfaceDark,
      border: Border(top: BorderSide(color: AppColors.borderDark)),
    ),
    child: _isRecording
      ? Row(children: [
          // Pause button
          GestureDetector(
            onTap: _togglePause,
            child: Container(width: 52, height: 52,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.cardDark,
                border: Border.all(color: AppColors.borderDark)),
              child: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: AppColors.textSecondary, size: 24)),
          ),
          const SizedBox(width: 14),
          // Stop / finish
          Expanded(child: GoldButton(
            label:     _finishing ? 'Finishing…' : 'FINISH SESSION',
            icon:      Icons.stop_rounded,
            isLoading: _finishing,
            onTap:     _finishing ? null : _finish,
          )),
        ])
      : GoldButton(
          label:     _starting ? 'Starting…' : 'START PRACTICE',
          icon:      Icons.mic_rounded,
          isLoading: _starting,
          onTap:     _starting ? null : _startSession,
        ),
  );
}

// ── Supporting widgets ────────────────────────────────────

class _FeatureBadge extends StatelessWidget {
  final String label; final Color color;
  const _FeatureBadge(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35))),
    child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
        fontWeight: FontWeight.w600, color: color)),
  );
}

class _StatPill extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatPill({required this.icon, required this.label,
      required this.value, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.25))),
    child: Row(children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 8,
            color: color.withOpacity(0.8), letterSpacing: 1.2,
            fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 15,
            fontWeight: FontWeight.w800, color: color)),
      ]),
    ]),
  );
}

class _FillerFlash extends StatelessWidget {
  final String word;
  const _FillerFlash({required this.word});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: AppColors.amberWarning.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.amberWarning.withOpacity(0.5)),
      boxShadow: [BoxShadow(color: AppColors.amberWarning.withOpacity(0.2),
          blurRadius: 12)]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warning_amber_rounded, color: AppColors.amberWarning, size: 14),
      const SizedBox(width: 6),
      Text('Filler: "$word"', style: const TextStyle(fontFamily: 'Outfit',
          fontSize: 12, fontWeight: FontWeight.w700,
          color: AppColors.amberWarning)),
    ]),
  );
}

class _PostureAlert extends StatelessWidget {
  const _PostureAlert();
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.errorRed.withOpacity(0.4)),
      boxShadow: [BoxShadow(color: AppColors.errorRed.withOpacity(0.2), blurRadius: 12)]),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.accessibility_new, color: AppColors.errorRed, size: 14),
      SizedBox(width: 6),
      Text('Slouching detected!', style: TextStyle(fontFamily: 'Outfit',
          fontSize: 12, fontWeight: FontWeight.w700,
          color: AppColors.errorRed)),
    ]),
  );
}
