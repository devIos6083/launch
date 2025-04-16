import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:launch/models/activity_model.dart';
import 'package:launch/models/user_model.dart';
import 'package:launch/repositories/activity_repository.dart';
import 'package:launch/repositories/user_repository.dart';

enum ProfileViewState {
  initial,
  loading,
  loaded,
  error,
}

class ProfileViewModel with ChangeNotifier {
  final UserRepository _userRepository;
  final ActivityRepository _activityRepository;

  ProfileViewState _state = ProfileViewState.initial;
  UserModel? _userProfile;
  List<ActivitySession> _recentSessions = [];
  Map<String, int> _weeklyProgress = {};
  String? _errorMessage;
  StreamSubscription<UserModel?>? _userProfileSubscription;

  ProfileViewModel({
    required UserRepository userRepository,
    required ActivityRepository activityRepository,
  })  : _userRepository = userRepository,
        _activityRepository = activityRepository;

  // 상태 및 데이터 접근자
  ProfileViewState get state => _state;
  UserModel? get userProfile => _userProfile;
  List<ActivitySession> get recentSessions => _recentSessions;
  Map<String, int> get weeklyProgress => _weeklyProgress;
  String? get errorMessage => _errorMessage;

  int get streak => _userProfile?.streak ?? 0;
  int get totalCompletedActivities =>
      _userProfile?.totalCompletedActivities ?? 0;

  // 사용자 프로필 로드
  Future<void> loadUserProfile(String userId) async {
    try {
      _state = ProfileViewState.loading;
      notifyListeners();

      // 사용자 프로필 가져오기
      _userProfile = await _userRepository.getUserProfile(userId);

      // 주간 진행 상황 가져오기
      _weeklyProgress = await _userRepository.getUserWeeklyProgress(userId);

      // 최근 활동 세션 가져오기
      await loadRecentSessions(userId);

      // 사용자 프로필 스트림 설정
      _setupUserProfileStream(userId);

      _state = ProfileViewState.loaded;
      notifyListeners();
    } catch (e) {
      _state = ProfileViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 최근 활동 세션 로드
  Future<void> loadRecentSessions(String userId) async {
    try {
      // 일주일 전 날짜 계산
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      // 활동 세션 가져오기
      _recentSessions = await _activityRepository.getUserActivitySessions(
        userId,
        startDate: oneWeekAgo,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 사용자 프로필 스트림 설정
  void _setupUserProfileStream(String userId) {
    // 기존 구독 취소
    _userProfileSubscription?.cancel();

    // 새 구독 설정
    _userProfileSubscription = _userRepository.userProfileStream(userId).listen(
      (userProfile) {
        _userProfile = userProfile;
        if (userProfile != null) {
          _weeklyProgress = userProfile.weeklyProgress;
        }
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // 스트릭 업데이트
  Future<void> updateStreak(String userId) async {
    try {
      await _userRepository.updateUserStreak(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 주간 진행 상황 업데이트
  Future<void> updateWeeklyProgress(String userId) async {
    try {
      // 현재 요일 이름 가져오기
      final dayName = _getDayName(DateTime.now().weekday);

      // 업데이트
      await _userRepository.updateUserWeeklyProgress(userId, dayName);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 에러 초기화
  void resetError() {
    _errorMessage = null;
    if (_state == ProfileViewState.error) {
      _state = _userProfile != null
          ? ProfileViewState.loaded
          : ProfileViewState.initial;
    }
    notifyListeners();
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

  // 요일 형식 변환 (월,화,수,목,금,토,일)
  String getDayNameKorean(String dayName) {
    switch (dayName) {
      case 'monday':
        return '월';
      case 'tuesday':
        return '화';
      case 'wednesday':
        return '수';
      case 'thursday':
        return '목';
      case 'friday':
        return '금';
      case 'saturday':
        return '토';
      case 'sunday':
        return '일';
      default:
        return '';
    }
  }

  // 리소스 해제
  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
