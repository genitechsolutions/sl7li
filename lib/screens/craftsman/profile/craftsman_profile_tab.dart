import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/dashed_border_box.dart';
import '../../../data/craftsman_verification.dart';
import '../../../data/dummy_data.dart';
import '../../craftsman_profile/craftsman_profile_screen.dart';
import '../../home/home_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../../settings/settings_screen.dart';
import '../widgets/craftsman_cards.dart';
import 'edit_profile_screen.dart';
import 'verification_dialog.dart';

/// تاب "الملف الشخصي" للمهني: بطاقة التعريف، التوثيق، المسار، معرض الأعمال، المحفظة، إدارة الحساب.
class CraftsmanProfileTab extends StatelessWidget {
  const CraftsmanProfileTab({super.key});

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
                          icon: 'assets/icons/ic_set_bell_dark.svg',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          ),
                        ),
                        const Spacer(),
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
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'رضا الكويفاتي',
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
                                'تكييف وتبريد',
                                style: AppTextStyles.body16.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
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
                            '(128) 4.9',
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CraftsmanProfileScreen(
                                  profile: sampleCraftsmanProfile,
                                  selfView: true,
                                ),
                              ),
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
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/icons/cr_switch.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  colors.primaryContent,
                                  BlendMode.srcIn,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
            child: Row(
              children: [
                Text('معرض الأعمال', style: AppTextStyles.title18Medium),
                const Spacer(),
                Text(
                  '(0/20)',
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.body12.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DashedBorderBox(
              height: 146,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 40,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text('إضغط لإضافة صور', style: AppTextStyles.body14Medium),
                    const SizedBox(height: 4),
                    Text(
                      'لا توجد صور في معرض أعمالك بعد',
                      style: AppTextStyles.body12.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                      const Row(
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
                CraftsmanTxRow(
                  title: 'أرباح خدمة - تنظيف مكيفات',
                  value: '+1000',
                  color: colors.success,
                  icon: 'assets/icons/cr_arrow_in.svg',
                ),
                CraftsmanTxRow(
                  title: 'سحب رصيد',
                  value: '-1000',
                  color: colors.error,
                  icon: 'assets/icons/cr_arrow_out.svg',
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
            Text(
              label,
              style: AppTextStyles.title18Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
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
              if (badge.isNotEmpty)
                Text(
                  badge,
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: badgeColor,
                  ),
                ),
              const Spacer(),
              Flexible(child: Text(title, style: AppTextStyles.body16Medium)),
              const SizedBox(width: 12),
              Icon(Icons.badge_outlined, color: colors.textPrimary),
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
                    Text(
                      'توثيق حسابي',
                      style: AppTextStyles.title18Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.verified, size: 20, color: colors.textOnPrimary),
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
