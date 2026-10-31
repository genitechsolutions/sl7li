import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// فتح نافذة منبثقة مع خلفية معتمة ومموّهة (متل تصميم "طلباتي").
Future<T?> showAppModal<T>(BuildContext context, WidgetBuilder builder) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, _, _) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: builder(context),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class AppDialogCard extends StatelessWidget {
  const AppDialogCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class AppDialogButton extends StatelessWidget {
  const AppDialogButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// دائرة ملونة 36 فيها أيقونة (ممنوع / نجمة) بجنب عنوان النافذة.
class AppDialogBadge extends StatelessWidget {
  const AppDialogBadge({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }
}
