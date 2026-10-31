import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/craftsman_header.dart';
import '../../core/widgets/offer_card.dart';
import '../../data/dummy_data.dart';
import '../new_request/new_request_screen.dart';
import '../offer_details/offer_details_screen.dart';
import 'widgets/expandable_bio.dart';
import 'widgets/info_tile.dart';
import 'widgets/profile_top_bar.dart';
import 'widgets/review_card.dart';

class CraftsmanProfileScreen extends StatefulWidget {
  const CraftsmanProfileScreen({
    super.key,
    required this.profile,
    this.selfView = false,
  });

  final CraftsmanProfile profile;

  /// المهني بيشوف صفحته العامة: الزر السفلي بيرجّعه للملف الشخصي.
  final bool selfView;

  @override
  State<CraftsmanProfileScreen> createState() => _CraftsmanProfileScreenState();
}

class _CraftsmanProfileScreenState extends State<CraftsmanProfileScreen> {
  static const _padding = EdgeInsets.symmetric(horizontal: 20);
  // العناوين الفرعية بالتصميم داخلة 12 عن باقي المحتوى.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  int _tab = 1;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: widget.selfView
              ? 'العودة للملف الشخصي'
              : 'اطلب عرض سعر من المهني',
          onPressed: () => widget.selfView
              ? Navigator.pop(context)
              : Navigator.push(context, NewRequestScreen.route()),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileTopBar(onShareTap: () {}), // TODO: share
              Padding(
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    CraftsmanHeader(craftsman: profile.craftsman),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 20),
                      child: ExpandableBio(
                        text: profile.bio,
                        previewLength: profile.bioPreviewLength,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 22,
                          color: context.colors.textPrimary,
                        ),
                        Text(
                          profile.craftsman.location,
                          style: AppTextStyles.body18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    InfoTile(label: 'الخبرة', value: profile.experience),
                    const SizedBox(height: 4),
                    InfoTile(label: 'الأدوات', value: profile.tools),
                    const SizedBox(height: 4),
                    InfoTile(label: 'التنقل', value: profile.transport),
                    const SizedBox(height: 36),
                    const Padding(
                      padding: _labelPadding,
                      child: Text(
                        'التخصصات المتاحة',
                        style: AppTextStyles.title18Medium,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in profile.specialties) AppChip(label: s),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: _labelPadding,
                      child: Text(
                        'العروض الخاصة',
                        style: AppTextStyles.title18Medium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 212,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: _padding,
                  itemCount: profile.offers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 13),
                  itemBuilder: (_, index) => OfferCard(
                    offer: profile.offers[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OfferDetailsScreen(
                          details: sampleOfferDetails,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSegmentedControl(
                      options: const ['معرض الأعمال', 'آراء العملاء'],
                      selected: _tab,
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                    const SizedBox(height: 14),
                    if (_tab == 0)
                      _works(profile.works)
                    else
                      ..._reviews(profile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _reviews(CraftsmanProfile profile) {
    return [
      Padding(
        padding: _labelPadding,
        child: Row(
          spacing: 6,
          children: [
            Icon(Icons.star_rounded, size: 22, color: context.colors.star),
            Text('${profile.craftsman.rating}', style: AppTextStyles.body18),
            const Spacer(),
            Text(
              '${profile.reviews.length} مراجعات',
              style: AppTextStyles.body18,
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (final review in profile.reviews)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: ReviewCard(review: review),
        ),
    ];
  }

  Widget _works(List<String> works) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final image in works)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, fit: BoxFit.cover),
          ),
      ],
    );
  }
}
