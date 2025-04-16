import 'package:launch/models/activity_model.dart';
import 'package:launch/services/activity_service.dart';
import 'package:launch/services/storage_service.dart';
import 'package:uuid/uuid.dart';

abstract class ActivityRepository {
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
  Future<bool> hasDefaultActivities(String userId);
  Future<void> createDefaultActivities(String userId);
  Stream<List<Activity>> userActivitiesStream(String userId);
}

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityService _activityService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  // 저장소 키
  static const String _keyHasDefaultActivities = 'has_default_activities_';

  ActivityRepositoryImpl({
    required ActivityService activityService,
    required StorageService storageService,
  })  : _activityService = activityService,
        _storageService = storageService;

  @override
  Future<List<Activity>> getUserActivities(String userId) {
    return _activityService.getUserActivities(userId);
  }

  @override
  Future<Activity> getActivity(String activityId) {
    return _activityService.getActivity(activityId);
  }

  @override
  Future<Activity> createActivity(Activity activity) {
    // ID가 없으면 UUID 생성
    final newActivity =
        activity.id.isEmpty ? activity.copyWith(id: _uuid.v4()) : activity;

    return _activityService.createActivity(newActivity);
  }

  @override
  Future<void> updateActivity(Activity activity) {
    return _activityService.updateActivity(activity);
  }

  @override
  Future<void> deleteActivity(String activityId) {
    return _activityService.deleteActivity(activityId);
  }

  @override
  Future<void> incrementCompletionCount(String activityId) {
    return _activityService.incrementCompletionCount(activityId);
  }

  @override
  Future<List<ActivitySession>> getUserActivitySessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _activityService.getUserActivitySessions(userId,
        startDate: startDate, endDate: endDate);
  }

  @override
  Future<ActivitySession> createActivitySession(ActivitySession session) {
    // ID가 없으면 UUID 생성
    final newSession =
        session.id.isEmpty ? session.copyWith(id: _uuid.v4()) : session;

    return _activityService.createActivitySession(newSession);
  }

  @override
  Future<void> updateActivitySession(ActivitySession session) {
    return _activityService.updateActivitySession(session);
  }

  @override
  Future<void> completeActivitySession(String sessionId) {
    return _activityService.completeActivitySession(sessionId);
  }

  @override
  Future<bool> hasDefaultActivities(String userId) async {
    final key = '$_keyHasDefaultActivities$userId';
    return await _storageService.getBool(key) ?? false;
  }

  @override
  Future<void> createDefaultActivities(String userId) async {
    // 기본 활동 목록 가져오기
    final defaultActivities = Activity.getDefaultActivities(userId);

    // 기본 활동 저장
    for (final activity in defaultActivities) {
      await _activityService.createActivity(activity);
    }

    // 기본 활동 생성 완료 표시
    final key = '$_keyHasDefaultActivities$userId';
    await _storageService.setBool(key, true);
  }

  @override
  Stream<List<Activity>> userActivitiesStream(String userId) {
    return _activityService.userActivitiesStream(userId);
  }
}
