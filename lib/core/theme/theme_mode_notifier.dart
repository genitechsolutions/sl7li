import 'package:flutter/material.dart';

/// وضع الثيم الحالي. الافتراضي حسب الجهاز، وزر "الوضع المظلم" بالإعدادات بيبدّله.
/// (ValueNotifier عادي مش state management؛ بس مشان `MaterialApp` يعيد البناء.)
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
