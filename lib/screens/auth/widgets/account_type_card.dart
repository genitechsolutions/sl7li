import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// كرت نوع الحساب: مربع أيقونة ملوّن، وعنوان وشرح جنبه.
class AccountTypeCard extends StatelessWidget {
  const AccountTypeCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Widget icon;
  final Color iconBackground;
  final String title;
  final String description;
  final VoidCallback onTap;

  // أسطر النص بالتصميم كل 27px.
  static const _lineHeight = 27 / 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          spacing: 20,
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body16Medium.copyWith(height: _lineHeight)),
                  Text(
                    description,
                    style: AppTextStyles.body16.copyWith(
                      color: context.colors.textSecondary,
                      height: _lineHeight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
