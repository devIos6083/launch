import 'package:flutter/material.dart';
import 'package:launch/core/constant/colors.dart';

class CountdownTimer extends StatelessWidget {
  final int seconds;
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;
  final Widget? child;

  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.progress,
    this.size = 200,
    this.backgroundColor = const Color(0xFF222222),
    this.progressColor = AppColors.primaryColor,
    this.textColor = Colors.white,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 선
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
        ),

        // 진행 상태 원
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),

        // 시간 표시
        if (child != null)
          child!
        else
          Text(
            seconds.toString(),
            style: TextStyle(
              fontFamily: 'jua',
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
      ],
    );
  }
}

class CountdownTimerWithBackgroundLines extends StatelessWidget {
  final int seconds;
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;

  const CountdownTimerWithBackgroundLines({
    super.key,
    required this.seconds,
    required this.progress,
    this.size = 200,
    this.backgroundColor = const Color(0xFF222222),
    this.progressColor = AppColors.primaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 선
          ...List.generate(5, (index) {
            return Positioned(
              top: size * 0.15 + (index * size * 0.15),
              left: size * 0.2,
              right: size * 0.2,
              child: Container(
                height: 2,
                color: const Color(0xFF333333),
              ),
            );
          }),

          // 진행 상태 원
          SizedBox(
            width: size * 0.85,
            height: size * 0.85,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: const Color(0xFF333333),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          // 시간 표시
          Text(
            seconds.toString(),
            style: TextStyle(
              fontFamily: 'jua',
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CountdownTimerWithBreath extends StatelessWidget {
  final int seconds;
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;
  final Animation<double> breathAnimation;

  const CountdownTimerWithBreath({
    super.key,
    required this.seconds,
    required this.progress,
    required this.breathAnimation,
    this.size = 200,
    this.backgroundColor = const Color(0xFF222222),
    this.progressColor = AppColors.primaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 원
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
        ),

        // 숨쉬는 원
        AnimatedBuilder(
          animation: breathAnimation,
          builder: (context, child) {
            return Container(
              width: size * (0.7 + breathAnimation.value * 0.1),
              height: size * (0.7 + breathAnimation.value * 0.1),
              decoration: BoxDecoration(
                color: progressColor
                    .withOpacity(0.1 + breathAnimation.value * 0.1),
                shape: BoxShape.circle,
              ),
            );
          },
        ),

        // 진행 상태 원
        SizedBox(
          width: size * 0.9,
          height: size * 0.9,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: const Color(0xFF333333),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),

        // 시간 표시
        Text(
          seconds.toString(),
          style: TextStyle(
            fontFamily: 'jua',
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
