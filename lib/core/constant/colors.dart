import 'package:flutter/material.dart';

class AppColors {
  // 주요 색상
  static const Color primaryColor = Color(0xFFFF5A3D); // 메인 오렌지-레드 색상
  static const Color accentColor = Color(0xFF5AC8FA); // 포커스 모드 색상 (파란색)

  // 감정 색상
  static const Color energeticColor = Color(0xFFFFCC00); // 활기찬 감정 (노랑)
  static const Color pleasantColor = Color(0xFF4CD964); // 편안한 감정 (초록)
  static const Color calmColor = Color(0xFF5AC8FA); // 차분한 감정 (파랑)
  static const Color tenseColor = Color(0xFFFF3B30); // 긴장된 감정 (빨강)

  // 주간 진행 색상
  static const Color progressColor = Color(0xFF9D4DFF); // 진행률 색상 (보라)

  // 배경 색상
  static const Color backgroundColor = Color(0xFF4CD964); // 앱 배경
  static const Color surfaceColor =
      Color.fromARGB(255, 109, 149, 100); // 카드, 필드 배경
  static const Color cardHighlightColor =
      Color.fromARGB(255, 27, 91, 42); // 활동 카드 아이콘 배경

  // 텍스트 색상
  static const Color primaryTextColor = Colors.white; // 주요 텍스트
  static const Color secondaryTextColor = Color(0xFF808080); // 보조 텍스트
  static const Color hintTextColor = Color(0xFF808080); // 힌트 텍스트

  // 기능 색상
  static const Color successColor = Color(0xFF4CD964); // 성공 (초록)
  static const Color warningColor = Color(0xFFFFCC00); // 경고 (노랑)
  static const Color errorColor = Color(0xFFFF3B30); // 오류 (빨강)

  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5A3D), Color(0xFFFF3B30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient focusGradient = LinearGradient(
    colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
