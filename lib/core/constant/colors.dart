import 'package:flutter/material.dart';

class AppColors {
  // 주요 색상
  static const Color primaryColor = Color(0xFF9B7EDE); // 메인 파스텔 퍼플
  static const Color accentColor = Color(0xFF7EB8DE); // 파스텔 블루

  // 테마 색상 (파스텔 배경)
  static const Color lavenderBg = Color(0xFFF0E4FF); // 라벤더 배경
  static const Color peachBg = Color(0xFFFFEFDD); // 복숭아 배경
  static const Color mintBg = Color(0xFFE4FFF0); // 민트 배경
  static const Color softYellowBg = Color(0xFFFFF9E4); // 연한 노랑 배경

  // 감정 색상 (파스텔 버전)
  static const Color energeticColor = Color(0xFFFFD485); // 활기찬 감정 (파스텔 노랑)
  static const Color pleasantColor = Color(0xFF9DDCB0); // 편안한 감정 (파스텔 초록)
  static const Color calmColor = Color(0xFF9BCFEE); // 차분한 감정 (파스텔 파랑)
  static const Color tenseColor = Color(0xFFFFB1A3); // 긴장된 감정 (파스텔 빨강)

  // 진행 색상
  static const Color progressColor = Color(0xFFBF9FF8); // 진행률 색상 (연한 보라)

  // 배경 색상
  static const Color backgroundColor = Color(0xFFF0E4FF); // 앱 배경 (라벤더)
  static const Color surfaceColor = Color(0xFFFCFCFC); // 카드 배경 (흰색/매우 연한 회색)
  static const Color cardHighlightColor =
      Color(0xFFE8E8E8); // 활동 카드 아이콘 배경 (연한 회색)

  // 텍스트 색상
  static const Color primaryTextColor = Color(0xFF333333); // 주요 텍스트 (진한 회색)
  static const Color secondaryTextColor = Color(0xFF777777); // 보조 텍스트 (중간 회색)
  static const Color hintTextColor = Color(0xFFAAAAAA); // 힌트 텍스트 (연한 회색)

  // 기능 색상
  static const Color successColor = Color(0xFF9DDCB0); // 성공 (파스텔 초록)
  static const Color warningColor = Color(0xFFFFD485); // 경고 (파스텔 노랑)
  static const Color errorColor = Color(0xFFFFB1A3); // 오류 (파스텔 빨강)

  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9B7EDE), Color(0xFFB798F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient focusGradient = LinearGradient(
    colors: [Color(0xFF7EB8DE), Color(0xFF9BCFEE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 테마별 그라데이션
  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFFF0E4FF), Color(0xFFE6DAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFFEFDD), Color(0xFFFFE7CD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
