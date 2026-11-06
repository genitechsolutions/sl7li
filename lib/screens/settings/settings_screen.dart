import '../craftsman/signup/signup_step1_screen.dart';
import '../../core/widgets/form/options_sheet.dart';
import '../../core/widgets/info_dialog.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/notification_badge.dart';
import '../../core/backend/backend_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/feature_cubits.dart';
import '../../app_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_mode_notifier.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../auth/phone_login_screen.dart';
import '../home/home_screen.dart';
import '../messages/messages_screen.dart';
import '../my_requests/my_requests_screen.dart';
import '../new_request/new_request_screen.dart';
import '../notifications/notifications_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_screen.dart';

/// "الإعدادات": الملف الشخصي، الوضع المظلم، الإشعارات، المساعدة، وإدارة الحساب.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.craftsmanMode = false});

  /// إعدادات المهني: بدون الشريط السفلي، وفيها "التبديل لوضع الزبون".
  final bool craftsmanMode;

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _logout(BuildContext context) async {
    final ok = await showAppModal<bool>(
      context,
      (context) => const _LogoutDialog(),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await showAppModal<bool>(
      context,
      (context) => const _DeleteDialog(),
    );
    if (ok == true && context.mounted) await _finishDelete(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget sectionTitle(String text, {double top = 28}) => Padding(
      padding: EdgeInsets.fromLTRB(20, top, 20, 8),
      child: Text(
        text,
        style: AppTextStyles.title18Medium.copyWith(
          color: colors.textSecondary,
          height: 1.5,
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.pageAlt,
        bottomNavigationBar: craftsmanMode
            ? null
            : AppBottomNavBar(
                currentIndex: 3,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                  if (index == 1) _push(context, const MyRequestsScreen());
                  if (index == 2) _push(context, const MessagesScreen());
                },
                onAddTap: () =>
                    Navigator.push(context, NewRequestScreen.route()),
              ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(
              onBell: () => _push(context, const NotificationsScreen()),
              onEdit: () => _push(context, const ProfileScreen()),
            ),
            const SizedBox(height: 12),
            const _NameAndPhone(),
            sectionTitle('التطبيق', top: 20),
            _Row(
              icon: 'assets/icons/ic_set_profile.svg',
              title: 'الملف الشخصي',
              onTap: () => _push(context, const ProfileScreen()),
            ),
            _Row(
              icon: 'assets/icons/ic_set_moon.svg',
              title: 'الوضع المظلم',
              trailing: AppToggle(
                value: isDark,
                onChanged: (v) => themeModeNotifier.value = v
                    ? ThemeMode.dark
                    : ThemeMode.light,
              ),
            ),
            _Row(
              icon: 'assets/icons/ic_set_bell.svg',
              title: craftsmanMode ? 'الإشعارات' : 'تخصيص الإشعارات',
              onTap: () => _push(context, const NotificationSettingsScreen()),
            ),
            sectionTitle('المساعدة والدعم'),
            _Row(
              icon: 'assets/icons/ic_set_help.svg',
              title: 'كيفية استخدام التطبيق',
              onTap: () => showInfoDialog(
                context,
                title: 'كيفية استخدام التطبيق',
                lines: const [
                  '1. اضغط زر + وصف مشكلتك واختر نوع الخدمة والموقع.',
                  '2. بتوصلك عروض من المهنيين المناسبين بتابع "طلباتي".',
                  '3. قارن العروض وتواصل مع المهني واتفق معه عبر الدردشة.',
                  '4. بعد إنجاز العمل قيّم المهني لتساعد باقي الزبائن.',
                ],
              ),
            ),
            _Row(
              icon: 'assets/icons/ic_set_shield.svg',
              title: 'الأمان والخصوصية',
              onTap: () => showInfoDialog(
                context,
                title: 'الأمان والخصوصية',
                lines: const [
                  'رقمك بيُستخدم لتسجيل الدخول والتواصل مع المهنيين اللي بتختارهم بس.',
                  'ما منشارك بياناتك مع أي جهة خارجية، وفيك تحذف حسابك بأي وقت من "إدارة الحساب".',
                ],
              ),
            ),
            if (craftsmanMode)
              _Row(
                icon: 'assets/icons/ic_user.svg',
                title: 'التبديل لوضع الزبون',
                trailing: SvgPicture.asset(
                  'assets/icons/cr_switch.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
              )
            else
              _Row(
                icon: 'assets/icons/ic_set_tools.svg',
                title: 'انضم كحرفي',
                onTap: () => _push(context, const SignupStep1Screen()),
              ),
            sectionTitle('إدارة الحساب'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                spacing: 8,
                children: [
                  _AccountButton(
                    label: 'تسجيل الخروج',
                    icon: 'assets/icons/ic_set_logout.svg',
                    filled: false,
                    onTap: () => _logout(context),
                  ),
                  _AccountButton(
                    label: 'حذف الحساب',
                    icon: 'assets/icons/ic_set_trash.svg',
                    filled: true,
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBell, required this.onEdit});

  final VoidCallback onBell;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 159,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 107,
            width: double.infinity,
            decoration: BoxDecoration(color: colors.primary),
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              maxWidth: 624,
              maxHeight: 558,
              alignment: const Alignment(0.55, 0.9),
              child: SvgPicture.asset(
                'assets/icons/settings_header_pattern.svg',
                width: 624,
                height: 558,
              ),
            ),
          ),
          PositionedDirectional(
            end: 20,
            top: 43,
            child: SafeArea(
              top: false,
              child: NotificationBadge(child: AppIconButton(
                icon: 'assets/icons/ic_bell.svg',
                onTap: onBell,
              )),
            ),
          ),
          Positioned(
            top: 63,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/profile_avatar.png',
                        width: 96,
                        height: 96,
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/ic_edit_badge.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 20, 20, 20),
          decoration: BoxDecoration(
            color: colors.cardAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(icon, width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body16Medium.copyWith(height: 1.5),
                ),
              ),
              if (trailing != null)
                trailing!
              else
                RotatedBox(
                  quarterTurns: 1,
                  child: SvgPicture.asset(
                    'assets/icons/ic_chevron_row.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({
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
                height: 1.5,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تأكيد تسجيل الخروج', style: AppTextStyles.title20),
          const SizedBox(height: 8),
          Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
            style: AppTextStyles.body16,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppDialogButton(
                  label: 'تأكيد',
                  background: colors.primary,
                  foreground: colors.textOnPrimary,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDialogButton(
                  label: 'إلغاء',
                  background: colors.background,
                  foreground: colors.primaryContent,
                  border: colors.border,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog();

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  static const _reasons = [
    'ما عدت بحتاج التطبيق',
    'ما لقيت المهنيين المناسبين',
    'مشاكل بالتطبيق',
    'قلق على الخصوصية',
    'سبب آخر',
  ];

  String? _reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppDialogBadge(
                color: colors.error,
                child: SvgPicture.asset(
                  'assets/icons/ic_set_trash.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تأكيد حذف الحساب',
                style: AppTextStyles.title18Medium.copyWith(
                  color: colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تنبيه مهم',
                      style: AppTextStyles.body16.copyWith(color: colors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'حذف الحساب عملية نهائية ولا يمكن التراجع عنها ستفقد جميع بياناتك الشخصية والمهنية إذا كنت حرفياً، ستفقد ملفك المهني وجميع إنجازاتك',
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.error,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('سبب الحذف', style: AppTextStyles.body16Medium),
          const SizedBox(height: 8),
          AppSelectField(
            hint: 'اختر سبب الحذف',
            value: _reason,
            onTap: () async {
              final v = await showOptionsSheet(
                context,
                title: 'سبب الحذف',
                options: _reasons,
              );
              if (v != null) setState(() => _reason = v);
            },
          ),
          const SizedBox(height: 20),
          Text('ملاحظات إضافية', style: AppTextStyles.body16Medium),
          const SizedBox(height: 8),
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.fieldFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              style: AppTextStyles.body16,
              decoration: InputDecoration.collapsed(
                hintText: 'أي ملاحظات أو اقتراحات لتحسين الخدمة...',
                hintStyle: AppTextStyles.body16.copyWith(
                  color: colors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppDialogButton(
                  label: 'حذف الحساب',
                  background: colors.destructive,
                  foreground: colors.textOnPrimary,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDialogButton(
                  label: 'إلغاء',
                  background: colors.background,
                  foreground: colors.primaryContent,
                  border: colors.border,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// تأكيد تسجيل الخروج ثم الرجوع لصفحة الرقم (بيستعملها الإعدادات وبروفايل المهني).
Future<void> confirmLogout(BuildContext context) async {
  final ok = await showAppModal<bool>(
    context,
    (context) => const _LogoutDialog(),
  );
  if (ok == true && context.mounted) {
    await signOutAndReset(context);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
      (_) => false,
    );
  }
}

/// تأكيد حذف الحساب ثم الرجوع لصفحة الرقم.
Future<void> confirmDeleteAccount(BuildContext context) async {
  final ok = await showAppModal<bool>(
    context,
    (context) => const _DeleteDialog(),
  );
  if (ok == true && context.mounted) await _finishDelete(context);
}

Future<void> _finishDelete(BuildContext context) async {
  try {
    await context.read<ProfileCubit>().deleteAccount();
  } on BackendException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (!context.mounted) return;
  await signOutAndReset(context);
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    (_) => false,
  );
}

/// الاسم + الرقم من بيانات الحساب (حقيقية بالوضع الحقيقي).
class _NameAndPhone extends StatefulWidget {
  const _NameAndPhone();

  @override
  State<_NameAndPhone> createState() => _NameAndPhoneState();
}

class _NameAndPhoneState extends State<_NameAndPhone> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileCubit c) => c.state.data);
    return Column(
      children: [
        Text(profile?.name ?? '', style: AppTextStyles.title20),
        const SizedBox(height: 4),
        Text(
          profile?.displayPhone ?? '',
          textDirection: TextDirection.ltr,
          style: AppTextStyles.body18.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
