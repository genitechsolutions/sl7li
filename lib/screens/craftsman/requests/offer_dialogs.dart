import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/app_toggle.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../new_request/widgets/success_illustration.dart';

/// بيانات العرض اللي المهني بيرسله.
class OfferDraft {
  String pricing = 'سعر ثابت';
  String price = '';
  String priceTo = '';
  bool freeVisit = true;
  String visitFee = '';
  bool materialsIncluded = false;
  String materialsFee = '';

  bool get valid => switch (pricing) {
    'نطاق سعري' => price.trim().isNotEmpty && priceTo.trim().isNotEmpty,
    _ => price.trim().isNotEmpty,
  };

  String get priceText => switch (pricing) {
    'نطاق سعري' => '$price - $priceTo',
    _ => price,
  };

  String get unit =>
      pricing == 'سعر بالساعة' ? 'ليرة جديدة / ساعة' : 'ليرة جديدة';
}

const _pricingTypes = ['سعر ثابت', 'نطاق سعري', 'سعر بالساعة'];

Widget _title(
  BuildContext context,
  String text, {
  required Widget badge,
  Color? color,
}) => Row(
  children: [
    badge,
    const SizedBox(width: 12),
    Expanded(
      child: Text(
        text,
        style: AppTextStyles.title18Medium.copyWith(color: color),
      ),
    ),
  ],
);

/// "عليك تقديم عرض أولا" — بيرجع true إذا ضغط "تقديم عرض".
Future<bool?> showOfferFirstDialog(BuildContext context) =>
    showAppModal<bool>(context, (context) {
      final colors = context.colors;
      return AppDialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(
              context,
              'عليك تقديم عرض أولا',
              badge: AppDialogBadge(
                color: colors.verified,
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'عليك تقدم عرض قبل ان تتمكن من إرسال رسائل للزبون أو التواصل معه عبر واتساب',
              style: AppTextStyles.body16.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppDialogButton(
                    label: 'تقديم عرض',
                    background: colors.success,
                    foreground: colors.textOnPrimary,
                    onTap: () => Navigator.of(context).pop(true),
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
    });

const _ignoreReasons = [
  'السعر لا يناسبني',
  'الموقع بعيد',
  'خارج اختصاصي',
  'غير متوفر حالياً',
];

/// "تأكيد تجاهل الطلب" — بيرجع true إذا أكّد.
Future<bool?> showIgnoreRequestDialog(BuildContext context) =>
    showAppModal<bool>(context, (context) => const _IgnoreDialog());

class _IgnoreDialog extends StatefulWidget {
  const _IgnoreDialog();

  @override
  State<_IgnoreDialog> createState() => _IgnoreDialogState();
}

class _IgnoreDialogState extends State<_IgnoreDialog> {
  String? _reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
            context,
            'تأكيد تجاهل الطلب',
            color: colors.error,
            badge: AppDialogBadge(
              color: colors.destructive,
              child: SvgPicture.asset(
                'assets/icons/ic_block.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('لماذا لست مهتماً؟', style: AppTextStyles.body16Medium),
          const SizedBox(height: 8),
          AppSelectField(
            hint: 'اختر سبب التجاهل',
            value: _reason,
            onTap: () async {
              final v = await showOptionsSheet(
                context,
                title: 'سبب التجاهل',
                options: _ignoreReasons,
              );
              if (v != null) setState(() => _reason = v);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: _reason == null ? 0.5 : 1,
                  child: AppDialogButton(
                    label: 'تجاهل الطلب',
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

/// ورقة "إرسال عرض سعر" ← "تأكيد إرسال العرض" ← "تم إرسال عرضك بنجاح". بترجع true لما ينرسل.
Future<bool?> showSendOfferFlow(
  BuildContext context, {
  required String requestTitle,
}) async {
  final draft = OfferDraft();
  while (true) {
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OfferSheet(draft: draft, requestTitle: requestTitle),
    );
    if (proceed != true || !context.mounted) return null;
    final confirmed = await showAppModal<bool>(
      context,
      (_) => _ConfirmOffer(draft: draft),
    );
    if (confirmed == null || !context.mounted) return null;
    if (confirmed) {
      await showAppModal<void>(context, (_) => const _OfferSent());
      return true;
    }
    // "تعديل": بنرجع للورقة بنفس البيانات.
  }
}

class _OfferSheet extends StatefulWidget {
  const _OfferSheet({required this.draft, required this.requestTitle});

  final OfferDraft draft;
  final String requestTitle;

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  OfferDraft get _d => widget.draft;

  // متحكّمات ثابتة (إعادة إنشاؤها بكل build بتخرّب المؤشر).
  final _ctl = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.body12.copyWith(color: colors.textSecondary);

    Widget label(String text, {bool required = false, String? note}) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 12),
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.body16Medium,
          children: [
            TextSpan(text: text),
            if (required)
              TextSpan(
                text: ' *',
                style: TextStyle(color: colors.error),
              ),
            if (note != null) TextSpan(text: ' $note', style: small),
          ],
        ),
      ),
    );

    Widget toggleRow(String text, bool value, ValueChanged<bool> onChanged) =>
        Row(
          children: [
            Expanded(child: Text(text, style: AppTextStyles.body16Medium)),
            AppToggle(value: value, onChanged: onChanged),
          ],
        );

    Widget moneyField(String hint, String initial, ValueChanged<String> on) =>
        AppTextField(
          hint: hint,
          keyboardType: TextInputType.number,
          controller: _ctl.putIfAbsent(
            hint,
            () => TextEditingController(text: initial),
          ),
          onChanged: (v) => setState(() => on(v)),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرسال عرض سعر',
                          style: AppTextStyles.title18Medium,
                        ),
                        Text(
                          widget.requestTitle,
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Icon(Icons.close, color: colors.primaryContent),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              label('الكلفة التقديرية للعمل', required: true),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 8),
                child: Text('نوع التسعير', style: small.copyWith(fontSize: 14)),
              ),
              AppSelectField(
                hint: 'نوع التسعير',
                value: _d.pricing,
                onTap: () async {
                  final v = await showOptionsSheet(
                    context,
                    title: 'نوع التسعير',
                    options: _pricingTypes,
                  );
                  if (v != null) setState(() => _d.pricing = v);
                },
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 8,
                children: [
                  if (_d.pricing == 'نطاق سعري') ...[
                    Expanded(
                      child: moneyField('من', _d.price, (v) => _d.price = v),
                    ),
                    Expanded(
                      child: moneyField(
                        'إلى',
                        _d.priceTo,
                        (v) => _d.priceTo = v,
                      ),
                    ),
                  ] else
                    Expanded(
                      flex: 2,
                      child: moneyField(
                        _d.pricing == 'سعر بالساعة'
                            ? 'السعر / ساعة'
                            : 'السعر التقديري',
                        _d.price,
                        (v) => _d.price = v,
                      ),
                    ),
                  Expanded(
                    child: IgnorePointer(
                      // TODO: عملات تانية (ما في تصميم)؛ ليرة سورية بس.
                      child: AppSelectField(
                        hint: 'العملة',
                        value: 'ليرة سورية',
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              toggleRow(
                _d.freeVisit
                    ? 'الكشف والمواصلات مجانية'
                    : 'أجور الكشف والمواصلات',
                _d.freeVisit,
                (v) => setState(() => _d.freeVisit = v),
              ),
              if (!_d.freeVisit) ...[
                const SizedBox(height: 12),
                moneyField(
                  'المبلغ التقريبي',
                  _d.visitFee,
                  (v) => _d.visitFee = v,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'قدم كشف مجاني لتحصل على فرصة أعلى لرد من الزبون',
                        style: small.copyWith(color: colors.warning),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              toggleRow(
                _d.materialsIncluded
                    ? 'كلفة العرض تشمل المواد'
                    : 'كلفة العرض لا تشمل المواد',
                _d.materialsIncluded,
                (v) => setState(() => _d.materialsIncluded = v),
              ),
              if (!_d.materialsIncluded) ...[
                const SizedBox(height: 12),
                label('تكلفة المواد', note: '(اختياري)'),
                moneyField(
                  'المبلغ التقريبي',
                  _d.materialsFee,
                  (v) => _d.materialsFee = v,
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _d.valid ? () => Navigator.of(context).pop(true) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _d.valid ? colors.primary : colors.disabled,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'إرسال العرض',
                    style: AppTextStyles.title18Medium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmOffer extends StatelessWidget {
  const _ConfirmOffer({required this.draft});

  final OfferDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.textSecondary,
    );
    final green = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.success,
    );

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
            context,
            'تأكيد إرسال العرض',
            badge: AppDialogBadge(
              color: colors.success,
              child: Icon(
                Icons.send_outlined,
                size: 18,
                color: colors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'هل أنت متأكد من إرسال هذا العرض؟',
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('الكلفة الأولية التقديرية', style: AppTextStyles.body16),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${draft.priceText} ',
                      style: AppTextStyles.title20.copyWith(
                        color: colors.success,
                      ),
                    ),
                    TextSpan(
                      text: draft.unit,
                      style: AppTextStyles.body16.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('أجور الكشف والمواصلات', style: small),
              const Spacer(),
              Text(
                draft.freeVisit ? 'مجاني' : '${draft.visitFee} ليرة جديدة',
                style: green,
              ),
            ],
          ),
          Row(
            children: [
              Text('أجور المواد والأدوات', style: small),
              const Spacer(),
              Text(
                draft.materialsIncluded
                    ? 'مشمولة'
                    : (draft.materialsFee.isEmpty
                          ? '—'
                          : '${draft.materialsFee} ليرة جديدة'),
                style: green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppDialogButton(
                  label: 'إرسال العرض',
                  background: colors.success,
                  foreground: colors.textOnPrimary,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDialogButton(
                  label: 'تعديل',
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

class _OfferSent extends StatelessWidget {
  const _OfferSent();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget line(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
      ),
    );

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SuccessIllustration(),
          const SizedBox(height: 12),
          Text('تم إرسال عرضك بنجاح', style: AppTextStyles.title22Bold),
          const SizedBox(height: 4),
          Text(
            'ما هي الخطوة التالية؟',
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          line('تم إشعار الزبون بوجود عرض سعر جديد'),
          line('سيراجع الزبون العروض ويختار الأنسب'),
          line('ستصلك إشعارات عند قبول عرضك'),
          const SizedBox(height: 12),
          AppDialogButton(
            label: 'رؤية مهامي الحالية',
            background: colors.primary,
            foreground: colors.textOnPrimary,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
          AppDialogButton(
            label: 'العودة للصفحة الرئيسية',
            background: colors.background,
            foreground: colors.primaryContent,
            border: colors.border,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
