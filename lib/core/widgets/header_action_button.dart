import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// زر صغير بحدود بزاوية الهيدر ("إلغاء"، "العودة للصفحة الرئيسية").
class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(78, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.primaryContent,
        side: BorderSide(color: context.colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.title16,
      ),
      child: Text(label),
    );
  }
}
