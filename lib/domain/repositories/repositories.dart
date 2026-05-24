// lib/domain/repositories/script_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/script_entity.dart';

abstract class ScriptRepository {
  Future<Either<Failure, List<ScriptEntity>>> getScripts();
  Future<Either<Failure, ScriptEntity>> getScriptById(String id);
  Future<Either<Failure, ScriptEntity>> createScript(ScriptEntity script);
  Future<Either<Failure, ScriptEntity>> updateScript(ScriptEntity script);
  Future<Either<Failure, void>> deleteScript(String id);
  Future<Either<Failure, ScriptEntity>> apexifyScript(String id);
  Future<Either<Failure, List<QAEntity>>> generateQA(String scriptId);
}

abstract class SessionRepository {
  Future<Either<Failure, String>> startSession({String? scriptId});
  Future<Either<Failure, void>> uploadAudioChunk(String sessionId, List<int> bytes);
  Future<Either<Failure, void>> savePostureAlert(String sessionId);
  Future<Either<Failure, void>> finishSession(String sessionId);
  Future<Either<Failure, List<dynamic>>> getSessions();
  Future<Either<Failure, Map<String, dynamic>>> getSessionReport(String id);
}

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, void>> register(String name, String email, String password);
  Future<Either<Failure, void>> logout();
  bool get isAuthenticated;
}

class Failure {
  final String message;
  final int? statusCode;
  const Failure({required this.message, this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: 'No internet connection');
}

class CacheFailure extends Failure {
  const CacheFailure() : super(message: 'Cache error');
}
