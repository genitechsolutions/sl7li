import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../data/dummy_data.dart';
import '../craftsman_profile/craftsman_profile_screen.dart';
import '../offer_details/offer_details_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import '../my_requests/my_requests_screen.dart';
import '../new_request/new_request_screen.dart';
import '../offers/offers_screen.dart';
import '../search/search_screen.dart';
import '../service_details/service_details_screen.dart';
import '../../core/widgets/craftsman_card.dart';
import 'widgets/help_card.dart';
import '../../core/widgets/promo_banner.dart';
import 'widgets/home_header.dart';
import '../../core/widgets/offer_card.dart';
import 'widgets/section_header.dart';
import 'widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          // TODO: navigate to messages / settings tabs
          onTap: (index) {
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen()));
            }
            if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
            }
            if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }
          },
          onAddTap: () => Navigator.push(context, NewRequestScreen.route()),
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: _padding,
                  child: HomeHeader(
                    onSearchTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: _padding,
                  child: PromoBanner(
                    title: 'تواصل مع أفضل المهنيين',
                    subtitle: 'اعرض مشكلتك واحصل على أفضل العروض من مهنيين محترفين لحل مشكلتك',
                    buttonLabel: 'إيجاد حل لمشكلتك',
                    onPressed: () => Navigator.push(context, NewRequestScreen.route()),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: _padding,
                  child: SectionHeader(title: 'الخدمات الشائعة'),
                ),
                const SizedBox(height: 12),
                Padding(padding: _padding, child: _servicesGrid(context)),
                const SizedBox(height: 24),
                Padding(
                  padding: _padding,
                  child: SectionHeader(
                    title: 'العروض الخاصة',
                    onSeeAllTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OffersScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 212,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: _padding,
                    itemCount: specialOffers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 13),
                    itemBuilder: (_, index) => OfferCard(
                      offer: specialOffers[index],
                      onTap: () => _openOfferDetails(context),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: _padding,
                  child: SectionHeader(title: 'حرفيون مميزون'),
                ),
                const SizedBox(height: 12),
                for (final craftsman in featuredCraftsmen)
                  Padding(
                    padding: _padding.copyWith(bottom: 12),
                    child: CraftsmanCard(
                      craftsman: craftsman,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CraftsmanProfileScreen(profile: sampleCraftsmanProfile),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Padding(
                  padding: _padding,
                  child: HelpCard(onLearnMoreTap: () {}), // TODO: navigate to about
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openOfferDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfferDetailsScreen(details: sampleOfferDetails)),
    );
  }

  Widget _servicesGrid(BuildContext context) {
    final cards = [
      for (final service in popularServices)
        ServiceCard(
          label: service.name,
          image: service.image,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ServiceDetailsScreen(details: sampleServiceDetails),
            ),
          ),
        ),
      ServiceCard(
        label: 'المزيد',
        icon: Icons.more_horiz,
        onTap: () {}, // TODO: navigate to all services
      ),
    ];

    return Column(
      spacing: 12,
      children: [
        for (var row = 0; row < cards.length; row += 4)
          Row(
            spacing: 11,
            children: [for (final card in cards.skip(row).take(4)) Expanded(child: card)],
          ),
      ],
    );
  }
}
