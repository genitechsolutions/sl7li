import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              CircleAvatar(radius: 26, backgroundImage: AssetImage(review.avatar)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const SizedBox(height: 2),
                    Text(review.name, style: AppTextStyles.body16Medium),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: i < review.rating ? context.colors.star : context.colors.border,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  review.date,
                  style: AppTextStyles.body12.copyWith(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.tag,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              review.tag,
              style: AppTextStyles.body14.copyWith(color: context.colors.tagText),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            review.comment,
            style: AppTextStyles.body16.copyWith(color: context.colors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
