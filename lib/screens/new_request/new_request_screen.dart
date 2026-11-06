import '../../core/widgets/coming_soon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_text_field.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../../core/widgets/form/field_icons.dart';
import '../../core/widgets/form/form_label.dart';
import '../../core/widgets/form/options_sheet.dart';
import '../../core/widgets/form/phone_field.dart';
import '../../data/dummy_data.dart';
import '../../data/repositories/craftsman_signup_repository.dart';
import '../../data/repositories/service_classifier_repository.dart';
import '../../data/request_draft.dart';
import 'request_details_screen.dart';
import 'widgets/request_step_header.dart';

/// طلب خدمة — الخطوة 1: تصنيف الطلب.
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  static const routeName = '/new-request';

  /// افتح الطلب بهالـ route مشان "إلغاء" بالخطوات الجاية يعرف لوين يرجع.
  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: routeName),
    builder: (_) => const NewRequestScreen(),
  );

  /// "إلغاء" من أي خطوة: بيسكّر كل خطوات الطلب.
  static void cancelFlow(BuildContext context) {
    Navigator.of(context)
      ..popUntil(ModalRoute.withName(routeName))
      ..pop();
  }

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  static const _autoClassify = 'التصنيف التلقائي';
  // النصوص الصغيرة تحت الحقول داخلة 12 بالتصميم.
  static const _notePadding = EdgeInsetsDirectional.only(start: 12, top: 8, bottom: 4);

  final _draft = RequestDraft();
  final _description = TextEditingController();
  final _customerName = TextEditingController();
  final _phone = TextEditingController();
  final _area = TextEditingController();
  String? _serviceType;
  bool _autoClassifyFailed = false;
  String? _subSpecialty;
  String? _serviceId;
  String? _specialtyId;
  bool _classifying = false;
  bool _onBehalf = false;
  String _city = requestCities.first;

  @override
  void dispose() {
    _description.dispose();
    _customerName.dispose();
    _phone.dispose();
    _area.dispose();
    super.dispose();
  }

  void _continue() {
    _draft
      ..description = _description.text.trim()
      ..serviceType = _autoClassifyFailed ? null : _serviceType
      ..subSpecialty = _subSpecialty
      ..serviceId = _autoClassifyFailed ? null : _serviceId
      ..specialtyId = _autoClassifyFailed ? null : _specialtyId
      ..onBehalf = _onBehalf
      ..customerName = _customerName.text
      ..phone = _phone.text
      ..city = _city
      ..area = _area.text;
    Navigator.push(context, MaterialPageRoute(builder: (_) => RequestDetailsScreen(draft: _draft)));
  }

  Future<void> _pickServiceType() async {
    final type = await showOptionsSheet(context, title: 'نوع الخدمة', options: requestServiceTypes);
    if (type == null) return;
    setState(() {
      _serviceType = type;
      _autoClassifyFailed = false;
      _subSpecialty = null;
      _serviceId = serviceIdForLabel(type);
      _specialtyId = null;
    });
  }

  Future<void> _classifyAutomatically() async {
    if (_classifying) return;
    final classifier = context.read<ServiceClassifier>();
    final description = _description.text.trim();
    setState(() => _classifying = true);
    ServiceClassification? result;
    try {
      if (description.isNotEmpty) result = await classifier.classify(description);
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() {
      _classifying = false;
      _autoClassifyFailed = result == null;
      _serviceType = result?.serviceLabel ?? _autoClassify;
      _serviceId = result?.serviceId;
      _subSpecialty = result?.specialtyLabel;
      _specialtyId = result?.specialtyId;
    });
  }

  Future<void> _pickSubSpecialty() async {
    final value = await showOptionsSheet(
      context,
      title: 'التخصص الفرعي',
      options: sampleServiceDetails.specialties.toSet().toList(),
    );
    if (value != null) {
      setState(() {
        _subSpecialty = value;
        _specialtyId = craftsmanSpecialtyIds[value];
      });
    }
  }

  Future<void> _pickCity() async {
    final city = await showOptionsSheet(context, title: 'المدينة', options: requestCities);
    if (city != null) setState(() => _city = city);
  }

  @override
  Widget build(BuildContext context) {
    final hasServiceType = _serviceType != null && !_autoClassifyFailed;
    final canContinue = _description.text.trim().isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'المتابعة',
          onPressed: canContinue ? _continue : null,
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              RequestStepHeader(step: 1, totalSteps: 4, onCancel: () => Navigator.pop(context)),
              const SizedBox(height: 22),
              const Center(child: Text('تصنيف الطلب', style: AppTextStyles.title24Bold)),
              const SizedBox(height: 1),
              ..._field(
                const FormLabel('وصف المشكلة', isRequired: true),
                AppTextField(
                  hint: 'اشرح تفاصيل المشكلة أو العمل المطلوب...',
                  controller: _description,
                  minLines: 4,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              ..._field(
                const FormLabel('نوع الخدمة', isRequired: true),
                AppSelectField(
                  hint: 'اختر نوع الخدمة',
                  value: _serviceType,
                  trailing: FieldIcons.search(),
                  hasError: _autoClassifyFailed,
                  onTap: _pickServiceType,
                ),
              ),
              Padding(
                padding: _notePadding,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _autoClassifyFailed
                      ? Text(
                          'تعذر تحديد النوع تلقائيا, يرجى تحديده يدويا',
                          style: AppTextStyles.body12.copyWith(color: context.colors.error),
                        )
                      : GestureDetector(
                          onTap: _classifyAutomatically,
                          child: Text(
                            'أو اضغط للتصنيف تلقائيا',
                            style: AppTextStyles.body12.copyWith(color: context.colors.link),
                          ),
                        ),
                ),
              ),
              ..._field(
                const FormLabel('التخصص الفرعي', note: '(اختياري)'),
                AppSelectField(
                  hint: 'اختر التخصص الذي تحتاجه',
                  value: _subSpecialty,
                  onTap: hasServiceType ? _pickSubSpecialty : null,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text('حدد الطلب بالنيابة عن شخص أخر', style: AppTextStyles.body16Medium),
                  ),
                  AppToggle(value: _onBehalf, onChanged: (v) => setState(() => _onBehalf = v)),
                ],
              ),
              if (_onBehalf) ...[
                const SizedBox(height: 2),
                ..._field(
                  const FormLabel('اسم الزبون', isRequired: true),
                  AppTextField(hint: 'اسم الزبون', controller: _customerName),
                ),
                ..._field(
                  const FormLabel('رقم الواتساب', isRequired: true, note: '(بدون صفر)'),
                  PhoneField(
                    controller: _phone,
                    inline: true,
                    onCountryTap: showCountryNotice,
                  ), // TODO: pick country code
                ),
                ..._field(
                  const FormLabel('المدينة', isRequired: true),
                  AppSelectField(hint: 'اختر المدينة', value: _city, onTap: _pickCity),
                ),
                ..._field(
                  const FormLabel('الحي أو المنطقة', note: '(اختياري)'),
                  AppTextField(
                    hint: 'مركز المدينة',
                    controller: _area,
                    suffixIcon: FieldIcons.search(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// عنوان + حقل، مع المسافة قبلهم.
  List<Widget> _field(Widget label, Widget field) {
    return [const SizedBox(height: 32), label, const SizedBox(height: 8), field];
  }
}
