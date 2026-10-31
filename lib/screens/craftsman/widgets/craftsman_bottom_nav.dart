import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// الشريط السفلي للمهني: الرئيسية، الطلبات، عروضي، الرسائل، الإعدادات.
/// TODO: ما في تصميم للشريط بإطارات المهني (Figma)؛ هالترتيب مبني على أقسام الصفحة، والأيقونات من أيقونات الزبون.
class CraftsmanBottomNav extends StatelessWidget {
  const CraftsmanBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    ('الرئيسية', 'assets/icons/ic_nav_home.svg'),
    ('الطلبات', 'assets/icons/ic_nav_requests.svg'),
    ('عروضي', 'assets/icons/ic_tag_offer.svg'),
    ('الرسائل', 'assets/icons/ic_nav_messages.svg'),
    ('الإعدادات', 'assets/icons/ic_nav_settings.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        math.max(16, MediaQuery.paddingOf(context).bottom),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? colors.navActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        _items[i].$2,
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          i == currentIndex
                              ? colors.textPrimary
                              : colors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].$1,
                        style: AppTextStyles.body12.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: i == currentIndex
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
