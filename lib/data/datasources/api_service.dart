// lib/data/datasources/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptors
    _dio.interceptors.addAll([
      // Auth interceptor — attach JWT
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: AppConstants.tokenKey);
            // Trigger logout navigation
          }
          handler.next(error);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    ]);
  }

  // ── Auth ─────────────────────────────────────────────
  Future<Response> login(String email, String password) =>
    _dio.post('/auth/login', data: {'email': email, 'password': password});

  Future<Response> register(String name, String email, String password) =>
    _dio.post('/auth/register', data: {
      'full_name': name, 'email': email, 'password': password,
    });

  Future<Response> getProfile() => _dio.get('/auth/profile');

  // ── Scripts ──────────────────────────────────────────
  Future<Response> getScripts() => _dio.get('/scripts');
  Future<Response> getScript(String id) => _dio.get('/scripts/$id');
  Future<Response> createScript(Map<String, dynamic> data) =>
    _dio.post('/scripts', data: data);
  Future<Response> updateScript(String id, Map<String, dynamic> data) =>
    _dio.put('/scripts/$id', data: data);
  Future<Response> deleteScript(String id) => _dio.delete('/scripts/$id');
  Future<Response> apexifyScript(String id) => _dio.post('/scripts/$id/apexify');
  Future<Response> generateQA(String id) => _dio.post('/scripts/$id/qa');

  // ── Sessions ─────────────────────────────────────────
  Future<Response> startSession(Map<String, dynamic> data) =>
    _dio.post('/sessions/start', data: data);
  Future<Response> uploadAudio(String id, List<int> bytes) =>
    _dio.post('/sessions/$id/audio',
      data: FormData.fromMap({'audio': MultipartFile.fromBytes(bytes, filename: 'chunk.wav')}));
  Future<Response> savePostureAlert(String id) =>
    _dio.post('/sessions/$id/posture');
  Future<Response> finishSession(String id) =>
    _dio.post('/sessions/$id/finish');
  Future<Response> getSessions() => _dio.get('/sessions');
  Future<Response> getSessionReport(String id) => _dio.get('/sessions/$id/report');
}
