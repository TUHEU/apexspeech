// lib/data/repositories/repositories.dart
// Pattern: Repository Pattern — all API calls go through here

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../models/models.dart';

// ── Failure type ─────────────────────────────────────────
class Failure {
  final String message;
  final int? code;
  const Failure(this.message, {this.code});
}

// ── Auth Repository ───────────────────────────────────────
class AuthRepository {
  final _client = ApiClient.instance;
  final _storage = const FlutterSecureStorage();

  Future<Either<Failure, AuthResult>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await _client.login(email, password);
      final data = res.data['data'];
      await _saveTokens(data['access_token'], data['refresh_token']);
      return Right(
        AuthResult(
          success: true,
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_extractMessage(e), code: e.response?.statusCode));
    }
  }

  Future<Either<Failure, AuthResult>> register(
    String name,
    String email,
    String pw,
  ) async {
    try {
      final res = await _client.register(name, email, pw);
      final data = res.data['data'];
      await _saveTokens(data['access_token'], data['refresh_token']);
      return Right(
        AuthResult(
          success: true,
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_extractMessage(e), code: e.response?.statusCode));
    }
  }

  Future<void> logout() async {
    try {
      await _client.logout();
    } catch (_) {}
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final t = await _storage.read(key: AppConstants.tokenKey);
    return t != null;
  }

  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: AppConstants.tokenKey, value: access);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refresh);
  }

  String _extractMessage(DioException e) =>
      e.response?.data?['message'] ?? e.message ?? 'Unknown error';
}

// ── Profile Repository ────────────────────────────────────
class ProfileRepository {
  final _client = ApiClient.instance;

  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final res = await _client.getProfile();
      if (res.statusCode != 200)
        return Left(Failure('Auth error', code: res.statusCode));
      final user = res.data?['data']?['user'];
      if (user == null) return Left(Failure('No user data'));
      return Right(UserModel.fromJson(user as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserEntity>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.updateProfile(data);
      return Right(
        UserModel.fromJson(res.data['data']['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  String _msg(DioException e) => e.response?.data?['message'] ?? 'Error';
}

// ── Script Repository ─────────────────────────────────────
class ScriptRepository {
  final _client = ApiClient.instance;

  Future<Either<Failure, List<ScriptEntity>>> getAll() async {
    try {
      final res = await _client.getScripts();
      if (res.statusCode != 200) return const Right([]);
      final data = res.data?['data'];
      if (data == null) return const Right([]);
      final scripts = (data['scripts'] as List? ?? [])
          .map((j) => ScriptModel.fromJson(j as Map<String, dynamic>))
          .toList();
      return Right(scripts);
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    } catch (_) {
      return const Right([]);
    }
  }

  Future<Either<Failure, ScriptEntity>> getById(int id) async {
    try {
      final res = await _client.getScript(id);
      if (res.statusCode != 200)
        return Left(Failure('Script not found', code: res.statusCode));
      final script = res.data?['data']?['script'];
      if (script == null) return Left(Failure('No script data'));
      return Right(ScriptModel.fromJson(script as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ScriptEntity>> create(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.createScript(data);
      if (res.statusCode != 200 && res.statusCode != 201) {
        return Left(
          Failure(
            res.data?['message'] ?? 'Create failed',
            code: res.statusCode,
          ),
        );
      }
      final script = res.data?['data']?['script'];
      if (script == null) return Left(Failure('No script returned'));
      return Right(ScriptModel.fromJson(script as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ScriptEntity>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.updateScript(id, data);
      return Right(
        ScriptModel.fromJson(
          res.data['data']['script'] as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _client.deleteScript(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, ScriptEntity>> apexify(int id) async {
    try {
      final res = await _client.apexifyScript(id);
      return Right(
        ScriptModel.fromJson(
          res.data['data']['script'] as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, List<QAEntity>>> generateQA(int id) async {
    try {
      final res = await _client.generateQA(id);
      final list = (res.data['data']['qa_list'] as List)
          .map((q) => QAModel.fromJson(q as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  String _msg(DioException e) => e.response?.data?['message'] ?? 'Error';
}

// ── Session Repository ────────────────────────────────────
class SessionRepository {
  final _client = ApiClient.instance;

  Future<Either<Failure, int>> start(int? scriptId) async {
    try {
      final res = await _client.startSession(scriptId);
      if (res.statusCode != 200 && res.statusCode != 201) {
        return Left(
          Failure(res.data?['message'] ?? 'Start failed', code: res.statusCode),
        );
      }
      final id = res.data?['data']?['session_id'];
      if (id == null) return Left(Failure('No session id returned'));
      return Right(_toInt(id));
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Future<Either<Failure, LiveFeedback>> uploadAudio(
    int id,
    List<int> bytes,
  ) async {
    try {
      final res = await _client.uploadAudio(id, bytes);
      final d = res.data['data'];
      return Right(
        LiveFeedback(
          confidenceScore: (d['confidence_score'] ?? 0.0).toDouble(),
          enthusiasmScore: (d['enthusiasm_score'] ?? 0.0).toDouble(),
          authorityScore: (d['authority_score'] ?? 0.0).toDouble(),
          transcription: d['transcription'] ?? '',
          fillerEvents: List<Map<String, dynamic>>.from(
            d['filler_events'] ?? [],
          ),
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, bool>> savePosture(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _client.savePosture(id, data);
      return const Right(true);
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, SessionEntity>> finish(int id, int duration) async {
    try {
      final res = await _client.finishSession(id, duration);
      return Right(
        SessionModel.fromJson(
          res.data['data']['session'] as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  Future<Either<Failure, List<SessionEntity>>> getAll() async {
    try {
      final res = await _client.getSessions();
      // 401 = token issue — return empty list gracefully, don't crash
      if (res.statusCode == 401 || res.statusCode == 403)
        return const Right([]);
      if (res.statusCode != 200) return const Right([]);
      final data = res.data?['data'];
      if (data == null) return const Right([]);
      final list = (data['sessions'] as List? ?? [])
          .map((s) => SessionModel.fromJson(s as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return const Right([]);
    } catch (_) {
      return const Right([]);
    }
  }

  Future<Either<Failure, SessionReportEntity>> getReport(int id) async {
    try {
      final res = await _client.getSessionReport(id);
      return Right(
        SessionReportModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(Failure(_msg(e)));
    }
  }

  String _msg(DioException e) => e.response?.data?['message'] ?? 'Error';
}
