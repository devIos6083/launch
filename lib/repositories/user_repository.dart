import 'package:firebase_database/firebase_database.dart';
import 'package:launch/models/user_model.dart';
import 'package:launch/services/auth_service.dart';
import 'package:launch/services/storage_service.dart';

abstract class UserRepository {
  Future<UserModel?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserModel user);
  Future<void> updateUserStreak(String userId);
  Future<void> updateUserWeeklyProgress(String userId, String dayName);
  Future<Map<String, int>> getUserWeeklyProgress(String userId);
  Stream<UserModel?> userProfileStream(String userId);
}

class UserRepositoryImpl implements UserRepository {
  final AuthService _authService;
  final StorageService _storageService;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // 저장소 키
  static const String _keyUserProfile = 'user_profile_';

  // 참조 경로
  String get _usersPath => 'users';

  UserRepositoryImpl({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      // Realtime Database에서 사용자 정보 가져오기
      final snapshot = await _database.ref().child('$_usersPath/$userId').get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        userData['id'] = userId; // ID 추가

        final user = UserModel.fromJson(userData);

        // 로컬 캐시에 저장
        await _cacheUserProfile(user);

        return user;
      } else {
        // 캐시된 데이터 확인
        return await _getCachedUserProfile(userId);
      }
    } catch (e) {
      // 에러 발생 시 캐시 데이터 반환 시도
      return await _getCachedUserProfile(userId);
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      // DateTime을 String으로 변환
      final userData = user.toJson();
      userData['createdAt'] = user.createdAt.toIso8601String();
      userData['lastLoginAt'] = user.lastLoginAt.toIso8601String();

      await _database.ref().child('$_usersPath/${user.id}').update(userData);

      // 로컬 캐시 업데이트
      await _cacheUserProfile(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserStreak(String userId) async {
    try {
      // 현재 사용자 정보 가져오기
      final user = await getUserProfile(userId);
      if (user == null) return;

      // 마지막 로그인 시간 기준으로 스트릭 업데이트
      final updatedUser = user.updateStreak(user.lastLoginAt);

      // Realtime Database 업데이트
      await _database.ref().child('$_usersPath/$userId').update({
        'streak': updatedUser.streak,
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      // 로컬 캐시 업데이트
      await _cacheUserProfile(updatedUser);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserWeeklyProgress(String userId, String dayName) async {
    try {
      // 사용자 정보 참조
      final userRef = _database.ref().child('$_usersPath/$userId');

      // 주간 진행 상황 참조
      final weeklyProgressRef = userRef.child('weeklyProgress/$dayName');

      // 트랜잭션으로 안전하게 업데이트
      final transactionResult =
          await weeklyProgressRef.runTransaction((Object? currentValue) {
        if (currentValue == null) {
          return Transaction.success(1);
        }

        if (currentValue is int) {
          return Transaction.success(currentValue + 1);
        } else if (currentValue is String) {
          final intValue = int.tryParse(currentValue) ?? 0;
          return Transaction.success(intValue + 1);
        }

        return Transaction.success(1);
      });

      if (transactionResult.committed) {
        // 총 완료 활동 업데이트
        final totalCompletedRef = userRef.child('totalCompletedActivities');
        await totalCompletedRef.runTransaction((Object? currentValue) {
          if (currentValue == null) {
            return Transaction.success(1);
          }

          if (currentValue is int) {
            return Transaction.success(currentValue + 1);
          } else if (currentValue is String) {
            final intValue = int.tryParse(currentValue) ?? 0;
            return Transaction.success(intValue + 1);
          }

          return Transaction.success(1);
        });

        // 마지막 로그인 시간 업데이트
        await userRef.update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }

      // 캐시 데이터 새로고침
      final updatedUser = await getUserProfile(userId);
      if (updatedUser != null) {
        await _cacheUserProfile(updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getUserWeeklyProgress(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.weeklyProgress ??
          {
            'monday': 0,
            'tuesday': 0,
            'wednesday': 0,
            'thursday': 0,
            'friday': 0,
            'saturday': 0,
            'sunday': 0,
          };
    } catch (e) {
      return {
        'monday': 0,
        'tuesday': 0,
        'wednesday': 0,
        'thursday': 0,
        'friday': 0,
        'saturday': 0,
        'sunday': 0,
      };
    }
  }

  @override
  Stream<UserModel?> userProfileStream(String userId) {
    return _database.ref().child('$_usersPath/$userId').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        userData['id'] = userId; // ID 추가

        final user = UserModel.fromJson(userData);

        // 비동기적으로 캐시 업데이트 (await 없이 실행)
        _cacheUserProfile(user);

        return user;
      } else {
        return null;
      }
    });
  }

  // 로컬 캐시에 사용자 프로필 저장
  Future<void> _cacheUserProfile(UserModel user) async {
    final key = '$_keyUserProfile${user.id}';
    await _storageService.setObject(key, user.toJson());
  }

  // 로컬 캐시에서 사용자 프로필 가져오기
  Future<UserModel?> _getCachedUserProfile(String userId) async {
    final key = '$_keyUserProfile$userId';
    final json = await _storageService.getObject(key);

    if (json != null) {
      return UserModel.fromJson(json);
    }

    return null;
  }
}
