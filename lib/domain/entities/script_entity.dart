// lib/domain/entities/script_entity.dart

class ScriptEntity {
  final String id;
  final String title;
  final String rawText;
  final String? apexifiedText;
  final String audienceType;
  final int estimatedDurationSeconds;
  final DateTime createdAt;
  final List<QAEntity> qaList;

  const ScriptEntity({
    required this.id,
    required this.title,
    required this.rawText,
    this.apexifiedText,
    required this.audienceType,
    required this.estimatedDurationSeconds,
    required this.createdAt,
    this.qaList = const [],
  });

  bool get isApexified => apexifiedText != null && apexifiedText!.isNotEmpty;

  String get durationLabel {
    final mins = estimatedDurationSeconds ~/ 60;
    final secs = estimatedDurationSeconds % 60;
    if (mins == 0) return '${secs}s';
    return secs == 0 ? '${mins}m' : '${mins}m ${secs}s';
  }
}

class QAEntity {
  final String id;
  final String question;
  final String suggestedAnswer;

  const QAEntity({
    required this.id,
    required this.question,
    required this.suggestedAnswer,
  });
}
