import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// شريط سفلي ثابت فيه زر رئيسي بعرض الشاشة (اطلب عرض سعر...)،
/// واختيارياً زر ثانوي بحدود تحته (رجوع للخطوة السابقة).
/// [note] نص صغير فوق الأزرار (موافقة على الشروط...).
/// [onPressed] = null يعني الزر معطّل.
class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.note,
    this.sideBySide = false,
  });

  /// الزر الثانوي جنب الرئيسي بنفس الصف (تعديل الملف/الخدمات) بدل ما يكون تحته.
  final bool sideBySide;

  final String label;
  final VoidCallback? onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final Widget? note;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final primaryButton = SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.textOnPrimary,
          disabledBackgroundColor: context.colors.disabled,
          disabledForegroundColor: context.colors.textOnPrimary,
          shape: shape,
          textStyle: AppTextStyles.title16,
        ),
        child: Text(label),
      ),
    );
    final secondaryButton = secondaryLabel == null
        ? null
        : SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: onSecondaryPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: context.colors.background,
                foregroundColor: context.colors.primaryContent,
                side: BorderSide(color: context.colors.border),
                shape: shape,
                textStyle: AppTextStyles.title16,
              ),
              child: Text(secondaryLabel!),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.divider)),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 9,
            children: [
              if (note != null)
                Padding(padding: const EdgeInsets.only(bottom: 4), child: note),
              if (sideBySide && secondaryLabel != null)
                Row(
                  spacing: 12,
                  children: [
                    Expanded(child: primaryButton),
                    Expanded(child: secondaryButton!),
                  ],
                )
              else ...[
                primaryButton,
                ?secondaryButton,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
