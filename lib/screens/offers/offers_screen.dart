import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/filter_chip_button.dart';
import '../../core/widgets/form/options_sheet.dart';
import '../../cubits/load_cubit.dart';
import '../../data/dummy_data.dart';
import '../../data/repositories/craftsman_signup_repository.dart';
import '../offer_details/offer_details_screen.dart';
import 'widgets/offer_list_card.dart';

const _cityCodes = {
  'دمشق': 'damascus',
  'حلب': 'aleppo',
  'حمص': 'homs',
  'حماة': 'hama',
  'اللاذقية': 'latakia',
  'طرطوس': 'tartus',
  'درعا': 'daraa',
};

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                child: Row(
                  spacing: 20,
                  children: [
                    AppIconButton(
                      icon: 'assets/icons/ic_arrow_back.svg',
                      onTap: () => Navigator.pop(context),
                    ),
                    const Text('العروض الخاصة', style: AppTextStyles.title22Bold),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<OffersCubit, LoadState<List<Offer>>>(
                builder: (context, _) {
                  final cubit = context.read<OffersCubit>();
                  String? nameOf(Map<String, String> m, String? code) =>
                      m.entries.where((e) => e.value == code).firstOrNull?.key;
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    child: Row(
                      spacing: 10,
                      children: [
                        FilterChipButton(
                          label: nameOf(craftsmanServiceIds, cubit.serviceCategory) ?? 'نوع الخدمة',
                          onTap: () async {
                            final v = await showOptionsSheet(
                              context,
                              title: 'نوع الخدمة',
                              options: ['الكل', ...craftsmanServiceIds.keys],
                            );
                            if (v == null) return;
                            cubit.applyFilters(
                              cityCode: cubit.cityCode,
                              serviceCategory: craftsmanServiceIds[v],
                            );
                          },
                        ),
                        FilterChipButton(
                          label: nameOf(_cityCodes, cubit.cityCode) ?? 'المنطقة',
                          onTap: () async {
                            final v = await showOptionsSheet(
                              context,
                              title: 'المنطقة',
                              options: ['الكل', ..._cityCodes.keys],
                            );
                            if (v == null) return;
                            cubit.applyFilters(
                              cityCode: _cityCodes[v],
                              serviceCategory: cubit.serviceCategory,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: LoadView<OffersCubit, List<Offer>>(
                  emptyText: 'لا توجد عروض حالياً',
                  isEmpty: (offers) => offers.isEmpty,
                  builder: (context, offers) => ListView.separated(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 13, 20, 24),
                    itemCount: offers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => OfferListCard(
                      offer: offers[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OfferDetailsScreen(offerId: offers[index].id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
