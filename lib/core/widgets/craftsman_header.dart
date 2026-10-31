import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'craftsman_avatar.dart';

/// صف الحرفي الكبير: صورة 72، الاسم + التوثيق، التقييم و"محترف موصى به".
class CraftsmanHeader extends StatelessWidget {
  const CraftsmanHeader({super.key, required this.craftsman, this.trailing});

  final Craftsman craftsman;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final rating = craftsman.rating;

    return Row(
      spacing: 14,
      children: [
        CraftsmanAvatar(image: craftsman.image, isPro: craftsman.isPro, size: 72),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: Text(
                      craftsman.name,
                      style: AppTextStyles.title20,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (craftsman.isVerified)
                    Icon(Icons.verified, size: 22, color: context.colors.verified),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 18, color: context.colors.star),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      rating != null ? '$rating (${craftsman.reviewsCount})' : 'لا يوجد تقييم بعد',
                      style: AppTextStyles.body16.copyWith(color: context.colors.textSecondary),
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
                        style: AppTextStyles.body16.copyWith(color: context.colors.link),
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
        ?trailing,
      ],
    );
  }
}
