// lib/domain/entities/entities.dart
// Pattern: Value Object / Entity — pure Dart, no Flutter/framework dependency

class UserEntity {
  final int    id;
  final String fullName;
  final String email;
  final int    apexLevel;
  final String levelName;
  final int    totalSessions;
  final double avgConfidence;
  final int    streakDays;

  const UserEntity({
    required this.id, required this.fullName, required this.email,
    required this.apexLevel, required this.levelName,
    required this.totalSessions, required this.avgConfidence,
    required this.streakDays,
  });
}

class ScriptEntity {
  final int     id;
  final String  title;
  final String  rawText;
  final String? apexifiedText;
  final String  audienceType;
  final int     estimatedDuration;
  final bool    isApexified;
  final String  createdAt;
  final List<QAEntity> qaList;

  const ScriptEntity({
    required this.id, required this.title, required this.rawText,
    this.apexifiedText, required this.audienceType,
    required this.estimatedDuration, required this.isApexified,
    required this.createdAt, this.qaList = const [],
  });

  String get durationLabel {
    final m = estimatedDuration ~/ 60;
    final s = estimatedDuration % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

class QAEntity {
  final int    id;
  final String question;
  final String suggestedAnswer;
  final String difficulty;
  const QAEntity({required this.id, required this.question,
      required this.suggestedAnswer, required this.difficulty});
}

class SessionEntity {
  final int    id;
  final int?   scriptId;
  final int    durationSeconds;
  final double confidenceScore;
  final double enthusiasmScore;
  final double authorityScore;
  final double overallScore;
  final String grade;
  final int    fillerWordCount;
  final int    postureAlerts;
  final String? transcription;
  final String status;
  final String createdAt;

  const SessionEntity({
    required this.id, this.scriptId, required this.durationSeconds,
    required this.confidenceScore, required this.enthusiasmScore,
    required this.authorityScore, required this.overallScore,
    required this.grade, required this.fillerWordCount,
    required this.postureAlerts, this.transcription,
    required this.status, required this.createdAt,
  });

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}

class CoachingTipEntity {
  final int    id;
  final String tipType;
  final String title;
  final String body;
  final String iconEmoji;
  const CoachingTipEntity({required this.id, required this.tipType,
      required this.title, required this.body, required this.iconEmoji});
  bool get isStrength => tipType == 'strength';
}

class SessionReportEntity {
  final SessionEntity          session;
  final List<CoachingTipEntity> coachingTips;
  final List<FillerEventEntity> fillerEvents;

  const SessionReportEntity({
    required this.session,
    required this.coachingTips,
    required this.fillerEvents,
  });
}

class FillerEventEntity {
  final String word;
  final double timestampSeconds;
  const FillerEventEntity({required this.word, required this.timestampSeconds});
}

class LiveFeedback {
  final double confidenceScore;
  final double enthusiasmScore;
  final double authorityScore;
  final String transcription;
  final List<Map<String,dynamic>> fillerEvents;

  const LiveFeedback({
    this.confidenceScore = 0, this.enthusiasmScore = 0,
    this.authorityScore  = 0, this.transcription   = '',
    this.fillerEvents    = const [],
  });
}

class AuthResult {
  final bool        success;
  final String?     message;
  final UserEntity? user;
  final String?     accessToken;
  final String?     refreshToken;
  const AuthResult({required this.success, this.message,
      this.user, this.accessToken, this.refreshToken});
}
