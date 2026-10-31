import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../auth/phone_login_screen.dart';

/// 3 صفحات تعريفية (اطلب الخدمة / قارن العروض / اختر الأفضل) بعد شاشة البداية.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    ('اطلب الخدمة', 'صف المشكلة وتواصل مع مهنيين موثوقين قريبين منك جاهزين لاستلام طلبك'),
    ('قارن العروض', 'اطّلع على أعمال المهنيين السابقة والتقييمات وقارن عروض الأسعار'),
    ('اختر الأفضل', 'اختر المهني الأنسب لك وتابع الطلب حتى الإنجاز'),
  ];

  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _Page(title: _pages[i].$1, body: _pages[i].$2),
                ),
              ),
              // الأزرار بمكانها الفيزيائي متل التصميم: "التالي" يمين و"السابق" يسار.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _NavButton(
                                        flip: false,
                        filled: false,
                        onTap: _index == 0 ? null : () => _go(_index - 1),
                      ),
                      Expanded(child: Center(child: _Dots(count: _pages.length, index: _index))),
                      _isLast
                          ? _StartButton(onTap: _finish)
                          : _NavButton(
                                                    flip: true,
                              filled: true,
                              onTap: () => _go(_index + 1),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _finish,
                child: Text(
                  'تخطي',
                  style: AppTextStyles.body16.copyWith(
                    color: colors.link,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.link,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // TODO: asset — صورة المهني مع الـ Bolt الأصفر (Figma 149:1212 / 149:1129) محتاجة تصدير.
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title30Bold.copyWith(fontSize: 32, height: 1.8),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.title20.copyWith(color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: i == index ? 12 : 8,
            height: i == index ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? colors.accent : colors.accent.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.flip,
    required this.filled,
    required this.onTap,
  });

  final bool flip;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;
    final bg = filled ? colors.primary : colors.disabled;

    return Material(
      color: enabled || filled ? bg : colors.disabled,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Transform.flip(
              flipX: flip,
              // TODO: asset — سهم التصميم (Figma 149:1118) SVG؛ مؤقتاً أيقونة Material.
              child: Icon(Icons.arrow_back, size: 28, color: colors.textOnPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            'إبدأ الآن',
            style: AppTextStyles.title18Medium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
