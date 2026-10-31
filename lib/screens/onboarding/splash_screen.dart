import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/svg_theme_colors.dart';
import 'onboarding_screen.dart';

/// شاشة البداية: خلفية صفرا مع الشعار. بعد ثانيتين بتفتح الـ Onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // شريط حالة غامق فوق الأصفر بالفاتح والداكن.
      value: AppTheme.overlayStyle(context).copyWith(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.colors.accent,
        body: Center(
          // TODO: asset — الـ Bolt الأبيض ونقشة الأيقونة خلف الشعار (Figma 148:822) محتاجين تصدير SVG.
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            width: 300,
            colorMapper: SvgThemeColors.of(context),
            theme: SvgTheme(currentColor: context.colors.primary),
          ),
        ),
      ),
    );
  }
}
