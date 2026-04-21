import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/hive/user_hive_model.dart';
import 'firestore_sync_service.dart';
import 'hive_service.dart';

/// Firebase аутентификация сервисі
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreSyncService _sync = FirestoreSyncService();

  UserHiveModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  UserHiveModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  /// Қосымша іске қосылғанда бар сессияны жүктеу
  Future<void> restoreSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Алдымен Hive кэшінен жүктеу (жылдам)
      _currentUser = HiveService.users.get(firebaseUser.uid);
      notifyListeners();
      // Фонда Firestore-дан жаңарту
      final fresh = await _sync.fetchAndCacheUser(firebaseUser.uid);
      if (fresh != null) {
        _currentUser = fresh;
        notifyListeners();
      }
    }
  }

  /// Кіру (студент немесе admin)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = await _sync.fetchAndCacheUser(cred.user!.uid);
      if (user == null) {
        await _auth.signOut();
        _errorMessage = 'Пайдаланушы деректері табылмады.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Шығу
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Firebase қате кодтарын қазақшаға аудару
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Бұл email-мен пайдаланушы жоқ.';
      case 'wrong-password':
        return 'Қате пароль.';
      case 'invalid-credential':
        return 'Email немесе пароль қате.';
      case 'user-disabled':
        return 'Аккаунт блокталған.';
      case 'too-many-requests':
        return 'Тым көп сынақ. Кейінірек қайталаңыз.';
      default:
        return 'Кіру кезінде қате орын алды.';
    }
  }
}
