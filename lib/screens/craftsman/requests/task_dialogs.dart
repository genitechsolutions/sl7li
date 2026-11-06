import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../cubits/job_lifecycle_cubit.dart';
import '../../../data/my_request.dart';
import '../../../data/repositories/job_lifecycle_repository.dart';
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
  if (result == null || !context.mounted) return result;
  if (result == 'cancel') {
    if (jobId == null) {
      await showCancelOfferDialog(context);
    } else if (!await withdrawMyOffer(
      context,
      jobId: jobId,
      proposalId: proposalId,
    )) {
      return null;
    }
    return result;
  }
  if (jobId == null) return result;
  return await _runTaskAction(context, result, jobId, proposalId) ? result : null;
}

void _toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// تنفيذ "اتفقنا / قيد التنفيذ / تم الإنجاز" بالخلفية؛ true إذا نجح.
Future<bool> _runTaskAction(
  BuildContext context,
  String action,
  String jobId,
  String? knownProposalId,
) async {
  final jobs = context.read<CraftsmanJobsCubit>();
  final lifecycle = context.read<JobLifecycleCubit>();
  RequestOffer? mine;
  try {
    mine = await jobs.myProposal(jobId);
  } on Object {
    mine = null;
  }
  if (!context.mounted) return false;
  final proposalId = knownProposalId ?? mine?.proposalId;
  if (action != 'working' && proposalId == null) {
    _toast(context, 'ما لقينا عرضك على هالطلب');
    return false;
  }
  if (action == 'agreed' && mine?.isApproved == true) {
    _toast(context, 'الزبون أكّد الاتفاق معك من قبل');
    return false;
  }
  CompletionInput? input;
  if (action == 'done') {
    input = await showCompletionDialog(context, initialAmount: quoteAmountOf(mine));
    if (input == null || !context.mounted) return false;
  }
  try {
    switch (action) {
      case 'agreed':
        await lifecycle.claimSelected(jobId, proposalId!);
      case 'working':
        await lifecycle.startWork(jobId);
      case _:
        await lifecycle.claimDone(jobId, proposalId!, input!);
    }
  } on BackendException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return false;
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر تحديث الحالة، حاول مرة ثانية');
    return false;
  }
  if (!context.mounted) return true;
  _toast(
    context,
    switch (action) {
      'agreed' => 'أرسلنا للزبون طلب تأكيد الاتفاق',
      'working' => 'تم تحديث الحالة: قيد التنفيذ',
      _ => 'أرسلنا للزبون طلب تأكيد الإنجاز',
    },
  );
  await refreshAfterLifecycle(context, professional: true);
  return true;
}

/// السعر المعروض بالعرض كرقم (أعلى سعر إذا كان نطاق)؛ فاضي إذا مجهول.
String quoteAmountOf(RequestOffer? offer) {
  final last = offer?.price.split('-').last ?? '';
  return last.replaceAll(RegExp(r'[^0-9]'), '');
}

/// "تم إنجاز المهمة": المبلغ الفعلي + تقييم الزبون + مطابقة الوصف. بترجع null إذا ألغى.
Future<CompletionInput?> showCompletionDialog(
  BuildContext context, {
  String initialAmount = '',
}) => showAppModal<CompletionInput>(
  context,
  (_) => _CompletionDialog(initialAmount: initialAmount),
);

class _CompletionDialog extends StatefulWidget {
  const _CompletionDialog({required this.initialAmount});

  final String initialAmount;

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  late final _amount = TextEditingController(text: widget.initialAmount);
  final _notes = TextEditingController();
  var _stars = 5;
  var _accuracy = JobAccuracy.close;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int? get _value {
    final v = int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
    return v != null && v > 0 && v <= 2147483647 ? v : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = AppTextStyles.body16Medium;

    return AppDialogCard(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم إنجاز المهمة', style: AppTextStyles.title18Medium),
            const SizedBox(height: 16),
            Text('المبلغ الفعلي (ليرة جديدة)', style: label),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'مثال: 100000',
              controller: _amount,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('تقييمك للزبون', style: label),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => setState(() => _stars = i),
                    child: SvgPicture.asset(
                      'assets/icons/ic_star.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        i <= _stars ? colors.star : colors.border,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('مدى مطابقة العمل للوصف', style: label),
            const SizedBox(height: 8),
            AppSelectField(
              hint: 'اختر',
              value: _accuracy.label,
              onTap: () async {
                final v = await showOptionsSheet(
                  context,
                  title: 'مدى مطابقة العمل للوصف',
                  options: [for (final a in JobAccuracy.values) a.label],
                );
                if (v == null) return;
                setState(() => _accuracy = JobAccuracy.values.firstWhere((a) => a.label == v));
              },
            ),
            const SizedBox(height: 16),
            Text('ملاحظات (اختياري)', style: label),
            const SizedBox(height: 8),
            AppTextField(hint: 'أي ملاحظات عن العمل', controller: _notes, minLines: 2),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: _value == null ? 0.5 : 1,
                    child: AppDialogButton(
                      label: 'تأكيد الإنجاز',
                      background: colors.success,
                      foreground: colors.textOnPrimary,
                      onTap: _value == null
                          ? null
                          : () => Navigator.of(context).pop(
                              CompletionInput(
                                earnings: _value!,
                                clientRating: _stars,
                                accuracy: _accuracy,
                                notes: _notes.text,
                              ),
                            ),
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
      ),
    );
  }
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
