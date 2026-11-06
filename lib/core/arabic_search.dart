/// توحيد النص العربي للبحث: بدون تشكيل، وبتوحيد الألف والياء والتاء المربوطة.
String normalizeArabic(String input) {
  final b = StringBuffer();
  for (final r in input.toLowerCase().runes) {
    if ((r >= 0x064B && r <= 0x065F) || r == 0x0670 || r == 0x0640) continue;
    switch (r) {
      case 0x0622 || 0x0623 || 0x0625 || 0x0671:
        b.writeCharCode(0x0627);
      case 0x0649:
        b.writeCharCode(0x064A);
      case 0x0629:
        b.writeCharCode(0x0647);
      default:
        b.writeCharCode(r);
    }
  }
  return b.toString().trim();
}

/// هل [text] بيحتوي [query] بعد التوحيد (استعلام فاضي = مطابق).
bool arabicContains(String text, String query) {
  final q = normalizeArabic(query);
  return q.isEmpty || normalizeArabic(text).contains(q);
}
