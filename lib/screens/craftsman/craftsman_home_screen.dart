import 'package:flutter/material.dart';
import '../../data/repositories/wallet_repository.dart';

import '../../data/craftsman_verification.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/backend/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';
import '../../data/craftsman_data.dart';
import '../../data/repositories/requests_repository.dart';
import '../messages/messages_screen.dart';
import 'offers/my_offers_tab.dart';
import 'profile/craftsman_profile_tab.dart';
import 'requests/craftsman_request_details_screen.dart';
import 'requests/craftsman_requests_tab.dart';
import 'widgets/craftsman_bottom_nav.dart';
import 'widgets/craftsman_cards.dart';
import 'widgets/craftsman_header.dart';
import 'widgets/craftsman_request_card.dart';

/// واجهة المهني: الرئيسية، الطلبات، عروضي، الرسائل، الملف الشخصي (تابات بشريط سفلي).
class CraftsmanHomeScreen extends StatefulWidget {
  const CraftsmanHomeScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<CraftsmanHomeScreen> createState() => _CraftsmanHomeScreenState();
}

class _CraftsmanHomeScreenState extends State<CraftsmanHomeScreen> {
  late int _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>();
    profile.load().then((_) {
      final st = profile.state.data?.idStatus;
      if (st == null) return;
      verificationNotifier.value = switch (st) {
        'approved' => VerificationStatus.verified,
        'rejected' => VerificationStatus.rejected,
        _ => VerificationStatus.pending,
      };
    });
    context.read<WalletCubit>().load();
    context.read<WalletTxCubit>().load(force: true);
  }

  void _select(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.pageAlt,
        bottomNavigationBar: CraftsmanBottomNav(
          currentIndex: _tab,
          onTap: _select,
        ),
        body: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(onSeeRequests: () => setState(() => _tab = 1)),
            const CraftsmanRequestsTab(),
            const MyOffersTab(),
            const MessagesScreen(craftsmanMode: true),
            const CraftsmanProfileTab(),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onSeeRequests});

  final VoidCallback onSeeRequests;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = AppTextStyles.body16.copyWith(color: colors.textSecondary);
    final real = AppConfig.mode == BackendMode.amplify;
    final jobs = context.select((CraftsmanJobsCubit c) => c.state.data);
    final points = context.select((WalletCubit c) => c.state.data);
    final num = AppTextStyles.title24Medium.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.1,
    );

    Widget card({
      required Widget child,
      Color? color,
      EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    }) => Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );

    Widget stat(String icon, String title, Widget value) => Expanded(
      child: card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(icon, width: 32, height: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            value,
          ],
        ),
      ),
    );

    Widget money(String v, {Color? color}) => Text.rich(
      TextSpan(
        style: num.copyWith(color: color),
        children: [
          TextSpan(text: '$v '),
          TextSpan(
            text: 'ل.س',
            style: AppTextStyles.body12.copyWith(
              fontSize: 13,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );

    Widget sectionHeader(String title, {VoidCallback? onAll}) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.title18Medium),
          const Spacer(),
          if (onAll != null)
            GestureDetector(
              onTap: onAll,
              child: Text(
                'عرض الكل',
                style: AppTextStyles.body16.copyWith(
                  color: colors.link,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.link,
                ),
              ),
            ),
        ],
      ),
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const CraftsmanHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            spacing: 12,
            children: [
              Row(
                spacing: 12,
                children: [
                  stat(
                    'assets/icons/cr_tasks.svg',
                    'المهام النشطة',
                    Text(real ? '${jobs?.tasks.length ?? 0}' : '2', style: num),
                  ),
                  stat(
                    'assets/icons/cr_tasks_done.svg',
                    'المهام المكتملة',
                    Text(real ? '${jobs?.done.length ?? 0}' : '13', style: num),
                  ),
                ],
              ),
              Row(
                spacing: 12,
                children: [
                  stat(
                    'assets/icons/cr_star_box.svg',
                    'التقييم',
                    Text(
                      real ? '—' : '5 / 4.3',
                      textDirection: TextDirection.ltr,
                      style: num,
                    ),
                  ),
                  stat(
                    'assets/icons/cr_cash.svg',
                    'إجمالي الأرباح',
                    Text(
                      real ? '—' : r'$1000',
                      textDirection: TextDirection.ltr,
                      style: num,
                    ),
                  ),
                ],
              ),
              card(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: SvgPicture.asset(
                        'assets/icons/cr_trend_up.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('أرباح الأسبوع الماضي', style: label),
                          const SizedBox(height: 4),
                          Text(
                            '16 آب 2026 — 22 آب 2026',
                            style: AppTextStyles.body12.copyWith(
                              fontSize: 13,
                              color: colors.textHint,
                            ),
                          ),
                          const SizedBox(height: 4),
                          money(real ? '—' : '100000'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const CraftsmanProgressCard(),
            ],
          ),
        ),
        sectionHeader('محفظتي'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 8,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/cr_wallet.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'محفظتي',
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textOnPrimaryMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        style: num.copyWith(color: colors.textOnPrimary),
                        children: [
                          TextSpan(text: real ? '${points ?? 0} ' : '100000 '),
                          TextSpan(
                            text: real ? 'نقطة' : 'ل.س',
                            style: AppTextStyles.body12.copyWith(
                              fontSize: 13,
                              color: colors.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: WalletBtn(
                            label: 'شحن الرصيد',
                            icon: 'assets/icons/cr_charge.svg',
                            filled: true,
                          ),
                        ),
                        Expanded(
                          child: WalletBtn(
                            label: 'سحب رصيد',
                            icon: 'assets/icons/cr_withdraw.svg',
                            filled: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              for (final t
                  in (context.select((WalletTxCubit c) => c.state.data) ?? const <WalletTx>[]).take(2))
                CraftsmanTxRow(
                  title: t.title,
                  value: t.value,
                  color: t.income ? colors.success : colors.error,
                  income: t.income,
                ),
              GestureDetector(
                onTap: () {}, // TODO: سجل المحفظة الكامل (ما في تصميم)
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'مشاهدة السجل كاملا',
                    style: AppTextStyles.title18Medium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primaryContent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        sectionHeader('آخر الطلبات الواردة', onAll: onSeeRequests),
        LoadView<CraftsmanJobsCubit, CraftsmanJobs>(
          compact: true,
          builder: (context, jobs) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 171,
                child: jobs.available.isEmpty
                    ? const Center(child: Text('لا توجد طلبات واردة حالياً'))
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          for (final r in jobs.available)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: 12,
                              ),
                              child: SizedBox(
                                width: 293,
                                child: _MiniRequest(request: r),
                              ),
                            ),
                        ],
                      ),
              ),
              sectionHeader('مهامي الحالية', onAll: onSeeRequests),
              if (jobs.tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('لا توجد مهام حالية')),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CraftsmanRequestCard(
                    request: jobs.tasks.first,
                    onDetails: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CraftsmanRequestDetailsScreen(
                          request: jobs.tasks.first,
                          offerSent: true,
                        ),
                      ),
                    ),
                    onPrimary: () {},
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MiniRequest extends StatelessWidget {
  const _MiniRequest({required this.request});

  final CraftsmanRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                request.date,
                style: AppTextStyles.body12.copyWith(
                  fontSize: 13,
                  color: colors.textHint,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colors.barrier,
              ),
              Text(
                request.urgency,
                style: AppTextStyles.body12.copyWith(
                  fontSize: 13,
                  color: colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            request.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title18Medium,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: _clip(request.description),
              children: [
                TextSpan(
                  text: ' قراءة المزيد',
                  style: TextStyle(
                    color: colors.link,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.link,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body16.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/cr_pin.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(colors.chipText, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                request.location,
                style: AppTextStyles.body16.copyWith(color: colors.chipText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// وصف مختصر (حد أقصى ~54 حرف عند حدّ كلمة) ليتّسع مع "قراءة المزيد" بسطرين.
String _clip(String text, {int max = 54}) {
  if (text.length <= max) return text;
  final cut = text.substring(0, max);
  final space = cut.lastIndexOf(' ');
  return (space > 20 ? cut.substring(0, space) : cut).trimRight();
}
