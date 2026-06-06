import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';
import 'recordings_screen.dart';
import 'progress_dashboard_screen.dart'; // ← added this line

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final SpeechToText _stt = SpeechToText();
  late AnimationController _pulseCtrl;

  bool _isRecording = false;
  bool _recorderReady = false;
  bool _isSaving = false;
  String? _audioPath;
  String _transcript = '';
  int _wordCount = 0;
  int _fillerCount = 0;
  int _repeatedCount = 0;
  double _speed = 0;
  Map<String, int> _frequentWords = {};
  DateTime? _startTime;

  final _fillers = [
    'um',
    'uh',
    'like',
    'you know',
    'basically',
    'actually',
    'literally',
  ];

  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      await Permission.microphone.request();
      await _recorder.openRecorder();
      setState(() => _recorderReady = true);
    } catch (e) {
      debugPrint('Recorder init error: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_recorderReady) {
      _snack('Recorder not ready, please wait');
      return;
    }
    bool enabled = await _stt.initialize(
      onStatus: (s) {
        if (s == 'done' && _isRecording) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isRecording && mounted) _startSTT();
          });
        }
      },
      onError: (e) {
        if (e.errorMsg != 'error_busy' && _isRecording) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isRecording && mounted) _startSTT();
          });
        }
      },
    );
    if (!enabled) {
      _snack('Speech recognition unavailable');
      return;
    }

    await _startSTT();
    await Future.delayed(const Duration(milliseconds: 500));

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );

    _startTime = DateTime.now();
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _audioPath = path;
      _transcript = '';
      _wordCount = 0;
      _fillerCount = 0;
      _repeatedCount = 0;
      _speed = 0;
      _frequentWords = {};
    });
  }

  Future<void> _startSTT() async {
    if (_stt.isListening) return;
    await _stt.listen(
      onResult: (r) {
        if (mounted) {
          setState(() => _transcript = r.recognizedWords);
          _analyze();
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 8),
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> _stopRecording() async {
    setState(() => _isSaving = true);
    try {
      await _stt.stop();
      await Future.delayed(const Duration(milliseconds: 300));
      final path = await _recorder.stopRecorder();
      _calcSpeed();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _isSaving = false;
      });

      // Auto-save to database
      await DatabaseHelper.instance.insertRecording({
        'title': 'Session ${DateTime.now().toString().substring(0, 16)}',
        'audio_path': path ?? '',
        'transcript': _transcript,
        'word_count': _wordCount,
        'filler_word_count': _fillerCount,
        'repeated_word_count': _repeatedCount,
        'speaking_speed': _speed,
        'frequent_words': jsonEncode(_frequentWords),
        'date_created': DateTime.now().toIso8601String(),
      });

      _snack('Session saved successfully ✓', color: AppColors.matrixGreen);
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isSaving = false;
      });
      _snack('Error stopping: $e');
    }
  }

  void _analyze() {
    final words = _transcript
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    _wordCount = words.length;
    _fillerCount = 0;
    for (final f in _fillers) {
      _fillerCount += words.where((w) => w == f).length;
    }
    _repeatedCount = 0;
    for (var i = 1; i < words.length; i++) {
      if (words[i] == words[i - 1]) _repeatedCount++;
    }
    final freq = <String, int>{};
    for (final w in words) {
      if (w.isNotEmpty) freq[w] = (freq[w] ?? 0) + 1;
    }
    setState(() {
      _frequentWords = Map.fromEntries(
        freq.entries.where((e) => e.value > 1).toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
    });
  }

  void _calcSpeed() {
    if (_startTime == null) return;
    final mins = DateTime.now().difference(_startTime!).inSeconds / 60;
    if (mins > 0) setState(() => _speed = _wordCount / mins);
  }

  void _snack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: color ?? AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _stt.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(
      title: const Text('APEX SPEECH'),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.purpleLight),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    ),
    body: IndexedStack(
      index: _navIndex,
      children: [_recordTab(), _historyTab(), _progressTab()],
    ),
    bottomNavigationBar: _bottomNav(),
  );

  Widget _recordTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        const SizedBox(height: 20),

        // Mic indicator
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final scale = _isRecording ? 1.0 + _pulseCtrl.value * 0.08 : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? AppColors.errorRed.withOpacity(0.15)
                      : AppColors.purpleDark.withOpacity(0.3),
                  border: Border.all(
                    color: _isRecording
                        ? AppColors.errorRed
                        : AppColors.purpleLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isRecording
                                  ? AppColors.errorRed
                                  : AppColors.purpleLight)
                              .withOpacity(0.3),
                      blurRadius: _isRecording ? 30 : 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 60,
                  color: _isRecording
                      ? AppColors.errorRed
                      : AppColors.purpleLight,
                ),
              ),
            );
          },
        ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),

        const SizedBox(height: 16),
        Text(
          _isRecording ? 'Recording...' : 'Ready to Record',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        if (_isRecording) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: AppColors.errorRed,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),

        // Record button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaving
                  ? AppColors.textMuted
                  : _isRecording
                  ? AppColors.errorRed
                  : AppColors.purpleLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isSaving
                ? null
                : _isRecording
                ? _stopRecording
                : _startRecording,
            child: _isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _isRecording ? 'STOP RECORDING' : 'START RECORDING',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 24),

        // Transcript
        if (_transcript.isNotEmpty || _isRecording) ...[
          _card(
            title: 'Live Transcript',
            icon: Icons.record_voice_over,
            child: Text(
              _transcript.isEmpty ? 'Listening...' : _transcript,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: _transcript.isEmpty
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
                height: 1.65,
                fontStyle: _transcript.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Analysis
        _card(
          title: 'Speech Analysis',
          icon: Icons.bar_chart,
          child: Column(
            children: [
              _stat(
                'Words spoken',
                '$_wordCount',
                Icons.text_fields,
                AppColors.accentBlue,
              ),
              _stat(
                'Filler words',
                '$_fillerCount',
                Icons.warning_amber_rounded,
                _fillerCount > 5
                    ? AppColors.errorRed
                    : _fillerCount > 2
                    ? AppColors.amberWarning
                    : AppColors.matrixGreen,
              ),
              _stat(
                'Repeated words',
                '$_repeatedCount',
                Icons.repeat,
                AppColors.amberWarning,
              ),
              _stat(
                'Speaking speed',
                '${_speed.toStringAsFixed(1)} WPM',
                Icons.speed,
                _speed > 0 && (_speed < 100 || _speed > 180)
                    ? AppColors.amberWarning
                    : AppColors.matrixGreen,
              ),
              if (_frequentWords.isNotEmpty) ...[
                const Divider(color: AppColors.borderDark, height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Overused Words',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _frequentWords.entries
                      .take(6)
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amberWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.amberWarning.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '"${e.key}" ×${e.value}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: AppColors.amberWarning,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        if (_audioPath != null)
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  'Playback',
                  Icons.play_arrow_rounded,
                  () => Navigator.pushNamed(
                    context,
                    '/playback',
                    arguments: _audioPath,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  'AI Feedback',
                  Icons.auto_awesome,
                  () => Navigator.pushNamed(context, '/feedback'),
                ),
              ),
            ],
          ),

        const SizedBox(height: 80),
      ],
    ),
  );

  Widget _historyTab() => const RecordingsScreen(embedded: true);

  Widget _progressTab() => const ProgressDashboardScreen(embedded: true);

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderDark),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.purpleLight),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _stat(String label, String value, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.purpleDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.purpleLight.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.purpleLight),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purpleLight,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _bottomNav() => Container(
    decoration: const BoxDecoration(
      color: AppColors.surfaceDark,
      border: Border(top: BorderSide(color: AppColors.borderDark)),
    ),
    child: SafeArea(
      child: SizedBox(
        height: 58,
        child: Row(
          children:
              [
                ('Record', Icons.mic_rounded, Icons.mic_outlined),
                ('History', Icons.history_rounded, Icons.history),
                ('Progress', Icons.bar_chart_rounded, Icons.bar_chart_outlined),
              ].asMap().entries.map((e) {
                final sel = _navIndex == e.key;
                final (label, fill, out) = e.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _navIndex = e.key),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sel ? fill : out,
                          color: sel
                              ? AppColors.purpleLight
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel
                                ? AppColors.purpleLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    ),
  );
}
