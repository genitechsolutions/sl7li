import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';

import '../../core/theme/app_colors.dart';
import '../notifications/notifications_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/svg_theme_colors.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/my_request.dart';
import '../new_request/new_request_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import 'dialogs/request_dialogs.dart';
import 'request_details_screen.dart';
import 'widgets/request_card.dart';

/// "طلباتي" — قائمة طلبات الزبون مع فلتر الحالة (تاب من الشريط السفلي).
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  // تسميات الفلتر؛ الأعداد بتنحسب من الطلبات المحمّلة. الافتراضي "النشطة".
  static const _labels = ['الكل', 'النشطة', 'مكتملة', 'ملغاة'];

  static const _statusOfFilter = {
    1: RequestStatus.active,
    2: RequestStatus.done,
    3: RequestStatus.canceled,
  };

  List<MyRequest> _visibleOf(List<MyRequest> all, int filter) {
    final status = _statusOfFilter[filter];
    return status == null ? all : all.where((r) => r.status == status).toList();
  }

  int _filter = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        // الصفحة بالخلفية الرمادية والكروت فاتحة.
        backgroundColor: colors.pageAlt,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) Navigator.of(context).pop();
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagesScreen()),
              );
            }
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }
          },
          onAddTap: () => Navigator.push(context, NewRequestScreen.route()),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.background,
              padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      height: 52,
                      colorMapper: SvgThemeColors.of(context),
                      theme: SvgTheme(currentColor: colors.primaryContent),
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
              child: LoadView<MyRequestsCubit, List<MyRequest>>(
                builder: (context, all) => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'طلباتي',
                            style: AppTextStyles.title24Medium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${all.length} طلبات',
                            style: AppTextStyles.body16.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _labels.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _FilterChip(
                          label: '${_labels[i]} (${_visibleOf(all, i).length})',
                          selected: i == _filter,
                          onTap: () => setState(() => _filter = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_visibleOf(all, _filter).isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Center(child: Text('لا توجد طلبات')),
                      ),
                    for (final request in _visibleOf(all, _filter))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        // TODO: navigate to request details / update status
                        // TODO: navigate to rating / reorder / update status
                        child: RequestCard(
                          request: request,
                          onDetails: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestDetailsScreen(request: request),
                            ),
                          ),
                          onUpdate: () => runUpdateStatusFlow(context),
                          onMore: () => runUpdateStatusFlow(context),
                          onRate: () => showRatingDialog(context),
                          onReorder: () {},
                        ),
                      ),
                    const SizedBox(height: 8),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(43),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? colors.textOnPrimary : colors.primaryContent,
          ),
        ),
      ),
    );
  }
}
