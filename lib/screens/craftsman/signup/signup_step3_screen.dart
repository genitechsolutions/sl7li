import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/app_toggle.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../core/widgets/form/options_sheet.dart';
import '../../../data/craftsman_signup.dart';
import '../widgets/signup_scaffold.dart';
import 'signup_step4_screen.dart';

/// تسجيل المهني 3/4: الخبرة والأدوات.
class SignupStep3Screen extends StatefulWidget {
  const SignupStep3Screen({super.key, required this.draft});

  final CraftsmanSignupDraft draft;

  @override
  State<SignupStep3Screen> createState() => _SignupStep3ScreenState();
}

class _SignupStep3ScreenState extends State<SignupStep3Screen> {
  final _years = TextEditingController();

  CraftsmanSignupDraft get _d => widget.draft;

  @override
  void initState() {
    super.initState();
    _years.text = _d.years;
    _years.addListener(() => setState(() => _d.years = _years.text));
  }

  @override
  void dispose() {
    _years.dispose();
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
    return SignupScaffold(
      step: 3,
      title: 'الخبرة والأدوات',
      onNext: _d.step3Valid
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignupStep4Screen(draft: _d)),
            )
          : null,
      children: [
        ...signupField(
          const FormLabel('سنوات الخبرة', isRequired: true),
          AppTextField(
            hint: 'أدخل عدد سنوات خبرتك',
            controller: _years,
            keyboardType: TextInputType.number,
          ),
          top: 30,
        ),
        ...signupField(
          const FormLabel('هل تملك وسيلة مواصلات؟', isRequired: true),
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
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'أمتلك جميع الأدوات اللازمة',
                  style: AppTextStyles.body16Medium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              AppToggle(
                value: _d.hasTools,
                onChanged: (v) => setState(() => _d.hasTools = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
