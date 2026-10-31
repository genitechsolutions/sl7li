import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// ثيم فاتح وداكن من نفس الـ tokens (AppColors.light / AppColors.dark).
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final base = ThemeData(brightness: brightness, fontFamily: AppTextStyles.fontFamily);
    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(seedColor: c.primary, brightness: brightness).copyWith(
        primary: c.primary,
        onPrimary: c.textOnPrimary,
        secondary: c.accent,
        surface: c.background,
        onSurface: c.textPrimary,
        error: c.error,
      ),
      // النصوص بدون لون بـ AppTextStyles بتاخد textPrimary من هون.
      textTheme: base.textTheme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.primaryContent),
      extensions: [c],
    );
  }

  /// لون أيقونات شريط الحالة حسب الثيم (غامقة بالفاتح، فاتحة بالداكن).
  static SystemUiOverlayStyle overlayStyle(BuildContext context) =>
      (Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent);
}
