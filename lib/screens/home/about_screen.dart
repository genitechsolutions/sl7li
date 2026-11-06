import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../new_request/new_request_screen.dart';

/// "معرفة المزيد عن صلحلي": شو التطبيق وكيف بيشتغل بـ 3 خطوات.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _steps = [
    ('اوصف مشكلتك', 'اكتب شو بدك وحدد نوع الخدمة والموقع، وأضف صور إذا بدك.'),
    ('استلم العروض', 'بيوصلك عروض أسعار من مهنيين مناسبين، وتقدر تحكي معهم مباشرة.'),
    ('اختار وخلّص', 'قارن العروض والتقييمات، اختار المهني المناسب وقيّم الخدمة بعد الإنجاز.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'إيجاد حل لمشكلتك',
          onPressed: () => Navigator.push(context, NewRequestScreen.route()),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppIconButton(
                  icon: 'assets/icons/ic_arrow_back.svg',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 24),
              const Text('عن صلّحلي', style: AppTextStyles.title24Bold),
              const SizedBox(height: 12),
              Text(
                'صلّحلي تطبيق بيوصلك بأفضل الحرفيين والمهنيين لحل أي مشكلة بالبيت: '
                'كهرباء، سباكة، دهان، تكييف وغيرها. بتطلب عرض سعر وبتختار الأنسب إلك.',
                style: AppTextStyles.body16.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              const Text('كيف بيشتغل؟', style: AppTextStyles.title20Medium),
              const SizedBox(height: 16),
              for (var i = 0; i < _steps.length; i++) ...[
                _StepCard(number: i + 1, title: _steps[i].$1, body: _steps[i].$2),
                if (i < _steps.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.title, required this.body});

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
            child: Text(
              '$number',
              style: AppTextStyles.title16.copyWith(color: context.colors.textOnPrimary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(title, style: AppTextStyles.title16),
                Text(
                  body,
                  style: AppTextStyles.body14.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
