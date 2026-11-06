import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/load_view.dart';
import '../../cubits/ratings_cubit.dart';
import '../../data/repositories/reports_ratings_repository.dart';

/// قائمة تقييمات المهني: المقيِّم، النجوم، النص، التاريخ.
class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.pageAlt,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colors.cardAlt,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/ic_arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'التقييمات',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LoadView<RatingsCubit, List<ProfessionalRating>>(
                emptyText: 'لا توجد تقييمات بعد',
                isEmpty: (list) => list.isEmpty,
                onInit: (c) => c.load(force: true),
                builder: (context, list) => ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _RatingCard(rating: list[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating});

  final ProfessionalRating rating;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rating.reviewer,
                  style: AppTextStyles.body16Medium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                textDirection: TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: i <= rating.stars ? colors.star : colors.border,
                    ),
                ],
              ),
            ],
          ),
          if (rating.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(rating.text, style: AppTextStyles.body14),
          ],
          if (rating.date.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rating.date,
              style: AppTextStyles.body12.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
