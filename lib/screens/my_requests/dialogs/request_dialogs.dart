import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../data/my_request.dart';
import '../../new_request/new_request_screen.dart';

// ───────────────────────── تحديث حالة الطلب ─────────────────────────

/// أزرار "تحديث الحالة". النتيجة: 'agree' | 'done' | 'edit' | 'cancel' أو null (رجوع).
Future<String?> showUpdateStatusDialog(BuildContext context) {
  return showAppModal<String>(context, (context) {
    final colors = context.colors;

    Widget action(String label, String result, Color bg, Color fg) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppDialogButton(
        label: label,
        background: bg,
        foreground: fg,
        onTap: () => Navigator.of(context).pop(result),
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
          action(
            'تعديل الطلب',
            'edit',
            colors.accentButton,
            colors.textOnAccent,
          ),
          action(
            'إلغاء الطلب',
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
}

// ───────────────────────── تم الاتفاق مع مهني ─────────────────────────

/// اختيار المهني اللي تم الاتفاق معه من العروض. بترجع فهرس المختار (أو null).
Future<int?> showAgreementDialog(
  BuildContext context, {
  int count = 4,
  List<RequestOffer>? offers,
}) {
  return showAppModal<int>(
    context,
    (context) => _AgreementDialog(count: offers?.length ?? count, offers: offers),
  );
}

class _AgreementDialog extends StatefulWidget {
  const _AgreementDialog({required this.count, this.offers});

  final int count;
  final List<RequestOffer>? offers;

  @override
  State<_AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<_AgreementDialog> {
  late int _selected = widget.offers == null ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppDialogCard(
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
                name: widget.offers?[i].craftsmanName,
                price: widget.offers == null
                    ? null
                    : '${widget.offers![i].price} ${widget.offers![i].priceUnit}',
              ),
            ),
          ),
          Divider(height: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: AppDialogButton(
                    label: 'تأكيد',
                    background: colors.primary,
                    foreground: colors.textOnPrimary,
                    onTap: () => Navigator.of(context).pop(_selected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDialogButton(
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
  const _AgreementTile({
    required this.selected,
    required this.onTap,
    this.name,
    this.price,
  });

  final bool selected;
  final VoidCallback onTap;
  final String? name;
  final String? price;

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
                          name ?? 'مركز قزاز للتكيف والتبريد',
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
                    price ?? '100 ليرة سورية',
                    style: AppTextStyles.body14.copyWith(color: colors.success),
                  ),
                ],
              ),
            ),
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

/// تأكيد إلغاء الطلب مع سبب إجباري. بترجع السبب إذا أكّد.
Future<String?> showCancelRequestDialog(BuildContext context) {
  return showAppModal<String>(context, (context) => const _CancelDialog());
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

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppDialogBadge(
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
            AppDialogButton(
              label: 'إخفاء رقم الواتساب عن المهنيين',
              background: colors.primary,
              foreground: colors.textOnPrimary,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            AppDialogButton(
              label: 'تعليق الطلب مؤقتاً',
              background: colors.accentButton,
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
                  child: AppDialogButton(
                    label: 'تأكيد الإلغاء',
                    background: colors.destructive,
                    foreground: colors.textOnPrimary,
                    onTap: _reason == null
                        ? null
                        : () => Navigator.of(context).pop(_reason),
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
  return showAppModal<int>(context, (context) => const _RatingDialog());
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

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppDialogBadge(
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
                child: AppDialogButton(
                  label: 'إرسال التقييم',
                  background: colors.accentButton,
                  foreground: colors.textOnAccent,
                  onTap: () => Navigator.of(context).pop(_stars),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDialogButton(
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

void _toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// بينفّذ عملية بالخلفية وبيعرض نتيجتها؛ بيرجّع true إذا نجحت.
Future<bool> _backend(BuildContext context, Future<void> Function() run, String ok) async {
  try {
    await run();
  } on BackendException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return false;
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر تنفيذ العملية، حاول مرة ثانية');
    return false;
  }
  if (context.mounted) _toast(context, ok);
  return true;
}

/// "تم الاتفاق مع مهني": بيعرض العروض الحقيقية وبيقبل المختار.
Future<bool> agreeWithOffer(BuildContext context, String jobId) async {
  final cubit = context.read<MyRequestsCubit>();
  List<RequestOffer> offers;
  try {
    offers = await cubit.offers(jobId);
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر تحميل العروض');
    return false;
  }
  if (!context.mounted) return false;
  if (offers.isEmpty) {
    _toast(context, 'ما وصلتك عروض لسا');
    return false;
  }
  final index = await showAgreementDialog(context, offers: offers);
  final proposalId = index == null ? null : offers[index].proposalId;
  if (proposalId == null || !context.mounted) return false;
  return _backend(
    context,
    () => cubit.respondToOffer(proposalId, approve: true),
    'تم الاتفاق مع المهني',
  );
}

/// نافذة "تحديث الحالة" ومتابعتها. بترجع true إذا تغيّر شي بالخلفية.
Future<bool> runUpdateStatusFlow(BuildContext context, MyRequest request) async {
  final result = await showUpdateStatusDialog(context);
  if (!context.mounted) return false;
  final id = request.id;
  switch (result) {
    case 'agree':
      if (id == null) {
        await showAgreementDialog(context);
        return false;
      }
      return agreeWithOffer(context, id);
    case 'edit':
      // TODO: تعبئة الطلب الحالي مسبقاً (ما في frames مخصصة)؛ هلق بيفتح خطوات الطلب.
      await Navigator.push(context, NewRequestScreen.route());
    case 'cancel':
      final reason = await showCancelRequestDialog(context);
      if (reason == null || id == null || !context.mounted) return false;
      return _backend(
        context,
        () => context.read<MyRequestsCubit>().cancel(id, reason: reason),
        'تم إلغاء الطلب',
      );
  }
  return false;
}
