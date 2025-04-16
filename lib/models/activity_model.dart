import 'package:firebase_database/firebase_database.dart';

class Activity {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int completionCount;
  final DateTime createdAt;
  final bool isCustom;
  final String userId;
  final int durationMinutes; // 활동 진행 시간 (분)

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.completionCount = 0,
    required this.createdAt,
    this.isCustom = false,
    required this.userId,
    this.durationMinutes = 30,
  });

  // JSON에서 Activity 객체로 변환
  factory Activity.fromJson(Map<String, dynamic> json) {
    // Realtime Database에서는 DateTime이 String으로 저장됨
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now();
    }

    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      completionCount: json['completionCount'] as int? ?? 0,
      createdAt: parseDateTime(json['createdAt']),
      isCustom: json['isCustom'] as bool? ?? false,
      userId: json['userId'] as String,
      durationMinutes: json['durationMinutes'] as int? ?? 30,
    );
  }

  // Realtime Database 스냅샷에서 Activity 객체로 변환
  factory Activity.fromDatabase(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    data['id'] = snapshot.key;
    return Activity.fromJson(data);
  }

  // Activity 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'completionCount': completionCount,
      'createdAt': createdAt.toIso8601String(), // DateTime을 String으로 변환
      'isCustom': isCustom,
      'userId': userId,
      'durationMinutes': durationMinutes,
    };
  }

  // 복사본 생성 (값 업데이트 용)
  Activity copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    int? completionCount,
    DateTime? createdAt,
    bool? isCustom,
    String? userId,
    int? durationMinutes,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      completionCount: completionCount ?? this.completionCount,
      createdAt: createdAt ?? this.createdAt,
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  // 기본 활동 생성 (앱 최초 설정용)
  static List<Activity> getDefaultActivities(String userId) {
    final now = DateTime.now();
    return [
      Activity(
        id: 'study',
        name: '공부하기',
        description: '하루 30분 집중',
        emoji: '📚',
        completionCount: 0,
        createdAt: now,
        isCustom: false,
        userId: userId,
        durationMinutes: 30,
      ),
      Activity(
        id: 'exercise',
        name: '운동하기',
        description: '홈트레이닝 15분',
        emoji: '💪',
        completionCount: 0,
        createdAt: now,
        isCustom: false,
        userId: userId,
        durationMinutes: 15,
      ),
      Activity(
        id: 'reading',
        name: '독서하기',
        description: '책 한 챕터 읽기',
        emoji: '📖',
        completionCount: 0,
        createdAt: now,
        isCustom: false,
        userId: userId,
        durationMinutes: 20,
      ),
      Activity(
        id: 'meditation',
        name: '명상하기',
        description: '10분 집중 명상',
        emoji: '🧘',
        completionCount: 0,
        createdAt: now,
        isCustom: false,
        userId: userId,
        durationMinutes: 10,
      ),
    ];
  }
}

// 활동 세션 기록 모델
class ActivitySession {
  final String id;
  final String activityId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final bool completed;

  ActivitySession({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.completed = false,
  });

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    // Realtime Database에서는 DateTime이 String으로 저장됨
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.parse(value);
      }
      return null;
    }

    return ActivitySession(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      userId: json['userId'] as String,
      startTime: parseDateTime(json['startTime']) ?? DateTime.now(),
      endTime: parseDateTime(json['endTime']),
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      completed: json['completed'] as bool? ?? false,
    );
  }

  factory ActivitySession.fromDatabase(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    data['id'] = snapshot.key;
    return ActivitySession.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'userId': userId,
      'startTime': startTime.toIso8601String(), // DateTime을 String으로 변환
      'endTime': endTime?.toIso8601String(), // DateTime을 String으로 변환
      'durationSeconds': duration.inSeconds,
      'completed': completed,
    };
  }

  ActivitySession copyWith({
    String? id,
    String? activityId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    bool? completed,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }
}
