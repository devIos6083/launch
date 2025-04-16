import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:launch/services/timer_service.dart';

enum CountdownState {
  initial,
  counting,
  completed,
  canceled,
}

class CountdownViewModel with ChangeNotifier {
  final TimerService _timerService;

  CountdownState _state = CountdownState.initial;
  int _secondsRemaining = 10; // 기본값: 10초
  int _totalSeconds = 10;
  StreamSubscription<int>? _countdownSubscription;

  CountdownViewModel({
    required TimerService timerService,
  }) : _timerService = timerService {
    _initCountdownListener();
  }

  // 상태 및 데이터 접근자
  CountdownState get state => _state;
  int get secondsRemaining => _secondsRemaining;
  int get totalSeconds => _totalSeconds;
  double get progress => _totalSeconds > 0
      ? ((_totalSeconds - _secondsRemaining) / _totalSeconds)
      : 0.0;
  bool get isRunning => _state == CountdownState.counting;

  // 카운트다운 리스너 초기화
  void _initCountdownListener() {
    _countdownSubscription = _timerService.countdownStream.listen((seconds) {
      _secondsRemaining = seconds;

      if (seconds <= 0) {
        _state = CountdownState.completed;
      }

      notifyListeners();
    });
  }

  // 카운트다운 시작
  Future<void> startCountdown({int seconds = 10}) async {
    if (_state == CountdownState.counting) {
      await cancelCountdown();
    }

    _totalSeconds = seconds;
    _secondsRemaining = seconds;
    _state = CountdownState.counting;

    notifyListeners();

    await _timerService.startCountdown(seconds);
  }

  // 카운트다운 취소
  Future<void> cancelCountdown() async {
    if (_state == CountdownState.counting) {
      await _timerService.cancelCountdown();
      _state = CountdownState.canceled;
      notifyListeners();
    }
  }

  // 카운트다운 재설정
  void resetCountdown() {
    _state = CountdownState.initial;
    _secondsRemaining = _totalSeconds;
    notifyListeners();
  }

  // 카운트다운 완료 여부 확인
  bool isCompleted() {
    return _state == CountdownState.completed;
  }

  // 리소스 해제
  @override
  void dispose() {
    _countdownSubscription?.cancel();
    super.dispose();
  }
}
