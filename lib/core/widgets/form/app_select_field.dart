import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'field_icons.dart';

/// حقل اختيار (بيفتح قائمة) بخلفية رمادية وأيقونة بالطرف (سهم افتراضياً).
/// [onTap] = null يعني الحقل معطّل. [hasError] بيعطي حدود حمرا،
/// و[isActive] حدود كحلي (لما تكون القائمة مفتوحة).
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.hint,
    required this.onTap,
    this.value,
    this.trailing,
    this.hasError = false,
    this.isActive = false,
  });

  final String hint;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool hasError;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: context.colors.fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: hasError
              ? Border.all(color: context.colors.error)
              : isActive
              ? Border.all(
                  color: context.colors.primaryContent,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.body16.copyWith(
                  color: value != null ? context.colors.textPrimary : context.colors.textHint,
                ),
              ),
            ),
            trailing ?? FieldIcons.dropdown(enabled: onTap != null),
          ],
        ),
      ),
    );
  }
}
