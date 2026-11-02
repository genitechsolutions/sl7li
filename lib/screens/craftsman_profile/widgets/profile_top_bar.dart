import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/svg_theme_colors.dart';
import '../../../core/widgets/app_icon_button.dart';

/// الشريط العلوي لصفحة الحرفي: خلفية متدرجة مع زخرفة اللوغو، زر رجوع ومشاركة.
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key, required this.onShareTap});

  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      height: top + 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(context.colors.background, context.colors.surface, 0.22)!,
            context.colors.surface,
          ],
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            start: 0,
            child: SvgPicture.asset(
              'assets/icons/profile_header_deco.svg',
              width: 412,
              height: 107,
              colorMapper: SvgThemeColors.of(context),
            ),
          ),
          PositionedDirectional(
            top: top + 11,
            start: 20,
            end: 20,
            child: Row(
              children: [
                AppIconButton(
                  icon: 'assets/icons/ic_arrow_back.svg',
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                AppIconButton(icon: 'assets/icons/ic_share.svg', onTap: onShareTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
