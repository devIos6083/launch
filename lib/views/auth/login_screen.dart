import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:launch/core/constant/colors.dart';
import 'package:launch/viewmodels/auth_viewmodel.dart';
import 'package:launch/views/widgets/app_button.dart';
import 'package:launch/views/widgets/app_text_field.dart';
import 'package:launch/core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 이메일/비밀번호 로그인
  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // 구글 로그인
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.signInWithGoogle();

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // 카카오 로그인
  Future<void> _signInWithKakao() async {
    setState(() => _isLoading = true);

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.signInWithKakao();

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // 회원가입 화면으로 이동
  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final errorMessage = authViewModel.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앱 로고 및 이름
                Center(
                  child: Column(
                    children: [
                      // 로고 (간단한 원형 + 숫자 10)
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
                        child: const Center(
                          child: Text(
                            "10",
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 앱 이름
                      const Text(
                        "LAUNCH MODE",
                        style: TextStyle(
                          fontFamily: 'jua',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // 로그인 폼
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 이메일 입력 필드
                      AppTextField(
                        controller: _emailController,
                        hintText: '이메일',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // 비밀번호 입력 필드
                      AppTextField(
                        controller: _passwordController,
                        hintText: '비밀번호',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 8),

                      // 비밀번호 찾기 링크
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // 비밀번호 재설정 다이얼로그 표시
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  _buildResetPasswordDialog(context),
                            );
                          },
                          child: const Text(
                            '비밀번호를 잊으셨나요?',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 에러 메시지
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: AppColors.errorColor,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (errorMessage != null) const SizedBox(height: 16),

                      // 로그인 버튼
                      AppButton(
                        text: '로그인',
                        onPressed:
                            _isLoading ? null : _signInWithEmailAndPassword,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),

                      // 구분선
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[800],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 소셜 로그인 버튼
                      // 카카오 로그인
                      AppButton(
                        text: '카카오톡으로 로그인',
                        onPressed: _isLoading ? null : _signInWithKakao,
                        backgroundColor: const Color(0xFFFEE500),
                        textColor: const Color(0xFF3A1D1D),
                        icon: 'img/kakao.png',
                      ),
                      const SizedBox(height: 12),

                      // 구글 로그인
                      AppButton(
                        text: 'Google로 로그인',
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        icon: 'img/google.png',
                      ),
                      const SizedBox(height: 32),

                      // 회원가입 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '계정이 없으신가요?',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            child: const Text(
                              '회원가입',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
        ),
      ),
    );
  }

  // 비밀번호 재설정 다이얼로그
  Widget _buildResetPasswordDialog(BuildContext context) {
    final resetEmailController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    return AlertDialog(
      backgroundColor: AppColors.surfaceColor,
      title: const Text(
        '비밀번호 재설정',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: dialogFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '가입한 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: resetEmailController,
              hintText: '이메일',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            '취소',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (dialogFormKey.currentState!.validate()) {
              Navigator.of(context).pop();

              // 비밀번호 재설정 요청
              final authViewModel =
                  Provider.of<AuthViewModel>(context, listen: false);
              final success = await authViewModel.resetPassword(
                resetEmailController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '비밀번호 재설정 이메일이 발송되었습니다.'
                          : '비밀번호 재설정 요청에 실패했습니다.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text(
            '전송',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
