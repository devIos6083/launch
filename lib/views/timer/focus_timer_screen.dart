import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:launch/core/constant/colors.dart';
import 'package:launch/viewmodels/timer_viewmodel.dart';
import 'package:launch/viewmodels/activity_viewmodel.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 설정
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 타이머 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  // 타이머 시작
  Future<void> _startTimer() async {
    final activityViewModel =
        Provider.of<ActivityViewModel>(context, listen: false);
    final timerViewModel = Provider.of<TimerViewModel>(context, listen: false);

    if (activityViewModel.selectedActivity != null) {
      await timerViewModel.startFocusTimer(activityViewModel.selectedActivity!);
    }
  }

  // 타이머 일시정지/재개
  void _togglePauseResume() {
    final timerViewModel = Provider.of<TimerViewModel>(context, listen: false);

    if (timerViewModel.isPaused) {
      timerViewModel.resumeTimer();
    } else {
      timerViewModel.pauseTimer();
    }
  }

  // 타이머 중지
  void _stopTimer() {
    _showStopConfirmDialog();
  }

  // 타이머 완료
  void _completeTimer() {
    final timerViewModel = Provider.of<TimerViewModel>(context, listen: false);
    timerViewModel.completeTimer();

    Navigator.of(context).pushReplacementNamed('/home');
  }

  // 타이머 중지 확인 다이얼로그
  Future<void> _showStopConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: const Text(
            '타이머 중지',
            style: TextStyle(
              fontFamily: 'jua',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '정말 타이머를 중지하시겠습니까?\n지금 중지하면 진행 상황이 저장되지 않습니다.',
            style: TextStyle(
              fontFamily: 'jua',
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'jua',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '중지',
                style: TextStyle(
                  fontFamily: 'jua',
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final timerViewModel =
          Provider.of<TimerViewModel>(context, listen: false);
      await timerViewModel.stopTimer();

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // 포맷된 시간 문자열 생성 (mm:ss)
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerViewModel = Provider.of<TimerViewModel>(context);
    final activityViewModel = Provider.of<ActivityViewModel>(context);

    final activity = activityViewModel.selectedActivity;
    final isRunning = timerViewModel.isRunning;
    final isPaused = timerViewModel.isPaused;
    final remainingSeconds = timerViewModel.remainingSeconds;
    final totalSeconds = timerViewModel.totalSeconds;
    final progress = timerViewModel.progress;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 활동 정보
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity?.name ?? '활동',
                          style: const TextStyle(
                            fontFamily: 'jua',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          activity?.description ?? '',
                          style: TextStyle(
                            fontFamily: 'jua',
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),

                    // 건너뛰기 버튼
                    TextButton(
                      onPressed: _completeTimer,
                      child: const Text(
                        '완료하기',
                        style: TextStyle(
                          fontFamily: 'jua',
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 타이머 정보 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // 시간 정보
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '남은 시간',
                          style: TextStyle(
                            fontFamily: 'jua',
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(remainingSeconds),
                          style: const TextStyle(
                            fontFamily: 'jua',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // 진행 바
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 진행률 텍스트
                          Text(
                            '${(progress * 100).toInt()}% 완료',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 진행 바
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFF333333),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 타이머 원
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePauseResume,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isPaused ? 1.0 : _pulseAnimation.value,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isPaused
                                      ? Colors.black.withOpacity(0.2)
                                      : AppColors.primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 진행 원
                                SizedBox(
                                  width: 260,
                                  height: 260,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFF333333),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isPaused
                                          ? Colors.grey
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                ),

                                // 시간 표시
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTime(remainingSeconds),
                                      style: TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: isPaused
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isPaused ? '일시정지됨' : '집중 중',
                                      style: TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 16,
                                        color: isPaused
                                            ? Colors.grey
                                            : AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 취소 버튼
                    GestureDetector(
                      onTap: _stopTimer,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),

                    // 일시정지/재개 버튼
                    GestureDetector(
                      onTap: _togglePauseResume,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                              isPaused ? AppColors.primaryColor : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: isPaused
                                ? Colors.white
                                : AppColors.primaryColor,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),

                    // 완료 버튼
                    GestureDetector(
                      onTap: _completeTimer,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
