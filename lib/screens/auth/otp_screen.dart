import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth/auth_cubit.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/form/form_label.dart';
import 'login_screen.dart';
import 'widgets/auth_bottom_bar.dart';
import 'widgets/auth_hero_image.dart';
import 'widgets/otp_input.dart';

/// "تأكيد الرقم" — إدخال رمز التحقق المرسل على واتساب.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  /// الرقم اللي انكتب بصفحة تسجيل الدخول، منسّق: "+963 993 930 716".
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _codeLength = 6;
  static const _resendAfter = 60;
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _code = TextEditingController();
  final _supportTap = TapGestureRecognizer()
    ..onTap = () {}; // TODO: open customer support
  Timer? _timer;
  int _secondsLeft = _resendAfter;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _supportTap.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  String get _countdown =>
      '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';

  void _confirm() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyCode(_code.text);
  }

  void _resend() {
    context.read<AuthCubit>().resendCode();
    _startTimer();
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      // الدخول نجح ← اختيار نوع الحساب (بتمسح اللي قبل).
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else if (state.status == AuthStatus.failure && state.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = AppTextStyles.body16.copyWith(
      color: context.colors.link,
      decoration: TextDecoration.underline,
      decorationColor: context.colors.link,
    );
    final canResend = _secondsLeft == 0;

    final verifying = context.select(
      (AuthCubit c) => c.state.status == AuthStatus.verifying,
    );
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onAuthChanged,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayStyle(context),
        child: Scaffold(
          backgroundColor: context.colors.background,
          bottomNavigationBar: AuthBottomBar(
            label: 'تأكيد الرمز',
            isLoading: verifying,
            onPressed: _code.text.length == _codeLength && !verifying
                ? _confirm
                : null,
            note: AuthNote(
              spans: [
                const TextSpan(text: 'في حال عدم وصول الرمز يمكنك '),
                TextSpan(
                  text: 'التواصل مع خدمة العملاء',
                  style: AuthNote.linkStyle(context),
                  recognizer: _supportTap,
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const AuthHeroImage(),
              const SizedBox(height: 16),
              const Text(
                'تأكيد الرقم',
                textAlign: TextAlign.center,
                style: AppTextStyles.title30Bold,
              ),
              const SizedBox(height: 12),
              Text(
                'تم إرسال رمز التحقق على واتساب إلى الرقم',
                textAlign: TextAlign.center,
                style: AppTextStyles.title20Medium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                widget.phone,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: AppTextStyles.title20.copyWith(
                  color: context.colors.link,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel('رمز التأكيد', isRequired: true),
                    ),
                    const SizedBox(height: 8),
                    OtpInput(controller: _code, length: _codeLength),
                    const SizedBox(height: 8),
                    Padding(
                      padding: _labelPadding,
                      child: Text(
                        'أدخل الرمز المكون من 6 أرقام المرسل إلى رقمك الوتس اب',
                        style: AppTextStyles.body14.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: _labelPadding,
                      child: Row(
                        spacing: 21,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: canResend ? _resend : null,
                              child: Text(
                                canResend
                                    ? 'إعادة إرسال الرمز'
                                    : 'إعادة إرسال الرمز خلال $_countdown',
                                style: link,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: context.colors.border,
                          ),
                          Flexible(
                            child: GestureDetector(
                              // الرقم بينكتب بصفحة تسجيل الدخول اللي قبل.
                              onTap: () => Navigator.pop(context),
                              child: Text('تغيير رقم الهاتف', style: link),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
