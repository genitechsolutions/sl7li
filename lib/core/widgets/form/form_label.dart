import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// عنوان حقل بالفورم: "وصف المشكلة *" أو "التخصص الفرعي (اختياري)".
class FormLabel extends StatelessWidget {
  const FormLabel(
    this.text, {
    super.key,
    this.isRequired = false,
    this.note,
    this.starAfterNote = false,
    this.noteSize = 12,
  });

  final String text;
  final bool isRequired;

  /// نص صغير رمادي بعد العنوان، مثل "(اختياري)".
  final String? note;

  /// النجمة بعد الملاحظة: "رقم الواتساب (بدون صفر) *" (صفحة تسجيل الدخول).
  final bool starAfterNote;

  /// حجم خط الملاحظة (12 افتراضياً، 14 بصفحة تسجيل الدخول).
  final double noteSize;

  @override
  Widget build(BuildContext context) {
    final star = TextSpan(
      text: ' *',
      style: TextStyle(color: context.colors.error),
    );

    return Text.rich(
      TextSpan(
        style: AppTextStyles.body16Medium,
        children: [
          TextSpan(text: text),
          if (isRequired && !starAfterNote) star,
          if (note != null)
            TextSpan(
              text: ' $note',
              style: AppTextStyles.body12.copyWith(
                color: context.colors.textSecondary,
                fontSize: noteSize,
              ),
            ),
          if (isRequired && starAfterNote) star,
        ],
      ),
    );
  }
}
