import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// زر مربع بحدود (52 افتراضياً)، فيه أيقونة SVG (بحث، رجوع، مشاركة...).
class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.icon, required this.onTap, this.size = 52});

  final String icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(size * 0.38),
          border: Border.all(color: context.colors.border),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          icon,
          width: size * 0.46,
          height: size * 0.46,
          colorFilter: ColorFilter.mode(context.colors.primaryContent, BlendMode.srcIn),
        ),
      ),
    );
  }
}
