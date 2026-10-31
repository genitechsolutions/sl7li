import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// شريط مراحل الطلب: مفتوح ← تم الاتفاق ← قيد التنفيذ ← مكتمل (من اليمين).
/// [stage] المرحلة الحالية (0..3). اللي قبلها مكتملة (أخضر)، واللي بعدها رمادي. 4 = الكل مكتمل.
class RequestStepper extends StatelessWidget {
  const RequestStepper({super.key, required this.stage});

  static const _labels = ['مفتوح', 'تم الاتفاق', 'قيد\nالتنفيذ', 'مكتمل'];
  static const _circle = 36.0;

  final int stage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color stepColor(int i) => i < stage
        ? colors.successLight
        : i == stage
            ? colors.stepActive
            : colors.border;

    return SizedBox(
      height: 79,
      child: LayoutBuilder(
        builder: (context, box) {
          final step = (box.maxWidth - _circle) / 3;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // الخطوط بين الدوائر: لونها حسب المرحلة اللي قبلها.
              for (var i = 0; i < 3; i++)
                PositionedDirectional(
                  start: i * step + _circle + 8,
                  top: 16,
                  width: step - _circle - 16,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: stepColor(i),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              for (var i = 0; i < 4; i++) ...[
                PositionedDirectional(
                  start: i * step,
                  top: 0,
                  width: _circle,
                  height: _circle,
                  child: _Dot(index: i, stage: stage, color: stepColor(i)),
                ),
                PositionedDirectional(
                  start: i * step + _circle / 2 - 40,
                  top: 40,
                  width: 80,
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: i <= stage ? stepColor(i) : colors.textHint,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.stage, required this.color});

  final int index;
  final int stage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: index < stage
            ? SvgPicture.asset('assets/icons/ic_step_check.svg', width: 20, height: 20)
            : index == stage
                ? Image.asset('assets/images/step_spinner.png', width: 20, height: 20)
                : Text(
                    '${index + 1}',
                    style: AppTextStyles.body16Medium.copyWith(color: colors.textHint),
                  ),
      ),
    );
  }
}
