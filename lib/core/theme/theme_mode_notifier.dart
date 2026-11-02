import 'package:flutter/material.dart';

/// وضع الثيم الحالي. الافتراضي حسب الجهاز، وزر "الوضع المظلم" بالإعدادات بيبدّله.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
