import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch/core/constant/colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      // 기본 색상 테마 - 라이트 테마로 변경
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.accentColor,
        surface: AppColors.surfaceColor,
        onSurface: AppColors.primaryTextColor,
        error: AppColors.errorColor,
      ),

      // 배경색
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryTextColor),
        titleTextStyle: TextStyle(
          fontFamily: 'jua',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          color: AppColors.hintTextColor,
          fontSize: 14,
          fontFamily: 'jua',
        ),
        errorStyle: TextStyle(
          color: AppColors.errorColor,
          fontSize: 12,
          fontFamily: 'jua',
        ),
      ),

      // 텍스트 테마
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        displayMedium: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        displaySmall: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        headlineMedium: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        titleLarge: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        bodyLarge: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 16,
            color: AppColors.primaryTextColor,
          ),
        ),
        bodyMedium: GoogleFonts.getFont(
          'jua',
          textStyle: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryTextColor,
          ),
        ),
      ),

      // 카드 테마
      cardTheme: CardTheme(
        color: AppColors.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // 바텀시트 테마
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // 아이콘 테마
      iconTheme: IconThemeData(
        color: AppColors.primaryTextColor,
        size: 22,
      ),

      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor.withOpacity(0.3);
          }
          return AppColors.cardHighlightColor;
        }),
      ),

      // 체크박스 테마
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.cardHighlightColor;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // 시스템 테마가 다크모드일 때를 위한 라이트 테마 (파스텔 다크 테마)
  static ThemeData get darkPastelTheme {
    return ThemeData(
      useMaterial3: true,
      // 다크 모드에서도 파스텔 느낌을 유지하는 색상 테마
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.accentColor,
        // 어두운 배경에 맞는 더 어두운 파스텔 색상들
        surface: Color(0xFF3A3045),
        onSurface: Colors.white,
        error: AppColors.errorColor,
      ),

      // 배경색
      scaffoldBackgroundColor: Color(0xFF2A2235), // 어두운 보라색 배경

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'jua',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // 그 외 테마 요소들은 라이트 테마와 유사하지만 색상이 다크 모드에 맞게 조정됨...
    );
  }
}
