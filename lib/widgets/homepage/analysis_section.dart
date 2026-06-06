import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class SpeechAnalysisSection extends StatelessWidget {
  final int wordCount;
  final int fillerWordCount;
  final int repeatedWordCount;
  final double speakingSpeed;
  final Map<String, int> frequentWords;

  const SpeechAnalysisSection({
    super.key,
    required this.wordCount,
    required this.fillerWordCount,
    required this.repeatedWordCount,
    required this.speakingSpeed,
    required this.frequentWords,
  });

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
          const Icon(Icons.bar_chart, size: 14, color: AppColors.purpleLight),
          const SizedBox(width: 7),
          const Text('Speech Analysis', style: TextStyle(
            fontFamily: 'Outfit', fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        _stat('Words spoken',   '$wordCount',   Icons.text_fields,   AppColors.accentBlue),
        _stat('Filler words',   '$fillerWordCount', Icons.warning_amber_rounded,
            fillerWordCount > 5 ? AppColors.errorRed
            : fillerWordCount > 2 ? AppColors.amberWarning
            : AppColors.matrixGreen),
        _stat('Repeated words', '$repeatedWordCount', Icons.repeat, AppColors.amberWarning),
        _stat('Speaking speed',
            '${speakingSpeed.toStringAsFixed(1)} WPM', Icons.speed,
            speakingSpeed > 0 && (speakingSpeed < 100 || speakingSpeed > 180)
                ? AppColors.amberWarning : AppColors.matrixGreen),
        if (frequentWords.isNotEmpty) ...[
          const Divider(color: AppColors.borderDark, height: 20),
          const Text('Overused Words', style: TextStyle(
            fontFamily: 'Outfit', fontSize: 12,
            color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: frequentWords.entries.take(6).map((e) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.amberWarning.withOpacity(0.3))),
                child: Text('"${e.key}" ×${e.value}',
                  style: const TextStyle(fontFamily: 'Outfit',
                      fontSize: 11, color: AppColors.amberWarning)),
              )).toList()),
        ],
      ]),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(
        fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary))),
      Text(value, style: TextStyle(fontFamily: 'Outfit',
          fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]));
}
