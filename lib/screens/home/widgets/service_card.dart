import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// كرت خدمة بشبكة "الخدمات الشائعة". مرّر [image] أو [icon].
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.label, required this.onTap, this.image, this.icon});

  final String label;
  final VoidCallback onTap;
  final String? image;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: image != null
                  ? Image.asset(image!)
                  : Icon(icon, size: 32, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.body12),
          ],
        ),
      ),
    );
  }
}
