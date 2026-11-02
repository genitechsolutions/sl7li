import 'dart:math' as math;

import 'package:flutter/material.dart';

/// حلقة تقدّم بشكل عدّاد 270° (فتحة بالأسفل) متل التصميم.
class ArcProgress extends StatelessWidget {
  const ArcProgress({
    super.key,
    required this.value,
    required this.trackColor,
    required this.progressColor,
    this.size = 68,
    this.strokeWidth = 8,
    this.child,
  });

  /// نسبة الإنجاز 0..1.
  final double value;
  final Color trackColor;
  final Color progressColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  /// المسار بيبدأ من أسفل اليسار (135° بنظام الكانفس) وبيمشي مع عقارب الساعة 270°.
  static const startAngle = 3 * math.pi / 4;
  static const trackSweep = 3 * math.pi / 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
          value: value.clamp(0.0, 1.0),
          trackColor: trackColor,
          progressColor: progressColor,
          strokeWidth: strokeWidth,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double value;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(
      rect,
      ArcProgress.startAngle,
      ArcProgress.trackSweep,
      false,
      paint..color = trackColor,
    );
    if (value > 0) {
      canvas.drawArc(
        rect,
        ArcProgress.startAngle,
        ArcProgress.trackSweep * value,
        false,
        paint..color = progressColor,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.strokeWidth != strokeWidth;
}
