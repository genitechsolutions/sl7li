import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// سطر اقتراح بحث: أيقونة (سجل/بحث)، النص، وسهم لتعبئة الحقل.
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.onFill,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 59,
        child: Row(
          spacing: 8,
          children: [
            // الأيقونات بالتصميم ما بتنعكس مع RTL.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Icon(icon, size: 22, color: context.colors.textSecondary),
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body18,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onFill,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.north_east_rounded,
                  size: 20,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
