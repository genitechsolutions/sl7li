import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// حقل رقم الواتساب: الرقم، ورمز الدولة (+963) مع العلم.
/// [inline]: شكل التصميم (تسجيل الدخول وطلب الخدمة) — الرقم لاصق برمز الدولة (عاليسار).
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    this.controller,
    required this.onCountryTap,
    this.inline = false,
    this.restrictInput = false,
    this.hasError = false,
  });

  /// رمز الدولة الوحيد هلق.
  static const countryCode = '+963';

  /// طول الرقم بدون رمز الدولة وبدون صفر.
  static const length = 9;

  /// الرقم صحيح إذا كان [length] أرقام بالضبط.
  static bool isValid(String number) => RegExp('^[1-9][0-9]{${length - 1}}\$').hasMatch(number);

  /// "993930716" → "+963 993 930 716" (بيشيل الصفر بالأول إذا انكتب).
  static String format(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');
    final groups = [
      for (var i = 0; i < digits.length; i += 3)
        digits.substring(i, (i + 3).clamp(0, digits.length)),
    ];
    return [countryCode, ...groups].join(' ');
  }

  final TextEditingController? controller;
  final VoidCallback onCountryTap;
  final bool inline;

  /// أرقام بس، أقصى شي [length]، وبدون صفر بالأول (صفحة تسجيل الدخول بس).
  final bool restrictInput;

  /// حدود حمرا (رقم غير صحيح).
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: EdgeInsetsDirectional.fromSTEB(20, 0, inline ? 12 : 20, 0),
      decoration: BoxDecoration(
        color: context.colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: hasError ? Border.all(color: context.colors.error) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: restrictInput
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.deny(RegExp('^0+')),
                      LengthLimitingTextInputFormatter(length),
                    ]
                  : null,
              // الرقم بينكتب من اليسار لليمين، بس بيضل على يمين الحقل متل التصميم
              // (أو جنب رمز الدولة بشكل [inline]).
              textDirection: TextDirection.ltr,
              textAlign: inline ? TextAlign.left : TextAlign.right,
              cursorColor: context.colors.primaryContent,
              style: AppTextStyles.body16,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: inline ? 'XXX XXX XXX' : '993 930 716',
                hintStyle: AppTextStyles.body16.copyWith(color: context.colors.textHint),
              ),
            ),
          ),
          if (inline) const SizedBox(width: 13),
          Container(width: 1, height: 28, color: context.colors.primary),
          SizedBox(width: inline ? 9 : 10),
          GestureDetector(
            onTap: onCountryTap,
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: inline ? 4 : 6),
                Text(countryCode, textDirection: TextDirection.ltr, style: AppTextStyles.body16),
                SizedBox(width: inline ? 8 : 6),
                const _SyrianFlag(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyrianFlag extends StatelessWidget {
  const _SyrianFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 21,
        height: 14,
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFF016B2C))),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      const Icon(Icons.star, size: 5, color: Color(0xFFCE1126)),
                  ],
                ),
              ),
            ),
            Expanded(child: Container(color: const Color(0xFF2D2B2C))),
          ],
        ),
      ),
    );
  }
}
