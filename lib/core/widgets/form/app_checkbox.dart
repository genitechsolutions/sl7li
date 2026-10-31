import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// مربع اختيار 20×20: فاضي بحدود رمادية، أو أزرق (info) بعلامة صح بيضا.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, this.size = 20});

  final bool value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value ? colors.verified : colors.fieldFill,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: value ? colors.verified : colors.border),
      ),
      alignment: Alignment.center,
      child: value
          ? Icon(Icons.check, size: size - 6, color: colors.textOnPrimary)
          : null,
    );
  }
}
