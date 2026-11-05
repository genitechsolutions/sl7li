import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/backend/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/repositories/profile_repository.dart';
import '../craftsman/craftsman_home_screen.dart';
import '../craftsman/signup/signup_step1_screen.dart';
import '../home/home_screen.dart';
import 'customer_login_screen.dart';
import 'widgets/account_type_card.dart';
import 'widgets/auth_header.dart';

/// "تسجيل الدخول" — اختيار نوع الحساب (زبون / مهني). أول صفحة بالتطبيق.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// حساب حقيقي موجود: بنتجاوز نماذج التسجيل ونفتح الواجهة مباشرة.
  Future<UserProfile?> _existingProfile(BuildContext context) async {
    if (AppConfig.mode != BackendMode.amplify) return null;
    final cubit = context.read<ProfileCubit>();
    await cubit.load(force: true);
    return cubit.state.data;
  }

  Future<void> _customer(BuildContext context) async {
    final profile = await _existingProfile(context);
    if (!context.mounted) return;
    if (profile != null && profile.name.isNotEmpty) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
    );
  }

  Future<void> _craftsman(BuildContext context) async {
    final profile = await _existingProfile(context);
    if (!context.mounted) return;
    if (profile != null && profile.isProfessional) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
        (_) => false,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupStep1Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const AuthHeader(
                title: 'تسجيل الدخول',
                subtitle: 'اختر نوع الحساب للمتابعة',
              ),
              const SizedBox(height: 35),
              AccountTypeCard(
                icon: SvgPicture.asset(
                  'assets/icons/ic_user.svg',
                  width: 36,
                  height: 36,
                ),
                iconBackground: context.colors.primary,
                title: 'دخول الزبائن',
                description: 'جد أفضل الحرفيين المناسبين لحل مشكلتك',
                onTap: () => _customer(context),
              ),
              const SizedBox(height: 12),
              AccountTypeCard(
                icon: SvgPicture.asset(
                  'assets/icons/ic_tools.svg',
                  width: 36,
                  height: 36,
                ),
                iconBackground: context.colors.accent,
                title: 'دخول المهنيين',
                description: 'أعرض خدماتك وقدم عروضك واحصل على فرص',
                onTap: () => _craftsman(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
