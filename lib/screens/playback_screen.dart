import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../helpers/app_colors.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});
  @override State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final _player = AudioPlayer();
  bool _playing = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => _playing = s == PlayerState.playing));
  }

  String _fmt(Duration d) =>
    '${d.inMinutes.toString().padLeft(2,'0')}:${(d.inSeconds%60).toString().padLeft(2,'0')}';

  @override void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final path = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: const Text('PLAYBACK')),
      body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 110, height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.purpleDark.withOpacity(0.3),
              border: Border.all(color: AppColors.purpleLight, width: 1.5),
              boxShadow: [BoxShadow(color: AppColors.purpleLight.withOpacity(0.3), blurRadius: 28)]),
            child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 56, color: AppColors.purpleLight)),
          const SizedBox(height: 32),
          const Text('Recorded Audio', style: TextStyle(fontFamily: 'Outfit',
              fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          SliderTheme(data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.purpleLight,
            inactiveTrackColor: AppColors.borderDark,
            thumbColor: AppColors.purpleLight,
            overlayColor: AppColors.purpleLight.withOpacity(0.2)),
            child: Slider(
              min: 0, max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmt(_position), style: const TextStyle(fontFamily: 'Outfit',
                fontSize: 12, color: AppColors.textMuted)),
            Text(_fmt(_duration), style: const TextStyle(fontFamily: 'Outfit',
                fontSize: 12, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              if (path == null) return;
              _playing ? await _player.pause() : await _player.play(DeviceFileSource(path));
            },
            child: Text(_playing ? 'PAUSE' : 'PLAY RECORDING',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 16,
                  fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)))),
        ],
      ))),
    );
  }
}
