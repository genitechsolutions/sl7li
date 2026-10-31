import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/form/app_checkbox.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/field_icons.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../data/craftsman_signup.dart';
import '../../../data/dummy_data.dart';
import '../../new_request/widgets/photo_picker.dart';
import '../../new_request/widgets/request_step_header.dart';
import '../../new_request/widgets/success_illustration.dart';

/// إنشاء عرض ترويجي (4 خطوات + نجاح): وصف، تفاصيل (سعر/خصم، تاريخ، صور)، موقع، تأكيد.
class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  int _step = 1;

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _percent = TextEditingController();
  final _district = TextEditingController();

  String? _service;
  String _offerType = 'سعر خاص';
  DateTime? _expiry;
  final List<String> _photos = [];
  String _city = 'دمشق';
  final List<String> _districts = [
    'مركز المدينة',
    'المزة',
    'البرامكة',
    'المنطقة الصناعية',
    'منطقة',
  ];
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_title, _desc, _price, _percent, _district]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _desc, _price, _percent, _district]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => switch (_step) {
    1 =>
      _title.text.trim().isNotEmpty &&
          _desc.text.trim().isNotEmpty &&
          _service != null,
    2 =>
      (_offerType == 'سعر خاص'
              ? _price.text.trim().isNotEmpty
              : _percent.text.trim().isNotEmpty) &&
          _photos.isNotEmpty,
    3 => _districts.isNotEmpty && _confirmed,
    _ => true,
  };

  void _next() => setState(() => _step++);

  void _back() {
    if (_step == 1) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'الحد الأقصى 3 أشهر من اليوم',
    );
    if (d != null) setState(() => _expiry = d);
  }

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> on,
  ) async {
    final v = await showOptionsSheet(context, title: title, options: options);
    if (v != null) setState(() => on(v));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = _step == 5;

    Widget label(Widget l, {double top = 20}) => Padding(
      padding: EdgeInsetsDirectional.only(top: top, start: 12, bottom: 8),
      child: l,
    );

    Widget body;
    String title;
    switch (_step) {
      case 1:
        title = 'وصف العرض العام';
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.noticeWarning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: colors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'سياسة النشر بخصوص أرقام الهاتف',
                        style: AppTextStyles.body16.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final t in const [
                    'يمنع كتابة أي رقم هاتف في عنوان العرض أو وصف العرض',
                    'يمنع ظهور أي رقم هاتف داخل الصور المرفوعة',
                    'سيظهر للعميل زر لطلب سعر منك عبر المنصة',
                  ])
                    Text(
                      '•  $t',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.warning,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            label(const FormLabel('عنوان العرض', isRequired: true)),
            AppTextField(hint: 'عنوان العرض', controller: _title),
            label(const FormLabel('وصف العرض', isRequired: true)),
            AppTextField(
              hint: 'اوصف العرض وصفا تفصيليا...',
              controller: _desc,
              minLines: 5,
            ),
            label(const FormLabel('نوع الخدمة', isRequired: true)),
            AppSelectField(
              hint: 'اختر نوع الخدمة',
              value: _service,
              onTap: () => _pick('نوع الخدمة', [
                for (final s in craftsmanServiceOptions) s.$1,
              ], (v) => _service = v),
            ),
          ],
        );
      case 2:
        title = 'تفاصيل العرض';
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label(const FormLabel('نوع العرض', isRequired: true), top: 24),
            AppSelectField(
              hint: 'نوع العرض',
              value: _offerType,
              onTap: () => _pick('نوع العرض', const [
                'سعر خاص',
                'خصم نسبة',
              ], (v) => _offerType = v),
            ),
            if (_offerType == 'سعر خاص') ...[
              label(const FormLabel('السعر', isRequired: true)),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      hint: 'سعر العرض',
                      controller: _price,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: AppSelectField(
                        hint: 'العملة',
                        value: 'ليرة سورية',
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              label(const FormLabel('نسبة الخصم', isRequired: true)),
              AppTextField(
                hint: 'ادخل نسبة الخصم',
                controller: _percent,
                keyboardType: TextInputType.number,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.percent, color: colors.textSecondary),
                ),
              ),
            ],
            label(const FormLabel('تاريخ انتهاء العرض', note: '(اختياري)')),
            AppSelectField(
              hint: 'يوم / شهر / سنة',
              value: _expiry == null
                  ? null
                  : '${_expiry!.year} / ${_expiry!.month} / ${_expiry!.day}',
              trailing: Icon(
                Icons.calendar_month_outlined,
                color: colors.primaryContent,
              ),
              onTap: _pickDate,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8, start: 12),
              child: Text(
                'إذا لم تحدد تاريخا، سيتم تعيين مدة افتراضية شهر واحد',
                style: AppTextStyles.body12.copyWith(color: colors.link),
              ),
            ),
            label(
              Row(
                children: [
                  const FormLabel('صور العرض', isRequired: true),
                  const Spacer(),
                  Text(
                    '(${_photos.length}/10)',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.body12.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PhotoPicker(
              photos: _photos,
              maxPhotos: 10,
              // TODO: اختيار صور حقيقي (image_picker بموافقة)؛ صورة تجريبية.
              onAdd: () => setState(
                () => _photos.add('assets/images/offer_carpentry.jpg'),
              ),
              onRemove: (i) => setState(() => _photos.removeAt(i)),
            ),
          ],
        );
      case 3:
        title = 'الموقع';
        final q = _district.text.trim();
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label(
              const FormLabel('المدينة المخدمة', isRequired: true),
              top: 24,
            ),
            AppSelectField(
              hint: 'اختر المدينة',
              value: _city,
              onTap: () => _pick('المدينة', loginCities, (v) => _city = v),
            ),
            label(const FormLabel('الأحياء المخدمة', isRequired: true)),
            AppTextField(
              hint: 'ابحث عن الحي أو المنطقة...',
              controller: _district,
              showFocusBorder: true,
              suffixIcon: FieldIcons.search(),
            ),
            if (q.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() {
                  if (!_districts.contains(q)) _districts.add(q);
                  _district.clear();
                }),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12, left: 12),
                  child: Text(
                    'إضغط هنا لإضافة “$q”',
                    style: AppTextStyles.body14.copyWith(
                      color: colors.link,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            label(
              Text.rich(
                TextSpan(
                  style: AppTextStyles.body16Medium,
                  children: [
                    const TextSpan(text: 'المناطق المختارة '),
                    TextSpan(
                      text: '(${_districts.length})',
                      style: AppTextStyles.body12.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in _districts)
                  GestureDetector(
                    onTap: () => setState(() => _districts.remove(d)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 18,
                            color: colors.textOnPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            d,
                            style: AppTextStyles.body16Medium.copyWith(
                              color: colors.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _confirmed = !_confirmed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'أؤكد أن العنوان والوصف والصور لا تحتوي على أي رقم هاتف ظاهر *',
                      style: AppTextStyles.body16.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppCheckbox(value: _confirmed),
                ],
              ),
            ),
          ],
        );
      case 4:
        title = 'تأكيد إنشاء العرض';
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 212,
                child: Image.asset(
                  _photos.isEmpty
                      ? 'assets/images/offer_carpentry.jpg'
                      : _photos.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _title.text.isEmpty ? 'عنوان العرض يكتب هنا' : _title.text,
              style: AppTextStyles.title18Medium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _offerType == 'سعر خاص'
                      ? '${_price.text} ل.س'
                      : '${_percent.text}% خصم',
                  style: AppTextStyles.title18Medium.copyWith(
                    color: colors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _expiry == null
                      ? 'ساري حتى شهر من الآن'
                      : 'ساري حتى ${_expiry!.day}/${_expiry!.month}/${_expiry!.year}',
                  style: AppTextStyles.body14.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 16,
                start: 12,
                bottom: 4,
              ),
              child: Text(
                'وصف العرض:',
                style: AppTextStyles.body16Medium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(
              _desc.text.isEmpty ? 'وصف العرض' : _desc.text,
              style: AppTextStyles.body16.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(label: _service ?? 'الكهرباء'),
                AppChip(label: _city),
              ],
            ),
          ],
        );
      default:
        title = 'تم إنشاء العرض بنجاح';
        body = Column(
          children: [
            const SizedBox(height: 56),
            const SuccessIllustration(),
            const SizedBox(height: 32),
            Text('تم إنشاء العرض بنجاح', style: AppTextStyles.title24Bold),
            const SizedBox(height: 8),
            Text(
              'ما هي الخطوة التالية؟',
              style: AppTextStyles.title18.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            for (final t in const [
              'عرضك الآن قيد المراجعة',
              'سيتم إشعارك عند تأكيد العرض الخاص بك',
              'عادة يتم تأكيد العرض خلال 24 ساعة',
              'ستصلك إشعارات عندما يطلب أحد العرض',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body16.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        );
    }

    Widget btn(String text, VoidCallback? onTap, {bool primary = true}) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary
                    ? (onTap == null ? colors.disabled : colors.primary)
                    : colors.background,
                borderRadius: BorderRadius.circular(12),
                border: primary ? null : Border.all(color: colors.border),
              ),
              child: Text(
                text,
                style: AppTextStyles.title18Medium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primary ? colors.textOnPrimary : colors.primaryContent,
                ),
              ),
            ),
          ),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_step == 4)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'بإنشاء العرض أنت توافق على الشروط والأحكام و سياسة الخصوصية',
                        style: AppTextStyles.body12.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  Row(
                    spacing: 12,
                    children: [
                      if (done)
                        btn('العودة لصفحة عروضي', () => Navigator.pop(context))
                      else ...[
                        btn(
                          _step == 4 ? 'إنشاء العرض' : 'المتابعة',
                          _valid ? _next : null,
                        ),
                        if (_step > 1)
                          btn('الخطوة السابقة', _back, primary: false),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              RequestStepHeader(
                title: 'إنشاء عرض',
                step: done ? 5 : _step,
                totalSteps: 4,
                subtitle: done ? 'تم إنشاء العرض' : null,
                actionLabel: done ? 'العودة للصفحة الرئيسية' : 'إلغاء',
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 22),
              if (!done)
                Center(child: Text(title, style: AppTextStyles.title24Bold)),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
