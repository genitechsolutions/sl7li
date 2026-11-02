import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

/// شاشة البداية: خلفية صفرا مع شعار "صلّحلي" على الـ Bolt الأبيض. بعد ثانيتين بتفتح الـ Onboarding.
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
      value: AppTheme.overlayStyle(context).copyWith(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.colors.accent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: const Alignment(0, -0.034),
              child: OverflowBox(
                maxWidth: 740,
                maxHeight: 668,
                child: SvgPicture.asset('assets/icons/splash_pattern.svg', width: 740, height: 668),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: OverflowBox(
                maxWidth: 494,
                maxHeight: 394,
                child: SvgPicture.asset('assets/icons/splash_bolt.svg', width: 494, height: 394),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 300,
                height: 96,
                child: FittedBox(child: _SplashLogo()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// الشعار مع الشعار اللفظي "كلشي بينحل" (ثلاث قطع SVG بنفس مواقعها بـ Figma، عرض 219.12).
class _SplashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 219.12,
      height: 70.21,
      child: Stack(
        children: [
          Positioned(
            left: 141.9,
            top: 0,
            width: 77.2,
            height: 70.2,
            child: SvgPicture.asset('assets/icons/splash_logo_186da.svg', fit: BoxFit.fill),
          ),
          Positioned(
            left: 0,
            top: 3.62,
            width: 130.57,
            height: 54.7,
            child: SvgPicture.asset('assets/icons/splash_logo_34079.svg', fit: BoxFit.fill),
          ),
          Positioned(
            left: 30.74,
            top: 45.45,
            width: 99.8,
            height: 20.06,
            child: SvgPicture.asset('assets/icons/splash_logo_87802.svg', fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
