import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// كرت "تشعر بالضياع؟" بآخر الصفحة الرئيسية.
class HelpCard extends StatelessWidget {
  const HelpCard({super.key, required this.onLearnMoreTap});

  final VoidCallback onLearnMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('تشعر بالضياع؟', style: AppTextStyles.title16),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onLearnMoreTap,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.accent,
                foregroundColor: context.colors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: AppTextStyles.title16,
              ),
              child: const Text('معرفة المزيد عن صلحلي'),
            ),
          ),
        ],
      ),
    );
  }
}
