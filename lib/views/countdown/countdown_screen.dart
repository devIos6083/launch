import 'package:flutter/material.dart';
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
    Navigator.of(context).pop();
  }

  // 집중 타이머 화면으로 이동
  void _navigateToFocusTimer() {
    Navigator.of(context).pushReplacementNamed('/focus_timer');
  }

  @override
  Widget build(BuildContext context) {
    final countdownViewModel = Provider.of<CountdownViewModel>(context);
    final activityViewModel = Provider.of<ActivityViewModel>(context);

    final selectedActivity = activityViewModel.selectedActivity;
    final seconds = countdownViewModel.secondsRemaining;
    final progress = countdownViewModel.progress;
    final isCompleted = countdownViewModel.isCompleted();

    // 카운트다운 완료시 자동으로 타이머 화면으로 이동
    if (isCompleted) {
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
                          color: AppColors.surfaceColor,
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
                            color: Colors.white,
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
                      ),
                      const SizedBox(height: 40),

                      // 안내 텍스트
                      Column(
                        children: [
                          Text(
                            '카운트다운 후 바로 시작하세요',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '아무 생각없이, 바로 행동하세요!',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 14,
                              color: Colors.grey[400],
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
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
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
