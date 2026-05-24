// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'APEX SPEECH';
  static const String appTagline = 'Command Every Room.';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:5000/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'apex_jwt_token';
  static const String userKey = 'apex_user';
  static const String onboardingKey = 'apex_onboarding_done';

  // Audio
  static const int audioChunkDurationSeconds = 5;
  static const int sampleRate = 16000;

  // MediaPipe
  static const double slouchThresholdPercent = 0.15;
  static const int slouchAlertDurationSeconds = 3;
  static const int crossedArmsAlertDurationSeconds = 5;

  // Gamification
  static const int maxApexLevel = 10;
  static const List<String> levelNames = [
    'Novice', 'Apprentice', 'Communicator',
    'Presenter', 'Speaker', 'Orator',
    'Influencer', 'Authority', 'Apex Elite', 'Grand Master',
  ];

  // Filler Words
  static const List<String> fillerWords = [
    'um', 'uh', 'like', 'you know', 'sort of',
    'kind of', 'basically', 'literally', 'actually',
    'right', 'so yeah', 'i mean',
  ];
}
