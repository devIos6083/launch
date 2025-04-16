import 'package:firebase_auth/firebase_auth.dart';
import 'package:launch/models/user_model.dart';
import 'package:launch/services/auth_service.dart';
import 'package:launch/services/storage_service.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithKakao();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
  Future<void> saveUserSession(User user);
  Future<void> clearUserSession();
  Future<bool> isUserLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  // 저장소 키
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhoto = 'user_photo';
  static const String _keyIsLoggedIn = 'is_logged_in';

  AuthRepositoryImpl({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  @override
  Future<User?> getCurrentUser() async {
    return _authService.getCurrentUser();
  }

  @override
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await saveUserSession(user);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final user =
          await _authService.signUpWithEmailAndPassword(email, password, name);
      if (user != null) {
        await saveUserSession(user);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await saveUserSession(user);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithKakao() async {
    try {
      final user = await _authService.signInWithKakao();
      if (user != null) {
        await saveUserSession(user);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    await clearUserSession();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<void> saveUserSession(User user) async {
    await _storageService.setString(_keyUserId, user.uid);
    await _storageService.setString(_keyUserEmail, user.email ?? '');
    await _storageService.setString(_keyUserName, user.displayName ?? '');
    await _storageService.setString(_keyUserPhoto, user.photoURL ?? '');
    await _storageService.setBool(_keyIsLoggedIn, true);
  }

  @override
  Future<void> clearUserSession() async {
    await _storageService.remove(_keyUserId);
    await _storageService.remove(_keyUserEmail);
    await _storageService.remove(_keyUserName);
    await _storageService.remove(_keyUserPhoto);
    await _storageService.setBool(_keyIsLoggedIn, false);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await _storageService.getBool(_keyIsLoggedIn) ?? false;
  }
}
