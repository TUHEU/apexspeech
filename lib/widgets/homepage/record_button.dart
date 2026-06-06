import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.textMuted
              : isRecording
                  ? AppColors.errorRed
                  : AppColors.purpleLight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: isDisabled
            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Saving...', style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 16, color: Colors.white)),
              ])
            : Text(
                isRecording ? 'STOP RECORDING' : 'START RECORDING',
                style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1, color: Colors.white,
                ),
              ),
      ),
    );
  }
}
