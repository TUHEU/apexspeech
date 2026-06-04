// lib/data/models/models.dart
// Pattern: Factory Method — fromJson constructors build entities from API JSON

import '../../domain/entities/entities.dart';

class UserModel {
  static UserEntity fromJson(Map<String, dynamic> j) => UserEntity(
    id:             j['id'],
    fullName:       j['full_name'] ?? '',
    email:          j['email']    ?? '',
    apexLevel:      j['apex_level']     ?? 1,
    levelName:      j['level_name']     ?? 'Novice',
    totalSessions:  j['total_sessions'] ?? 0,
    avgConfidence:  (j['avg_confidence'] ?? 0.0).toDouble(),
    streakDays:     j['streak_days']    ?? 0,
  );
}

class ScriptModel {
  static ScriptEntity fromJson(Map<String, dynamic> j) => ScriptEntity(
    id:                j['id'],
    title:             j['title']          ?? '',
    rawText:           j['raw_text']        ?? '',
    apexifiedText:     j['apexified_text'],
    audienceType:      j['audience_type']   ?? 'General',
    estimatedDuration: j['estimated_duration'] ?? 0,
    isApexified:       j['is_apexified']    ?? false,
    createdAt:         j['created_at']      ?? '',
    qaList: (j['qa_list'] as List<dynamic>? ?? [])
        .map((q) => QAModel.fromJson(q as Map<String,dynamic>))
        .toList(),
  );
}

class QAModel {
  static QAEntity fromJson(Map<String, dynamic> j) => QAEntity(
    id:              j['id']              ?? 0,
    question:        j['question']        ?? '',
    suggestedAnswer: j['suggested_answer']?? '',
    difficulty:      j['difficulty']      ?? 'medium',
  );
}

class SessionModel {
  static SessionEntity fromJson(Map<String, dynamic> j) => SessionEntity(
    id:               j['id'],
    scriptId:         j['script_id'],
    durationSeconds:  j['duration_seconds']  ?? 0,
    confidenceScore:  (j['confidence_score'] ?? 0.0).toDouble(),
    enthusiasmScore:  (j['enthusiasm_score'] ?? 0.0).toDouble(),
    authorityScore:   (j['authority_score']  ?? 0.0).toDouble(),
    overallScore:     (j['overall_score']    ?? 0.0).toDouble(),
    grade:            j['grade']             ?? 'D',
    fillerWordCount:  j['filler_word_count'] ?? 0,
    postureAlerts:    j['posture_alerts']    ?? 0,
    transcription:    j['transcription'],
    status:           j['status']            ?? 'active',
    createdAt:        j['created_at']        ?? '',
  );
}

class CoachingTipModel {
  static CoachingTipEntity fromJson(Map<String, dynamic> j) => CoachingTipEntity(
    id:        j['id']         ?? 0,
    tipType:   j['tip_type']   ?? 'improvement',
    title:     j['title']      ?? '',
    body:      j['body']       ?? '',
    iconEmoji: j['icon_emoji'] ?? '💡',
  );
}

class FillerEventModel {
  static FillerEventEntity fromJson(Map<String, dynamic> j) => FillerEventEntity(
    word:             j['word']              ?? '',
    timestampSeconds: (j['timestamp_seconds'] ?? 0.0).toDouble(),
  );
}

class SessionReportModel {
  static SessionReportEntity fromJson(Map<String, dynamic> j) => SessionReportEntity(
    session:      SessionModel.fromJson(j['session'] as Map<String,dynamic>),
    coachingTips: (j['coaching_tips'] as List<dynamic>? ?? [])
        .map((t) => CoachingTipModel.fromJson(t as Map<String,dynamic>))
        .toList(),
    fillerEvents: (j['filler_events'] as List<dynamic>? ?? [])
        .map((f) => FillerEventModel.fromJson(f as Map<String,dynamic>))
        .toList(),
  );
}
