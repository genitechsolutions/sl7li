import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/my_request.dart';

/// كرت عرض سعر وارد (صفحة تفاصيل الطلب ← العروض).
class OfferTile extends StatelessWidget {
  const OfferTile({super.key, required this.offer, this.onOpen});

  final RequestOffer offer;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.textSecondary,
    );
    final price = small.copyWith(color: colors.success);

    Widget feeRow(String label, String value) => Row(
      children: [
        Text(label, style: small),
        const Spacer(),
        Text(value, style: price),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/offer_avatar.png',
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            offer.craftsmanName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/icons/ic_verified.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ic_star.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            colors.star,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${offer.reviews}) ${offer.rating}',
                          textDirection: TextDirection.ltr,
                          style: small,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: colors.border,
                        ),
                        Flexible(
                          child: Text(
                            'محترف موصى به',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: small,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onOpen,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/ic_open_external.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.primaryContent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(offer.priceLabel, style: AppTextStyles.body16),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${offer.price} ',
                      style: AppTextStyles.title20.copyWith(
                        color: colors.success,
                      ),
                    ),
                    TextSpan(
                      text: offer.priceUnit,
                      style: AppTextStyles.body16.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          feeRow('أجور الكشف والمواصلات', offer.inspectionFee),
          feeRow('أجور المواد والأدوات', offer.materialsFee),
        ],
      ),
    );
  }
}
