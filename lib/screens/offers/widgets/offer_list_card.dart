import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../data/dummy_data.dart';

/// كرت العرض بعرض الشاشة: صورة + شارة الخصم + تاغات، العنوان، الموقع، والحرفي.
class OfferListCard extends StatelessWidget {
  const OfferListCard({super.key, required this.offer, required this.onTap});

  final Offer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final craftsman = offer.craftsman;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(offer.image, width: double.infinity, height: 182, fit: BoxFit.cover),
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: _Pill(
                    label: offer.discount,
                    style: AppTextStyles.body14,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  bottom: 10,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final tag in offer.tags)
                        _Pill(
                          label: tag,
                          style: AppTextStyles.body12,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.title, style: AppTextStyles.title20),
                  const SizedBox(height: 8),
                  Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: context.colors.textSecondary,
                      ),
                      Text(
                        offer.location,
                        style: AppTextStyles.body18.copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (craftsman != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 14, 8, 8),
                child: _CraftsmanRow(craftsman: craftsman),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CraftsmanRow extends StatelessWidget {
  const _CraftsmanRow({required this.craftsman});

  final Craftsman craftsman;

  @override
  Widget build(BuildContext context) {
    final rating = craftsman.rating;

    return Row(
      spacing: 8,
      children: [
        CraftsmanAvatar(image: craftsman.image, isPro: craftsman.isPro),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
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
                spacing: 4,
                children: [
                  Icon(Icons.star_rounded, size: 18, color: context.colors.star),
                  Text(
                    rating != null ? '$rating (${craftsman.reviewsCount})' : 'لا يوجد تقييم بعد',
                    style: AppTextStyles.body12.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.style, required this.padding});

  final String label;
  final TextStyle style;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: style),
    );
  }
}
