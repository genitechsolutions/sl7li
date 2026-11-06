import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../../core/widgets/form/form_label.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/my_request.dart';
import '../../data/request_draft.dart';

/// تعديل طلب مفتوح: الوصف، مدى الإلحاح، التواصل عبر واتساب.
class EditRequestScreen extends StatefulWidget {
  const EditRequestScreen({super.key, required this.request});

  final MyRequest request;

  /// بيفتح الشاشة وبيرجع true إذا انحفظ التعديل.
  static Future<bool> open(BuildContext context, MyRequest request) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditRequestScreen(request: request)),
    );
    return saved == true;
  }

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  late final _description = TextEditingController(text: widget.request.description);
  late RequestPriority _priority = widget.request.priority;
  late bool _whatsapp = widget.request.shareWhatsapp;
  bool _saving = false;
  String? _error;

  static const _priorities = [
    RequestPriority.normal,
    RequestPriority.urgent,
    RequestPriority.emergency,
  ];

  bool get _valid =>
      _description.text.trim().length >= 10 || _description.text.trim() == widget.request.description.trim();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = widget.request.id;
    if (_saving) return;
    if (id == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<MyRequestsCubit>().updateRequest(
        id,
        description: _description.text,
        priority: _priority,
        shareWhatsapp: _whatsapp,
        cityCode: widget.request.cityCode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم حفظ تعديلات الطلب')));
      Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e is BackendException ? e.message : 'تعذّر حفظ التعديل، حاول مرة ثانية';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: AppBottomActionBar(
        label: _saving ? 'جاري الحفظ...' : 'حفظ التعديلات',
        onPressed: _valid && !_saving ? _save : null,
        secondaryLabel: 'إلغاء',
        onSecondaryPressed: _saving ? null : () => Navigator.of(context).pop(false),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
          children: [
            Row(
              children: [
                AppIconButton(
                  icon: 'assets/icons/ic_arrow_back.svg',
                  onTap: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('تعديل الطلب', style: AppTextStyles.title24Bold)),
              ],
            ),
            const SizedBox(height: 28),
            const FormLabel('وصف المشكلة', isRequired: true),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'اشرح المشكلة أو العمل المطلوب',
              controller: _description,
              minLines: 5,
              onChanged: (_) => setState(() {}),
            ),
            if (!_valid)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
                child: Text(
                  'الوصف لازم يكون 10 أحرف على الأقل',
                  style: AppTextStyles.body12.copyWith(color: colors.textSecondary),
                ),
              ),
            const SizedBox(height: 28),
            const FormLabel('مدى الإلحاح'),
            const SizedBox(height: 8),
            AppSegmentedControl(
              options: RequestDraft.urgencyLevels,
              selected: _priorities.indexOf(_priority),
              onChanged: (i) => setState(() => _priority = _priorities[i]),
              height: 48,
              textStyle: AppTextStyles.body16,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _whatsapp ? 'يسمح تواصل المهنيين عبر وتساب' : 'تواصل المهنيين عبر التطبيق فقط',
                    style: AppTextStyles.body16,
                  ),
                ),
                AppToggle(value: _whatsapp, onChanged: (v) => setState(() => _whatsapp = v)),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(_error!, style: AppTextStyles.body14.copyWith(color: colors.error)),
              ),
          ],
        ),
      ),
    );
  }
}
