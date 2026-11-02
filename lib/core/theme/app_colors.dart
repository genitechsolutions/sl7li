import 'package:flutter/material.dart';

/// ألوان التطبيق — مأخوذة من التصميم (فاتح + داكن).
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
    required this.textOnAccent,
    required this.successDisabled,
    required this.urgent,
    required this.destructive,
    required this.accentButton,
    required this.stepNextIcon,
    required this.barrier,
    required this.chatSent,
    required this.chatBarrier,
    required this.noticeSuccess,
    required this.noticeWarning,
    required this.noticeInfo,
    required this.chipText,
    required this.pageAlt,
    required this.cardAlt,
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

  /// نص فوق الأصفر (accent): غامق دايماً بالفاتح والداكن.
  final Color textOnAccent;

  /// زر النجاح المعطّل ("قبول العرض"). بالداكن مشتق (مش بالتصميم).
  final Color successDisabled;

  /// نص "طارئ" (بالداكن أفتح).
  final Color urgent;

  /// زر التحذير (حذف/إلغاء/اعتراض).
  final Color destructive;

  /// الأصفر كخلفية أزرار (بالداكن أغمق شوي).
  final Color accentButton;

  /// نص/رقم المراحل القادمة بشريط الطلب.
  final Color stepNextIcon;

  /// الفواصل الرفيعة بين النصوص (تاريخ | أولوية).
  final Color barrier;

  /// فقاعة الرسالة المرسلة بالدردشة.
  final Color chatSent;

  /// فاصل بطاقة الطلب داخل الدردشة.
  final Color chatBarrier;

  /// لون خلفية إشعار نجاح (10%).
  final Color noticeSuccess;

  /// لون خلفية إشعار تحذير (10%).
  final Color noticeWarning;

  /// لون خلفية إشعار معلومات (10%).
  final Color noticeInfo;

  /// نص التاغ/الشيبس (كحلي بالفاتح، رمادي فاتح بالداكن).
  final Color chipText;

  /// خلفية الصفحات "المعكوسة" (طلباتي، الإشعارات، الإعدادات…): رمادي بالفاتح، والأغمق بالداكن.
  final Color pageAlt;

  /// كروت الصفحات "المعكوسة": الفاتح بالفاتح، والأفتح (surface) بالداكن.
  final Color cardAlt;

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
    textOnAccent: Color(0xFF171922),
    successDisabled: Color(0xFFAFE7C4),
    urgent: Color(0xFFEB1809),
    destructive: Color(0xFFEB1809),
    accentButton: Color(0xFFF7C425),
    stepNextIcon: Color(0xFF989FBA),
    barrier: Color(0xFFC8CDDA),
    chatSent: Color(0xFF36407E),
    chatBarrier: Color(0xFFC8CDDA),
    noticeSuccess: Color(0xFF51CC7E),
    noticeWarning: Color(0xFFF48429),
    noticeInfo: Color(0xFF43A8DE),
    chipText: Color(0xFF36407E),
    pageAlt: Color(0xFFF0F0F5),
    cardAlt: Color(0xFFF9F9FB),
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
    success: Color(0xFF2E9D57),
    error: Color(0xFFDB3126),
    textHint: Color(0xFF989FBA),
    disabled: Color(0xFF373B52),
    successLight: Color(0xFF2E9D57),
    successPale: Color(0xFF1C3326),
    successRing: Color(0xFF2E7D4D),
    successDark: Color(0xFF71D595),
    tag: Color(0xFF2B3262),
    tagText: Color(0xFFDDDFEB),
    navActive: Color(0x268B94CD),
    verified: Color(0xFF2596D3),
    star: Color(0xFFF7C425),
    pro: Color(0xFFF8594D),
    warning: Color(0xFFF48429),
    textOnAccent: Color(0xFF171922),
    successDisabled: Color(0xFF2A5A3D),
    urgent: Color(0xFFF73426),
    destructive: Color(0xFFC41407),
    accentButton: Color(0xFFEBB409),
    stepNextIcon: Color(0xFF575F82),
    barrier: Color(0xFF27293A),
    chatSent: Color(0xFF1E2345),
    chatBarrier: Color(0xFF474D6A),
    noticeSuccess: Color(0xFF2E9D57),
    noticeWarning: Color(0xFFC15C0A),
    noticeInfo: Color(0xFF1F7DB0),
    chipText: Color(0xFFB0B6CA),
    pageAlt: Color(0xFF171922),
    cardAlt: Color(0xFF1F222E),
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
      textOnAccent: c(textOnAccent, other.textOnAccent),
      successDisabled: c(successDisabled, other.successDisabled),
      urgent: c(urgent, other.urgent),
      destructive: c(destructive, other.destructive),
      accentButton: c(accentButton, other.accentButton),
      stepNextIcon: c(stepNextIcon, other.stepNextIcon),
      barrier: c(barrier, other.barrier),
      chatSent: c(chatSent, other.chatSent),
      chatBarrier: c(chatBarrier, other.chatBarrier),
      noticeSuccess: c(noticeSuccess, other.noticeSuccess),
      noticeWarning: c(noticeWarning, other.noticeWarning),
      noticeInfo: c(noticeInfo, other.noticeInfo),
      chipText: c(chipText, other.chipText),
      pageAlt: c(pageAlt, other.pageAlt),
      cardAlt: c(cardAlt, other.cardAlt),
    );
  }
}

extension AppColorsContext on BuildContext {
  /// ألوان الثيم الحالي (فاتح أو داكن).
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
