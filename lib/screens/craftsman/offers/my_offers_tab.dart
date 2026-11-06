import '../../../core/widgets/coming_soon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/widgets/notification_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/app_image.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../data/repositories/my_offers_repository.dart';
import '../../notifications/notifications_screen.dart';
import 'create_offer_screen.dart';
import 'offer_actions.dart';

/// تاب "عروضي" (عروض ترويجية للمهني): حالياً الحالة الفاضية (الكل / قيد المراجعة / نشط).
class MyOffersTab extends StatefulWidget {
  const MyOffersTab({super.key});

  @override
  State<MyOffersTab> createState() => _MyOffersTabState();
}

class _MyOffersTabState extends State<MyOffersTab> {
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    context.read<MyOffersCubit>().load();
  }

  Widget _card(MyOffer o) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          AppImage(o.image, width: 96, height: 96),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title18Medium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      o.location,
                      o.discount,
                    ].where((e) => e.isNotEmpty).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body14.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    o.statusLabel,
                    style: AppTextStyles.body12Medium.copyWith(
                      color: o.active ? colors.success : colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'خيارات العرض',
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              onPressed: () => showOfferMenu(ctx, o),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final all =
        context.select((MyOffersCubit c) => c.state.data) ?? const <MyOffer>[];
    final pending = all.where((o) => o.statusLabel == 'قيد المراجعة').toList();
    final active = all.where((o) => o.active).toList();
    final filters = [
      'الكل (${all.length})',
      'قيد المراجعة (${pending.length})',
      'نشط (${active.length})',
    ];
    final shown = [all, pending, active][_filter];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.background,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Text(
                  'عروضي',
                  style: AppTextStyles.title24Medium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                NotificationBadge(child: AppIconButton(
                  icon: 'assets/icons/ic_bell.svg',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _filter = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == _filter ? colors.primary : colors.background,
                  borderRadius: BorderRadius.circular(43),
                  border: Border.all(
                    color: i == _filter ? colors.primary : colors.border,
                  ),
                ),
                child: Text(
                  filters[i],
                  style: AppTextStyles.title18Medium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: i == _filter
                        ? colors.textOnPrimary
                        : colors.primaryContent,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: shown.isNotEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    for (final o in shown) _card(o),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateOfferScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: colors.textOnPrimary),
                            const SizedBox(width: 12),
                            Text(
                              'إنشاء عرض جديد',
                              style: AppTextStyles.title18Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/cr_empty_offers.svg',
                        width: 178,
                        height: 178,
                      ),
                    ),
                    const SizedBox(height: 42),
                    Center(
                      child: Text(
                        'لم تقم بإنشاء أي عروض ترويجية',
                        style: AppTextStyles.title22Bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قم بإنشاء عروض خاصة للترويج لصفحتك وزيادة مبيعات خدمتك',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body18.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateOfferScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: colors.textOnPrimary),
                            const SizedBox(width: 12),
                            Text(
                              'إنشاء عرض جديد',
                              style: AppTextStyles.title18Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 33),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.cardAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'لا تعرف كيف تنشر عروضك؟',
                            style: AppTextStyles.title18Medium,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: showComingSoon,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.accentButton,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'مشاهدة فيديو توضيحي',
                                style: AppTextStyles.title18Medium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.textOnAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
