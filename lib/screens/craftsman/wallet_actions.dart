import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dialog.dart';

/// نافذة "شحن الرصيد": ما في نقطة نهاية دفع بالخلفية، فبنشرح طريقة الشحن.
Future<void> showTopUpDialog(BuildContext context) => _info(
  context,
  title: 'شحن الرصيد',
  body: 'شحن الرصيد الإلكتروني غير متاح حالياً وسيتوفر قريباً. '
      'لشحن رصيدك الآن تواصل مع خدمة العملاء وسنضيف النقاط لحسابك.',
);

/// نافذة "سحب رصيد": السحب غير متاح بالخلفية.
Future<void> showWithdrawDialog(BuildContext context) => _info(
  context,
  title: 'سحب رصيد',
  body: 'السحب غير متاح حالياً.',
);

Future<void> _info(BuildContext context, {required String title, required String body}) {
  return showAppModal<void>(context, (context) {
    final colors = context.colors;
    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title18Medium),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body16.copyWith(color: colors.textSecondary)),
          const SizedBox(height: 20),
          AppDialogButton(
            label: 'حسناً',
            background: colors.primary,
            foreground: colors.textOnPrimary,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  });
}
