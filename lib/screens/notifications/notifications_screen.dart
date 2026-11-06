import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';
import '../../cubits/unread_count_cubit.dart';
import '../../data/repositories/notifications_repository.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/chat_data.dart';
import '../../data/dummy_data.dart';
import '../my_requests/request_details_screen.dart';
import '../settings/notification_settings_screen.dart';

/// الإشعارات: مهمة / اليوم / الأسبوع الماضي، مع "تمييز الكل كمقروءة".
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = context.select(
      (NotificationsCubit c) => c.state.data?.unread ?? 0,
    );

    Widget section(
      String title,
      List<NotificationItem> items, {
      Widget? trailing,
      double top = 28,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, top, 20, 12),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _open(context, item),
              child: _NotificationCard(item: item),
            ),
          ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.pageAlt,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.cardAlt,
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
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Text(
                          '$unread',
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textOnPrimary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    AppIconButton(
                      icon: 'assets/icons/ic_refresh.svg',
                      onTap: () => context.read<NotificationsCubit>().load(force: true),
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: 'assets/icons/ic_settings.svg',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LoadView<NotificationsCubit, NotificationsData>(
                emptyText: 'لا توجد إشعارات',
                isEmpty: (d) =>
                    d.important.isEmpty &&
                    d.today.isEmpty &&
                    d.lastWeek.isEmpty,
                builder: (context, data) => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (data.important.isNotEmpty)
                      section(
                        'إشعارات مهمة',
                        data.important,
                        top: 20,
                        trailing: GestureDetector(
                          onTap: () {
                            context.read<UnreadCountCubit>().set(0);
                            context.read<NotificationsCubit>().markAllRead();
                          },
                          child: Text(
                            'تمييز الكل كمقروءة',
                            style: AppTextStyles.body12.copyWith(
                              fontSize: 13,
                              color: colors.link,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.link,
                            ),
                          ),
                        ),
                      ),
                    if (data.today.isNotEmpty)
                      section(
                        'اليوم',
                        data.today,
                        top: data.important.isEmpty ? 20 : 28,
                      ),
                    if (data.lastWeek.isNotEmpty)
                      section('الأسبوع الماضي', data.lastWeek),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نقر الإشعار: إذا مرتبط بطلب بنفتح تفاصيله (تاب العروض إذا إشعار عرض).
Future<void> _open(BuildContext context, NotificationItem item) async {
  if (item.unread) {
    context.read<UnreadCountCubit>().decrement();
    unawaited(context.read<NotificationsCubit>().markRead(item));
  }
  final id = item.entityId;
  if (item.entityType != 'job' || id == null) return;
  final cubit = context.read<MyRequestsCubit>();
  await cubit.load();
  if (!context.mounted) return;
  final match = (cubit.state.data ?? const []).where((r) => r.id == id);
  if (match.isEmpty) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RequestDetailsScreen(
        request: match.first,
        initialTab: item.kind == NotificationKind.offer ? 1 : 0,
      ),
    ),
  );
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
        colors.noticeSuccess,
      ),
      NotificationKind.completion => (
        'assets/icons/ic_notif_done.svg',
        colors.noticeInfo,
      ),
      NotificationKind.withdrawn => (
        'assets/icons/ic_notif_warning.svg',
        colors.noticeWarning,
      ),
      NotificationKind.message => (
        'assets/icons/ic_notif_message.svg',
        colors.noticeInfo,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
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
                                style: AppTextStyles.body16Medium.copyWith(
                                  height: 1.5,
                                ),
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
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestDetailsScreen(
                          request: sampleActiveRequests[2],
                          completionPending: true,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.accentButton,
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
