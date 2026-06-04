// lib/data/models/models.dart
// Pattern: Factory Method — fromJson constructors build entities from API JSON

import '../../domain/entities/entities.dart';

// Helper — safely parse any JSON value to int (handles String, int, double)
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class UserModel {
  static UserEntity fromJson(Map<String, dynamic> j) => UserEntity(
    id: _toInt(j['id']),
    fullName: j['full_name'] ?? '',
    email: j['email'] ?? '',
    apexLevel: _toInt(j['apex_level']),
    levelName: j['level_name'] ?? 'Novice',
    totalSessions: _toInt(j['total_sessions']),
    avgConfidence: (j['avg_confidence'] ?? 0.0).toDouble(),
    streakDays: _toInt(j['streak_days']),
  );
}

class ScriptModel {
  static ScriptEntity fromJson(Map<String, dynamic> j) => ScriptEntity(
    id: _toInt(j['id']),
    title: j['title'] ?? '',
    rawText: j['raw_text'] ?? '',
    apexifiedText: j['apexified_text'],
    audienceType: j['audience_type'] ?? 'General',
    estimatedDuration: _toInt(j['estimated_duration']),
    isApexified: j['is_apexified'] ?? false,
    createdAt: j['created_at'] ?? '',
    qaList: (j['qa_list'] as List<dynamic>? ?? [])
        .map((q) => QAModel.fromJson(q as Map<String, dynamic>))
        .toList(),
  );
}

class QAModel {
  static QAEntity fromJson(Map<String, dynamic> j) => QAEntity(
    id: _toInt(j['id']),
    question: j['question'] ?? '',
    suggestedAnswer: j['suggested_answer'] ?? '',
    difficulty: j['difficulty'] ?? 'medium',
  );
}

class SessionModel {
  static SessionEntity fromJson(Map<String, dynamic> j) => SessionEntity(
    id: _toInt(j['id']),
    scriptId: j['script_id'] != null ? _toInt(j['script_id']) : null,
    durationSeconds: _toInt(j['duration_seconds']),
    confidenceScore: (j['confidence_score'] ?? 0.0).toDouble(),
    enthusiasmScore: (j['enthusiasm_score'] ?? 0.0).toDouble(),
    authorityScore: (j['authority_score'] ?? 0.0).toDouble(),
    overallScore: (j['overall_score'] ?? 0.0).toDouble(),
    grade: j['grade'] ?? 'D',
    fillerWordCount: _toInt(j['filler_word_count']),
    postureAlerts: _toInt(j['posture_alerts']),
    transcription: j['transcription'],
    status: j['status'] ?? 'active',
    createdAt: j['created_at'] ?? '',
  );
}

class CoachingTipModel {
  static CoachingTipEntity fromJson(Map<String, dynamic> j) =>
      CoachingTipEntity(
        id: _toInt(j['id']),
        tipType: j['tip_type'] ?? 'improvement',
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        iconEmoji: j['icon_emoji'] ?? '💡',
      );
}

class FillerEventModel {
  static FillerEventEntity fromJson(Map<String, dynamic> j) =>
      FillerEventEntity(
        word: j['word'] ?? '',
        timestampSeconds: (j['timestamp_seconds'] ?? 0.0).toDouble(),
      );
}

class SessionReportModel {
  static SessionReportEntity fromJson(Map<String, dynamic> j) =>
      SessionReportEntity(
        session: SessionModel.fromJson(j['session'] as Map<String, dynamic>),
        coachingTips: (j['coaching_tips'] as List<dynamic>? ?? [])
            .map((t) => CoachingTipModel.fromJson(t as Map<String, dynamic>))
            .toList(),
        fillerEvents: (j['filler_events'] as List<dynamic>? ?? [])
            .map((f) => FillerEventModel.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}
