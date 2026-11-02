import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth/auth_cubit.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/form/form_label.dart';
import '../../core/widgets/form/phone_field.dart';
import '../home/home_screen.dart';
import 'otp_screen.dart';
import 'widgets/auth_bottom_bar.dart';
import 'widgets/auth_hero_image.dart';

/// "تسجيل الدخول" — إدخال رقم الواتساب. أول صفحة بالتطبيق.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _phone = TextEditingController();

  // بيبين خطأ الرقم بعد ما المستخدم يطلع من الحقل (متل التصميم).
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool get _phoneValid => PhoneField.isValid(_phone.text);

  bool get _showPhoneError =>
      _touched && _phone.text.isNotEmpty && !_phoneValid;

  /// الرقم بصيغة دولية بدون فراغات ("+963993930716") متل ما بيتوقعه Cognito.
  String get _e164 => PhoneField.format(_phone.text).replaceAll(' ', '');

  void _sendCode() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().requestCode(_e164);
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    if (state.status == AuthStatus.codeSent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: PhoneField.format(_phone.text)),
        ),
      );
    } else if (state.status == AuthStatus.failure && state.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sending = context.select(
      (AuthCubit c) => c.state.status == AuthStatus.sendingCode,
    );
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onAuthChanged,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayStyle(context),
        child: Scaffold(
          backgroundColor: context.colors.background,
          bottomNavigationBar: AuthBottomBar(
            label: 'إرسال رمز التحقق',
            isLoading: sending,
            onPressed: _phoneValid && !sending ? _sendCode : null,
            secondaryLabel: 'مشاهدة فيديو توضيحي',
            onSecondaryPressed: () {}, // TODO: open intro video
            note: GestureDetector(
              onTap: _continueAsGuest,
              child: Text(
                'الدخول كضيف',
                style: AppTextStyles.title18.copyWith(
                  color: context.colors.link,
                  decoration: TextDecoration.underline,
                  decorationColor: context.colors.link,
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const AuthHeroImage(),
              const SizedBox(height: 16),
              const Text(
                'تسجيل الدخول',
                textAlign: TextAlign.center,
                style: AppTextStyles.title30Bold,
              ),
              const SizedBox(height: 12),
              Text(
                'أدخل رقمك للمتابعة',
                textAlign: TextAlign.center,
                style: AppTextStyles.title20Medium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 33, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: _labelPadding,
                      child: FormLabel(
                        'رقم الواتساب',
                        isRequired: true,
                        note: '(بدون صفر)',
                        starAfterNote: true,
                        noteSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Focus(
                      onFocusChange: (focused) {
                        if (!focused) setState(() => _touched = true);
                      },
                      child: PhoneField(
                        controller: _phone,
                        inline: true,
                        restrictInput: true,
                        hasError: _showPhoneError,
                        showFocusBorder: true,
                        onCountryTap: () {}, // TODO: pick country code
                      ),
                    ),
                    if (_showPhoneError)
                      Padding(
                        padding: _labelPadding.add(
                          const EdgeInsetsDirectional.only(top: 4),
                        ),
                        child: Text(
                          'رقم الهاتف يجب أن يكون ${PhoneField.length} أرقام',
                          style: AppTextStyles.body12.copyWith(
                            color: context.colors.error,
                          ),
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
