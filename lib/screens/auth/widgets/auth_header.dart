import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/svg_theme_colors.dart';
import '../../../core/widgets/header_action_button.dart';

/// رأس صفحات الدخول: الشعار بالنص، العنوان والشرح تحته،
/// وزر "العودة" بالزاوية (فوق مستوى الشعار) إذا انعطى [onBack].
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle, this.onBack});

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 55),
            Center(
              child: SvgPicture.asset(
                'assets/icons/logo_mark.svg',
                height: 67,
                colorMapper: SvgThemeColors.of(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.title30Bold),
            const SizedBox(height: 13),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.title20.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
        if (onBack != null)
          PositionedDirectional(
            top: 11,
            end: 0,
            child: SizedBox(
              width: 92,
              child: HeaderActionButton(label: 'العودة', onPressed: onBack!),
            ),
          ),
      ],
    );
  }
}
