import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';

/// الشريط الأزرق فوق صفحة البحث: زر رجوع + حقل البحث.
class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      height: top + 75,
      decoration: BoxDecoration(color: context.colors.primary),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            start: 0,
            child: Opacity(
              opacity: 0.05,
              child: SvgPicture.asset('assets/icons/banner_pattern.svg', width: 251, height: 178),
            ),
          ),
          PositionedDirectional(
            top: top + 11,
            start: 20,
            end: 20,
            child: Row(
              spacing: 12,
              children: [
                AppIconButton(
                  icon: 'assets/icons/ic_arrow_back.svg',
                  onTap: () => Navigator.pop(context),
                ),
                Expanded(child: _field(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 8,
        children: [
          SvgPicture.asset(
            'assets/icons/ic_search.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(context.colors.textSecondary, BlendMode.srcIn),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: context.colors.primaryContent,
              style: AppTextStyles.body16,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'إبحث عن خدمة, مهني أو اختصاص...',
                hintStyle: AppTextStyles.body16.copyWith(color: context.colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
