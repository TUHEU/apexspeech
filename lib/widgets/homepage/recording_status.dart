import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class RecordingStatusIndicator extends StatelessWidget {
  final bool isRecording;
  const RecordingStatusIndicator({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130, height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording
              ? AppColors.errorRed.withOpacity(0.15)
              : AppColors.purpleDark.withOpacity(0.3),
          border: Border.all(
            color: isRecording ? AppColors.errorRed : AppColors.purpleLight,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? AppColors.errorRed : AppColors.purpleLight)
                  .withOpacity(0.3),
              blurRadius: isRecording ? 30 : 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.mic_rounded,
          size: 60,
          color: isRecording ? AppColors.errorRed : AppColors.purpleLight,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        isRecording ? 'Recording...' : 'Ready to Record',
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      if (isRecording) ...[
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.errorRed)),
          const SizedBox(width: 6),
          const Text('LIVE', style: TextStyle(
            fontFamily: 'Outfit', fontSize: 11,
            color: AppColors.errorRed, letterSpacing: 2,
            fontWeight: FontWeight.w700)),
        ]),
      ],
    ]);
  }
}
