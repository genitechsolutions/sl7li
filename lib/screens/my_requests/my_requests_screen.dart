import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/svg_theme_colors.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/dummy_data.dart';
import '../../data/my_request.dart';
import '../new_request/new_request_screen.dart';
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
  // (التسمية، العدد) — الفلتر الافتراضي "النشطة".
  static const _filters = [
    ('الكل', 7),
    ('النشطة', 3),
    ('مكتملة', 2),
    ('ملغاة', 2),
  ];

  List<MyRequest> get _visible => switch (_filter) {
    0 => [
      ...sampleActiveRequests,
      ...sampleDoneRequests,
      ...sampleCanceledRequests,
    ],
    1 => sampleActiveRequests,
    2 => sampleDoneRequests,
    _ => sampleCanceledRequests,
  };

  int _filter = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        // الصفحة بالخلفية الرمادية والكروت فاتحة.
        backgroundColor: colors.surface,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 1,
          // TODO: navigate to messages / settings tabs
          onTap: (index) {
            if (index == 0) Navigator.of(context).pop();
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
                    // TODO: navigate to notifications
                    AppIconButton(
                      icon: 'assets/icons/ic_bell.svg',
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
                          '7 طلبات',
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
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _FilterChip(
                        label: '${_filters[i].$1} (${_filters[i].$2})',
                        selected: i == _filter,
                        onTap: () => setState(() => _filter = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final request in _visible)
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
