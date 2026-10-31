import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// بيفتح قائمة خيارات من تحت وبيرجع الخيار المختار (أو null إذا تسكّرت).
Future<String?> showOptionsSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.colors.background,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title, style: AppTextStyles.title18Medium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(option, style: AppTextStyles.body16),
                    onTap: () => Navigator.pop(context, option),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
