// lib/domain/entities/session_entity.dart

class SessionEntity {
  final String id;
  final String? scriptId;
  final int durationSeconds;
  final double confidenceScore;
  final double enthusiasmScore;
  final double authorityScore;
  final int fillerWordCount;
  final int postureAlerts;
  final String? transcription;
  final DateTime createdAt;
  final List<FillerWordEvent> fillerWordEvents;

  const SessionEntity({
    required this.id,
    this.scriptId,
    required this.durationSeconds,
    required this.confidenceScore,
    required this.enthusiasmScore,
    required this.authorityScore,
    required this.fillerWordCount,
    required this.postureAlerts,
    this.transcription,
    required this.createdAt,
    this.fillerWordEvents = const [],
  });

  double get overallScore =>
    (confidenceScore * 0.4 + enthusiasmScore * 0.3 + authorityScore * 0.3);

  String get grade {
    final s = overallScore;
    if (s >= 90) return 'S+';
    if (s >= 80) return 'A';
    if (s >= 70) return 'B';
    if (s >= 60) return 'C';
    return 'D';
  }

  String get durationLabel {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class FillerWordEvent {
  final String word;
  final double timestampSeconds;

  const FillerWordEvent({
    required this.word,
    required this.timestampSeconds,
  });
}

class LiveFeedbackState {
  final double confidenceScore;
  final double enthusiasmScore;
  final String? latestFillerWord;
  final bool isSlouchingDetected;
  final bool isConfidentGestureDetected;
  final List<double> pitchHistory;

  const LiveFeedbackState({
    this.confidenceScore = 0,
    this.enthusiasmScore = 0,
    this.latestFillerWord,
    this.isSlouchingDetected = false,
    this.isConfidentGestureDetected = false,
    this.pitchHistory = const [],
  });

  LiveFeedbackState copyWith({
    double? confidenceScore,
    double? enthusiasmScore,
    String? latestFillerWord,
    bool? isSlouchingDetected,
    bool? isConfidentGestureDetected,
    List<double>? pitchHistory,
  }) => LiveFeedbackState(
    confidenceScore: confidenceScore ?? this.confidenceScore,
    enthusiasmScore: enthusiasmScore ?? this.enthusiasmScore,
    latestFillerWord: latestFillerWord,
    isSlouchingDetected: isSlouchingDetected ?? this.isSlouchingDetected,
    isConfidentGestureDetected: isConfidentGestureDetected ?? this.isConfidentGestureDetected,
    pitchHistory: pitchHistory ?? this.pitchHistory,
  );
}
