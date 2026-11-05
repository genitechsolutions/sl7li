import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/options_sheet.dart';
import 'withdraw_offer.dart';

/// "تحديث حالة الطلب" عند المهني: بترجع 'agreed' | 'working' | 'done' | 'cancel' أو null.
Future<String?> showTaskStatusDialog(
  BuildContext context, {
  String? jobId,
  String? proposalId,
}) async {
  final result = await showAppModal<String>(context, (context) {
    final colors = context.colors;
    Widget action(String label, String value, Color bg, Color fg) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppDialogButton(
        label: label,
        background: bg,
        foreground: fg,
        onTap: () => Navigator.of(context).pop(value),
      ),
    );

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحديث حالة الطلب',
            style: AppTextStyles.title18Medium.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          action(
            'تم الاتفاق مع الزبون',
            'agreed',
            colors.primary,
            colors.textOnPrimary,
          ),
          action(
            'المهمة قيد التنفيذ',
            'working',
            colors.accentButton,
            colors.textOnAccent,
          ),
          action(
            'تم إنجاز المهمة',
            'done',
            colors.success,
            colors.textOnPrimary,
          ),
          action(
            'إلغاء العرض',
            'cancel',
            colors.destructive,
            colors.textOnPrimary,
          ),
          AppDialogButton(
            label: 'رجوع',
            background: colors.background,
            foreground: colors.primaryContent,
            border: colors.border,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  });
  if (result == 'cancel' && context.mounted) {
    if (jobId == null) {
      await showCancelOfferDialog(context);
    } else if (!await withdrawMyOffer(
      context,
      jobId: jobId,
      proposalId: proposalId,
    )) {
      return null;
    }
  }
  return result;
}

const _cancelReasons = [
  'لم نتفق على السعر',
  'الزبون لا يرد',
  'ظرف طارئ عندي',
  'سبب آخر',
];

/// "تأكيد إلغاء العرض" — بترجع true إذا أكّد.
Future<bool?> showCancelOfferDialog(BuildContext context) =>
    showAppModal<bool>(context, (_) => const _CancelOffer());

class _CancelOffer extends StatefulWidget {
  const _CancelOffer();

  @override
  State<_CancelOffer> createState() => _CancelOfferState();
}

class _CancelOfferState extends State<_CancelOffer> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppDialogBadge(
                color: colors.destructive,
                child: SvgPicture.asset(
                  'assets/icons/ic_block.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تأكيد إلغاء العرض',
                style: AppTextStyles.title18Medium.copyWith(
                  color: colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body16Medium,
              children: [
                const TextSpan(text: 'سبب الإلغاء '),
                TextSpan(
                  text: '*',
                  style: TextStyle(color: colors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppSelectField(
            hint: 'اختر سبب الإلغاء',
            value: _reason,
            onTap: () async {
              final v = await showOptionsSheet(
                context,
                title: 'سبب الإلغاء',
                options: _cancelReasons,
              );
              if (v != null) setState(() => _reason = v);
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تنبيه مهم',
                      style: AppTextStyles.body16.copyWith(color: colors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'هنا يكتب نص التنبيه في حال أردنا تنبيه المهني لمخاطر إلغاء العرض الخاص به',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.error,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: _reason == null ? 0.5 : 1,
                  child: AppDialogButton(
                    label: 'تأكيد الإلغاء',
                    background: colors.destructive,
                    foreground: colors.textOnPrimary,
                    onTap: _reason == null
                        ? null
                        : () => Navigator.of(context).pop(true),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDialogButton(
                  label: 'إلغاء',
                  background: colors.background,
                  foreground: colors.primaryContent,
                  border: colors.border,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
