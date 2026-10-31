import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CraftsmanProgressCard extends StatelessWidget {
  const CraftsmanProgressCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/cr_ring_a.svg', width: 68),
                    SvgPicture.asset('assets/icons/cr_ring_b.svg', width: 58),
                    SvgPicture.asset(
                      'assets/icons/cr_medal.svg',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مسار التطور',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      'المسار الحالي: 1 - بداية الرحلة',
                      style: AppTextStyles.body16Medium,
                    ),
                    Text(
                      'المسار التالي: 2 - حرفي موثق',
                      style: AppTextStyles.body16.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.noticeInfo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخطوات الموصى بها لرفع المستوى',
                  style: AppTextStyles.body16.copyWith(color: colors.verified),
                ),
                const SizedBox(height: 8),
                for (final t in const [
                  'أضف صورة لبروفايلك (من الملف الشخصي)',
                  'أضف صور في معرض أعمالك (من الملف الشخصي)',
                  'ارفع صورة هويتك لتوثيق حسابك (من الملف الشخصي)',
                ])
                  Text(
                    '•  $t',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.verified,
                      height: 1.85,
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

class WalletBtn extends StatelessWidget {
  const WalletBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final String icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: filled ? colors.primaryContent : colors.background,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.title18Medium.copyWith(
              fontWeight: FontWeight.w600,
              color: filled ? colors.primary : colors.primaryContent,
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              filled ? colors.primary : colors.primaryContent,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class CraftsmanTxRow extends StatelessWidget {
  const CraftsmanTxRow({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 32, height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body16),
                Text(
                  'منذ 3 أيام',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            textDirection: TextDirection.ltr,
            TextSpan(
              style: AppTextStyles.title24Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              children: [
                TextSpan(text: '$value '),
                TextSpan(
                  text: 'ل.س',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: color,
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
