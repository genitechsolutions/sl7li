import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// حقل إدخال بخلفية رمادية. [minLines] > 1 يعطي حقل نص متعدد الأسطر.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.minLines = 1,
    this.keyboardType,
    this.suffixIcon,
    this.focusNode,
    this.showFocusBorder = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final bool showFocusBorder;

  @override
  Widget build(BuildContext context) {
    final multiline = minLines > 1;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: multiline ? null : 1,
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      cursorColor: context.colors.primaryContent,
      style: AppTextStyles.body16,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body16.copyWith(color: context.colors.textHint),
        filled: true,
        fillColor: context.colors.fieldFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: multiline ? 17 : 15),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 52),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: showFocusBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.colors.primaryContent,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              )
            : null,
      ),
    );
  }
}
