import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// سويتش التصميم: أحمر لما يكون مطفي وأخضر لما يكون شغّال.
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? context.colors.successLight : context.colors.error,
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: context.colors.background, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
