// lib/presentation/screens/live_practice/live_practice_screen.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/apex_widgets.dart';
import '../../widgets/vibe_meter/vibe_meter.dart';
import '../../widgets/modulation_graph/modulation_graph.dart';

class LivePracticeScreen extends StatefulWidget {
  final Map<String, dynamic>? sessionData;
  const LivePracticeScreen({super.key, this.sessionData});

  @override
  State<LivePracticeScreen> createState() => _LivePracticeScreenState();
}

class _LivePracticeScreenState extends State<LivePracticeScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _showTeleprompter = true;
  bool _isSlouchingDetected = false;
  bool _isConfidentGesture = false;
  String? _latestFillerWord;
  double _confidenceScore = 0;
  double _enthusiasmScore = 0;
  int _sessionSeconds = 0;
  final List<double> _pitchHistory = [];

  late AnimationController _timerCtrl;
  late AnimationController _fillerCtrl;
  late AnimationController _postureCtrl;

  // Teleprompter content
  final String _script = '''Ladies and gentlemen, visionary leaders of tomorrow —

The future doesn't wait. It rewards those bold enough to seize it.

Our company stands at the apex of a transformational moment. The product we've built doesn't just solve a problem — it redefines the standard of excellence in our industry.

Our team isn't just working hard — they're architecting the future. And the opportunity before us isn't just good timing. It's generational.

The question isn't whether we act. The question is: how brilliantly will we execute?

I invite you to join us in building something extraordinary.

The future belongs to the prepared.''';

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(vsync: this, duration: const Duration(hours: 1));
    _fillerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _postureCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    _fillerCtrl.dispose();
    _postureCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      _startMockSession();
    }
  }

  void _startMockSession() {
    // Simulate live AI feedback
    Future.doWhile(() async {
      if (!_isRecording || !mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _sessionSeconds++;
        _confidenceScore = 55 + 35 * sin(_sessionSeconds * 0.12);
        _enthusiasmScore = 45 + 40 * cos(_sessionSeconds * 0.09);
        _pitchHistory.add(200 + 80 * sin(_sessionSeconds * 0.3) + (Random().nextDouble() * 40 - 20));
        if (_pitchHistory.length > 40) _pitchHistory.removeAt(0);

        // Simulate filler word detection
        if (_sessionSeconds % 8 == 0) {
          final words = ['um', 'uh', 'like', 'you know', 'basically'];
          _latestFillerWord = words[Random().nextInt(words.length)];
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _latestFillerWord = null);
          });
        }

        // Simulate posture alerts
        _isSlouchingDetected = _sessionSeconds % 15 == 0;
        if (_isSlouchingDetected) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _isSlouchingDetected = false);
          });
        }

        // Simulate confident gesture
        _isConfidentGesture = _sessionSeconds % 12 == 0;
        if (_isConfidentGesture) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _isConfidentGesture = false);
          });
        }
      });
      return true;
    });
  }

  void _endSession() {
    setState(() => _isRecording = false);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('End Session?',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 20,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Session duration: ${_sessionSeconds ~/ 60}m ${_sessionSeconds % 60}s',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            GoldButton(
              label: 'View Post-Game Report',
              prefixIcon: Icons.bar_chart_rounded,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.postGame, extra: 'session_mock_id');
              },
            ),
            const SizedBox(height: 12),
            GoldOutlinedButton(
              label: 'Continue Practice',
              onTap: () {
                Navigator.pop(context);
                _toggleRecording();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String get _timerLabel {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera Preview Placeholder ──────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.3),
                  radius: 0.8,
                  colors: [Color(0xFF0D1A0D), Color(0xFF050508)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecording ? Icons.videocam : Icons.videocam_off,
                      color: AppColors.textMuted.withOpacity(0.3),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording ? 'Camera Active (MediaPipe)' : 'Tap REC to start',
                      style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 12,
                        color: AppColors.textMuted.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Posture Overlay (when active) ───────────────
          if (_isRecording)
            Positioned.fill(
              child: CustomPaint(
                painter: _PostureSkeletonPainter(
                  isVisible: _isRecording,
                  phase: _sessionSeconds * 0.1,
                ),
              ),
            ),

          // ── Filler Word Alert ───────────────────────────
          if (_latestFillerWord != null)
            Positioned(
              top: 80,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.errorGlow, blurRadius: 20)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'FILLER WORD: "${_latestFillerWord!.toUpperCase()}"',
                        style: const TextStyle(
                          fontFamily: 'Outfit', fontSize: 13,
                          fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(begin: const Offset(0.8, 0.8), duration: 200.ms, curve: Curves.elasticOut),
              ),
            ),

          // ── Posture Alert ───────────────────────────────
          if (_isSlouchingDetected)
            Positioned(
              top: 120,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.amberWarning,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.amberGlow, blurRadius: 20)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⚠️', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('SLOUCHING DETECTED — STAND TALL',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                            fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

          // ── Confident Gesture Badge ─────────────────────
          if (_isConfidentGesture)
            Positioned(
              top: 120,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.matrixGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.greenGlow, blurRadius: 20)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✅', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('CONFIDENT GESTURE DETECTED',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                            fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

          // ── Top HUD ─────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => context.go(AppRouter.dashboard),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Timer
                    if (_isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.errorRed.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PulseDot(),
                            const SizedBox(width: 6),
                            Text(_timerLabel,
                              style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 14,
                                fontWeight: FontWeight.w700, color: Colors.white,
                              )),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Toggle teleprompter
                    GestureDetector(
                      onTap: () => setState(() => _showTeleprompter = !_showTeleprompter),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Icon(
                          _showTeleprompter ? Icons.subtitles : Icons.subtitles_off,
                          color: AppColors.goldRoyal, size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Teleprompter Overlay ─────────────────────────
          if (_showTeleprompter)
            Positioned(
              left: 16, right: 16, top: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.goldDim.withOpacity(0.4)),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      child: Text(
                        _script,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom Panel ─────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      border: const Border(
                        top: BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Vibe Meter + Scores
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Scores left
                            Column(
                              children: [
                                ScoreRing(score: _confidenceScore.clamp(0, 100), label: 'CONFIDENCE', color: AppColors.matrixGreen, size: 68),
                              ],
                            ),
                            // Vibe meter center
                            VibeMeter(
                              confidenceScore: _confidenceScore,
                              enthusiasmScore: _enthusiasmScore,
                              isActive: _isRecording,
                              size: 120,
                            ),
                            // Scores right
                            Column(
                              children: [
                                ScoreRing(score: _enthusiasmScore.clamp(0, 100), label: 'ENTHUSIASM', color: AppColors.goldRoyal, size: 68),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Modulation graph
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text('VOCAL MODULATION',
                                  style: TextStyle(
                                    fontFamily: 'Outfit', fontSize: 9,
                                    color: AppColors.textMuted, letterSpacing: 1.5,
                                  )),
                              ),
                              ModulationGraph(pitchData: _pitchHistory, height: 56),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Record / Stop buttons
                        Row(
                          children: [
                            if (_isRecording) ...[
                              Expanded(
                                child: GestureDetector(
                                  onTap: _endSession,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.errorRed.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.errorRed.withOpacity(0.5)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.stop_rounded, color: AppColors.errorRed, size: 20),
                                        SizedBox(width: 6),
                                        Text('END SESSION',
                                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                                              fontWeight: FontWeight.w700, color: AppColors.errorRed, letterSpacing: 1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: _toggleRecording,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: _isRecording
                                      ? const LinearGradient(colors: [Color(0xFF1A0000), Color(0xFF0D0000)])
                                      : AppColors.goldGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isRecording ? AppColors.errorRed : AppColors.goldRoyal,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isRecording ? AppColors.errorGlow : AppColors.goldGlow,
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isRecording ? Icons.pause_rounded : Icons.mic_rounded,
                                        color: _isRecording ? AppColors.errorRed : AppColors.obsidian,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isRecording ? 'PAUSE' : 'REC',
                                        style: TextStyle(
                                          fontFamily: 'Outfit', fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: _isRecording ? AppColors.errorRed : AppColors.obsidian,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PostureSkeletonPainter extends CustomPainter {
  final bool isVisible;
  final double phase;

  const _PostureSkeletonPainter({required this.isVisible, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isVisible) return;

    final paint = Paint()
      ..color = AppColors.matrixGreen.withOpacity(0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.matrixGreen.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.5;
    final bounce = sin(phase) * 4;

    // Body landmarks
    final points = {
      'head': Offset(cx, size.height * 0.18 + bounce),
      'neck': Offset(cx, size.height * 0.24 + bounce),
      'lShoulder': Offset(cx - 55, size.height * 0.30 + bounce),
      'rShoulder': Offset(cx + 55, size.height * 0.30 + bounce),
      'lElbow': Offset(cx - 75, size.height * 0.44 + bounce),
      'rElbow': Offset(cx + 75, size.height * 0.44 + bounce),
      'lWrist': Offset(cx - 85, size.height * 0.56 + bounce),
      'rWrist': Offset(cx + 85, size.height * 0.56 + bounce),
      'lHip': Offset(cx - 40, size.height * 0.58 + bounce),
      'rHip': Offset(cx + 40, size.height * 0.58 + bounce),
    };

    // Connections
    final connections = [
      ['head', 'neck'], ['neck', 'lShoulder'], ['neck', 'rShoulder'],
      ['lShoulder', 'lElbow'], ['rShoulder', 'rElbow'],
      ['lElbow', 'lWrist'], ['rElbow', 'rWrist'],
      ['lShoulder', 'lHip'], ['rShoulder', 'rHip'],
      ['lHip', 'rHip'],
    ];

    for (final conn in connections) {
      final p1 = points[conn[0]]!;
      final p2 = points[conn[1]]!;
      canvas.drawLine(p1, p2, paint);
    }

    // Dots at joints
    for (final pt in points.values) {
      canvas.drawCircle(pt, 4, dotPaint);
    }

    // Head circle
    canvas.drawCircle(points['head']!, 16, paint);
  }

  @override
  bool shouldRepaint(_PostureSkeletonPainter old) =>
    old.phase != phase || old.isVisible != isVisible;
}
