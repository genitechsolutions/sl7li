import '../../cubits/feature_cubits.dart';
import '../../cubits/load_cubit.dart';
import '../../cubits/load_view.dart';
import 'package:flutter/material.dart';
import '../../core/backend/app_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../data/dummy_data.dart';
import '../../data/popular_services.dart';
import '../../data/repositories/offers_repository.dart';
import 'about_screen.dart';
import 'all_services_screen.dart';
import '../craftsman_profile/craftsman_profile_loader.dart';
import '../offer_details/offer_details_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import '../my_requests/my_requests_screen.dart';
import '../new_request/new_request_screen.dart';
import '../offers/offers_screen.dart';
import '../search/search_screen.dart';
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
                  child: LoadView<FeaturedOffersCubit, List<Offer>>(
                    emptyText: 'لا توجد عروض حالياً',
                    isEmpty: (offers) => offers.isEmpty,
                    builder: (context, offers) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: _padding,
                      itemCount: offers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 13),
                      itemBuilder: (_, index) => OfferCard(
                        offer: offers[index],
                        onTap: () => _openOfferDetails(context, offers[index].id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: _padding,
                  child: SectionHeader(title: 'حرفيون مميزون'),
                ),
                const SizedBox(height: 12),
                BlocBuilder<FeaturedOffersCubit, LoadState<List<Offer>>>(
                  builder: (context, state) {
                    final offers = state.data ?? const <Offer>[];
                    final fromOffers = featuredCraftsmenFromOffers(offers);
                    // وضع fake: العروض بلا مهنيين حقيقيين فنعرض العينة.
                    final craftsmen = state.hasData && offers.any((o) => o.professionalId != null)
                        ? fromOffers
                        : (AppConfig.mode == BackendMode.fake ? featuredCraftsmen : const <Craftsman>[]);
                    return Column(
                      children: [
                        for (final craftsman in craftsmen)
                          Padding(
                            padding: _padding.copyWith(bottom: 12),
                            child: CraftsmanCard(
                              craftsman: craftsman,
                              onTap: () => openCraftsmanProfile(
                                context,
                                professionalId: craftsman.professionalId,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: _padding,
                  child: HelpCard(
                    onLearnMoreTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openOfferDetails(BuildContext context, String? offerId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OfferDetailsScreen(offerId: offerId)),
    );
  }

  Widget _servicesGrid(BuildContext context) {
    final cards = [
      for (final service in popularServices)
        ServiceCard(
          label: service.name,
          image: service.image,
          icon: service.icon,
          onTap: () => Navigator.push(context, NewRequestScreen.route(serviceId: service.id)),
        ),
      ServiceCard(
        label: 'المزيد',
        icon: Icons.more_horiz,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllServicesScreen()),
        ),
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
