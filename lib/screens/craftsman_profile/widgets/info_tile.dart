import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// سطر معلومة بخلفية رمادية: "الخبرة: 7 سنوات".
class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.body16,
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
