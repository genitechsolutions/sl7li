import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';

/// أيقونات أطراف الحقول.
abstract final class FieldIcons {
  static Widget search() => Builder(
    builder: (context) => SvgPicture.asset(
      'assets/icons/ic_search.svg',
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(context.colors.textSecondary, BlendMode.srcIn),
    ),
  );

  static Widget dropdown({bool enabled = true}) => Builder(
    builder: (context) => Icon(
      Icons.keyboard_arrow_down_rounded,
      size: 22,
      color: enabled ? context.colors.textSecondary : context.colors.textHint,
    ),
  );
}
