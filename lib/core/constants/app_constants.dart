// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  // ── Change this URL depending on how you run the app ──────────────────────
  //
  //   Windows Desktop   → http://localhost:5000/api/v1        ← YOU ARE HERE
  //   Android Emulator  → http://10.0.2.2:5000/api/v1
  //   Real Phone (WiFi) → http://192.168.1.191:5000/api/v1
  //   iOS Simulator     → http://127.0.0.1:5000/api/v1
  //
  static const String baseUrl = 'http://localhost:5000/api/v1';

  static const String tokenKey = 'apex_access_token';
  static const String refreshTokenKey = 'apex_refresh_token';
  static const String userKey = 'apex_user';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const List<String> fillerWords = [
    'um',
    'uh',
    'like',
    'you know',
    'sort of',
    'kind of',
    'basically',
    'literally',
    'actually',
    'right',
  ];

  static const List<String> audienceTypes = [
    'General',
    'Executives',
    'Investors',
    'Students',
    'Media',
    'Clients',
    'Wedding',
  ];

  static const List<String> levelNames = [
    'Novice',
    'Apprentice',
    'Communicator',
    'Presenter',
    'Speaker',
    'Orator',
    'Influencer',
    'Authority',
    'Apex Elite',
    'Grand Master',
  ];
}
