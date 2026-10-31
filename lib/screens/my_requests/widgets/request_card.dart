import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/craftsman_avatar.dart';
import '../../../data/my_request.dart';
import 'request_stepper.dart';

/// كرت طلب بقائمة "طلباتي".
class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, this.onDetails, this.onUpdate, this.onMore});

  final MyRequest request;
  final VoidCallback? onDetails;
  final VoidCallback? onUpdate;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (priorityText, priorityColor) = switch (request.priority) {
      RequestPriority.urgent => ('عاجل', colors.warning),
      RequestPriority.emergency => ('طارئ', colors.error),
      RequestPriority.normal => ('عادي', colors.verified),
    };

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          for (final (dy, blur) in const [(7.0, 16.0), (29.0, 29.0), (65.0, 39.0)])
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.date,
                style: AppTextStyles.body12.copyWith(fontSize: 13, color: colors.textHint),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Text(
                priorityText,
                style: AppTextStyles.body12.copyWith(fontSize: 13, color: priorityColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onMore,
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
                  child: SvgPicture.asset(
                    'assets/icons/ic_more_vert.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(colors.primaryContent, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          // التاريخ وزر القائمة بنفس السطر؛ العنوان تحت التاريخ بدون ما يزيد الارتفاع.
          Transform.translate(
            offset: const Offset(0, -12),
            child: Text(request.title, style: AppTextStyles.title18Medium),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: request.description,
              children: [
                // الطلبات المفتوحة (فيها عروض) بالتصميم آخر وصفها "قراءة المزيد".
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
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary, height: 1.5),
          ),
          if (request.offersCount != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotatedBox(
                    quarterTurns: 1,
                    child: SvgPicture.asset(
                      'assets/icons/ic_chevron_down.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Color(0xFF171922), BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${request.offersCount} عروض واردة',
                    // نص فوق الأصفر: غامق دايماً بالفاتح والداكن.
                    style: AppTextStyles.body12.copyWith(fontSize: 13, color: const Color(0xFF171922)),
                  ),
                ],
              ),
            ),
          ],
          if (request.hasCraftsman) ...[
            const SizedBox(height: 16),
            _CraftsmanRow(request: request),
          ],
          const SizedBox(height: 20),
          RequestStepper(stage: request.stage),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'تحديث الحالة', filled: true, onTap: onUpdate)),
              const SizedBox(width: 12),
              Expanded(child: _ActionButton(label: 'التفاصيل', filled: false, onTap: onDetails)),
            ],
          ),
        ],
      ),
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
        const CraftsmanAvatar(image: 'assets/images/craftsman_1.jpg', isPro: true, size: 48),
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
                  SvgPicture.asset('assets/icons/ic_verified.svg', width: 20, height: 20),
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
                  // الأرقام بـ LTR متل التصميم "(128) 4.9".
                  Text(
                    '(${request.craftsmanReviews}) ${request.craftsmanRating}',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.body12.copyWith(fontSize: 13, color: colors.textSecondary),
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
  const _ActionButton({required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
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
          color: filled ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: filled ? colors.textOnPrimary : colors.primaryContent,
          ),
        ),
      ),
    );
  }
}
