import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:launch/models/activity_model.dart';

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final int totalSeconds;
  final int remainingSeconds;
  final ActivitySession? currentSession;

  TimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.currentSession,
  });

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? totalSeconds,
    int? remainingSeconds,
    ActivitySession? currentSession,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentSession: currentSession ?? this.currentSession,
    );
  }
}

abstract class TimerService {
  // 카운트다운 관련
  Future<void> startCountdown(int seconds);
  Future<void> cancelCountdown();
  Stream<int> get countdownStream;

  // 집중 타이머 관련
  Future<void> startFocusTimer(Activity activity);
  Future<void> pauseFocusTimer();
  Future<void> resumeFocusTimer();
  Future<void> stopFocusTimer();
  Future<void> completeFocusTimer();
  Stream<TimerState> get focusTimerStream;

  // 상태 확인
  bool get isCountdownRunning;
  bool get isFocusTimerRunning;
  bool get isFocusTimerPaused;

  // 알림 설정
  Future<void> setupNotifications();
}

class TimerServiceImpl implements TimerService {
  // 알림 관련
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 오디오 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 카운트다운 관련
  final StreamController<int> _countdownController =
      StreamController<int>.broadcast();
  Timer? _countdownTimer;
  bool _isCountdownRunning = false;

  // 집중 타이머 관련
  final StreamController<TimerState> _focusTimerController =
      StreamController<TimerState>.broadcast();
  Timer? _focusTimer;
  late TimerState _timerState;
  DateTime? _timerStartTime;
  DateTime? _timerPauseTime;

  TimerServiceImpl() {
    _timerState = TimerState();
    setupNotifications();
  }

  // 알림 설정
  @override
  Future<void> setupNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  // 카운트다운 시작
  @override
  Future<void> startCountdown(int seconds) async {
    if (_isCountdownRunning) {
      await cancelCountdown();
    }

    _isCountdownRunning = true;
    int remaining = seconds;

    _countdownController.add(remaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;

      if (remaining <= 0) {
        timer.cancel();
        _isCountdownRunning = false;
        _countdownController.add(0);
        _playSound('countdown_complete.mp3');
      } else {
        _countdownController.add(remaining);
        if (remaining <= 3) {
          _playSound('tick.mp3');
        }
      }
    });
  }

  // 카운트다운 취소
  @override
  Future<void> cancelCountdown() async {
    _countdownTimer?.cancel();
    _isCountdownRunning = false;
  }

  // 집중 타이머 시작
  @override
  Future<void> startFocusTimer(Activity activity) async {
    if (_timerState.isRunning) {
      await stopFocusTimer();
    }

    final durationSeconds = activity.durationMinutes * 60;
    _timerStartTime = DateTime.now();

    // 새 타이머 세션 생성
    final session = ActivitySession(
      id: '',
      activityId: activity.id,
      userId: activity.userId,
      startTime: _timerStartTime!,
      duration: Duration(seconds: durationSeconds),
      completed: false,
    );

    _timerState = TimerState(
      isRunning: true,
      isPaused: false,
      totalSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      currentSession: session,
    );

    _focusTimerController.add(_timerState);

    // 타이머 시작
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsedSeconds =
          DateTime.now().difference(_timerStartTime!).inSeconds;
      final remaining = durationSeconds - elapsedSeconds;

      if (remaining <= 0) {
        timer.cancel();
        completeFocusTimer();
      } else {
        _timerState = _timerState.copyWith(remainingSeconds: remaining);
        _focusTimerController.add(_timerState);
      }
    });

    // 백그라운드 전환 감지를 위한 앱 생명주기 리스너 추가
    // 실제 구현에서는 AppLifecycleState 이벤트를 감지하여 처리
  }

  // 집중 타이머 일시정지
  @override
  Future<void> pauseFocusTimer() async {
    if (_timerState.isRunning && !_timerState.isPaused) {
      _focusTimer?.cancel();
      _timerPauseTime = DateTime.now();

      _timerState = _timerState.copyWith(isPaused: true);
      _focusTimerController.add(_timerState);
    }
  }

  // 집중 타이머 재개
  @override
  Future<void> resumeFocusTimer() async {
    if (_timerState.isRunning && _timerState.isPaused) {
      // 일시정지 시간만큼 시작 시간 조정
      final pauseDuration = DateTime.now().difference(_timerPauseTime!);
      _timerStartTime = _timerStartTime!.add(pauseDuration);

      _timerState = _timerState.copyWith(isPaused: false);
      _focusTimerController.add(_timerState);

      // 타이머 재시작
      _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final elapsedSeconds =
            DateTime.now().difference(_timerStartTime!).inSeconds;
        final remaining = _timerState.totalSeconds - elapsedSeconds;

        if (remaining <= 0) {
          timer.cancel();
          completeFocusTimer();
        } else {
          _timerState = _timerState.copyWith(remainingSeconds: remaining);
          _focusTimerController.add(_timerState);
        }
      });
    }
  }

  // 집중 타이머 중지
  @override
  Future<void> stopFocusTimer() async {
    _focusTimer?.cancel();

    _timerState = TimerState();
    _focusTimerController.add(_timerState);

    _timerStartTime = null;
    _timerPauseTime = null;
  }

  // 집중 타이머 완료
  @override
  Future<void> completeFocusTimer() async {
    _focusTimer?.cancel();

    // 타이머 완료 알림
    await _showTimerCompleteNotification();

    // 완료 사운드 재생
    await _playSound('timer_complete.mp3');

    // 상태 업데이트
    _timerState = TimerState(
      isRunning: false,
      isPaused: false,
      totalSeconds: _timerState.totalSeconds,
      remainingSeconds: 0,
      currentSession: _timerState.currentSession?.copyWith(
        completed: true,
        endTime: DateTime.now(),
      ),
    );

    _focusTimerController.add(_timerState);

    _timerStartTime = null;
    _timerPauseTime = null;
  }

  // 타이머 완료 알림 표시
  Future<void> _showTimerCompleteNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'focus_timer_channel',
      'Focus Timer Notifications',
      channelDescription: 'Notifications for focus timer completion',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '타이머 완료!',
      '집중 시간이 끝났습니다. 잘 하셨어요!',
      notificationDetails,
    );
  }

  // 사운드 재생
  Future<void> _playSound(String soundName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$soundName'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  // 카운트다운 스트림
  @override
  Stream<int> get countdownStream => _countdownController.stream;

  // 집중 타이머 스트림
  @override
  Stream<TimerState> get focusTimerStream => _focusTimerController.stream;

  // 카운트다운 실행 중 여부
  @override
  bool get isCountdownRunning => _isCountdownRunning;

  // 집중 타이머 실행 중 여부
  @override
  bool get isFocusTimerRunning => _timerState.isRunning;

  // 집중 타이머 일시정지 여부
  @override
  bool get isFocusTimerPaused => _timerState.isPaused;

  // 리소스 해제
  void dispose() {
    _countdownTimer?.cancel();
    _focusTimer?.cancel();
    _countdownController.close();
    _focusTimerController.close();
    _audioPlayer.dispose();
  }
}
