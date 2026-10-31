import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../home/home_screen.dart';
import '../../notifications/notifications_screen.dart';

/// هيدر المهني الأبيض: صورته واسمه و"التبديل لوضع الزبون" وجرس الإشعارات وحالة التوفر.
class CraftsmanHeader extends StatelessWidget {
  const CraftsmanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/craftsman_avatar_self.jpg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رضا الكويفاتي', style: AppTextStyles.title18Medium),
                      GestureDetector(
                        // وضع الزبون: بيفتح الرئيسية العادية.
                        onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/cr_switch.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'التبديل لوضع الزبون',
                              style: AppTextStyles.body12.copyWith(
                                fontSize: 13,
                                color: colors.primaryContent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: 'assets/icons/ic_bell.svg',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('حالة التوفر', style: AppTextStyles.body16Medium),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.noticeWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(43),
                  ),
                  child: Text(
                    'يتطلب مسار 3+ لتغيير حالة التوفر',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
