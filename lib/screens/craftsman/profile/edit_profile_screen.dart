import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_action_bar.dart';
import '../../../core/widgets/form/app_checkbox.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/app_toggle.dart';
import '../../../core/widgets/form/field_icons.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../core/widgets/form/phone_field.dart';
import '../../../data/craftsman_signup.dart';
import '../../../data/dummy_data.dart';
import '../signup/signup_step2_screen.dart';
import '../widgets/signup_scaffold.dart';

/// "الملف الشخصي" عند المهني (Edit profile): بيانات وهمية مبدئية، زر الحفظ بيتفعّل بأول تعديل.
class EditCraftsmanProfileScreen extends StatefulWidget {
  const EditCraftsmanProfileScreen({super.key});

  @override
  State<EditCraftsmanProfileScreen> createState() => _EditState();
}

class _EditState extends State<EditCraftsmanProfileScreen> {
  final _d = CraftsmanSignupDraft()
    ..businessName = 'رضا الكويفاتي'
    ..city = 'دمشق'
    ..districts.addAll([
      'مركز المدينة',
      'المزة',
      'المنطقة الصناعية',
      'البرامكة',
    ])
    ..services.addAll(['التكييف', 'الكهرباء', 'السباكة'])
    ..specialties['التكييف'] = {'تبديل وصيانة الضواغط', 'نقل وحدات المكيف'}
    ..years = '4 سنوات'
    ..transport = 'نعم, سيارة خاصة';

  late final _name = TextEditingController(text: _d.businessName);
  final _phone = TextEditingController(text: '939 316 463');
  final _bio = TextEditingController();
  late final _years = TextEditingController(text: _d.years);
  final _address = TextEditingController();
  final _district = TextEditingController();

  String _active = 'التكييف';
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _phone, _bio, _years, _address]) {
      c.addListener(() => _dirty = true);
    }
    _district.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _bio, _years, _address, _district]) {
      c.dispose();
    }
    super.dispose();
  }

  void _change(VoidCallback fn) => setState(() {
    fn();
    _dirty = true;
  });

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> onPicked,
  ) async {
    final v = await showOptionsSheet(context, title: title, options: options);
    if (v != null) _change(() => onPicked(v));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = craftsmanSpecialtiesByService[_active] ?? const <String>[];
    final chosen = _d.specialties.putIfAbsent(_active, () => {});
    final q = _district.text.trim();
    final matches = q.isEmpty
        ? const <String>[]
        : loginDistricts
              .where((x) => x.contains(q) && !_d.districts.contains(x))
              .take(4)
              .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'حفظ التغييرات',
          onPressed: _dirty ? () => Navigator.pop(context) : null,
          secondaryLabel: 'إلغاء',
          sideBySide: true,
          onSecondaryPressed: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الملف الشخصي',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Center(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/craftsman_avatar_self.jpg',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          PositionedDirectional(
                            start: 0,
                            bottom: 0,
                            // TODO: اختيار صورة حقيقي (image_picker)
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/icons/ic_edit_badge.svg',
                                width: 16,
                                height: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('الاسم الكامل'),
                    AppTextField(hint: 'الاسم الكامل', controller: _name),
                    top: 54,
                  ),
                  ...signupField(
                    const FormLabel('الرقم'),
                    PhoneField(
                      controller: _phone,
                      inline: true,
                      restrictInput: true,
                      onCountryTap: () {}, // TODO: pick country code
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 4,
                    ),
                    child: Text(
                      'تغيير رقم الهاتف سيتطلب إدخال رمز تأكيد',
                      style: AppTextStyles.body12.copyWith(color: colors.error),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('نبذة عن خبرتك ومهاراتك'),
                    AppTextField(
                      hint: 'نبذة مختصرة عن خدماتك وخبراتك...',
                      controller: _bio,
                      minLines: 4,
                    ),
                    top: 36,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الخدمات التي تقدمها',
                          style: AppTextStyles.body16Medium,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SignupStep2Screen(draft: _d, editing: true),
                              ),
                            );
                            setState(() {
                              if (!_d.services.contains(_active) &&
                                  _d.services.isNotEmpty) {
                                _active = _d.services.first;
                              }
                            });
                          },
                          child: Text(
                            'تعديل',
                            style: AppTextStyles.body12.copyWith(
                              fontSize: 13,
                              color: colors.link,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.link,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in _d.services)
                        GestureDetector(
                          onTap: () => setState(() => _active = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: s == _active
                                  ? colors.primary
                                  : colors.background,
                              borderRadius: BorderRadius.circular(43),
                              border: Border.all(
                                color: s == _active
                                    ? colors.primary
                                    : colors.border,
                              ),
                            ),
                            child: Text(
                              s,
                              style: AppTextStyles.title18Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: s == _active
                                    ? colors.textOnPrimary
                                    : colors.primaryContent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'تخصصاتك ضمن $_active',
                      style: AppTextStyles.body16.copyWith(color: colors.link),
                    ),
                  ),
                  for (final o in options)
                    if (chosen.contains(o))
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _change(() => chosen.remove(o)),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(o, style: AppTextStyles.body16),
                              ),
                              const AppCheckbox(value: true),
                            ],
                          ),
                        ),
                      ),
                  ...signupField(
                    const FormLabel('سنوات الخبرة'),
                    AppTextField(
                      hint: 'أدخل عدد سنوات خبرتك',
                      controller: _years,
                    ),
                    top: 24,
                  ),
                  ...signupField(
                    const FormLabel('هل تملك وسيلة مواصلات؟'),
                    AppSelectField(
                      hint: 'اختر وسيلة مواصلات',
                      value: _d.transport,
                      onTap: () => _pick(
                        'وسيلة المواصلات',
                        craftsmanTransportOptions,
                        (v) => _d.transport = v,
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('أوقات العمل المفضلة'),
                    AppSelectField(
                      hint: 'اختر أوقات عملك المناسبة',
                      value: _d.workTimes,
                      onTap: () => _pick(
                        'أوقات العمل',
                        craftsmanWorkTimeOptions,
                        (v) => _d.workTimes = v,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'أمتلك جميع الأدوات اللازمة',
                            style: AppTextStyles.body16Medium,
                          ),
                        ),
                        AppToggle(
                          value: _d.hasTools,
                          onChanged: (v) => _change(() => _d.hasTools = v),
                        ),
                      ],
                    ),
                  ),
                  ...signupField(
                    const FormLabel('المدينة'),
                    AppSelectField(
                      hint: 'اختر مدينتك',
                      value: _d.city,
                      onTap: () => _pick(
                        'المدينة المخدمة',
                        loginCities,
                        (v) => _d.city = v,
                      ),
                    ),
                  ),
                  ...signupField(
                    const FormLabel('الحي'),
                    AppTextField(
                      hint: 'ابحث عن الحي أو المنطقة...',
                      controller: _district,
                      suffixIcon: FieldIcons.search(),
                    ),
                  ),
                  for (final m in matches)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _change(() {
                        _d.districts.add(m);
                        _district.clear();
                      }),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(m, style: AppTextStyles.body16),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.body16Medium,
                        children: [
                          const TextSpan(text: 'المناطق المختارة '),
                          TextSpan(
                            text: '(${_d.districts.length})',
                            style: AppTextStyles.body12.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in _d.districts)
                        GestureDetector(
                          onTap: () => _change(() => _d.districts.remove(d)),
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
                  ...signupField(
                    const FormLabel('عنوان الورشة'),
                    AppTextField(hint: 'عنوان الورشة', controller: _address),
                    top: 24,
                  ),
                  ...signupField(
                    const FormLabel('موقع الورشة على الخريطة'),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 175,
                            width: double.infinity,
                            // TODO: خريطة حقيقية (google_maps_flutter بموافقة)
                            child: Image.asset(
                              'assets/images/map_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _change(() {}),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'تحديد موقعي تلقائيا',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
