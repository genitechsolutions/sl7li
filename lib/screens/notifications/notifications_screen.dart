import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/chat_data.dart';
import '../../data/dummy_data.dart';

/// الإشعارات: مهمة / اليوم / الأسبوع الماضي، مع "تمييز الكل كمقروءة".
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget section(
      String title,
      List<NotificationItem> items, {
      Widget? trailing,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(title, style: AppTextStyles.title18Medium),
              const Spacer(),
              ?trailing,
            ],
          ),
        ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: _NotificationCard(item: item),
          ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الإشعارات',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Text(
                        '4',
                        style: AppTextStyles.body16.copyWith(
                          color: colors.textOnPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // TODO: إعدادات الإشعارات / تحديث
                    AppIconButton(
                      icon: 'assets/icons/ic_refresh.svg',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: 'assets/icons/ic_settings.svg',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  section(
                    'إشعارات مهمة',
                    sampleImportantNotifications,
                    trailing: Text(
                      'تمييز الكل كمقروءة',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.link,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.link,
                      ),
                    ),
                  ),
                  section('اليوم', sampleTodayNotifications),
                  section('الأسبوع الماضي', sampleLastWeekNotifications),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, tint) = switch (item.kind) {
      NotificationKind.offer => (
        'assets/icons/ic_notif_offer.svg',
        colors.successLight,
      ),
      NotificationKind.completion => (
        'assets/icons/ic_notif_done.svg',
        colors.verified,
      ),
      NotificationKind.withdrawn => (
        'assets/icons/ic_notif_warning.svg',
        colors.warning,
      ),
      NotificationKind.message => (
        'assets/icons/ic_notif_message.svg',
        colors.verified,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(icon, width: 32, height: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.body16Medium,
                              ),
                            ),
                            Text(
                              item.time,
                              style: AppTextStyles.body12.copyWith(
                                fontSize: 13,
                                color: colors.textHint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.actionLabel != null) ...[
                const SizedBox(height: 12),
                // TODO: navigate to request details
                Center(
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.actionLabel!,
                      style: AppTextStyles.title18Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textOnAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.unread)
            PositionedDirectional(
              start: -4,
              top: -4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
