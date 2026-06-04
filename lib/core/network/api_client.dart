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

  // ── Prevents infinite refresh loop ──────────────────
  bool _isRefreshing = false;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {'Content-Type': 'application/json'},
        // Don't throw on 4xx so we can handle them gracefully
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        onResponse: (response, handler) async {
          // If we got a 401 AND we are not already refreshing, try once
          if (response.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            final refreshed = await _tryRefresh();
            _isRefreshing = false;

            if (refreshed) {
              // Retry the original request with the new token
              final token = await _storage.read(key: AppConstants.tokenKey);
              final opts = response.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final retry = await Dio(
                  BaseOptions(
                    baseUrl: AppConstants.baseUrl,
                    validateStatus: (s) => s != null && s < 500,
                  ),
                ).fetch(opts);
                return handler.next(retry);
              } catch (_) {
                // Retry failed — just pass the 401 through
              }
            }
          }
          handler.next(response);
        },

        onError: (err, handler) {
          // Don't retry on network errors — just pass through
          handler.next(err);
        },
      ),
      // Remove LogInterceptor in production — it slows things down
      // LogInterceptor(requestBody: false, responseBody: false),
    ]);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refresh == null) return false;
    try {
      final res = await Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          validateStatus: (s) => s != null && s < 500,
        ),
      ).post('/auth/refresh', data: {'refresh_token': refresh});

      if (res.statusCode == 200) {
        final token = res.data['data']['access_token'];
        await _storage.write(key: AppConstants.tokenKey, value: token);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Dio get dio => _dio;

  // ── Auth ─────────────────────────────────────────────
  Future<Response> login(String email, String pw) =>
      _dio.post('/auth/login', data: {'email': email, 'password': pw});
  Future<Response> register(String name, String email, String pw) => _dio.post(
    '/auth/register',
    data: {'full_name': name, 'email': email, 'password': pw},
  );
  Future<Response> logout() => _dio.post('/auth/logout');

  // ── Profile ──────────────────────────────────────────
  Future<Response> getProfile() => _dio.get('/profile/');
  Future<Response> updateProfile(Map<String, dynamic> d) =>
      _dio.put('/profile/', data: d);

  // ── Scripts ──────────────────────────────────────────
  Future<Response> getScripts() => _dio.get('/scripts/');
  Future<Response> getScript(int id) => _dio.get('/scripts/$id');
  Future<Response> createScript(Map<String, dynamic> d) =>
      _dio.post('/scripts/', data: d);
  Future<Response> updateScript(int id, Map<String, dynamic> d) =>
      _dio.put('/scripts/$id', data: d);
  Future<Response> deleteScript(int id) => _dio.delete('/scripts/$id');
  Future<Response> apexifyScript(int id) => _dio.post('/scripts/$id/apexify');
  Future<Response> generateQA(int id) => _dio.post('/scripts/$id/qa');

  // ── Sessions ─────────────────────────────────────────
  Future<Response> startSession(int? scriptId) =>
      _dio.post('/sessions/start', data: {'script_id': scriptId});
  Future<Response> uploadAudio(int id, List<int> bytes) => _dio.post(
    '/sessions/$id/audio',
    data: FormData.fromMap({
      'audio': MultipartFile.fromBytes(bytes, filename: 'chunk.wav'),
    }),
  );
  Future<Response> savePosture(int id, Map<String, dynamic> d) =>
      _dio.post('/sessions/$id/posture', data: d);
  Future<Response> finishSession(int id, int duration) =>
      _dio.post('/sessions/$id/finish', data: {'duration_seconds': duration});
  Future<Response> getSessions() => _dio.get('/sessions/');
  Future<Response> getSessionReport(int id) => _dio.get('/sessions/$id/report');
}
