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
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        label(const FormLabel('السعر', isRequired: true)),
                        AppTextField(
                          hint: 'سعر العرض',
                          controller: _price,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        label(
                          Text(
                            'العملة',
                            style: AppTextStyles.body14.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: AppSelectField(
                            hint: 'العملة',
                            value: 'ليرة سورية',
                            onTap: () {},
                          ),
                        ),
                      ],
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
              keyboardType: TextInputType.text,
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
                  AppCheckbox(value: _confirmed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أؤكد أن العنوان والوصف والصور لا تحتوي على أي رقم هاتف ظاهر *',
                      style: AppTextStyles.body16.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 4:
        title = 'تأكيد إنشاء العرض';
        final specialties =
            (craftsmanSpecialtiesByService[_service] ??
                    craftsmanSpecialtiesByService['الكهرباء']!)
                .take(3)
                .toList();
        final photos = _photos.isEmpty
            ? const ['assets/images/offer_carpentry.jpg']
            : _photos;
        Widget overlayPill(String text, {bool counter = false}) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: counter ? 10 : 12,
            vertical: counter ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: counter ? colors.barrier : colors.background,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            text,
            textDirection: counter ? TextDirection.ltr : null,
            style: AppTextStyles.body14.copyWith(
              color: counter ? colors.textOnPrimary : colors.textPrimary,
            ),
          ),
        );
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 242,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(photos.first, fit: BoxFit.cover),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: overlayPill(_city),
                    ),
                    PositionedDirectional(
                      bottom: 12,
                      start: 12,
                      child: overlayPill('1 / ${photos.length}', counter: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _title.text.isEmpty ? 'عنوان العرض يكتب هنا' : _title.text,
              style: AppTextStyles.title20.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _offerType == 'سعر خاص'
                      ? '${_price.text} ل.س'
                      : 'خصم ${_percent.text}%',
                  style: AppTextStyles.title20.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _expiry == null
                      ? 'ساري حتى شهر من الآن'
                      : 'ساري حتى ${_expiry!.day}/${_expiry!.month}/${_expiry!.year}',
                  style: AppTextStyles.body16.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 20,
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
              style: AppTextStyles.title18.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in specialties) AppChip(label: t)],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 24,
                start: 12,
                bottom: 8,
              ),
              child: Text(
                'صور العرض',
                style: AppTextStyles.body16Medium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Row(
              spacing: 12,
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          photos[i % photos.length],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.body16.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'يمكنك التواصل مع '),
                    TextSpan(
                      text: 'خدمة العملاء',
                      style: TextStyle(
                        color: colors.link,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.link,
                      ),
                    ),
                    const TextSpan(
                      text: ' في حال تأخر تأكيد العرض أكثر من ذلك',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
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
                      child: Text.rich(
                        TextSpan(
                          style: AppTextStyles.body12.copyWith(
                            color: colors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'بإنشاء العرض أنت توافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: TextStyle(
                                color: colors.link,
                                decoration: TextDecoration.underline,
                                decorationColor: colors.link,
                              ),
                            ),
                            const TextSpan(text: ' و '),
                            TextSpan(
                              text: 'سياسة الخصوصية',
                              style: TextStyle(
                                color: colors.link,
                                decoration: TextDecoration.underline,
                                decorationColor: colors.link,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
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
