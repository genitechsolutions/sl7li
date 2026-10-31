import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/craftsman_data.dart';
import '../home/home_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import 'offers/my_offers_tab.dart';
import 'requests/craftsman_requests_tab.dart';
import 'widgets/craftsman_bottom_nav.dart';
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

  void _select(int i) {
    // TODO: الرسائل والملف الشخصي للمهني (frames Messages / Profile) لسا ما انبنت بشريط المهني؛ مؤقتاً بنفتح شاشات الزبون.
    if (i == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MessagesScreen()),
      );
      return;
    }
    if (i == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      return;
    }
    setState(() => _tab = i);
  }

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
    final num = AppTextStyles.title24Medium.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.5,
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
            const SizedBox(height: 8),
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
        // الهيدر الأبيض
        Container(
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
                          Text(
                            'رضا الكويفاتي',
                            style: AppTextStyles.title18Medium,
                          ),
                          GestureDetector(
                            // وضع الزبون: بيفتح الرئيسية العادية.
                            onTap: () => Navigator.of(context)
                                .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
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
        ),
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
                    Text('2', style: num),
                  ),
                  stat(
                    'assets/icons/cr_tasks_done.svg',
                    'المهام المكتملة',
                    Text('13', style: num),
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
                      '5 / 4.3',
                      textDirection: TextDirection.ltr,
                      style: num,
                    ),
                  ),
                  stat(
                    'assets/icons/cr_cash.svg',
                    'إجمالي الأرباح',
                    Text(
                      r'$1000',
                      textDirection: TextDirection.ltr,
                      style: num,
                    ),
                  ),
                ],
              ),
              card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/cr_trend_up.svg',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 12),
                        Text('أرباح الأسبوع الماضي', style: label),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '16 آب 2026 — 22 آب 2026',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.textHint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    money('100000'),
                  ],
                ),
              ),
              _ProgressCard(),
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
                          const TextSpan(text: '100000 '),
                          TextSpan(
                            text: 'ل.س',
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
                          child: _WalletBtn(
                            label: 'شحن الرصيد',
                            icon: 'assets/icons/cr_charge.svg',
                            filled: true,
                          ),
                        ),
                        Expanded(
                          child: _WalletBtn(
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
              _TxRow(
                title: 'أرباح خدمة - تنظيف مكيفات',
                value: '+1000',
                color: colors.success,
                icon: 'assets/icons/cr_arrow_in.svg',
              ),
              _TxRow(
                title: 'سحب رصيد',
                value: '-1000',
                color: colors.error,
                icon: 'assets/icons/cr_arrow_out.svg',
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
        SizedBox(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final r in sampleAvailableRequests)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: SizedBox(width: 293, child: _MiniRequest(request: r)),
                ),
            ],
          ),
        ),
        sectionHeader('مهامي الحالية', onAll: onSeeRequests),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CraftsmanRequestCard(
            request: sampleCraftsmanTasks[0],
            onDetails: () {},
            onPrimary: () {},
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
          Text(
            request.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body16.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
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

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
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
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/cr_ring_a.svg', width: 68),
                    SvgPicture.asset('assets/icons/cr_ring_b.svg', width: 58),
                    SvgPicture.asset(
                      'assets/icons/cr_medal.svg',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مسار التطور',
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      'المسار الحالي: 1 - بداية الرحلة',
                      style: AppTextStyles.body16Medium,
                    ),
                    Text(
                      'المسار التالي: 2 - حرفي موثق',
                      style: AppTextStyles.body16.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.noticeInfo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخطوات الموصى بها لرفع المستوى',
                  style: AppTextStyles.body16.copyWith(color: colors.verified),
                ),
                const SizedBox(height: 8),
                for (final t in const [
                  'أضف صورة لبروفايلك (من الملف الشخصي)',
                  'أضف صور في معرض أعمالك (من الملف الشخصي)',
                  'ارفع صورة هويتك لتوثيق حسابك (من الملف الشخصي)',
                ])
                  Text(
                    '•  $t',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.verified,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBtn extends StatelessWidget {
  const _WalletBtn({
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final String icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: filled ? colors.primaryContent : colors.background,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.title18Medium.copyWith(
              fontWeight: FontWeight.w600,
              color: filled ? colors.primary : colors.primaryContent,
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              filled ? colors.primary : colors.primaryContent,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 32, height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body16),
                Text(
                  'منذ 3 أيام',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            textDirection: TextDirection.ltr,
            TextSpan(
              style: AppTextStyles.title24Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              children: [
                TextSpan(text: '$value '),
                TextSpan(
                  text: 'ل.س',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
