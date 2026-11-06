import 'package:flutter/material.dart';

import '../../../core/widgets/notification_badge.dart';
import '../../../data/repositories/wallet_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../core/widgets/app_image.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../cubits/professional_profile_cubit.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../data/craftsman_verification.dart';
import '../../craftsman_profile/craftsman_profile_loader.dart';
import '../../home/home_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../../settings/settings_screen.dart';
import '../wallet_actions.dart';
import '../widgets/craftsman_cards.dart';
import 'edit_profile_screen.dart';
import 'portfolio_section.dart';
import 'verification_dialog.dart';

/// تاب "الملف الشخصي" للمهني: بطاقة التعريف، التوثيق، المسار، معرض الأعمال، المحفظة، إدارة الحساب.
class CraftsmanProfileTab extends StatefulWidget {
  const CraftsmanProfileTab({super.key});

  @override
  State<CraftsmanProfileTab> createState() => _CraftsmanProfileTabState();
}

class _CraftsmanProfileTabState extends State<CraftsmanProfileTab> {
  @override
  void initState() {
    super.initState();
    context.read<ProfessionalProfileCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );

    final pro = context.select((ProfessionalProfileCubit c) => c.state.data);

    return ValueListenableBuilder<VerificationStatus>(
      valueListenable: verificationNotifier,
      builder: (context, status, _) => ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 107,
            decoration: BoxDecoration(color: colors.primary),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                OverflowBox(
                  maxWidth: 624,
                  maxHeight: 558,
                  alignment: const Alignment(0.55, 0.9),
                  child: SvgPicture.asset(
                    'assets/icons/settings_header_pattern.svg',
                    width: 624,
                    height: 558,
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        AppIconButton(
                          icon: 'assets/icons/ic_settings.svg',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SettingsScreen(craftsmanMode: true),
                            ),
                          ),
                        ),
                        const Spacer(),
                        NotificationBadge(child: AppIconButton(
                          icon: 'assets/icons/ic_set_bell_dark.svg',
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              spacing: 12,
              children: [
                card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (pro?.imageUrl != null)
                            ClipOval(
                              child: AppImage(
                                pro!.imageUrl!,
                                width: 64,
                                height: 64,
                              ),
                            )
                          else
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: colors.tag,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.person_outline,
                                size: 32,
                                color: colors.primary,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    (pro?.businessName.isNotEmpty ?? false)
                                        ? pro!.businessName
                                        : context.select(
                                            (ProfileCubit c) =>
                                                c.state.data?.name ?? '',
                                          ),
                                    style: AppTextStyles.title18Medium,
                                  ),
                                  if (status ==
                                      VerificationStatus.verified) ...[
                                    const SizedBox(width: 6),
                                    SvgPicture.asset(
                                      'assets/icons/ic_verified.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                (pro?.headline.isNotEmpty ?? false)
                                    ? pro!.headline
                                    : 'تكييف وتبريد',
                                style: AppTextStyles.body16.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const EditCraftsmanProfileScreen(),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/ic_edit_badge.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                colors.primaryContent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_star.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              colors.star,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pro == null
                                ? '(0) 0.0'
                                : '(${pro.reviewCount}) ${(pro.rating ?? 0).toStringAsFixed(1)}',
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.body14.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: colors.barrier,
                          ),
                          GestureDetector(
                            onTap: () => openCraftsmanProfile(
                              context,
                              professionalId: context.read<AuthCubit>().state.session?.userId,
                              selfView: true,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'مشاهدة صفحتي العامة',
                                  style: AppTextStyles.body14.copyWith(
                                    color: colors.link,
                                    decoration: TextDecoration.underline,
                                    decorationColor: colors.link,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: colors.link,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/cr_switch.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  colors.primaryContent,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'التبديل لوضع الزبون',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title18Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.primaryContent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _VerificationCard(status: status),
                const CraftsmanProgressCard(),
              ],
            ),
          ),
          const CraftsmanPortfolioSection(),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('محفظتي', style: AppTextStyles.title18Medium),
            ),
          ),
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
                      Text(
                        'محفظتي',
                        style: AppTextStyles.body16.copyWith(
                          color: colors.textOnPrimaryMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '100000 ل.س',
                        style: AppTextStyles.title24Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: WalletBtn(
                              label: 'شحن الرصيد',
                              icon: 'assets/icons/cr_charge.svg',
                              filled: true,
                              onTap: () => showTopUpDialog(context),
                            ),
                          ),
                          Expanded(
                            child: WalletBtn(
                              label: 'سحب رصيد',
                              icon: 'assets/icons/cr_withdraw.svg',
                              filled: false,
                              onTap: () => showWithdrawDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                for (final t
                    in (context.select((WalletTxCubit c) => c.state.data) ??
                            const <WalletTx>[])
                        .take(2))
                  CraftsmanTxRow(
                    title: t.title,
                    value: t.value,
                    color: t.income ? colors.success : colors.error,
                    income: t.income,
                    ago: walletTxAgo(t.createdAt, DateTime.now()),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('إدارة الحساب', style: AppTextStyles.title18Medium),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              spacing: 8,
              children: [
                _AccountBtn(
                  label: 'تسجيل الخروج',
                  icon: 'assets/icons/ic_set_logout.svg',
                  filled: false,
                  onTap: () => confirmLogout(context),
                ),
                _AccountBtn(
                  label: 'حذف الحساب',
                  icon: 'assets/icons/ic_set_trash.svg',
                  filled: true,
                  onTap: () => confirmDeleteAccount(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AccountBtn extends StatelessWidget {
  const _AccountBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = filled ? colors.textOnPrimary : colors.primaryContent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled ? colors.destructive : colors.background,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.title18Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة "توثيق الحساب": حسب [status] (غير موثق / جاري التحقق / مرفوض / موثق).
class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (title, badge, badgeColor, body) = switch (status) {
      VerificationStatus.none => (
        'توثيق الحساب',
        'غير موثق بعد',
        colors.warning,
        'توثيق حسابك يزيد نسبة ظهوره للمستخدمين',
      ),
      VerificationStatus.pending => (
        'توثيق الحساب',
        'جاري التحقق',
        colors.success,
        'جاري التحقق من صورة هويتك, سيتم اشعارك عند توثيق حسابك',
      ),
      VerificationStatus.rejected => (
        'توثيق الحساب',
        'تم رفض التوثيق',
        colors.error,
        'تم رفض الصورة التي قمت برفعها, حاول مجددا',
      ),
      VerificationStatus.verified => ('تم توثيق حسابك', '', colors.success, ''),
    };
    final showButton =
        status == VerificationStatus.none ||
        status == VerificationStatus.rejected;

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
              Icon(Icons.badge_outlined, color: colors.textPrimary),
              const SizedBox(width: 12),
              Flexible(child: Text(title, style: AppTextStyles.body16Medium)),
              const Spacer(),
              if (badge.isNotEmpty)
                Text(
                  badge,
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: badgeColor,
                  ),
                ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTextStyles.body16.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (showButton) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => showVerificationDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 20, color: colors.textOnPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'توثيق حسابي',
                      style: AppTextStyles.title18Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'ستحصل على 100 نقطة لرصيدك بعد التوثيق',
                style: AppTextStyles.body12.copyWith(
                  fontSize: 13,
                  color: colors.link,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
