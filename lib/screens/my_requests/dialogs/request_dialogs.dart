import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/options_sheet.dart';

/// فتح نافذة منبثقة مع خلفية معتمة ومموّهة (متل تصميم "طلباتي").
Future<T?> _showModal<T>(BuildContext context, WidgetBuilder builder) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, _, _) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: builder(context),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// دائرة ملونة 36 فيها أيقونة (ممنوع / نجمة) بجنب عنوان النافذة.
class _TitleBadge extends StatelessWidget {
  const _TitleBadge({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ───────────────────────── تحديث حالة الطلب ─────────────────────────

/// أزرار "تحديث الحالة". النتيجة: 'agree' | 'done' | 'edit' | 'cancel' أو null (رجوع).
Future<String?> showUpdateStatusDialog(BuildContext context) {
  return _showModal<String>(context, (context) {
    final colors = context.colors;

    Widget action(String label, String result, Color bg, Color fg) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _DialogButton(
        label: label,
        background: bg,
        foreground: fg,
        onTap: () => Navigator.of(context).pop(result),
      ),
    );

    return _DialogCard(
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
            'تم الاتفاق مع مهني',
            'agree',
            colors.primary,
            colors.textOnPrimary,
          ),
          action(
            'تم إنجاز المهمة',
            'done',
            colors.success,
            colors.textOnPrimary,
          ),
          action('تعديل الطلب', 'edit', colors.accent, colors.textOnAccent),
          action('إلغاء الطلب', 'cancel', colors.error, colors.textOnPrimary),
          _DialogButton(
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
}

// ───────────────────────── تم الاتفاق مع مهني ─────────────────────────

/// اختيار المهني اللي تم الاتفاق معه من العروض. بترجع فهرس المختار (أو null).
Future<int?> showAgreementDialog(BuildContext context, {int count = 4}) {
  return _showModal<int>(context, (context) => _AgreementDialog(count: count));
}

class _AgreementDialog extends StatefulWidget {
  const _AgreementDialog({required this.count});

  final int count;

  @override
  State<_AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<_AgreementDialog> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _DialogCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'تم الاتفاق مع مهني',
              style: AppTextStyles.title18Medium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'اختر المهني الذي تم الاتفاق معه من العروض المقدّمة',
              style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
            ),
          ),
          Divider(height: 1, color: colors.border),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              itemCount: widget.count,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _AgreementTile(
                selected: i == _selected,
                onTap: () => setState(() => _selected = i),
              ),
            ),
          ),
          Divider(height: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'تأكيد',
                    background: colors.primary,
                    foreground: colors.textOnPrimary,
                    onTap: () => Navigator.of(context).pop(_selected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'إلغاء',
                    background: colors.background,
                    foreground: colors.primaryContent,
                    border: colors.border,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.successLight : colors.border,
          ),
        ),
        child: Row(
          children: [
            const CraftsmanAvatar(
              image: 'assets/images/craftsman_1.jpg',
              isPro: true,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'مركز قزاز للتكيف والتبريد',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/ic_verified.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  Text(
                    '100 ليرة سورية',
                    style: AppTextStyles.body14.copyWith(color: colors.success),
                  ),
                ],
              ),
            ),
            // دائرة الراديو (حدود رمادية، والمختار نقطة زرقاء).
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.verified : colors.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.verified,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── إلغاء الطلب ─────────────────────────

const _cancelReasons = ['لم أتلق أي عروض أو رسائل', 'أتلقى الكثير من الرسائل'];

/// تأكيد إلغاء الطلب مع سبب إجباري. بترجع true إذا أكّد.
Future<bool?> showCancelRequestDialog(BuildContext context) {
  return _showModal<bool>(context, (context) => const _CancelDialog());
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  String? _reason;

  Future<void> _pickReason() async {
    final picked = await showOptionsSheet(
      context,
      title: 'سبب الإلغاء',
      options: _cancelReasons,
    );
    if (picked != null) setState(() => _reason = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget notice({
      required String title,
      required String body,
      required Color color,
      required IconData icon,
    }) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.body16.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTextStyles.body12.copyWith(
              fontSize: 13,
              color: color,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    return _DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TitleBadge(
                color: colors.error,
                child: SvgPicture.asset(
                  'assets/icons/ic_block.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تأكيد إلغاء طلب الخدمة',
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
            onTap: _pickReason,
          ),
          if (_reason == _cancelReasons[0]) ...[
            const SizedBox(height: 16),
            notice(
              title: 'نصيحة',
              body: 'ننصحك بالانتظار 3 أيام على الأقل لإتاحة الفرصة للمزيد من المهنيين لرؤية طلبك والتفاعل معه',
              color: colors.verified,
              icon: Icons.info_outline,
            ),
          ],
          if (_reason == _cancelReasons[1]) ...[
            const SizedBox(height: 16),
            Text('خيارات بديلة', style: AppTextStyles.body16),
            const SizedBox(height: 8),
            // TODO: إخفاء رقم الواتساب / تعليق الطلب (إجراءات وهمية)
            _DialogButton(
              label: 'إخفاء رقم الواتساب عن المهنيين',
              background: colors.primary,
              foreground: colors.textOnPrimary,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _DialogButton(
              label: 'تعليق الطلب مؤقتاً',
              background: colors.accent,
              foreground: colors.textOnAccent,
              onTap: () {},
            ),
          ],
          const SizedBox(height: 16),
          notice(
            title: 'تنبيه مهم',
            body: 'بعد إلغاء الطلب لن يتمكن أي مهني من تقديم عروض جديدة هذا الإجراء لا يمكن التراجع عنه',
            color: colors.error,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: _reason == null ? 0.5 : 1,
                  child: _DialogButton(
                    label: 'تأكيد الإلغاء',
                    background: colors.error,
                    foreground: colors.textOnPrimary,
                    onTap: _reason == null
                        ? null
                        : () => Navigator.of(context).pop(true),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  label: 'إلغاء',
                  background: colors.background,
                  foreground: colors.primaryContent,
                  border: colors.border,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── تقييم الخدمة ─────────────────────────

/// تقييم الخدمة (5 نجوم + تعليق اختياري). بترجع عدد النجوم (أو null إذا إلغاء).
Future<int?> showRatingDialog(BuildContext context) {
  return _showModal<int>(context, (context) => const _RatingDialog());
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog();

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _stars = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TitleBadge(
                color: colors.star,
                child: SvgPicture.asset(
                  'assets/icons/ic_star_rate.svg',
                  width: 17,
                  height: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text('تقييم الخدمة', style: AppTextStyles.title18Medium),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CraftsmanAvatar(
                image: 'assets/images/craftsman_1.jpg',
                isPro: true,
                size: 64,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'مركز قزاز للتكيف والتبريد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/icons/ic_verified.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                    Text(
                      'محترف موصى به',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // النجوم بتتعبّى من اليمين (الأولى يمين) متل التصميم.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _stars = i),
                  child: SvgPicture.asset(
                    'assets/icons/ic_star.svg',
                    width: 36,
                    height: 36,
                    colorFilter: ColorFilter.mode(
                      i <= _stars ? colors.star : colors.border,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body16Medium,
              children: [
                const TextSpan(text: 'تعليقاتك وملاحظاتك '),
                TextSpan(
                  text: '(اختياري)',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.fieldFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              style: AppTextStyles.body16,
              decoration: InputDecoration.collapsed(
                hintText: 'شاركنا تجربتك أو أي ملاحظات تود مشاركتها...',
                hintStyle: AppTextStyles.body16.copyWith(
                  color: colors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  label: 'إرسال التقييم',
                  background: colors.accent,
                  foreground: colors.textOnAccent,
                  onTap: () => Navigator.of(context).pop(_stars),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  label: 'إلغاء',
                  background: colors.background,
                  foreground: colors.primaryContent,
                  border: colors.border,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// مسار "تحديث حالة الطلب": النافذة الرئيسية ثم الاتفاق/الإلغاء حسب الاختيار.
/// TODO: "تعديل الطلب" (frames Editing) لسا ما انبنت؛ "تم إنجاز المهمة" بدها تحديث الحالة فعلياً.
Future<void> runUpdateStatusFlow(BuildContext context) async {
  final result = await showUpdateStatusDialog(context);
  if (!context.mounted) return;
  switch (result) {
    case 'agree':
      await showAgreementDialog(context);
    case 'cancel':
      await showCancelRequestDialog(context);
  }
}
