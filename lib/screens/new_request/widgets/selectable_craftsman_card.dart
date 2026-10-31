import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../data/dummy_data.dart';

/// كرت حرفي مع مربع اختيار (صفحة استهداف المهنيين).
class SelectableCraftsmanCard extends StatelessWidget {
  const SelectableCraftsmanCard({
    super.key,
    required this.craftsman,
    required this.selected,
    required this.onTap,
  });

  final Craftsman craftsman;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = AppTextStyles.body12.copyWith(color: context.colors.textSecondary);
    final rating = craftsman.rating;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 8,
          children: [
            CraftsmanAvatar(image: craftsman.image, isPro: craftsman.isPro),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Flexible(
                        child: Text(
                          craftsman.name,
                          style: AppTextStyles.body16Medium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (craftsman.isVerified)
                        Icon(Icons.verified, size: 18, color: context.colors.verified),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: context.colors.star),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rating != null
                              ? '$rating (${craftsman.reviewsCount})'
                              : 'لا يوجد تقييم بعد',
                          style: secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (craftsman.isRecommended) ...[
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: context.colors.border,
                        ),
                        Flexible(
                          child: Text(
                            'محترف موصى به',
                            style: secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? context.colors.verified : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: selected ? null : Border.all(color: context.colors.border, width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 18, color: context.colors.textOnPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
