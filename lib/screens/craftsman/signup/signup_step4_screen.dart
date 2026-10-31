import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form/app_text_field.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../data/craftsman_signup.dart';
import '../widgets/signup_scaffold.dart';
import 'signup_review_screen.dart';

/// تسجيل المهني 4/4: معلومات إضافية (عنوان الورشة، موقعها على الخريطة، نبذة).
class SignupStep4Screen extends StatefulWidget {
  const SignupStep4Screen({super.key, required this.draft});

  final CraftsmanSignupDraft draft;

  @override
  State<SignupStep4Screen> createState() => _SignupStep4ScreenState();
}

class _SignupStep4ScreenState extends State<SignupStep4Screen> {
  final _address = TextEditingController();
  final _bio = TextEditingController();

  CraftsmanSignupDraft get _d => widget.draft;

  @override
  void initState() {
    super.initState();
    _address
      ..text = _d.workshopAddress
      ..addListener(() => setState(() => _d.workshopAddress = _address.text));
    _bio
      ..text = _d.bio
      ..addListener(() => setState(() => _d.bio = _bio.text));
  }

  @override
  void dispose() {
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SignupScaffold(
      step: 4,
      title: 'معلومات إضافية',
      onNext: _d.step4Valid
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignupReviewScreen(draft: _d)),
            )
          : null,
      children: [
        ...signupField(
          const FormLabel('عنوان الورشة', isRequired: true),
          AppTextField(
            hint: 'أدخل عنوان الورشة أو مكان العمل',
            controller: _address,
          ),
          top: 30,
        ),
        ...signupField(
          const FormLabel('موقع الورشة على الخريطة', isRequired: true),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 175,
                  width: double.infinity,
                  // TODO: خريطة حقيقية (google_maps_flutter بموافقة)؛ صورة ثابتة هلق.
                  child: Image.asset(
                    'assets/images/map_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _d.locationSet = true),
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
        ...signupField(
          const FormLabel('نبذة عن خبرتك ومهاراتك', isRequired: true),
          AppTextField(
            hint: 'نبذة مختصرة عن خدماتك وخبراتك...',
            controller: _bio,
            minLines: 4,
          ),
        ),
      ],
    );
  }
}
