import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_action_bar.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/app_toggle.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../data/craftsman_signup.dart';
import '../signup/signup_step2_screen.dart';
import '../widgets/signup_scaffold.dart';

/// "تعديل الملف الشخصي" عند المهني (بيانات وهمية مبدئية).
class EditCraftsmanProfileScreen extends StatefulWidget {
  const EditCraftsmanProfileScreen({super.key});

  @override
  State<EditCraftsmanProfileScreen> createState() => _EditState();
}

class _EditState extends State<EditCraftsmanProfileScreen> {
  final _d = CraftsmanSignupDraft()
    ..businessName = 'ورشة أبو أحمد'
    ..city = 'دمشق'
    ..districts.addAll(['المزة', 'كفرسوسة'])
    ..services.addAll(['الكهرباء', 'التكييف'])
    ..years = '8'
    ..transport = craftsmanTransportOptions.first
    ..workTimes = craftsmanWorkTimeOptions.first
    ..workshopAddress = 'دمشق - المزة - شارع الجلاء'
    ..bio = 'فني كهرباء وتكييف بخبرة طويلة بالصيانة والتركيب.';

  late final _name = TextEditingController(text: _d.businessName);
  late final _years = TextEditingController(text: _d.years);
  late final _address = TextEditingController(text: _d.workshopAddress);
  late final _bio = TextEditingController(text: _d.bio);

  @override
  void dispose() {
    _name.dispose();
    _years.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pick(
    String title,
    List<String> options,
    ValueChanged<String> onPicked,
  ) async {
    final v = await showOptionsSheet(context, title: title, options: options);
    if (v != null) setState(() => onPicked(v));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'حفظ التغييرات',
          secondaryLabel: 'إلغاء',
          onSecondaryPressed: () => Navigator.pop(context),
          onPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            children: [
              Text('تعديل الملف الشخصي', style: AppTextStyles.title24Bold),
              ...signupField(
                const FormLabel('اسم المهني أو الورشة', isRequired: true),
                AppTextField(hint: 'الاسم', controller: _name),
              ),
              ...signupField(
                const FormLabel('نبذة عنك'),
                AppTextField(
                  hint: 'اكتب نبذة قصيرة',
                  controller: _bio,
                  minLines: 4,
                ),
              ),
              ...signupField(
                const FormLabel('الخدمات والتخصصات'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in _d.services) AppChip(label: s),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SignupStep2Screen(draft: _d, editing: true),
                          ),
                        );
                        setState(() {});
                      },
                      child: Text(
                        'تعديل',
                        style: AppTextStyles.body16Medium.copyWith(
                          color: colors.link,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...signupField(
                const FormLabel('سنوات الخبرة'),
                AppTextField(
                  hint: 'عدد السنوات',
                  controller: _years,
                  keyboardType: TextInputType.number,
                ),
              ),
              ...signupField(
                const FormLabel('وسيلة المواصلات'),
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
                  hint: 'اختر أوقات عملك',
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
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
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
                      onChanged: (v) => setState(() => _d.hasTools = v),
                    ),
                  ],
                ),
              ),
              ...signupField(
                const FormLabel('عنوان الورشة'),
                AppTextField(hint: 'العنوان', controller: _address),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
