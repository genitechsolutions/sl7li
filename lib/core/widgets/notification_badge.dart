import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/unread_count_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// شارة العدد فوق زاوية الجرس؛ بتحمّل العدّاد أول ما تظهر.
class NotificationBadge extends StatefulWidget {
  const NotificationBadge({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UnreadCountCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = context.select((UnreadCountCubit c) => c.state.data ?? 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (count > 0)
          PositionedDirectional(
            end: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body12.copyWith(
                  fontSize: 11,
                  height: 1.2,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
