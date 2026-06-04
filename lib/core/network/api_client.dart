// lib/core/network/api_client.dart
// Pattern: Singleton + Interceptor Chain

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl:        AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers:        {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      // Attach JWT on every request
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401) {
            // Try refresh
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final token = await _storage.read(key: AppConstants.tokenKey);
              err.requestOptions.headers['Authorization'] = 'Bearer $token';
              final retry = await _dio.fetch(err.requestOptions);
              return handler.resolve(retry);
            }
          }
          handler.next(err);
        },
      ),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refresh == null) return false;
    try {
      final res = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final token = res.data['data']['access_token'];
      await _storage.write(key: AppConstants.tokenKey, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Dio get dio => _dio;

  // ── Auth ─────────────────────────────────────────────
  Future<Response> login(String email, String pw) =>
      _dio.post('/auth/login', data: {'email': email, 'password': pw});
  Future<Response> register(String name, String email, String pw) =>
      _dio.post('/auth/register', data: {'full_name': name, 'email': email, 'password': pw});
  Future<Response> logout() => _dio.post('/auth/logout');

  // ── Profile ──────────────────────────────────────────
  Future<Response> getProfile()       => _dio.get('/profile/');
  Future<Response> updateProfile(Map<String,dynamic> d) => _dio.put('/profile/', data: d);

  // ── Scripts ──────────────────────────────────────────
  Future<Response> getScripts()       => _dio.get('/scripts/');
  Future<Response> getScript(int id)  => _dio.get('/scripts/$id');
  Future<Response> createScript(Map<String,dynamic> d)   => _dio.post('/scripts/', data: d);
  Future<Response> updateScript(int id, Map<String,dynamic> d) => _dio.put('/scripts/$id', data: d);
  Future<Response> deleteScript(int id)   => _dio.delete('/scripts/$id');
  Future<Response> apexifyScript(int id)  => _dio.post('/scripts/$id/apexify');
  Future<Response> generateQA(int id)     => _dio.post('/scripts/$id/qa');

  // ── Sessions ─────────────────────────────────────────
  Future<Response> startSession(int? scriptId) =>
      _dio.post('/sessions/start', data: {'script_id': scriptId});
  Future<Response> uploadAudio(int id, List<int> bytes) =>
      _dio.post('/sessions/$id/audio',
          data: FormData.fromMap({
            'audio': MultipartFile.fromBytes(bytes, filename: 'chunk.wav'),
          }));
  Future<Response> savePosture(int id, Map<String,dynamic> d) =>
      _dio.post('/sessions/$id/posture', data: d);
  Future<Response> finishSession(int id, int duration) =>
      _dio.post('/sessions/$id/finish', data: {'duration_seconds': duration});
  Future<Response> getSessions()           => _dio.get('/sessions/');
  Future<Response> getSessionReport(int id)=> _dio.get('/sessions/$id/report');
}
