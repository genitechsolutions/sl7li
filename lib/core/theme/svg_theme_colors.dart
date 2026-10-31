import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_colors.dart';

/// بيبدّل ألوان الـ SVG الثابتة (الكحلي والرمادي تبع التصميم الفاتح) بألوان الثيم الحالي.
/// للشعارات والرسومات اللي فيها أكتر من لون (ما بينفع معها colorFilter).
class SvgThemeColors extends ColorMapper {
  const SvgThemeColors(this.colors);

  factory SvgThemeColors.of(BuildContext context) => SvgThemeColors(context.colors);

  final AppColors colors;

  static const _navy = 0xFF36407E;
  static const _hint = 0xFF989FBA;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    return switch (color.toARGB32()) {
      _navy => colors.primary,
      _hint => colors.textHint,
      _ => color,
    };
  }

  // الـ mapper جزء من مفتاح الكاش تبع الصورة.
  @override
  bool operator ==(Object other) => other is SvgThemeColors && other.colors == colors;

  @override
  int get hashCode => colors.hashCode;
}
