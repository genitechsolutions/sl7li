import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/backend/app_config.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../cubits/auth/auth_cubit.dart';
import '../screens/auth/login_screen.dart';

/// زر دخول مباشر كمستخدم تجريبي بدون رمز SMS (devqa فقط، مطفي افتراضياً).
/// بينفعّل بـ `--dart-define=ENABLE_TEST_LOGIN=true --dart-define=TEST_LOGIN_PASSWORD=...`
/// والرقم الافتراضي حساب الزبون؛ للمهني `--dart-define=TEST_LOGIN_PHONE=+963222222222`.
/// للحذف: امسح هالملف + السطر المعلّم TEST-LOGIN بـ phone_login_screen.dart.
class TestLogin {
  const TestLogin._();

  static const _flag = bool.fromEnvironment('ENABLE_TEST_LOGIN');
  static const _password = String.fromEnvironment('TEST_LOGIN_PASSWORD');
  static const _phone = String.fromEnvironment(
    'TEST_LOGIN_PHONE',
    defaultValue: '+963111111111',
  );

  static bool get enabled =>
      _flag &&
      _password.isNotEmpty &&
      AppConfig.mode == BackendMode.amplify &&
      !AppConfig.isProduction;
}

class TestLoginButton extends StatefulWidget {
  const TestLoginButton({super.key});

  @override
  State<TestLoginButton> createState() => _TestLoginButtonState();
}

class _TestLoginButtonState extends State<TestLoginButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    final cubit = context.read<AuthCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      try {
        await Amplify.Auth.signOut();
      } on AuthException {
        // ما في جلسة.
      }
      final res = await Amplify.Auth.signIn(
        username: TestLogin._phone,
        password: TestLogin._password,
      );
      if (!res.isSignedIn) throw const AuthNotAuthorizedException('needs code');
      await cubit.restore();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on AuthException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('فشل الدخول التجريبي: ${e.message}')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: TextButton(
          onPressed: _busy ? null : _signIn,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'دخول كمستخدم تجريبي',
                  style: AppTextStyles.body16.copyWith(color: context.colors.error),
                ),
        ),
      ),
    );
  }
}
