import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:firebase_database/firebase_database.dart';
import 'package:launch/models/user_model.dart' as app_user;

abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithKakao();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 참조 경로
  String get _usersPath => 'users';

  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 마지막 로그인 시간 업데이트
      await _updateUserLastLogin(userCredential.user!.uid);

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 프로필 업데이트
      await userCredential.user?.updateDisplayName(name);

      // Realtime Database에 사용자 데이터 저장
      await _createUserInDatabase(
        userCredential.user!,
        app_user.LoginProvider.email,
      );

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // 구글 로그인 진행
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 구글 인증 정보 얻기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      // 사용자가 처음 로그인한 경우 Realtime Database에 데이터 생성
      await _createUserInDatabase(
        userCredential.user!,
        app_user.LoginProvider.google,
      );

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await kakao.isKakaoTalkInstalled()) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 얻기
      User? user = await _handleKakaoLogin();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 카카오 로그인 처리
  Future<User?> _handleKakaoLogin() async {
    try {
      // 카카오 사용자 정보 요청
      kakao.User kakaoUser = await kakao.UserApi.instance.me();

      // 파이어베이스 커스텀 토큰 만들기 (서버 필요 - 여기서는 예시)
      // 실제 구현에서는 서버 엔드포인트 호출 필요
      // final customToken = await _getFirebaseCustomToken(kakaoUser.id);

      // 커스텀 토큰으로 Firebase 인증
      // final userCredential = await _auth.signInWithCustomToken(customToken);

      // 임시 처리: 이메일로 가입 (실제 구현에서는 위 주석 코드 활용)
      final kakaoEmail =
          kakaoUser.kakaoAccount?.email ?? '${kakaoUser.id}@kakao.com';
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: kakaoEmail,
        password: 'kakao_${kakaoUser.id}', // 실제 구현에서는 안전한 방법 필요
      );

      // 사용자가 처음 로그인한 경우 Realtime Database에 데이터 생성
      await _createUserInDatabase(
        userCredential.user!,
        app_user.LoginProvider.kakao,
        kakaoUser.kakaoAccount?.profile?.nickname,
        kakaoUser.kakaoAccount?.profile?.profileImageUrl,
      );

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // 카카오 로그아웃
    try {
      await kakao.UserApi.instance.logout();
    } catch (e) {
      // 카카오 로그아웃 에러는 무시
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Realtime Database에 사용자 데이터 생성
  Future<void> _createUserInDatabase(
    User user,
    app_user.LoginProvider provider, [
    String? displayName,
    String? photoUrl,
  ]) async {
    final userRef = _database.ref().child('$_usersPath/${user.uid}');
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      final now = DateTime.now();

      final newUser = app_user.UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName,
        photoUrl: photoUrl ?? user.photoURL,
        createdAt: now,
        lastLoginAt: now,
        loginProvider: provider,
      );

      // DateTime을 String으로 변환
      final userData = newUser.toJson();
      userData['createdAt'] = now.toIso8601String();
      userData['lastLoginAt'] = now.toIso8601String();

      await userRef.set(userData);
    } else {
      // 이미 존재하는 사용자면 마지막 로그인 시간만 업데이트
      await _updateUserLastLogin(user.uid);
    }
  }

  // 사용자 마지막 로그인 시간 업데이트
  Future<void> _updateUserLastLogin(String userId) async {
    final now = DateTime.now();
    await _database.ref().child('$_usersPath/$userId').update({
      'lastLoginAt': now.toIso8601String(),
    });
  }
}
