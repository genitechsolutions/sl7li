import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'customer_login_screen.dart';
import 'widgets/account_type_card.dart';
import 'widgets/auth_header.dart';

/// "تسجيل الدخول" — اختيار نوع الحساب (زبون / مهني). أول صفحة بالتطبيق.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        // هالصفحة معكوسة: الخلفية surface والكروت background.
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const AuthHeader(title: 'تسجيل الدخول', subtitle: 'اختر نوع الحساب للمتابعة'),
              const SizedBox(height: 35),
              AccountTypeCard(
                icon: SvgPicture.asset('assets/icons/ic_user.svg', width: 36, height: 36),
                iconBackground: context.colors.primary,
                title: 'دخول الزبائن',
                description: 'جد أفضل الحرفيين المناسبين لحل مشكلتك',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
                ),
              ),
              const SizedBox(height: 12),
              AccountTypeCard(
                icon: SvgPicture.asset('assets/icons/ic_tools.svg', width: 36, height: 36),
                iconBackground: context.colors.accent,
                title: 'دخول المهنيين',
                description: 'أعرض خدماتك وقدم عروضك واحصل على فرص',
                onTap: () {}, // TODO: navigate to craftsman login (المستخدم: خليه ما بيعمل شي هلق)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
