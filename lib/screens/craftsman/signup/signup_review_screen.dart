import '../../../core/widgets/coming_soon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../cubits/craftsman_signup_cubit.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../data/craftsman_signup.dart';
import '../craftsman_home_screen.dart';
import '../widgets/signup_scaffold.dart';

/// "مراجعة معلومات الحساب": ملخص كل الخطوات قبل "تأكيد إنشاء الحساب".
class SignupReviewScreen extends StatelessWidget {
  const SignupReviewScreen({super.key, required this.draft});

  final CraftsmanSignupDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final link = AppTextStyles.body12.copyWith(
      color: colors.link,
      decoration: TextDecoration.underline,
      decorationColor: colors.link,
    );

    Widget infoBox(String label, String value) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );

    final specialties = {
      for (final s in draft.services) ...?draft.specialties[s],
    };

    final submitting =
        context.watch<CraftsmanSignupCubit>().state.status ==
        SignupStatus.submitting;

    return BlocListener<CraftsmanSignupCubit, CraftsmanSignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error ?? 'تعذّر إنشاء الحساب')),
            );
        } else if (state.status == SignupStatus.success) {
          context.read<ProfileCubit>().load(force: true);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
            (_) => false,
          );
        }
      },
      child: _scaffold(context, colors, link, infoBox, specialties, submitting),
    );
  }

  Widget _scaffold(
    BuildContext context,
    AppColors colors,
    TextStyle link,
    Widget Function(String, String) infoBox,
    Set<String> specialties,
    bool submitting,
  ) {
    return SignupScaffold(
      step: 5,
      title: 'مراجعة معلومات الحساب',
      stepSubtitle: 'مراجعة المعلومات',
      nextLabel: submitting ? 'جارٍ إنشاء الحساب...' : 'تأكيد إنشاء الحساب',
      onNext: submitting
          ? null
          : () => context.read<CraftsmanSignupCubit>().submit(draft),
      bottomNote: Text.rich(
        TextSpan(
          style: AppTextStyles.body12.copyWith(color: colors.textSecondary),
          children: [
            const TextSpan(text: 'بالمتابعة أنت توافق على '),
            TextSpan(
              text: 'الشروط والأحكام',
              style: link,
              recognizer: TapGestureRecognizer()..onTap = showComingSoon,
            ),
            const TextSpan(text: ' و '),
            TextSpan(
              text: 'سياسة الخصوصية',
              style: link,
              recognizer: TapGestureRecognizer()..onTap = showComingSoon,
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 24),
        Text(
          draft.businessName.isEmpty
              ? 'مركز النور للكهرباء'
              : draft.businessName,
          style: AppTextStyles.title22Bold,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'مسارك: ',
              style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
            ),
            Text(
              'مبتدئ',
              style: AppTextStyles.body14.copyWith(color: colors.verified),
            ),
            Container(
              width: 1,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: colors.border,
            ),
            Text(
              'التقييم: لا يوجد',
              style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          draft.bio.isEmpty ? 'نبذة مختصرة' : draft.bio,
          style: AppTextStyles.body16.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${draft.city ?? 'دمشق'}${draft.districts.isEmpty ? '' : ', ${draft.districts.first}'}',
              style: AppTextStyles.body16,
            ),
            const SizedBox(width: 8),
            SvgPicture.asset('assets/icons/cr_pin.svg', width: 16, height: 16),
          ],
        ),
        const SizedBox(height: 16),
        infoBox('الخبرة', '${draft.years.isEmpty ? '0' : draft.years} سنوات'),
        infoBox('الأدوات', draft.hasTools ? 'نعم, أملك جميع الأدوات' : 'لا'),
        infoBox('التنقل', draft.transport ?? 'لا يوجد'),
        const SizedBox(height: 20),
        Text('التخصصات المتاحة', style: AppTextStyles.body16Medium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final s in specialties) AppChip(label: s)],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
