import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/craftsman_data.dart';
import '../widgets/craftsman_header.dart';
import '../widgets/craftsman_request_card.dart';
import 'craftsman_request_details_screen.dart';
import 'offer_dialogs.dart';
import 'task_dialogs.dart';

/// تاب "الطلبات" عند المهني: "مهامي الحالية" / "الطلبات المتاحة" مع فلتر بحسب الحالة.
class CraftsmanRequestsTab extends StatefulWidget {
  const CraftsmanRequestsTab({super.key, this.empty = false});

  /// للعرض بالحالة الفاضية (frames Empty status).
  final bool empty;

  @override
  State<CraftsmanRequestsTab> createState() => _CraftsmanRequestsTabState();
}

class _CraftsmanRequestsTabState extends State<CraftsmanRequestsTab> {
  /// 0 مهامي الحالية، 1 الطلبات المتاحة.
  int _mode = 0;
  int _filter = 0;

  static const _taskFilters = [
    'الكل',
    'عرض مرسل',
    'تم الاتفاق',
    'قيد التنفيذ',
    'مكتمل',
    'ملغاة',
  ];
  static const _availableFilters = [
    'الكل',
    'خدمات إصلاحات الكهربائية',
    'التكييف',
    'السباكة',
  ];

  List<CraftsmanRequest> get _items {
    if (widget.empty) {
      return const [];
    }
    if (_mode == 1) {
      return _filter == 0
          ? sampleAvailableRequests
          : sampleAvailableRequests.take(1).toList();
    }
    final all = [
      ...sampleCraftsmanTasks,
      ...sampleDoneTasks,
      ...sampleCancelledTasks,
    ];
    return switch (_filter) {
      0 => all,
      1 =>
        all
            .where((r) => r.state == CraftsmanRequestState.task && r.stage == 0)
            .toList(),
      2 =>
        all
            .where((r) => r.state == CraftsmanRequestState.task && r.stage == 1)
            .toList(),
      3 =>
        all
            .where((r) => r.state == CraftsmanRequestState.task && r.stage == 2)
            .toList(),
      4 => all.where((r) => r.state == CraftsmanRequestState.done).toList(),
      _ =>
        all
            .where(
              (r) =>
                  r.state == CraftsmanRequestState.cancelled ||
                  r.state == CraftsmanRequestState.withdrawn,
            )
            .toList(),
    };
  }

  void _open(CraftsmanRequest r) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CraftsmanRequestDetailsScreen(
        request: r,
        offerSent: r.state != CraftsmanRequestState.open,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = _mode == 0 ? _taskFilters : _availableFilters;
    final items = _items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CraftsmanHeader(),
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
                      for (final (i, label) in [
                        'مهامي الحالية (${widget.empty ? 0 : 9})',
                        'الطلبات المتاحة (${widget.empty ? 0 : 7})',
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
                        '${filters[i]} (${widget.empty ? 0 : _countFor(i)})',
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
              if (items.isEmpty)
                _Empty(
                  mode: _mode,
                  onSeeAvailable: () => setState(() => _mode = 1),
                )
              else ...[
                const SizedBox(height: 16),
                for (final r in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: CraftsmanRequestCard(
                      request: r,
                      onDetails: () => _open(r),
                      onPrimary: () => switch (r.state) {
                        CraftsmanRequestState.task => showTaskStatusDialog(
                          context,
                        ),
                        _ => showSendOfferFlow(context, requestTitle: r.title),
                      },
                      onMore: showRequestMoreMenu,
                    ),
                  ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  int _countFor(int i) {
    final saved = _filter;
    _filter = i;
    final n = _items.length;
    _filter = saved;
    return n;
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.mode, required this.onSeeAvailable});

  final int mode;
  final VoidCallback onSeeAvailable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/cr_empty_offers.svg',
            width: 178,
            height: 178,
          ),
          const SizedBox(height: 24),
          Text(
            mode == 0 ? 'لا توجد مهام حالية' : 'لا توجد طلبات متاحة حالياً',
            style: AppTextStyles.title22Bold,
          ),
          const SizedBox(height: 8),
          Text(
            mode == 0
                ? 'ستظهر هنا الطلبات التي قدمت لها عروضا لمتابعتها'
                : 'ستجد هنا الطلبات المناسبة لخبراتك وموقع عملك حين توفرها',
            textAlign: TextAlign.center,
            style: AppTextStyles.body16.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (mode == 0) ...[
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onSeeAvailable,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'رؤية الطلبات المتاحة',
                  style: AppTextStyles.title18Medium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
