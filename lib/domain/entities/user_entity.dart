// lib/domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final int apexLevel;
  final int totalSessions;
  final double avgConfidence;
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.apexLevel,
    required this.totalSessions,
    required this.avgConfidence,
    required this.createdAt,
  });

  String get levelName {
    const names = [
      'Novice', 'Apprentice', 'Communicator', 'Presenter',
      'Speaker', 'Orator', 'Influencer', 'Authority',
      'Apex Elite', 'Grand Master',
    ];
    final idx = (apexLevel - 1).clamp(0, names.length - 1);
    return names[idx];
  }
}

// lib/domain/entities/script_entity.dart (appended below as separate file)
