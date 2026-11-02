import 'package:flutter/material.dart';

/// الصورة الكبيرة فوق صفحات الدخول (الطاقية مع النقشة)، بنسخة للفاتح ونسخة للداكن.
class AuthHeroImage extends StatelessWidget {
  const AuthHeroImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Image.asset(
      isDark ? 'assets/images/otp_header_dark.png' : 'assets/images/otp_header.png',
      height: 263,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}
