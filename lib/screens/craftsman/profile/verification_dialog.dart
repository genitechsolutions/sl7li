import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/dashed_border_box.dart';
import '../../../data/craftsman_verification.dart';

/// "توثيق الهوية مطلوب": رفع صورة الهوية (3 حالات: فاضي، جاري الرفع، تم الرفع).
Future<bool?> showVerificationDialog(BuildContext context) =>
    showAppModal<bool>(context, (_) => const _VerificationDialog());

enum _Phase { empty, uploading, uploaded }

class _VerificationDialog extends StatefulWidget {
  const _VerificationDialog();

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  _Phase _phase = _Phase.empty;

  // TODO: اختيار صورة حقيقي (image_picker بموافقة)؛ رفع وهمي.
  Future<void> _pick() async {
    setState(() => _phase = _Phase.uploading);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _phase = _Phase.uploaded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 144,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/request_photo_1.png', fit: BoxFit.cover),
            if (_phase == _Phase.uploading)
              ColoredBox(
                color: const Color(0x99000000),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'جاري الرفع...',
                        style: AppTextStyles.body16.copyWith(
                          color: colors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppDialogBadge(
                color: colors.verified,
                child: Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: colors.textOnPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text('توثيق الهوية مطلوب', style: AppTextStyles.title18Medium),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body16.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: 'لإتمام التوثيق والتفاعل مع الطلبات, يرجى رفع صورة واضحة للوجه الأمامي لبطاقة الهوية الحكومية ',
                ),
                TextSpan(
                  text: 'ستتم مراجعتها خلال 24 ساعة',
                  style: TextStyle(color: colors.link),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_phase == _Phase.empty)
            GestureDetector(
              onTap: _pick,
              child: DashedBorderBox(
                height: 146,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        size: 40,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'إضغط لإضافة صور',
                        style: AppTextStyles.body14Medium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ارفع صورة الوجه الأمامي للهوية',
                        style: AppTextStyles.body12.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            photo,
          const SizedBox(height: 16),
          if (_phase == _Phase.uploaded) ...[
            AppDialogButton(
              label: 'رفع الصورة',
              background: colors.primary,
              foreground: colors.textOnPrimary,
              onTap: () {
                verificationNotifier.value = VerificationStatus.pending;
                Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 8),
            AppDialogButton(
              label: 'تغيير الصورة',
              background: colors.background,
              foreground: colors.primaryContent,
              border: colors.border,
              onTap: _pick,
            ),
          ] else
            AppDialogButton(
              label: 'العودة للملف المهني',
              background: colors.background,
              foreground: colors.primaryContent,
              border: colors.border,
              onTap: () => Navigator.of(context).pop(false),
            ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body12.copyWith(color: colors.textSecondary),
              children: [
                const TextSpan(text: 'في حال واجهتي أي مشكلة يمكنك '),
                TextSpan(
                  text: 'التواصل مع خدمة العملاء',
                  style: TextStyle(
                    color: colors.link,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
