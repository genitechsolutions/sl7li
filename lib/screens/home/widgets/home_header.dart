import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/svg_theme_colors.dart';
import '../../../core/widgets/app_icon_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/logo.svg',
          height: 52,
          colorMapper: SvgThemeColors.of(context),
          theme: SvgTheme(currentColor: context.colors.primaryContent),
        ),
        const Spacer(),
        AppIconButton(icon: 'assets/icons/ic_search.svg', onTap: onSearchTap),
      ],
    );
  }
}
