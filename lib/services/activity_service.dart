import 'package:firebase_database/firebase_database.dart';
import 'package:launch/models/activity_model.dart';
import 'package:uuid/uuid.dart';

abstract class ActivityService {
  Future<List<Activity>> getUserActivities(String userId);
  Future<Activity> getActivity(String activityId);
  Future<Activity> createActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String activityId);
  Future<void> incrementCompletionCount(String activityId);
  Future<List<ActivitySession>> getUserActivitySessions(String userId,
      {DateTime? startDate, DateTime? endDate});
  Future<ActivitySession> createActivitySession(ActivitySession session);
  Future<void> updateActivitySession(ActivitySession session);
  Future<void> completeActivitySession(String sessionId);
  Stream<List<Activity>> userActivitiesStream(String userId);
}

class ActivityServiceImpl implements ActivityService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final Uuid _uuid = const Uuid();

  // 참조 경로
  String get _activitiesPath => 'activities';
  String get _activitySessionsPath => 'activity_sessions';
  String get _usersPath => 'users';

  // 사용자 활동 목록 가져오기
  @override
  Future<List<Activity>> getUserActivities(String userId) async {
    try {
      final reference = _database.ref().child(_activitiesPath);
      final snapshot =
          await reference.orderByChild('userId').equalTo(userId).get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? activities =
            snapshot.value as Map<dynamic, dynamic>?;
        if (activities != null) {
          return activities.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            data['id'] = entry.key;

            // 날짜 변환 처리
            if (data['createdAt'] is String) {
              data['createdAt'] = DateTime.parse(data['createdAt']);
            }

            return Activity.fromJson(data);
          }).toList();
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // 특정 활동 상세 정보 가져오기
  @override
  Future<Activity> getActivity(String activityId) async {
    try {
      final reference = _database.ref().child('$_activitiesPath/$activityId');
      final snapshot = await reference.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = activityId;

        // 날짜 변환 처리
        if (data['createdAt'] is String) {
          data['createdAt'] = DateTime.parse(data['createdAt']);
        }

        return Activity.fromJson(data);
      } else {
        throw Exception('Activity not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 새 활동 생성
  @override
  Future<Activity> createActivity(Activity activity) async {
    try {
      // ID가 없으면 UUID 생성
      final activityId = activity.id.isEmpty ? _uuid.v4() : activity.id;
      final newActivity = activity.copyWith(id: activityId);

      // JSON 변환 시 DateTime을 문자열로 변환
      final Map<String, dynamic> activityData = newActivity.toJson();
      activityData['createdAt'] = newActivity.createdAt.toIso8601String();

      // 데이터 저장
      await _database
          .ref()
          .child('$_activitiesPath/$activityId')
          .set(activityData);

      return newActivity;
    } catch (e) {
      rethrow;
    }
  }

  // 활동 정보 업데이트
  @override
  Future<void> updateActivity(Activity activity) async {
    try {
      // JSON 변환 시 DateTime을 문자열로 변환
      final Map<String, dynamic> activityData = activity.toJson();
      activityData['createdAt'] = activity.createdAt.toIso8601String();

      await _database
          .ref()
          .child('$_activitiesPath/${activity.id}')
          .update(activityData);
    } catch (e) {
      rethrow;
    }
  }

  // 활동 삭제
  @override
  Future<void> deleteActivity(String activityId) async {
    try {
      await _database.ref().child('$_activitiesPath/$activityId').remove();
    } catch (e) {
      rethrow;
    }
  }

  // 활동 완료 횟수 증가
  @override
  Future<void> incrementCompletionCount(String activityId) async {
    try {
      final reference =
          _database.ref().child('$_activitiesPath/$activityId/completionCount');

      // 트랜잭션으로 안전하게 증가
      final transactionResult =
          await reference.runTransaction((Object? currentValue) {
        if (currentValue == null) {
          return Transaction.success(1);
        }

        return Transaction.success((currentValue as int) + 1);
      });

      if (transactionResult.committed == false) {
        throw Exception('Failed to increment completion count');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 사용자의 활동 세션 목록 가져오기
  @override
  Future<List<ActivitySession>> getUserActivitySessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final reference = _database.ref().child(_activitySessionsPath);
      final snapshot =
          await reference.orderByChild('userId').equalTo(userId).get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? sessions =
            snapshot.value as Map<dynamic, dynamic>?;
        if (sessions != null) {
          final List<ActivitySession> result = [];

          for (final entry in sessions.entries) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            data['id'] = entry.key;

            // 날짜 변환 처리
            if (data['startTime'] is String) {
              data['startTime'] = DateTime.parse(data['startTime']);
            }
            if (data['endTime'] != null && data['endTime'] is String) {
              data['endTime'] = DateTime.parse(data['endTime']);
            }

            // 시간 필터링
            if (startDate != null &&
                DateTime.parse(data['startTime'].toString())
                    .isBefore(startDate)) {
              continue;
            }
            if (endDate != null &&
                DateTime.parse(data['startTime'].toString()).isAfter(endDate)) {
              continue;
            }

            // 세션 시간 계산 (초 단위)
            if (!data.containsKey('durationSeconds')) {
              data['durationSeconds'] = 0;
            }

            result.add(ActivitySession.fromJson(data));
          }

          // 시작 시간 기준 내림차순 정렬
          result.sort((a, b) => b.startTime.compareTo(a.startTime));

          return result;
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // 새 활동 세션 생성
  @override
  Future<ActivitySession> createActivitySession(ActivitySession session) async {
    try {
      final sessionId = session.id.isEmpty ? _uuid.v4() : session.id;
      final newSession = session.copyWith(id: sessionId);

      // JSON 변환 시 DateTime을 문자열로 변환
      final Map<String, dynamic> sessionData = newSession.toJson();
      sessionData['startTime'] = newSession.startTime.toIso8601String();
      if (newSession.endTime != null) {
        sessionData['endTime'] = newSession.endTime!.toIso8601String();
      }

      // 세션 시간 계산 (초 단위)
      sessionData['durationSeconds'] = newSession.duration.inSeconds;

      // 데이터 저장
      await _database
          .ref()
          .child('$_activitySessionsPath/$sessionId')
          .set(sessionData);

      return newSession;
    } catch (e) {
      rethrow;
    }
  }

  // 활동 세션 업데이트
  @override
  Future<void> updateActivitySession(ActivitySession session) async {
    try {
      // JSON 변환 시 DateTime을 문자열로 변환
      final Map<String, dynamic> sessionData = session.toJson();
      sessionData['startTime'] = session.startTime.toIso8601String();
      if (session.endTime != null) {
        sessionData['endTime'] = session.endTime!.toIso8601String();
      }

      // 세션 시간 계산 (초 단위)
      sessionData['durationSeconds'] = session.duration.inSeconds;

      await _database
          .ref()
          .child('$_activitySessionsPath/${session.id}')
          .update(sessionData);
    } catch (e) {
      rethrow;
    }
  }

  // 활동 세션 완료 처리
  @override
  Future<void> completeActivitySession(String sessionId) async {
    try {
      final now = DateTime.now();
      final reference =
          _database.ref().child('$_activitySessionsPath/$sessionId');

      // 세션 정보 업데이트
      await reference.update({
        'completed': true,
        'endTime': now.toIso8601String(),
      });

      // 세션 정보 가져오기
      final snapshot = await reference.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // 해당 활동의 완료 횟수 증가
        await incrementCompletionCount(data['activityId']);

        // 사용자 통계 업데이트
        await _updateUserStatistics(data['userId']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // 사용자 통계 업데이트
  Future<void> _updateUserStatistics(String userId) async {
    try {
      // 오늘 날짜 가져오기
      final today = DateTime.now();
      final dayName = _getDayName(today.weekday);

      final userRef = _database.ref().child('$_usersPath/$userId');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData =
            Map<String, dynamic>.from(snapshot.value as Map? ?? {});

        // 마지막 활동 날짜 확인
        DateTime lastLoginAt;
        if (userData.containsKey('lastLoginAt') &&
            userData['lastLoginAt'] != null) {
          lastLoginAt = userData['lastLoginAt'] is String
              ? DateTime.parse(userData['lastLoginAt'])
              : DateTime.now();
        } else {
          lastLoginAt = DateTime.now();
        }

        // 연속 사용 일수 계산
        int currentStreak = userData['streak'] ?? 0;
        final yesterday = DateTime(today.year, today.month, today.day - 1);

        // 어제 활동했는지 확인
        bool wasActiveYesterday = lastLoginAt.year == yesterday.year &&
            lastLoginAt.month == yesterday.month &&
            lastLoginAt.day == yesterday.day;

        // 오늘 활동했는지 확인
        bool isActiveToday = lastLoginAt.year == today.year &&
            lastLoginAt.month == today.month &&
            lastLoginAt.day == today.day;

        // 스트릭 업데이트
        if (wasActiveYesterday || isActiveToday) {
          currentStreak += 1;
        } else {
          currentStreak = 1; // 스트릭 리셋
        }

        // 주간 진행 상황 업데이트
        Map<String, dynamic> weeklyProgress =
            userData['weeklyProgress'] as Map<String, dynamic>? ?? {};
        weeklyProgress[dayName] = (weeklyProgress[dayName] as int? ?? 0) + 1;

        // 총 완료 활동 업데이트
        final totalCompleted =
            (userData['totalCompletedActivities'] as int? ?? 0) + 1;

        // 사용자 문서 업데이트
        await userRef.update({
          'streak': currentStreak,
          'weeklyProgress': weeklyProgress,
          'totalCompletedActivities': totalCompleted,
          'lastLoginAt': today.toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // 요일 이름 반환
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  // 사용자 활동 스트림
  @override
  Stream<List<Activity>> userActivitiesStream(String userId) {
    final reference = _database.ref().child(_activitiesPath);

    return reference
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? activities =
            snapshot.value as Map<dynamic, dynamic>?;
        if (activities != null) {
          return activities.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            data['id'] = entry.key;

            // 날짜 변환 처리
            if (data['createdAt'] is String) {
              data['createdAt'] = DateTime.parse(data['createdAt']);
            }

            return Activity.fromJson(data);
          }).toList();
        }
      }

      return <Activity>[];
    });
  }
}
