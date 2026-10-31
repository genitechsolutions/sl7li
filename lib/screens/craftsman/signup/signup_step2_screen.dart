import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form/app_checkbox.dart';
import '../../../core/widgets/form/app_select_field.dart';
import '../../../core/widgets/form/field_popup.dart';
import '../../../core/widgets/form/form_label.dart';
import '../../../data/craftsman_signup.dart';
import '../widgets/signup_scaffold.dart';
import 'signup_step3_screen.dart';

/// تسجيل المهني 2/4: الخدمات (حتى 3) والتخصصات لكل خدمة.
class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({
    super.key,
    required this.draft,
    this.editing = false,
  });

  /// تعديل من الملف الشخصي: بيرجع بدل ما يكمّل للخطوة 3.
  final bool editing;

  final CraftsmanSignupDraft draft;

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  bool _open = false;

  /// الخدمة المفتوحة تخصصاتها حالياً.
  String? _activeService;

  CraftsmanSignupDraft get _d => widget.draft;

  void _toggleService(String name) => setState(() {
    if (_d.services.contains(name)) {
      _d.services.remove(name);
      _d.specialties.remove(name);
      if (_activeService == name) {
        _activeService = _d.services.isEmpty ? null : _d.services.first;
      }
    } else if (_d.services.length < craftsmanMaxServices) {
      _d.services.add(name);
      _activeService = name;
    }
  });

  void _toggleSpecialty(String service, String value) => setState(() {
    final set = _d.specialties.putIfAbsent(service, () => {});
    set.contains(value) ? set.remove(value) : set.add(value);
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active =
        _activeService ?? (_d.services.isEmpty ? null : _d.services.first);
    final options = active == null
        ? const <String>[]
        : craftsmanSpecialtiesByService[active] ?? const [];
    final chosen = active == null ? <String>{} : (_d.specialties[active] ?? {});

    return SignupScaffold(
      step: 2,
      title: 'الخدمات والتخصصات',
      subtitle: 'اختر الخدمات التي تقدمها وحدد التخصصات',
      nextLabel: widget.editing ? 'حفظ التغييرات' : 'التالي',
      onNext: _d.step2Valid
          ? widget.editing
                ? () => Navigator.pop(context)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignupStep3Screen(draft: _d),
                    ),
                  )
          : null,
      children: [
        ...signupField(
          Row(
            children: [
              const FormLabel('حدد الخدمات التي تقدمها', isRequired: true),
              const Spacer(),
              Text(
                '${_d.services.length}/$craftsmanMaxServices',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body12.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          FieldPopup(
            isOpen: _open,
            onDismiss: () => setState(() => _open = false),
            panel: FieldPopupPanel(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (name, image) in craftsmanServiceOptions)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggleService(name),
                        child: Container(
                          height: 47,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 12,
                          ),
                          child: Row(
                            children: [
                              Image.asset(image, width: 28, height: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(name, style: AppTextStyles.body16),
                              ),
                              AppCheckbox(value: _d.services.contains(name)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            child: AppSelectField(
              hint: 'حدد الخدمات التي تقدمها',
              value: _d.services.isEmpty ? null : _d.services.join(' ,'),
              isActive: _open,
              onTap: () => setState(() => _open = !_open),
            ),
          ),
          top: 24,
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          child: Text(
            'حدد تخصصاتك في كل خدمة',
            style: AppTextStyles.body16Medium,
          ),
        ),
        if (_d.services.isEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'لم تحدد أي خدمات بعد\nستظهر هنا الخدمات التي اخترتها',
              textAlign: TextAlign.center,
              style: AppTextStyles.title20Medium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _d.services)
                GestureDetector(
                  onTap: () => setState(() => _activeService = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: s == active ? colors.primary : colors.background,
                      borderRadius: BorderRadius.circular(43),
                      border: Border.all(
                        color: s == active ? colors.primary : colors.border,
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTextStyles.title18Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: s == active
                            ? colors.textOnPrimary
                            : colors.primaryContent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            child: Text(
              'اختر تخصصاتك ضمن $active',
              style: AppTextStyles.body16Medium,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'اختر واحدا أو أكثر',
                  style: AppTextStyles.body12.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      setState(() => _d.specialties[active!] = {...options}),
                  child: Text(
                    'تحديد الكل',
                    style: AppTextStyles.body12.copyWith(
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
          for (final o in options)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleSpecialty(active!, o),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    AppCheckbox(value: chosen.contains(o)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(o, style: AppTextStyles.title18)),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
