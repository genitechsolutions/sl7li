import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form/app_checkbox.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/field_icons.dart';
import '../../../core/widgets/form/field_popup.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../data/craftsman_signup.dart';
import '../../../data/dummy_data.dart';
import '../widgets/signup_scaffold.dart';
import 'signup_step2_screen.dart';

/// تسجيل المهني 1/4: المعلومات الأساسية (الاسم، المدينة، الأحياء المخدمة).
class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _draft = CraftsmanSignupDraft();
  final _name = TextEditingController();
  final _district = TextEditingController();
  final _districtFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() => _draft.businessName = _name.text));
    _district.addListener(() => setState(() {}));
    _districtFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _district.dispose();
    _districtFocus.dispose();
    super.dispose();
  }

  String get _query => _district.text.trim();

  List<String> get _matches => _query.isEmpty
      ? const []
      : loginDistricts.where((d) => d.contains(_query)).toList();

  void _toggle(String d) => setState(() {
    _draft.districts.contains(d)
        ? _draft.districts.remove(d)
        : _draft.districts.add(d);
  });

  Future<void> _pickCity() async {
    final city = await showOptionsSheet(
      context,
      title: 'المدينة المخدمة',
      options: loginCities,
    );
    if (city != null) setState(() => _draft.city = city);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final matches = _matches;
    final open = _districtFocus.hasFocus && _query.isNotEmpty;

    return SignupScaffold(
      step: 1,
      title: 'المعلومات الأساسية',
      onNext: _draft.step1Valid
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignupStep2Screen(draft: _draft),
              ),
            )
          : null,
      children: [
        ...signupField(
          const FormLabel(
            'اسم النشاط التجاري (أو الاسم الشخصي)',
            isRequired: true,
          ),
          AppTextField(
            hint: 'أدخل الاسم والكنية أو اسم الحساب التجاري',
            controller: _name,
          ),
          top: 30,
        ),
        ...signupField(
          const FormLabel('المدينة المخدمة', isRequired: true),
          AppSelectField(
            hint: 'اختر مدينتك',
            value: _draft.city,
            onTap: _pickCity,
          ),
        ),
        ...signupField(
          const FormLabel('الأحياء المخدمة', isRequired: true),
          FieldPopup(
            above: true,
            isOpen: open,
            onDismiss: _districtFocus.unfocus,
            panel: FieldPopupPanel(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in matches.take(4))
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggle(d),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(d, style: AppTextStyles.body16),
                              ),
                              AppCheckbox(value: _draft.districts.contains(d)),
                            ],
                          ),
                        ),
                      ),
                    if (matches.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'لا توجد مناطق تطابق البحث',
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _toggle(_query);
                          _district.clear();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'إضغط هنا لإضافة “$_query”',
                            style: AppTextStyles.body16.copyWith(
                              color: colors.link,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.link,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            child: AppTextField(
              hint: 'ابحث عن الحي أو المنطقة...',
              controller: _district,
              focusNode: _districtFocus,
              showFocusBorder: true,
              suffixIcon: FieldIcons.search(),
            ),
          ),
        ),
        if (_draft.districts.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.body16Medium,
                children: [
                  const TextSpan(text: 'المناطق المختارة '),
                  TextSpan(
                    text: '(${_draft.districts.length})',
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
              for (final d in _draft.districts)
                GestureDetector(
                  onTap: () => _toggle(d),
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
        ],
      ],
    );
  }
}
