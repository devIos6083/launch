import 'package:firebase_database/firebase_database.dart';

enum LoginProvider {
  email,
  google,
  kakao,
}

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final LoginProvider loginProvider;
  final List<String> favoriteActivityIds;
  final int streak; // 연속 사용 일수
  final int totalCompletedActivities;
  final Map<String, int> weeklyProgress; // 요일별 완료 활동 수

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.loginProvider,
    this.favoriteActivityIds = const [],
    this.streak = 0,
    this.totalCompletedActivities = 0,
    Map<String, int>? weeklyProgress,
  }) : weeklyProgress = weeklyProgress ??
            {
              'monday': 0,
              'tuesday': 0,
              'wednesday': 0,
              'thursday': 0,
              'friday': 0,
              'saturday': 0,
              'sunday': 0,
            };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Realtime Database에서는 DateTime이 String으로 저장됨
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now();
    }

    // 리스트 변환 처리 (Realtime Database에서는 리스트가 Map으로 저장될 수 있음)
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is Map) return value.values.map((e) => e.toString()).toList();
      return [];
    }

    // Map 변환 처리
    Map<String, int> parseWeeklyProgress(dynamic value) {
      if (value == null) {
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

      if (value is Map) {
        return (value).map((key, value) => MapEntry(key.toString(),
            (value is int) ? value : int.tryParse(value.toString()) ?? 0));
      }

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

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: parseDateTime(json['createdAt']),
      lastLoginAt: parseDateTime(json['lastLoginAt']),
      loginProvider: LoginProvider.values
          .byName((json['loginProvider'] as String?) ?? 'email'),
      favoriteActivityIds: parseStringList(json['favoriteActivityIds']),
      streak: json['streak'] as int? ?? 0,
      totalCompletedActivities: json['totalCompletedActivities'] as int? ?? 0,
      weeklyProgress: parseWeeklyProgress(json['weeklyProgress']),
    );
  }

  factory UserModel.fromDatabase(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    data['id'] = snapshot.key;
    return UserModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(), // DateTime을 String으로 변환
      'lastLoginAt': lastLoginAt.toIso8601String(), // DateTime을 String으로 변환
      'loginProvider': loginProvider.name,
      'favoriteActivityIds': favoriteActivityIds,
      'streak': streak,
      'totalCompletedActivities': totalCompletedActivities,
      'weeklyProgress': weeklyProgress,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    LoginProvider? loginProvider,
    List<String>? favoriteActivityIds,
    int? streak,
    int? totalCompletedActivities,
    Map<String, int>? weeklyProgress,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginProvider: loginProvider ?? this.loginProvider,
      favoriteActivityIds: favoriteActivityIds ?? this.favoriteActivityIds,
      streak: streak ?? this.streak,
      totalCompletedActivities:
          totalCompletedActivities ?? this.totalCompletedActivities,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    );
  }

  // 요일별 진행 상황 업데이트
  UserModel updateDailyProgress() {
    final today = DateTime.now();
    String dayName = _getDayName(today.weekday);

    final newProgress = Map<String, int>.from(weeklyProgress);
    newProgress[dayName] = (newProgress[dayName] ?? 0) + 1;

    return copyWith(
      weeklyProgress: newProgress,
      totalCompletedActivities: totalCompletedActivities + 1,
    );
  }

  // 스트릭 업데이트 (연속 사용 일수)
  UserModel updateStreak(DateTime lastActiveDate) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // 어제 활동했는지 확인
    final bool wasActiveYesterday = lastActiveDate.year == yesterday.year &&
        lastActiveDate.month == yesterday.month &&
        lastActiveDate.day == yesterday.day;

    // 오늘 활동했는지 확인
    final bool isActiveToday = lastActiveDate.year == now.year &&
        lastActiveDate.month == now.month &&
        lastActiveDate.day == now.day;

    // 어제 활동했으면 스트릭 유지/증가, 아니면 리셋
    if (wasActiveYesterday || isActiveToday) {
      return copyWith(streak: streak + 1);
    } else {
      return copyWith(streak: 1); // 스트릭 리셋
    }
  }

  // 요일명 반환
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
}
