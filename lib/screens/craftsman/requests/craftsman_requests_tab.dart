import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../data/craftsman_data.dart';
import '../../notifications/notifications_screen.dart';
import '../widgets/craftsman_request_card.dart';

/// تاب "الطلبات" عند المهني: "مهامي الحالية" و"الطلبات المتاحة" مع فلتر بحسب الحالة/الخدمة.
class CraftsmanRequestsTab extends StatefulWidget {
  const CraftsmanRequestsTab({super.key});

  @override
  State<CraftsmanRequestsTab> createState() => _CraftsmanRequestsTabState();
}

class _CraftsmanRequestsTabState extends State<CraftsmanRequestsTab> {
  /// 0 مهامي الحالية، 1 الطلبات المتاحة.
  int _mode = 0;
  int _filter = 0;

  static const _taskFilters = [
    'الكل (9)',
    'عرض مرسل (3)',
    'تم الاتفاق (2)',
    'قيد التنفيذ (2)',
    'مكتملة (2)',
  ];
  static const _availableFilters = [
    'الكل (7)',
    'خدمات إصلاحات الكهربائية (3)',
    'التكييف (2)',
    'السباكة (2)',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = _mode == 0 ? _taskFilters : _availableFilters;
    final items = _mode == 0 ? sampleCraftsmanTasks : sampleAvailableRequests;

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
                  'الطلبات',
                  style: AppTextStyles.title24Medium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
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
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.cardAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      for (final (i, label) in const [
                        'مهامي الحالية (9)',
                        'الطلبات المتاحة (7)',
                      ].indexed)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _mode = i;
                              _filter = 0;
                            }),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == _mode
                                    ? colors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                style: AppTextStyles.body16.copyWith(
                                  color: i == _mode
                                      ? colors.textOnPrimary
                                      : colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                        color: i == _filter
                            ? colors.primary
                            : colors.background,
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
              const SizedBox(height: 16),
              for (final r in items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  // TODO: تفاصيل الطلب / تقديم عرض / تحديث الحالة (frames Sending offer / Request details)
                  child: CraftsmanRequestCard(
                    request: r,
                    onDetails: () {},
                    onPrimary: () {},
                    onMore: () {},
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
