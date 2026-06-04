// lib/presentation/providers/providers.dart
// Pattern: Observer (ChangeNotifier) — UI rebuilds when state changes

import 'package:flutter/foundation.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';

// ── Auth Provider ──────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  UserEntity? _user;
  bool  _loading = false;
  String? _error;

  UserEntity? get user    => _user;
  bool        get loading => _loading;
  String?     get error   => _error;
  bool        get isLoggedIn => _user != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? v){ _error = v;   notifyListeners(); }

  Future<bool> login(String email, String pw) async {
    _setLoading(true); _setError(null);
    final result = await _repo.login(email, pw);
    _setLoading(false);
    return result.fold(
      (f) { _setError(f.message); return false; },
      (r) { _user = r.user; notifyListeners(); return true; },
    );
  }

  Future<bool> register(String name, String email, String pw) async {
    _setLoading(true); _setError(null);
    final result = await _repo.register(name, email, pw);
    _setLoading(false);
    return result.fold(
      (f) { _setError(f.message); return false; },
      (r) { _user = r.user; notifyListeners(); return true; },
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> checkAuth() async => _repo.isLoggedIn();
}

// ── Profile Provider ──────────────────────────────────────
class ProfileProvider extends ChangeNotifier {
  final _repo = ProfileRepository();

  UserEntity? _user;
  bool _loading = false;

  UserEntity? get user    => _user;
  bool        get loading => _loading;

  Future<void> load() async {
    _loading = true; notifyListeners();
    final r = await _repo.getProfile();
    r.fold((_) {}, (u) => _user = u);
    _loading = false; notifyListeners();
  }

  Future<bool> update(Map<String,dynamic> data) async {
    final r = await _repo.updateProfile(data);
    return r.fold((_) => false, (u) { _user = u; notifyListeners(); return true; });
  }
}

// ── Script Provider ───────────────────────────────────────
class ScriptProvider extends ChangeNotifier {
  final _repo = ScriptRepository();

  List<ScriptEntity> _scripts  = [];
  ScriptEntity?      _selected;
  bool               _loading  = false;
  bool               _apexifying = false;
  bool               _generatingQA = false;
  String?            _error;

  List<ScriptEntity> get scripts      => _scripts;
  ScriptEntity?      get selected     => _selected;
  bool               get loading      => _loading;
  bool               get apexifying   => _apexifying;
  bool               get generatingQA => _generatingQA;
  String?            get error        => _error;

  Future<void> loadAll() async {
    _loading = true; notifyListeners();
    final r = await _repo.getAll();
    r.fold((f) => _error = f.message, (list) => _scripts = list);
    _loading = false; notifyListeners();
  }

  Future<bool> create(Map<String,dynamic> data) async {
    final r = await _repo.create(data);
    return r.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (s) { _scripts.insert(0, s); notifyListeners(); return true; },
    );
  }

  Future<bool> update(int id, Map<String,dynamic> data) async {
    final r = await _repo.update(id, data);
    return r.fold((f) => false, (s) {
      final idx = _scripts.indexWhere((x) => x.id == id);
      if (idx >= 0) _scripts[idx] = s;
      if (_selected?.id == id) _selected = s;
      notifyListeners();
      return true;
    });
  }

  Future<bool> delete(int id) async {
    final r = await _repo.delete(id);
    return r.fold((_) => false, (_) {
      _scripts.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    });
  }

  Future<bool> apexify(int id) async {
    _apexifying = true; notifyListeners();
    final r = await _repo.apexify(id);
    _apexifying = false;
    return r.fold((_) { notifyListeners(); return false; }, (s) {
      final idx = _scripts.indexWhere((x) => x.id == id);
      if (idx >= 0) _scripts[idx] = s;
      _selected = s; notifyListeners(); return true;
    });
  }

  Future<bool> generateQA(int id) async {
    _generatingQA = true; notifyListeners();
    final r = await _repo.generateQA(id);
    _generatingQA = false;
    return r.fold(
      (_) { notifyListeners(); return false; },
      (qaList) {
        if (_selected?.id == id) {
          _selected = ScriptEntity(
            id: _selected!.id, title: _selected!.title,
            rawText: _selected!.rawText, apexifiedText: _selected!.apexifiedText,
            audienceType: _selected!.audienceType,
            estimatedDuration: _selected!.estimatedDuration,
            isApexified: _selected!.isApexified,
            createdAt: _selected!.createdAt, qaList: qaList,
          );
        }
        notifyListeners(); return true;
      },
    );
  }

  void select(ScriptEntity s) { _selected = s; notifyListeners(); }
}

// ── Session Provider ──────────────────────────────────────
class SessionProvider extends ChangeNotifier {
  final _repo = SessionRepository();

  List<SessionEntity>    _sessions   = [];
  SessionReportEntity?   _report;
  int?                   _activeId;
  bool                   _loading    = false;
  bool                   _recording  = false;
  LiveFeedback           _liveFeed   = const LiveFeedback();
  String?                _latestFiller;
  bool                   _isSlouching = false;
  List<double>           _pitchHistory = [];
  int                    _elapsed    = 0;

  List<SessionEntity>  get sessions     => _sessions;
  SessionReportEntity? get report       => _report;
  int?                 get activeId     => _activeId;
  bool                 get loading      => _loading;
  bool                 get recording    => _recording;
  LiveFeedback         get liveFeed     => _liveFeed;
  String?              get latestFiller => _latestFiller;
  bool                 get isSlouching  => _isSlouching;
  List<double>         get pitchHistory => _pitchHistory;
  int                  get elapsed      => _elapsed;

  Future<bool> start(int? scriptId) async {
    final r = await _repo.start(scriptId);
    return r.fold((_) => false, (id) {
      _activeId = id; _recording = true; _elapsed = 0;
      notifyListeners(); return true;
    });
  }

  void tickTimer() { _elapsed++; notifyListeners(); }

  Future<void> processAudio(List<int> bytes) async {
    if (_activeId == null) return;
    final r = await _repo.uploadAudio(_activeId!, bytes);
    r.fold((_) {}, (fb) {
      _liveFeed = fb;
      // Filler word flash
      if (fb.fillerEvents.isNotEmpty) {
        _latestFiller = fb.fillerEvents.last['word'];
        Future.delayed(const Duration(seconds: 2), () {
          _latestFiller = null; notifyListeners();
        });
      }
      // Mock pitch point
      _pitchHistory.add(200 + 60 * (fb.confidenceScore / 100));
      if (_pitchHistory.length > 40) _pitchHistory.removeAt(0);
      notifyListeners();
    });
  }

  Future<void> savePosture(String type, double ts) async {
    if (_activeId == null) return;
    await _repo.savePosture(_activeId!, {
      'event_type': type, 'timestamp_seconds': ts,
    });
  }

  void setSlouchAlert(bool v) { _isSlouching = v; notifyListeners(); }

  Future<bool> finish() async {
    if (_activeId == null) return false;
    _loading   = true; notifyListeners();
    final r    = await _repo.finish(_activeId!, _elapsed);
    _loading   = false; _recording = false;
    return r.fold((_) { notifyListeners(); return false; }, (s) {
      _sessions.insert(0, s); notifyListeners(); return true;
    });
  }

  Future<void> loadAll() async {
    _loading = true; notifyListeners();
    final r = await _repo.getAll();
    r.fold((_) {}, (list) => _sessions = list);
    _loading = false; notifyListeners();
  }

  Future<void> loadReport(int id) async {
    _loading = true; notifyListeners();
    final r = await _repo.getReport(id);
    r.fold((_) {}, (rep) => _report = rep);
    _loading = false; notifyListeners();
  }

  void resetLive() {
    _activeId     = null; _recording    = false;
    _liveFeed     = const LiveFeedback();
    _latestFiller = null; _isSlouching  = false;
    _pitchHistory = []; _elapsed       = 0;
    notifyListeners();
  }
}
