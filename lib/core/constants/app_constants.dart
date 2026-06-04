// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();
  static const String baseUrl          = 'http://10.0.2.2:5000/api/v1';  // Android emulator
  static const String tokenKey         = 'apex_access_token';
  static const String refreshTokenKey  = 'apex_refresh_token';
  static const String userKey          = 'apex_user';
  static const int    connectTimeout   = 30000;
  static const int    receiveTimeout   = 30000;

  static const List<String> fillerWords = [
    'um','uh','like','you know','sort of','kind of',
    'basically','literally','actually','right',
  ];

  static const List<String> audienceTypes = [
    'General','Executives','Investors','Students','Media','Clients','Wedding',
  ];

  static const List<String> levelNames = [
    'Novice','Apprentice','Communicator','Presenter',
    'Speaker','Orator','Influencer','Authority','Apex Elite','Grand Master',
  ];
}
