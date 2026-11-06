import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_dialog.dart';

/// نافذة معلومات بسيطة بزر "حسناً".
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required List<String> lines,
}) {
  return showAppModal<void>(context, (context) {
    final colors = context.colors;
    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title18Medium),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: AppTextStyles.body16.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          const SizedBox(height: 8),
          AppDialogButton(
            label: 'حسناً',
            background: colors.primary,
            foreground: colors.textOnPrimary,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  });
}
