import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:launch/models/activity_model.dart';
import 'package:launch/repositories/activity_repository.dart';
import 'package:launch/services/timer_service.dart';

enum FocusTimerState {
  initial,
  running,
  paused,
  completed,
}

class TimerViewModel with ChangeNotifier {
  final TimerService _timerService;
  final ActivityRepository _activityRepository;

  FocusTimerState _state = FocusTimerState.initial;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Activity? _currentActivity;
  ActivitySession? _currentSession;
  String? _errorMessage;
  StreamSubscription<TimerState>? _timerSubscription;

  TimerViewModel({
    required TimerService timerService,
    required ActivityRepository activityRepository,
  })  : _timerService = timerService,
        _activityRepository = activityRepository {
    _initTimerListener();
  }

  // 상태 및 데이터 접근자
  FocusTimerState get state => _state;
  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  Activity? get currentActivity => _currentActivity;
  ActivitySession? get currentSession => _currentSession;
  String? get errorMessage => _errorMessage;

  double get progress => _totalSeconds > 0
      ? ((_totalSeconds - _remainingSeconds) / _totalSeconds)
      : 0.0;
  String get formattedTime => _formatTime(_remainingSeconds);
  bool get isRunning => _state == FocusTimerState.running;
  bool get isPaused => _state == FocusTimerState.paused;

  // 타이머 리스너 초기화
  void _initTimerListener() {
    _timerSubscription = _timerService.focusTimerStream.listen((timerState) {
      _totalSeconds = timerState.totalSeconds;
      _remainingSeconds = timerState.remainingSeconds;
      _currentSession = timerState.currentSession;

      if (timerState.isRunning) {
        _state = timerState.isPaused
            ? FocusTimerState.paused
            : FocusTimerState.running;
      } else {
        _state = _remainingSeconds <= 0
            ? FocusTimerState.completed
            : FocusTimerState.initial;
      }

      notifyListeners();
    });
  }

  // 집중 타이머 시작
  Future<bool> startFocusTimer(Activity activity) async {
    try {
      _errorMessage = null;
      _currentActivity = activity;

      // 타이머 서비스로 타이머 시작
      await _timerService.startFocusTimer(activity);

      // 활동 세션 생성
      final createdSession = await _activityRepository.createActivitySession(
        ActivitySession(
          id: '',
          activityId: activity.id,
          userId: activity.userId,
          startTime: DateTime.now(),
          duration: Duration(minutes: activity.durationMinutes),
          completed: false,
        ),
      );

      _currentSession = createdSession;
      _state = FocusTimerState.running;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 타이머 일시정지
  Future<void> pauseTimer() async {
    try {
      await _timerService.pauseFocusTimer();
      _state = FocusTimerState.paused;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 타이머 재개
  Future<void> resumeTimer() async {
    try {
      await _timerService.resumeFocusTimer();
      _state = FocusTimerState.running;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 타이머 중지
  Future<void> stopTimer() async {
    try {
      await _timerService.stopFocusTimer();
      _state = FocusTimerState.initial;
      _currentActivity = null;
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 타이머 완료
  Future<bool> completeTimer() async {
    try {
      await _timerService.completeFocusTimer();

      // 활동 세션 완료 처리
      if (_currentSession != null) {
        await _activityRepository.completeActivitySession(_currentSession!.id);

        // 활동 완료 횟수 증가
        if (_currentActivity != null) {
          await _activityRepository
              .incrementCompletionCount(_currentActivity!.id);
        }
      }

      _state = FocusTimerState.completed;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 타이머 재설정
  void resetTimer() {
    _state = FocusTimerState.initial;
    _totalSeconds = 0;
    _remainingSeconds = 0;
    _currentActivity = null;
    _currentSession = null;
    notifyListeners();
  }

  // 시간 포맷팅 (MM:SS)
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 에러 초기화
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 리소스 해제
  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }
}
