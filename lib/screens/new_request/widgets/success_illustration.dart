import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// رسمة النجاح: دائرة خضرا فيها ✓، وحواليها حلقات ونقاط وإشارات +.
/// المواقع مأخوذة من التصميم (صندوق 198×140).
class SuccessIllustration extends StatelessWidget {
  const SuccessIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 198,
      height: 140,
      // الرسمة بالتصميم مش معكوسة، فمنثبّت المواقع من اليسار.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _at(29, 0, _circle(140, context.colors.successPale)),
            _at(
              47,
              18,
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: context.colors.successLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 64, color: context.colors.textOnPrimary),
              ),
            ),
            _at(65, 0, _ring(context, 10)),
            _at(186, 18, _ring(context, 12)),
            _at(0, 92, _ring(context, 12)),
            _at(182, 107, _ring(context, 12)),
            _at(154, 0, _plus(context, 12)),
            _at(17, 50, _plus(context, 12)),
            _at(149, 117, _plus(context, 8)),
            _at(23, 10, _circle(7, context.colors.successLight)),
            _at(182, 63, _circle(7, context.colors.successLight)),
            _at(52, 125, _circle(6, context.colors.successLight)),
          ],
        ),
      ),
    );
  }

  static Widget _at(double left, double top, Widget child) =>
      Positioned(left: left, top: top, child: child);

  static Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  static Widget _ring(BuildContext context, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: context.colors.successRing, width: 2),
    ),
  );

  static Widget _plus(BuildContext context, double size) {
    final thickness = size / 4;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: context.colors.successDark,
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [bar(size, thickness), bar(thickness, size)],
      ),
    );
  }
}
