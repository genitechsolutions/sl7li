import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/craftsman_data.dart';
import '../../my_requests/widgets/request_stepper.dart';

/// كرت طلب عند المهني: طلب متاح (زر "تقديم عرض") أو مهمة حالية (مراحل + "تحديث الحالة").
class CraftsmanRequestCard extends StatelessWidget {
  const CraftsmanRequestCard({
    super.key,
    required this.request,
    this.width,
    this.onDetails,
    this.onPrimary,
    this.onMore,
  });

  final CraftsmanRequest request;
  final double? width;
  final VoidCallback? onDetails;
  final VoidCallback? onPrimary;
  final void Function(BuildContext anchor)? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final urgencyColor = switch (request.urgency) {
      'طارئ' => colors.urgent,
      'عادي' => colors.link,
      _ => colors.warning,
    };

    Widget photos() => Row(
      spacing: 12,
      children: [
        for (var i = 1; i <= 3; i++)
          Expanded(
            child: AspectRatio(
              aspectRatio: 102 / 63,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/request_photo_$i.png',
                      fit: BoxFit.cover,
                    ),
                    if (i == 3 && request.photos > 3)
                      ColoredBox(
                        color: const Color(0x99000000),
                        child: Center(
                          child: Text(
                            '+${request.photos - 3 + 2}',
                            style: AppTextStyles.title20.copyWith(
                              color: colors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return Container(
      width: width,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
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
                  request.urgency,
                  style: AppTextStyles.body12.copyWith(
                    fontSize: 13,
                    color: urgencyColor,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (anchor) => GestureDetector(
                    onTap: onMore == null ? null : () => onMore!(anchor),
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
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
                        ),
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
          Text.rich(
            TextSpan(
              text: request.description,
              children: [
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
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/cr_pin.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(colors.chipText, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                request.location,
                style: AppTextStyles.body16.copyWith(color: colors.chipText),
              ),
              if (request.contacts != null) ...[
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: colors.barrier,
                ),
                Flexible(
                  child: Text(
                    'تواصل ${request.contacts} مهنيين مع الزبون',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body16.copyWith(
                      color: colors.verified,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          photos(),
          if (request.state == CraftsmanRequestState.task ||
              request.state == CraftsmanRequestState.done) ...[
            const SizedBox(height: 20),
            RequestStepper(
              stage: request.stage!,
              labels: const [
                'عرض\nمرسل',
                'تم الاتفاق',
                'قيد\nالتنفيذ',
                'مكتمل',
              ],
            ),
          ],
          if (request.state == CraftsmanRequestState.cancelled) ...[
            const SizedBox(height: 16),
            _StatusLine(text: 'تم إلغاء الطلب', color: colors.error),
            if (request.note != null) ...[
              const SizedBox(height: 8),
              Text(
                request.note!,
                style: AppTextStyles.body16.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
          if (request.state == CraftsmanRequestState.withdrawn) ...[
            const SizedBox(height: 16),
            _StatusLine(text: 'قمت بسحب عرضك', color: colors.error),
          ],
          if (request.state == CraftsmanRequestState.done && request.rated) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.star,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/ic_star_rate.svg',
                    width: 17,
                    height: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.body16,
                    children: [
                      const TextSpan(text: 'تم تقييم الخدمة, '),
                      TextSpan(
                        text: 'رؤية تقييمك',
                        style: TextStyle(
                          color: colors.link,
                          decoration: TextDecoration.underline,
                          decorationColor: colors.link,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (request.state == CraftsmanRequestState.open ||
              request.state == CraftsmanRequestState.task ||
              request.state == CraftsmanRequestState.withdrawn) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Btn(
                    label: request.state == CraftsmanRequestState.task
                        ? 'تحديث الحالة'
                        : 'تقديم عرض',
                    bg: request.state == CraftsmanRequestState.task
                        ? colors.primary
                        : colors.success,
                    fg: colors.textOnPrimary,
                    onTap: onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Btn(
                    label: 'التفاصيل',
                    bg: colors.background,
                    fg: colors.primaryContent,
                    border: colors.border,
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

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
    this.onTap,
  });

  final String label;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
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
        Text(text, style: AppTextStyles.body16.copyWith(color: color)),
      ],
    );
  }
}
