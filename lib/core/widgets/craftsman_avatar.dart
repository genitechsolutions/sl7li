import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// صورة الحرفي الدائرية (64 افتراضياً) مع شارة Pro بالزاوية.
class CraftsmanAvatar extends StatelessWidget {
  const CraftsmanAvatar({super.key, required this.image, required this.isPro, this.size = 64});

  final String? image;
  final bool isPro;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: context.colors.tag,
            backgroundImage: image == null
                ? null
                : image!.startsWith('http')
                ? NetworkImage(image!)
                : AssetImage(image!) as ImageProvider,
            child: image == null
                ? Icon(Icons.person, size: 36, color: context.colors.textOnPrimary)
                : null,
          ),
          if (isPro)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: context.colors.pro,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pro',
                  style: AppTextStyles.body12.copyWith(
                    color: context.colors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
