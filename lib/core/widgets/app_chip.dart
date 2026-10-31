import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// تاغ بحدود (التخصصات، تصنيفات العرض...).
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(color: context.colors.chipText),
        ),
      ),
    );
  }
}
