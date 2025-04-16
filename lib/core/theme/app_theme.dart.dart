import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch/core/constant/colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      // 기본 색상 테마
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: Colors.black,
        secondary: AppColors.accentColor,
        surface: AppColors.surfaceColor,
        onSurface: Colors.white,
        error: AppColors.errorColor,
      ),

      // 배경색
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
            fontWeight: FontWeight.bold,
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
            fontWeight: FontWeight.w600,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: AppColors.hintTextColor,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: AppColors.errorColor,
          fontSize: 12,
        ),
      ),

      // 텍스트 테마
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        displayMedium: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        displaySmall: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        headlineMedium: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        titleLarge: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bodyLarge: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        bodyMedium: GoogleFonts.getFont(
          'Roboto',
          textStyle: const TextStyle(
            fontFamily: 'jua',
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // 바텀시트 테마
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}
