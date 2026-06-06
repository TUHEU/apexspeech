import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Map<String, dynamic>? _recording;
  String _feedback = '';
  bool _loading = false;
  bool _generated = false;

  // Replace with your real key when available — mock feedback works without it
  static const String _apiKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)?.settings.arguments;
      if (id != null) _load(id as int);
    });
  }

  Future<void> _load(int id) async {
    final d = await DatabaseHelper.instance.getRecordingById(id);
    if (mounted) setState(() {
      _recording = d;
      if (d?['ai_feedback'] != null) { _feedback = d!['ai_feedback']; _generated = true; }
    });
  }

  Future<void> _getFeedback() async {
    if (_recording == null) return;
    setState(() { _loading = true; _feedback = ''; });

    // Mock feedback if no API key
    if (_apiKey.isEmpty || _apiKey.startsWith('sk-your')) {
      await Future.delayed(const Duration(seconds: 1));
      final words   = _recording!['word_count'] ?? 0;
      final fillers = _recording!['filler_word_count'] ?? 0;
      final speed   = (_recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1);
      final fb = '''
📊 OVERALL SCORE: ${_calcScore(fillers, double.tryParse(speed) ?? 0)}/10

✅ STRENGTHS
${words > 50 ? '• Good length — you spoke $words words, showing solid preparation.' : '• You got started — practice builds confidence over time.'}
• Your recording was successfully captured and transcribed.

⚠️ FILLER WORDS ($fillers detected)
${fillers == 0 ? '• Excellent! Zero filler words detected — clean delivery.' : fillers <= 3 ? '• Just $fillers filler words — great control! Keep it up.' : '• $fillers filler words detected. Try replacing each with a deliberate 2-second pause.'}

⏱️ SPEAKING SPEED ($speed WPM)
${_speedFeedback(double.tryParse(speed) ?? 0)}

💡 3 TIPS TO IMPROVE
1. Record yourself daily for 2 minutes — consistency beats perfection.
2. Pause intentionally after key points to let ideas land.
3. Vary your sentence length — short sentences create impact.
''';
      await DatabaseHelper.instance.updateRecording(_recording!['id'], {'ai_feedback': fb});
      if (mounted) setState(() { _feedback = fb; _generated = true; _loading = false; });
      return;
    }

    // Real OpenAI call
    try {
      final prompt = '''
You are a professional speech coach. Analyze this speech and provide detailed feedback.

Speech Data:
- Transcript: ${_recording!['transcript'] ?? 'No transcript'}
- Word Count: ${_recording!['word_count'] ?? 0}
- Filler Words Used: ${_recording!['filler_word_count'] ?? 0}
- Repeated Words: ${_recording!['repeated_word_count'] ?? 0}
- Speaking Speed: ${(_recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM
- Overused Words: ${_recording!['frequent_words'] ?? 'None'}

Provide: 1) Overall Score (out of 10), 2) Strengths, 3) Filler word feedback,
4) Speed feedback (ideal 120-150 WPM), 5) Repeated words, 6) 3 specific improvement tips.
Keep feedback encouraging but honest.
''';
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
        body: jsonEncode({'model': 'gpt-3.5-turbo',
          'messages': [{'role': 'user', 'content': prompt}], 'max_tokens': 800}),
      );
      if (res.statusCode == 200) {
        final fb = jsonDecode(res.body)['choices'][0]['message']['content'];
        await DatabaseHelper.instance.updateRecording(_recording!['id'], {'ai_feedback': fb});
        if (mounted) setState(() { _feedback = fb; _generated = true; _loading = false; });
      } else {
        if (mounted) setState(() { _feedback = 'Error: Check API key.'; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _feedback = 'Error: $e'; _loading = false; });
    }
  }

  int _calcScore(int fillers, double speed) {
    int score = 8;
    if (fillers > 10) score -= 3;
    else if (fillers > 5) score -= 2;
    else if (fillers > 2) score -= 1;
    if (speed > 0 && (speed < 100 || speed > 200)) score -= 1;
    return score.clamp(3, 10);
  }

  String _speedFeedback(double speed) {
    if (speed == 0) return '• Record a longer session to measure speed accurately.';
    if (speed < 100) return '• Too slow ($speed WPM). Try to speak a bit faster to maintain audience engagement.';
    if (speed > 180) return '• Too fast ($speed WPM). Slow down and give your audience time to absorb your words.';
    return '• Perfect speed ($speed WPM). You\'re in the ideal 120-180 WPM range — keep it up!';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.obsidian,
    appBar: AppBar(title: const Text('AI FEEDBACK')),
    body: _recording == null
      ? const Center(child: CircularProgressIndicator(color: AppColors.purpleLight))
      : SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(children: [
          // Summary
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.purpleDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.purpleLight.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recording Summary', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Text('Words: ${_recording!['word_count'] ?? 0}',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary)),
              Text('Filler Words: ${_recording!['filler_word_count'] ?? 0}',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary)),
              Text('Speed: ${(_recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary)),
            ])),
          const SizedBox(height: 18),

          if (!_generated) SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: _loading ? null : _getFeedback,
            child: _loading
              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('Generating feedback…', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: Colors.white)),
                ])
              : const Text('✨ GET AI FEEDBACK', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)))),

          if (_feedback.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.matrixGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.matrixGreen.withOpacity(0.25))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.matrixGreen),
                  const SizedBox(width: 7),
                  const Text('Your Feedback', style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Text(_feedback, style: const TextStyle(fontFamily: 'Outfit',
                    fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                if (_generated) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.purpleLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _getFeedback,
                    child: const Text('Regenerate', style: TextStyle(
                        fontFamily: 'Outfit', color: AppColors.purpleLight)))),
                ],
              ])),
          ],
          const SizedBox(height: 40),
        ])),
  );
}
