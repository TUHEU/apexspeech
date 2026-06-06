import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class TranscriptionPanel extends StatelessWidget {
  final String recognizedText;
  const TranscriptionPanel({super.key, required this.recognizedText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.record_voice_over, size: 14, color: AppColors.purpleLight),
          const SizedBox(width: 7),
          const Text('Live Transcript', style: TextStyle(
            fontFamily: 'Outfit', fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 10),
        Text(
          recognizedText.isEmpty ? 'Speech will appear here...' : recognizedText,
          style: TextStyle(
            fontFamily: 'Outfit', fontSize: 14, height: 1.65,
            color: recognizedText.isEmpty
                ? AppColors.textMuted : AppColors.textSecondary,
            fontStyle: recognizedText.isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ]),
    );
  }
}
