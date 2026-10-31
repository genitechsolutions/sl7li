import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'craftsman_avatar.dart';

class CraftsmanCard extends StatelessWidget {
  const CraftsmanCard({super.key, required this.craftsman, required this.onTap, this.color});

  final Craftsman craftsman;
  final VoidCallback onTap;

  /// الخلفية (surface افتراضياً).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final secondaryStyle = AppTextStyles.body14.copyWith(color: context.colors.textSecondary);
    final rating = craftsman.rating;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CraftsmanAvatar(image: craftsman.image, isPro: craftsman.isPro),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              craftsman.name,
                              style: AppTextStyles.body16Medium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (craftsman.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 18, color: context.colors.verified),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              craftsman.location,
                              style: secondaryStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: context.colors.border,
                          ),
                          Icon(Icons.star_rounded, size: 18, color: context.colors.star),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              rating != null
                                  ? '$rating (${craftsman.reviewsCount})'
                                  : 'لا يوجد تقييم بعد',
                              style: secondaryStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('الخدمات:', style: AppTextStyles.body14),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final service in craftsman.services) _Tag(label: service)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: context.colors.tag, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.body14.copyWith(color: context.colors.tagText)),
    );
  }
}
