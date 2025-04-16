// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:launch/core/constant/colors.dart';
import 'package:launch/models/activity_model.dart';
import 'package:launch/viewmodels/auth_viewmodel.dart';
import 'package:launch/viewmodels/profile_viewmodel.dart';
import 'package:launch/views/widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    if (authViewModel.user != null) {
      await profileViewModel.loadUserProfile(authViewModel.user!.uid);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 로그아웃
  Future<void> _signOut() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // 로그아웃 확인 다이얼로그
  Future<void> _showSignOutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontFamily: 'jua',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
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
                '로그아웃',
                style: TextStyle(
                  fontFamily: 'jua',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _signOut();
    }
  }

  // 날짜 포맷 (yyyy년 MM월 dd일)
  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  // 요일별 진행 상황 데이터 가져오기
  List<Map<String, dynamic>> _getWeeklyProgressData(
      ProfileViewModel profileViewModel) {
    final Map<String, int> weeklyProgress = profileViewModel.weeklyProgress;
    final List<String> dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    return dayNames.map((day) {
      return {
        'day': profileViewModel.getDayNameKorean(day),
        'count': weeklyProgress[day] ?? 0,
        'isToday': _getDayName(DateTime.now().weekday) == day,
      };
    }).toList();
  }

  // 요일 이름 반환
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    final user = authViewModel.user;
    final userProfile = profileViewModel.userProfile;
    final sessions = profileViewModel.recentSessions;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '내 프로필',
          style: TextStyle(
            fontFamily: 'jua',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showSignOutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자 프로필 카드
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // 프로필 이미지
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: user?.photoURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        user!.photoURL!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                            user.displayName?[0] ?? '?',
                                            style: const TextStyle(
                                              fontFamily: 'jua',
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Text(
                                      user?.displayName?[0] ?? '?',
                                      style: const TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // 사용자 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? '사용자',
                                  style: const TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 가입일
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      userProfile != null
                                          ? '가입일: ${_formatDate(userProfile.createdAt)}'
                                          : '가입일: -',
                                      style: TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 통계 섹션
                    const Text(
                      '내 통계',
                      style: TextStyle(
                        fontFamily: 'jua',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 통계 카드들
                    Row(
                      children: [
                        // 총 완료 활동
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '완료한 활동',
                                  style: TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profileViewModel.totalCompletedActivities
                                      .toString(),
                                  style: const TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 연속 일수
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '연속 일수',
                                  style: TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profileViewModel.streak.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'jua',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.energeticColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 주간 활동 차트
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '주간 활동',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 요일별 바 차트
                          SizedBox(
                            height: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _getWeeklyProgressData(profileViewModel)
                                  .map((data) {
                                final int count = data['count'];
                                final bool isToday = data['isToday'];

                                // 최대 높이 설정
                                const maxHeight = 120.0;
                                // 최소 높이 설정 (0이라도 약간의 높이 표시)
                                final barHeight = count > 0
                                    ? (count * 30).clamp(20.0, maxHeight)
                                    : 5.0;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // 활동 수 표시
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: count > 0
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // 바 차트
                                    Container(
                                      width: 24,
                                      height: barHeight.toDouble(),
                                      decoration: BoxDecoration(
                                        color: count > 0
                                            ? AppColors.progressColor
                                            : isToday
                                                ? AppColors.primaryColor
                                                    .withOpacity(0.3)
                                                : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // 요일 라벨
                                    Text(
                                      data['day'],
                                      style: TextStyle(
                                        fontFamily: 'jua',
                                        fontSize: 14,
                                        color: isToday
                                            ? AppColors.primaryColor
                                            : Colors.grey[400],
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 최근 활동 내역
                    const Text(
                      '최근 활동 내역',
                      style: TextStyle(
                        fontFamily: 'jua',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 활동 내역 리스트
                    sessions.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '최근 활동 내역이 없습니다.',
                                    style: TextStyle(
                                      fontFamily: 'jua',
                                      fontSize: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '첫 활동을 시작해보세요!',
                                    style: TextStyle(
                                      fontFamily: 'jua',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                sessions.length > 5 ? 5 : sessions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final session = sessions[index];

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    // 활동 상태 아이콘
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: session.completed
                                            ? AppColors.successColor
                                                .withOpacity(0.1)
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          session.completed
                                              ? Icons.check_circle
                                              : Icons.timer,
                                          color: session.completed
                                              ? AppColors.successColor
                                              : Colors.grey[400],
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // 활동 정보
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '활동 ID: ${session.activityId}',
                                            style: const TextStyle(
                                              fontFamily: 'jua',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '시작 시간: ${DateFormat('MM/dd HH:mm').format(session.startTime)}',
                                            style: TextStyle(
                                              fontFamily: 'jua',
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          if (session.endTime != null)
                                            Text(
                                              '종료 시간: ${DateFormat('MM/dd HH:mm').format(session.endTime!)}',
                                              style: TextStyle(
                                                fontFamily: 'jua',
                                                fontSize: 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // 활동 시간
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: session.completed
                                                ? AppColors.successColor
                                                    .withOpacity(0.1)
                                                : Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${session.duration.inMinutes}분',
                                            style: TextStyle(
                                              fontFamily: 'jua',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: session.completed
                                                  ? AppColors.successColor
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          session.completed ? '완료됨' : '진행 중',
                                          style: TextStyle(
                                            fontFamily: 'jua',
                                            fontSize: 12,
                                            color: session.completed
                                                ? AppColors.successColor
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
