import 'package:flutter/material.dart';
import 'package:launch/viewmodels/auth_viewmodel.dart';
import 'package:launch/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:launch/core/constant/colors.dart';
import 'package:launch/viewmodels/countdown_viewmodel.dart';
import 'package:launch/viewmodels/activity_viewmodel.dart';
import 'package:launch/views/widgets/countdown_timer.dart';
import 'package:launch/views/widgets/app_button.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathAnimationController;
  late Animation<double> _breathAnimation;

  // 중복 호출 방지 플래그 추가
  bool _completedHandled = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 설정
    _breathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 카운트다운 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  @override
  void dispose() {
    _breathAnimationController.dispose();
    super.dispose();
  }

  // 카운트다운 시작
  void _startCountdown() {
    final countdownViewModel =
        Provider.of<CountdownViewModel>(context, listen: false);
    countdownViewModel.startCountdown();
  }

  // 카운트다운 취소
  void _cancelCountdown() {
    final countdownViewModel =
        Provider.of<CountdownViewModel>(context, listen: false);
    countdownViewModel.cancelCountdown();
    Navigator.of(context).pop(false); // 취소된 경우 false 반환
  }

  // TTS 토글
  void _toggleTts() {
    final countdownViewModel =
        Provider.of<CountdownViewModel>(context, listen: false);
    countdownViewModel.toggleTts();
  }

  // 집중 타이머 화면으로 이동
  void _navigateToFocusTimer() {
    final activityViewModel =
        Provider.of<ActivityViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    // 중요: 카운트다운 완료 시 바로 통계 업데이트
    if (authViewModel.user != null) {
      // 로그 추가
      print('카운트다운 완료: 통계 업데이트 시작');

      // 활동 완료 처리 및 통계 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await profileViewModel
            .updateStatisticsAfterActivityCompletion(authViewModel.user!.uid);

        // 활동 완료 횟수 증가
        if (activityViewModel.selectedActivity != null) {
          await activityViewModel
              .incrementCompletionCount(activityViewModel.selectedActivity!.id);
        }

        // 화면 전환 전 결과 반환 (true = 활동 완료됨)
        Navigator.of(context).pop(true);

        // 추가 화면으로 이동 (필요한 경우)
        Navigator.of(context).pushReplacementNamed('/focus_timer');
      });
    } else {
      // 사용자 정보가 없을 경우
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countdownViewModel = Provider.of<CountdownViewModel>(context);
    final activityViewModel = Provider.of<ActivityViewModel>(context);

    final selectedActivity = activityViewModel.selectedActivity;
    final seconds = countdownViewModel.secondsRemaining;
    final progress = countdownViewModel.progress;
    final isCompleted = countdownViewModel.isCompleted();
    final isTtsEnabled = countdownViewModel.isTtsEnabled;

    // 카운트다운 완료시 결과 처리 - 중복 호출 방지
    if (isCompleted && !_completedHandled) {
      _completedHandled = true; // 중복 호출 방지 플래그
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToFocusTimer();
      });
    }

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
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Row(
                  children: [
                    // 뒤로가기 버튼
                    GestureDetector(
                      onTap: _cancelCountdown,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 활동 정보
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '카운트다운',
                          style: TextStyle(
                            fontFamily: 'jua',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          selectedActivity?.name ?? '활동',
                          style: const TextStyle(
                            fontFamily: 'jua',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // 오른쪽 끝에 TTS 토글 버튼 추가
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleTts,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isTtsEnabled
                              ? AppColors.primaryColor
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 카운트다운 타이머
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 큰 카운트다운 타이머
                      CountdownTimerWithBreath(
                        seconds: seconds,
                        progress: progress,
                        size: 280,
                        progressColor: AppColors.primaryColor,
                        breathAnimation: _breathAnimation,
                        backgroundColor: Colors.white, // 밝은 배경색
                        textColor: Colors.black87, // 어두운 텍스트 색상
                      ),
                      const SizedBox(height: 40),

                      // 안내 텍스트
                      Column(
                        children: [
                          const Text(
                            '카운트다운 후 바로 시작하세요',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // 어두운 텍스트 색상
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '아무 생각없이, 바로 행동하세요!',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 14,
                              color: Colors.grey[700], // 어두운 텍스트 색상
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(
                  child: AppButton(
                    text: '취소',
                    onPressed: _cancelCountdown,
                    backgroundColor:
                        AppColors.primaryColor.withOpacity(0.1), // 연한 색상
                    textColor: AppColors.primaryColor, // 메인 색상
                    height: 45,
                    borderRadius: 22.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
