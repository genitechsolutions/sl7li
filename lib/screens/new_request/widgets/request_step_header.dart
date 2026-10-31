import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/header_action_button.dart';

/// رأس خطوات "طلب خدمة": العنوان، رقم الخطوة، زر (إلغاء افتراضياً)، وشريط التقدم.
/// [step] أكبر من [totalSteps] يعني كل الخطوات خلصت (كلها خضرا).
class RequestStepHeader extends StatelessWidget {
  const RequestStepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.onCancel,
    this.subtitle,
    this.actionLabel = 'إلغاء',
  });

  final int step;
  final int totalSteps;
  final VoidCallback onCancel;
  final String? subtitle;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('طلب خدمة', style: AppTextStyles.title22Bold),
                  Text(
                    subtitle ?? 'الخطوة $step من $totalSteps',
                    style: AppTextStyles.body14.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            HeaderActionButton(label: actionLabel, onPressed: onCancel),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 9,
          children: [
            for (var i = 1; i <= totalSteps; i++)
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    // الخطوات المنتهية خضرا، الحالية كحلية، والجاية رمادية.
                    color: i < step
                        ? context.colors.successLight
                        : i == step
                        ? context.colors.stepActive
                        : context.colors.stepInactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
