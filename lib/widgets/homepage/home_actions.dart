import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class HomeActionButtons extends StatelessWidget {
  final String? audioPath;
  final VoidCallback onPlayback;
  final VoidCallback onFeedback;
  final VoidCallback onViewRecordings;

  const HomeActionButtons({
    super.key,
    required this.audioPath,
    required this.onPlayback,
    required this.onFeedback,
    required this.onViewRecordings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Playback + Feedback in a row
      Row(children: [
        Expanded(child: _btn('Playback', Icons.play_arrow_rounded,
            audioPath == null ? null : onPlayback)),
        const SizedBox(width: 10),
        Expanded(child: _btn('AI Feedback', Icons.auto_awesome, onFeedback)),
      ]),
      const SizedBox(height: 10),
      // View Recordings full width
      SizedBox(width: double.infinity,
        child: _btn('View Recordings', Icons.history_rounded, onViewRecordings,
            fullWidth: true)),
    ]);
  }

  Widget _btn(String label, IconData icon, VoidCallback? onTap,
      {bool fullWidth = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.borderDark
              : AppColors.purpleDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap == null
                ? AppColors.textMuted.withOpacity(0.2)
                : AppColors.purpleLight.withOpacity(0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16,
            color: onTap == null ? AppColors.textMuted : AppColors.purpleLight),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(
            fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textMuted : AppColors.purpleLight)),
        ]),
      ),
    );
  }
}
