import 'package:flutter/material.dart';

/// ألوان التطبيق — مأخوذة من التصميم (فاتح + داكن).
/// بالشاشات: `context.colors.primary` (مش ثابتة، فما بتنحط جوا `const`).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryContent,
    required this.accent,
    required this.background,
    required this.surface,
    required this.fieldFill,
    required this.stepActive,
    required this.stepInactive,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.textOnPrimaryMuted,
    required this.link,
    required this.success,
    required this.error,
    required this.textHint,
    required this.disabled,
    required this.successLight,
    required this.successPale,
    required this.successRing,
    required this.successDark,
    required this.tag,
    required this.tagText,
    required this.navActive,
    required this.verified,
    required this.star,
    required this.pro,
    required this.warning,
    required this.successDisabled,
  });

  /// الكحلي: خلفية الأزرار والتابات المختارة.
  final Color primary;

  /// الكحلي كلون نص/أيقونة/حدود (العودة، الشيبس، المؤشر). بالداكن فاتح ليبين.
  final Color primaryContent;
  final Color accent;

  /// خلفية الصفحات.
  final Color background;

  /// الكروت والحقول.
  final Color surface;

  /// تعبئة حقول الفورم (نص، اختيار، رقم، رفع صور). بالداكن أفتح من الكروت.
  final Color fieldFill;

  /// شريط خطوات الطلب: الخطوة الحالية والخطوات الجاية.
  final Color stepActive;
  final Color stepInactive;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color textOnPrimaryMuted;
  final Color link;
  final Color success;
  final Color error;
  final Color textHint;
  final Color disabled;
  final Color successLight;
  final Color successPale;
  final Color successRing;
  final Color successDark;
  final Color tag;
  final Color tagText;
  final Color navActive;
  final Color verified;
  final Color star;
  final Color pro;

  /// "عاجل" برتقالي (أولوية الطلب).
  final Color warning;

  /// زر النجاح المعطّل ("قبول العرض"). بالداكن مشتق (مش بالتصميم).
  final Color successDisabled;

  static const light = AppColors(
    primary: Color(0xFF36407E),
    primaryContent: Color(0xFF36407E),
    accent: Color(0xFFF7C425),
    background: Color(0xFFF9F9FB),
    surface: Color(0xFFF0F0F5),
    fieldFill: Color(0xFFF0F0F5),
    stepActive: Color(0xFF36407E),
    stepInactive: Color(0xFFC8CDDA),
    border: Color(0xFFC8CDDA),
    divider: Color(0xFFE0E3EA),
    textPrimary: Color(0xFF171922),
    textSecondary: Color(0xFF68719A),
    textOnPrimary: Color(0xFFF9F9FB),
    textOnPrimaryMuted: Color(0xFFC8CDDA),
    link: Color(0xFF2695D0),
    success: Color(0xFF2E9D57),
    error: Color(0xFFEB1809),
    textHint: Color(0xFF989FBA),
    disabled: Color(0xFFB0B6CA),
    successLight: Color(0xFF37BD68),
    successPale: Color(0xFFE6F3EC),
    successRing: Color(0xFF71D595),
    successDark: Color(0xFF257D46),
    tag: Color(0xFFC4C8E5),
    tagText: Color(0xFF1E2345),
    navActive: Color(0xFFDCDDE8),
    verified: Color(0xFF2596D3),
    star: Color(0xFFEBB409),
    pro: Color(0xFFF8594D),
    warning: Color(0xFFE86F0C),
    successDisabled: Color(0xFFAFE7C4),
  );

  static const dark = AppColors(
    primary: Color(0xFF2A3161),
    primaryContent: Color(0xFFF9F9FB),
    accent: Color(0xFFF7C425),
    background: Color(0xFF171922),
    surface: Color(0xFF1F222E),
    fieldFill: Color(0xFF27293A),
    stepActive: Color(0xFF36407E),
    stepInactive: Color(0xFF27293A),
    border: Color(0xFF373B52),
    divider: Color(0xFF272A3A),
    textPrimary: Color(0xFFF9F9FB),
    textSecondary: Color(0xFFB0B6CA),
    textOnPrimary: Color(0xFFF9F9FB),
    textOnPrimaryMuted: Color(0xFFC8CDDA),
    link: Color(0xFF43A8DE),
    success: Color(0xFF37BD68),
    error: Color(0xFFDB3126),
    textHint: Color(0xFF989FBA),
    disabled: Color(0xFF262B4D),
    successLight: Color(0xFF2E9D57),
    successPale: Color(0xFF1C3326),
    successRing: Color(0xFF2E7D4D),
    successDark: Color(0xFF71D595),
    tag: Color(0xFF2B3262),
    tagText: Color(0xFFDDDFEB),
    navActive: Color(0xFF2B3262),
    verified: Color(0xFF2596D3),
    star: Color(0xFFF7C425),
    pro: Color(0xFFF8594D),
    warning: Color(0xFFE86F0C),
    successDisabled: Color(0xFF2A5A3D),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: c(primary, other.primary),
      primaryContent: c(primaryContent, other.primaryContent),
      accent: c(accent, other.accent),
      background: c(background, other.background),
      surface: c(surface, other.surface),
      fieldFill: c(fieldFill, other.fieldFill),
      stepActive: c(stepActive, other.stepActive),
      stepInactive: c(stepInactive, other.stepInactive),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textOnPrimary: c(textOnPrimary, other.textOnPrimary),
      textOnPrimaryMuted: c(textOnPrimaryMuted, other.textOnPrimaryMuted),
      link: c(link, other.link),
      success: c(success, other.success),
      error: c(error, other.error),
      textHint: c(textHint, other.textHint),
      disabled: c(disabled, other.disabled),
      successLight: c(successLight, other.successLight),
      successPale: c(successPale, other.successPale),
      successRing: c(successRing, other.successRing),
      successDark: c(successDark, other.successDark),
      tag: c(tag, other.tag),
      tagText: c(tagText, other.tagText),
      navActive: c(navActive, other.navActive),
      verified: c(verified, other.verified),
      star: c(star, other.star),
      pro: c(pro, other.pro),
      warning: c(warning, other.warning),
      successDisabled: c(successDisabled, other.successDisabled),
    );
  }
}

extension AppColorsContext on BuildContext {
  /// ألوان الثيم الحالي (فاتح أو داكن).
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
