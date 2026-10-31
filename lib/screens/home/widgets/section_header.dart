import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAllTap});

  final String title;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.title16),
        const Spacer(),
        if (onSeeAllTap != null)
          GestureDetector(
            onTap: onSeeAllTap,
            child: Text(
              'عرض الكل',
              style: AppTextStyles.body14.copyWith(
                color: context.colors.link,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.link,
              ),
            ),
          ),
      ],
    );
  }
}
