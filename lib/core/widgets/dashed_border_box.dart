import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// صندوق بحدود متقطعة (رفع الصور).
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    this.height,
    this.radius = 12,
    this.color,
  });

  final Widget child;
  final double? height;
  final double radius;

  /// لون الحدود (primaryContent افتراضياً).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        radius: radius,
        color: color ?? context.colors.primaryContent,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.fieldFill,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  static const _strokeWidth = 2.0;
  static const _dash = 13.0;
  static const _gap = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.radius != radius || old.color != color;
}
