import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/svg_theme_colors.dart';
import '../theme/app_text_styles.dart';

/// الشريط السفلي للتطبيق.
/// [currentIndex]: 0 الرئيسية، 1 طلباتي، 2 الرسائل، 3 الإعدادات.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          // التصميم يضع "الرئيسية" على اليسار، فنثبّت الترتيب LTR.
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(context, 0, 'assets/icons/ic_nav_home.svg', 'الرئيسية'),
              _item(context, 1, 'assets/icons/ic_nav_requests.svg', 'طلباتي'),
              GestureDetector(
                onTap: onAddTap,
                child: SvgPicture.asset(
                  'assets/icons/ic_add.svg',
                  width: 52,
                  height: 52,
                  colorMapper: SvgThemeColors.of(context),
                ),
              ),
              _item(context, 2, 'assets/icons/ic_nav_messages.svg', 'الرسائل'),
              _item(context, 3, 'assets/icons/ic_nav_settings.svg', 'الإعدادات'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, String icon, String label) {
    final isActive = index == currentIndex;
    final color = isActive ? context.colors.textPrimary : context.colors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? context.colors.navActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.body12.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
