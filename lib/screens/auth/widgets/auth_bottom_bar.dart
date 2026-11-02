import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// أسفل صفحات الدخول: زر رئيسي بعرض الشاشة، واختيارياً زر أصفر تحته ([secondaryLabel])،
class AuthBottomBar extends StatelessWidget {
  const AuthBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    required this.note,
    this.isLoading = false,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget note;
  final bool isLoading;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 37),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.textOnPrimary,
                  disabledBackgroundColor: context.colors.disabled,
                  disabledForegroundColor: context.colors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.title16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    if (isLoading)
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.textOnPrimary,
                        ),
                      ),
                    Text(label),
                  ],
                ),
              ),
            ),
            if (secondaryLabel != null && !keyboardOpen)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: onSecondaryPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.accent,
                    foregroundColor: context.colors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.title16,
                  ),
                  child: Text(secondaryLabel!),
                ),
              ),
            if (!keyboardOpen)
              Padding(
                padding: EdgeInsets.only(top: secondaryLabel != null ? 9 : 0),
                child: note,
              ),
          ],
        ),
      ),
    );
  }
}

/// سطر صغير رمادي فيه روابط زرقا مسطّرة (الشروط، خدمة العملاء...).
class AuthNote extends StatelessWidget {
  const AuthNote({super.key, required this.spans});

  final List<InlineSpan> spans;

  static TextStyle linkStyle(BuildContext context) =>
      AppTextStyles.body14.copyWith(
        color: context.colors.link,
        decoration: TextDecoration.underline,
        decorationColor: context.colors.link,
      );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
      style: AppTextStyles.body14.copyWith(color: context.colors.textSecondary),
    );
  }
}
