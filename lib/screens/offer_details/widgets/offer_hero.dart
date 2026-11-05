import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/app_image.dart';

/// معرض صور العرض أعلى الصفحة (تحت شريط الحالة) مع زر الرجوع، المدينة، وعدّاد الصور.
class OfferHero extends StatefulWidget {
  const OfferHero({super.key, required this.images, required this.city});

  final List<String> images;
  final String city;

  @override
  State<OfferHero> createState() => _OfferHeroState();
}

class _OfferHeroState extends State<OfferHero> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 12;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: SizedBox(
        height: 265,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (_, index) =>
                  AppImage(widget.images[index], width: double.infinity, height: double.infinity),
            ),
            PositionedDirectional(
              top: top,
              start: 20,
              child: AppIconButton(
                icon: 'assets/icons/ic_arrow_back.svg',
                size: 40,
                onTap: () => Navigator.pop(context),
              ),
            ),
            PositionedDirectional(
              top: top,
              end: 20,
              child: _Pill(height: 32, child: Text(widget.city, style: AppTextStyles.body14)),
            ),
            PositionedDirectional(
              bottom: 14,
              start: 20,
              child: _Pill(
                height: 24,
                child: Text(
                  '${_page + 1} / ${widget.images.length}',
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.body14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(widthFactor: 1, child: child),
    );
  }
}
