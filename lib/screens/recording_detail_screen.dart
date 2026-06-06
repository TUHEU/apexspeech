import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';

class RecordingDetailScreen extends StatefulWidget {
  final int recordingId;
  const RecordingDetailScreen({super.key, required this.recordingId});
  @override State<RecordingDetailScreen> createState() => _RecordingDetailScreenState();
}

class _RecordingDetailScreenState extends State<RecordingDetailScreen> {
  Map<String, dynamic>? _recording;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final d = await DatabaseHelper.instance.getRecordingById(widget.recordingId);
    if (mounted) setState(() => _recording = d);
  }

  @override
  Widget build(BuildContext context) {
    if (_recording == null) return Scaffold(backgroundColor: AppColors.obsidian,
      body: const Center(child: CircularProgressIndicator(color: AppColors.purpleLight)));

    Map<String, int> freq = {};
    if (_recording!['frequent_words'] != null) {
      try { freq = Map<String, int>.from(jsonDecode(_recording!['frequent_words'])); } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: Text(_recording!['title'] ?? 'Recording')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_recording!['date_created']?.toString().substring(0, 16) ?? '',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 18),

          // Stats card
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Speech Analysis', style: TextStyle(fontFamily: 'Outfit',
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            _stat('Word Count',     '${_recording!['word_count'] ?? 0}',          AppColors.accentBlue),
            _stat('Filler Words',   '${_recording!['filler_word_count'] ?? 0}',   AppColors.amberWarning),
            _stat('Repeated Words', '${_recording!['repeated_word_count'] ?? 0}', AppColors.amberWarning),
            _stat('Speaking Speed', '${(_recording!['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM', AppColors.matrixGreen),
            if (freq.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Overused Words', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...freq.entries.map((e) => Text('  "${e.key}" — used ${e.value} times',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary))),
            ],
          ])),
          const SizedBox(height: 14),

          // Transcript card
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transcript', style: TextStyle(fontFamily: 'Outfit',
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(
              (_recording!['transcript']?.isEmpty ?? true)
                  ? 'No transcript available'
                  : _recording!['transcript'],
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14,
                  color: AppColors.textSecondary, height: 1.65)),
          ])),

          if (_recording!['ai_feedback'] != null) ...[
            const SizedBox(height: 14),
            _card(borderColor: AppColors.matrixGreen.withOpacity(0.3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.matrixGreen),
                  const SizedBox(width: 7),
                  const Text('AI Feedback', style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 10),
                Text(_recording!['ai_feedback'], style: const TextStyle(
                    fontFamily: 'Outfit', fontSize: 14, color: AppColors.textSecondary, height: 1.65)),
              ])),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _card({required Widget child, Color? borderColor}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor ?? AppColors.borderDark)),
    child: child,
  );

  Widget _stat(String label, String value, Color color) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Outfit',
          fontSize: 13, color: AppColors.textSecondary))),
      Text(value, style: TextStyle(fontFamily: 'Outfit',
          fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]));
}
