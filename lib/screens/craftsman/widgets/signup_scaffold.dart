import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_action_bar.dart';
import '../../new_request/widgets/request_step_header.dart';

/// هيكل خطوات تسجيل المهني: هيدر "دخول المهنيين" + شريط التقدم + عنوان بالنص + زر "التالي".
class SignupScaffold extends StatelessWidget {
  const SignupScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.children,
    required this.onNext,
    this.subtitle,
    this.nextLabel = 'التالي',
    this.stepSubtitle,
    this.bottomNote,
  });

  /// رقم الخطوة (1..4)، و5 = المراجعة (كل الخطوات خضرا).
  final int step;
  final String title;
  final String? subtitle;
  final String? stepSubtitle;
  final List<Widget> children;

  /// null = الزر معطّل.
  final VoidCallback? onNext;
  final String nextLabel;
  final Widget? bottomNote;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: nextLabel,
          onPressed: onNext,
          note: bottomNote,
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              RequestStepHeader(
                title: 'دخول المهنيين',
                step: step,
                totalSteps: 4,
                subtitle: stepSubtitle,
                actionLabel: 'العودة',
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 22),
              Center(child: Text(title, style: AppTextStyles.title24Bold)),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title20Medium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// عنوان حقل + الحقل بنفس مسافات خطوات الطلب (عنوان داخل 12، مسافة 8، وبعدها 20).
List<Widget> signupField(Widget label, Widget field, {double top = 20}) => [
  SizedBox(height: top),
  Padding(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
    child: label,
  ),
  const SizedBox(height: 8),
  field,
];
