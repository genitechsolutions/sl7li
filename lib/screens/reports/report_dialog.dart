import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/form_label.dart';
import '../../core/widgets/form/options_sheet.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/repositories/reports_ratings_repository.dart';

void _toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// إبلاغ عن عرض المهني المرتبط بمحادثة/طلب: بيجيب العرض، بيتحقق من الأهلية، بيفتح النافذة وبيرسل البلاغ.
Future<void> reportConversationOffer(
  BuildContext context, {
  required String? jobId,
  Set<String> professionalIds = const {},
  String? name,
}) async {
  final myRequests = context.read<MyRequestsCubit>();
  final repo = context.read<ServiceReportsRepository>();
  String? proposalId;
  if (jobId != null) {
    try {
      final offers = await myRequests.offers(jobId);
      final match = offers.where(
        (o) => professionalIds.isEmpty || professionalIds.contains(o.professionalId),
      );
      proposalId = match.firstOrNull?.proposalId;
    } on Object {
      proposalId = null;
    }
  }
  if (!context.mounted) return;
  await reportTarget(
    context,
    repo,
    targetType: 'proposal',
    targetId: proposalId,
    name: name,
  );
}

/// فحص الأهلية ثم النافذة ثم الإرسال لهدف محدد (`proposal` أو `offer`).
Future<void> reportTarget(
  BuildContext context,
  ServiceReportsRepository repo, {
  required String targetType,
  required String? targetId,
  String? name,
}) async {
  if (targetId == null) {
    _toast(context, 'ما في عرض مرتبط بهالمحادثة للإبلاغ عنه');
    return;
  }
  ReportEligibility eligibility;
  try {
    eligibility = await repo.eligibility(targetType, targetId);
  } on BackendException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return;
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر التحقق من إمكانية الإبلاغ، حاول مرة ثانية');
    return;
  }
  if (!context.mounted) return;
  if (!eligibility.canReport) {
    _toast(context, 'ما بتقدر تبلّغ عن هالعرض');
    return;
  }
  final result = await showAppModal<_ReportResult>(
    context,
    (_) => _ReportDialog(name: name, reported: eligibility.reportedCategories),
  );
  if (result == null || !context.mounted) return;
  try {
    await repo.create(
      targetType: targetType,
      targetId: targetId,
      category: result.category,
      reason: result.reason,
      details: result.details,
    );
    if (context.mounted) _toast(context, 'تم استلام بلاغك، رح يراجعه فريق صلّحلي');
  } on BackendException catch (e) {
    if (context.mounted) _toast(context, e.message);
  } on Object {
    if (context.mounted) _toast(context, 'تعذّر إرسال البلاغ، حاول مرة ثانية');
  }
}

class _ReportResult {
  const _ReportResult(this.category, this.reason, this.details);
  final ReportCategory category;
  final ReportReason reason;
  final String details;
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({this.name, this.reported = const []});

  final String? name;
  final List<String> reported;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _notes = TextEditingController();
  ReportCategory? _category;
  ReportReason? _reason;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  List<ReportCategory> get _available => [
    for (final c in ReportCategory.values)
      if (!widget.reported.contains(c.value)) c,
  ];

  bool get _valid {
    final reason = _reason;
    if (_category == null || reason == null) return false;
    final len = _notes.text.trim().length;
    return len <= reportDetailsMax && (!reason.needsDetails || len >= reportDetailsMin);
  }

  Future<void> _pickCategory() async {
    final label = await showOptionsSheet(
      context,
      title: 'نوع المشكلة',
      options: [for (final c in _available) c.label],
    );
    if (label == null) return;
    setState(() {
      _category = ReportCategory.values.firstWhere((c) => c.label == label);
      _reason = null;
    });
  }

  Future<void> _pickReason() async {
    final options = reportReasons[_category]!;
    final label = await showOptionsSheet(
      context,
      title: 'سبب البلاغ',
      options: [for (final r in options) r.label],
    );
    if (label == null) return;
    setState(() => _reason = options.firstWhere((r) => r.label == label));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = widget.name;

    return AppDialogCard(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إبلاغ', style: AppTextStyles.title18Medium),
            if (name != null) ...[
              const SizedBox(height: 4),
              Text(
                'عن عرض $name',
                style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            if (_available.isEmpty)
              Text(
                'سبق وبلّغت عن هالعرض بكل الأنواع',
                style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
              )
            else ...[
              const FormLabel('نوع المشكلة', isRequired: true),
              const SizedBox(height: 8),
              AppSelectField(
                hint: 'اختر نوع المشكلة',
                value: _category?.label,
                onTap: _pickCategory,
              ),
              const SizedBox(height: 16),
              const FormLabel('سبب البلاغ', isRequired: true),
              const SizedBox(height: 8),
              AppSelectField(
                hint: 'اختر السبب',
                value: _reason?.label,
                onTap: _category == null ? null : _pickReason,
              ),
              const SizedBox(height: 16),
              FormLabel(
                'تفاصيل إضافية',
                isRequired: _reason?.needsDetails ?? false,
                note: (_reason?.needsDetails ?? false) ? null : '(اختياري)',
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'اكتب التفاصيل هون',
                controller: _notes,
                minLines: 3,
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (_available.isNotEmpty)
                  Expanded(
                    child: AppDialogButton(
                      label: 'إرسال البلاغ',
                      background: _valid ? colors.destructive : colors.disabled,
                      foreground: colors.textOnPrimary,
                      onTap: _valid
                          ? () => Navigator.of(context).pop(
                              _ReportResult(_category!, _reason!, _notes.text),
                            )
                          : null,
                    ),
                  ),
                if (_available.isNotEmpty) const SizedBox(width: 12),
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
