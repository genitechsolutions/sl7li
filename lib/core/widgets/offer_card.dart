import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/dummy_data.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onTap});

  final Offer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 218,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(offer.image, width: 218, height: 131, fit: BoxFit.cover),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(offer.discount, style: AppTextStyles.body12Medium),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: AppTextStyles.body14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        offer.location,
                        style: AppTextStyles.body12.copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
