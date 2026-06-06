import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';
import 'recording_detail_screen.dart';

class RecordingsScreen extends StatefulWidget {
  final bool embedded;
  const RecordingsScreen({super.key, this.embedded = false});
  @override State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  List<Map<String, dynamic>> _recordings = [];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllRecordings();
    if (mounted) setState(() => _recordings = data);
  }

  Future<void> _delete(int id, String path) async {
    await DatabaseHelper.instance.deleteRecording(id);
    final f = File(path);
    if (await f.exists()) await f.delete();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final body = _recordings.isEmpty
      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.mic_none, size: 60, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('No recordings yet', style: TextStyle(fontFamily: 'Outfit',
              fontSize: 16, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          const Text('Record a speech to see it here', style: TextStyle(
              fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
        ]))
      : ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _recordings.length,
          itemBuilder: (ctx, i) {
            final r = _recordings[i];
            final preview = (r['transcript'] ?? '').toString();
            final short   = preview.isEmpty ? 'No transcription'
                : preview.length > 80 ? '${preview.substring(0, 80)}…' : preview;
            return GestureDetector(
              onTap: () => Navigator.push(ctx, MaterialPageRoute(
                builder: (_) => RecordingDetailScreen(recordingId: r['id'])))
                .then((_) => _load()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.borderDark)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(r['title'] ?? 'Recording',
                      style: const TextStyle(fontFamily: 'Outfit',
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                    IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 18),
                      onPressed: () => _delete(r['id'], r['audio_path'] ?? '')),
                  ]),
                  const SizedBox(height: 5),
                  Text(short, style: const TextStyle(fontFamily: 'Outfit',
                      fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    _chip(Icons.text_fields, '${r['word_count'] ?? 0} words'),
                    _chip(Icons.speed, '${(r['speaking_speed'] ?? 0.0).toStringAsFixed(1)} WPM'),
                    _chip(Icons.calendar_today, (r['date_created'] ?? '').toString().substring(0, 10)),
                  ]),
                ]),
              ),
            );
          },
        );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: const Text('RECORDINGS')), body: body);
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.purpleLight.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.purpleLight.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: AppColors.purpleLight),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontFamily: 'Outfit',
          fontSize: 10, color: AppColors.purpleLight)),
    ]),
  );
}
