import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../data/my_request.dart';
import 'request_stepper.dart';

/// كرت طلب بقائمة "طلباتي".
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    this.onDetails,
    this.onUpdate,
    this.onMore,
    this.onRate,
    this.onReorder,
  });

  final MyRequest request;
  final VoidCallback? onDetails;
  final VoidCallback? onUpdate;
  final VoidCallback? onMore;
  final VoidCallback? onRate;
  final VoidCallback? onReorder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (priorityText, priorityColor) = switch (request.priority) {
      RequestPriority.urgent => ('عاجل', colors.warning),
      RequestPriority.emergency => ('طارئ', colors.urgent),
      RequestPriority.normal => ('عادي', colors.link),
    };

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          for (final (dy, blur) in const [
            (7.0, 16.0),
            (29.0, 29.0),
            (65.0, 39.0),
          ])
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.01),
              offset: Offset(0, dy),
              blurRadius: blur,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.date,
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: colors.textHint,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: colors.barrier,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Text(
                  priorityText,
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: priorityColor,
                  ),
                ),
                const Spacer(),
                if (request.status != RequestStatus.canceled &&
                    !(request.status == RequestStatus.done && request.rated))
                  GestureDetector(
                    onTap: request.status == RequestStatus.done
                        ? onRate
                        : onMore,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: request.status == RequestStatus.done
                          ? SvgPicture.asset(
                              'assets/icons/ic_star.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                colors.star,
                                BlendMode.srcIn,
                              ),
                            )
                          : SvgPicture.asset(
                              'assets/icons/ic_more_vert.svg',
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
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Text(request.title, style: AppTextStyles.title18Medium),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 40),
            child: Text.rich(
              TextSpan(
                text: request.description,
                children: [
                  if (request.offersCount != null)
                    TextSpan(
                      text: ' قراءة المزيد',
                      style: TextStyle(
                        color: colors.verified,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.verified,
                      ),
                    ),
                ],
              ),
              style: AppTextStyles.body16.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          if (request.offersCount != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accentButton,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${request.offersCount} عروض واردة',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.textOnAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: 1,
                    child: SvgPicture.asset(
                      'assets/icons/ic_chevron_down.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        colors.textOnAccent,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (request.hasCraftsman) ...[
            const SizedBox(height: 16),
            _CraftsmanRow(request: request),
          ],
          if (request.status == RequestStatus.active) ...[
            const SizedBox(height: 20),
            RequestStepper(stage: request.stage),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'تحديث الحالة',
                    filled: true,
                    onTap: onUpdate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'التفاصيل',
                    filled: false,
                    onTap: onDetails,
                  ),
                ),
              ],
            ),
          ],
          if (request.status == RequestStatus.done) ...[
            if (request.rated) ...[
              const SizedBox(height: 20),
              _RatedNote(),
              const SizedBox(height: 16),
              _ActionButton(label: 'التفاصيل', filled: false, onTap: onDetails),
            ] else ...[
              const SizedBox(height: 20),
              RequestStepper(stage: request.stage),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'تقييم الخدمة',
                      filled: true,
                      accent: true,
                      onTap: onRate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'التفاصيل',
                      filled: false,
                      onTap: onDetails,
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (request.status == RequestStatus.canceled) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.destructive,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/ic_block.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  request.cancelNote!,
                  style: AppTextStyles.body16.copyWith(color: colors.error),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'إعادة الطلب',
                    filled: true,
                    onTap: onReorder,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'التفاصيل',
                    filled: false,
                    onTap: onDetails,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RatedNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: colors.star, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/ic_star_rate.svg',
            width: 17,
            height: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text('تم تقييم الخدمة, شكرا لرأيك', style: AppTextStyles.body16),
      ],
    );
  }
}

class _CraftsmanRow extends StatelessWidget {
  const _CraftsmanRow({required this.request});

  final MyRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        const CraftsmanAvatar(
          image: 'assets/images/craftsman_1.jpg',
          isPro: true,
          size: 48,
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
                      request.craftsmanName!,
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
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic_star.svg',
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(colors.star, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${request.craftsmanReviews}) ${request.craftsmanRating}',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final bool filled;

  /// الزر الأصفر الثانوي ("تقييم الخدمة").
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent
              ? colors.accentButton
              : filled
              ? colors.primary
              : colors.background,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: accent
                ? const Color(0xFF171922)
                : filled
                ? colors.textOnPrimary
                : colors.primaryContent,
          ),
        ),
      ),
    );
  }
}
