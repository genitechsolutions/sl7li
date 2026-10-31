import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/form/app_toggle.dart';

/// "تخصيص الإشعارات": مفاتيح لإشعارات التطبيق والواتساب (طلبات، عروض، رسائل، ترويجية).
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // [التطبيق: الكل، طلبات، عروض، رسائل، ترويجية] و[الواتساب: نفس الترتيب]. الترويجية مطفية متل التصميم.
  final _app = [true, true, true, true, false];
  final _whatsapp = [true, true, true, true, false];

  static const _items = [
    ('إشعارات الطلبات', 'تحديثات حالة طلباتك'),
    ('إشعارات العروض', 'عند وصول عروض جديدة'),
    ('إشعارات الرسائل', null),
    ('العروض الترويجية', 'خصومات وعروض حصرية في منطقتك'),
  ];

  Widget _group(String title, List<bool> state) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 33, 20, 20),
          child: Row(
            children: [
              Text(title, style: AppTextStyles.title18Medium),
              const Spacer(),
              AppToggle(
                value: state[0],
                onChanged: (v) => setState(() {
                  for (var i = 0; i < state.length; i++) {
                    // مفتاح المجموعة بيشغّل/بيطفي الكل
                    state[i] = v;
                  }
                }),
              ),
            ],
          ),
        ),
        for (var i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 21.5,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_items[i].$1, style: AppTextStyles.body16Medium),
                        if (_items[i].$2 != null)
                          Text(
                            _items[i].$2!,
                            style: AppTextStyles.body16.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AppToggle(
                    value: state[i + 1],
                    onChanged: (v) => setState(() => state[i + 1] = v),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Column(
          children: [
            Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تخصيص الإشعارات',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
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
                  _group('إشعارات التطبيق', _app),
                  _group('إشعارات الواتساب', _whatsapp),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
