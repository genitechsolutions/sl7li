import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// أزرار اختيار متلاصقة بخلفية رمادية، والمختار كحلي (تابات، مدى الإلحاح...).
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.height = 46,
    this.textStyle = AppTextStyles.body14,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final double height;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? context.colors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    options[i],
                    style: textStyle.copyWith(
                      color: i == selected
                          ? context.colors.textOnPrimary
                          : context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
