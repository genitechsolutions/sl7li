import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// زر فلتر بحدود وسهم لتحت (نوع الخدمة، المنطقة).
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: context.colors.primaryContent,
            ),
            Text(
              label,
              style: AppTextStyles.body14.copyWith(
                color: context.colors.primaryContent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
