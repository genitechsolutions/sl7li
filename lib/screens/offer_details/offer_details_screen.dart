import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';
import '../../cubits/offer_details_cubit.dart';
import '../../core/widgets/app_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/craftsman_header.dart';
import '../craftsman_profile/craftsman_profile_screen.dart';
import '../../data/dummy_data.dart';
import 'widgets/offer_hero.dart';

class OfferDetailsScreen extends StatelessWidget {
  const OfferDetailsScreen({super.key, this.offerId});

  /// null = بيانات وهمية (عروض ما إلها id حقيقي).
  final String? offerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfferDetailsCubit(context.read<OffersCubit>(), offerId),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: LoadView<OfferDetailsCubit, OfferDetails>(
          builder: (context, details) => _OfferDetailsView(details: details),
        ),
      ),
    );
  }
}

class _OfferDetailsView extends StatelessWidget {
  const _OfferDetailsView({required this.details});

  final OfferDetails details;

  static const _padding = EdgeInsets.symmetric(horizontal: 20);
  // العناوين الفرعية بالتصميم داخلة 12 عن باقي المحتوى.
  static const _labelPadding = EdgeInsetsDirectional.only(start: 12);

  @override
  Widget build(BuildContext context) {
    final secondary = AppTextStyles.body16.copyWith(color: context.colors.textSecondary);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OfferHero(images: details.images, city: details.city),
              Padding(
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    Text(details.title, style: AppTextStyles.title20),
                    const SizedBox(height: 12),
                    Row(
                      spacing: 16,
                      children: [
                        Text(
                          details.discount,
                          style: AppTextStyles.title20.copyWith(color: context.colors.success),
                        ),
                        Text('ساري حتى ${details.validUntil}', style: secondary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: _labelPadding,
                      child: Text('وصف العرض:', style: secondary),
                    ),
                    const SizedBox(height: 8),
                    Text(details.description, style: AppTextStyles.body18.copyWith(height: 1.5)),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final tag in details.tags) AppChip(label: tag)],
                    ),
                    const SizedBox(height: 32),
                    CraftsmanHeader(
                      craftsman: details.craftsman,
                      trailing: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CraftsmanProfileScreen(profile: sampleCraftsmanProfile),
                          ),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.open_in_new_rounded,
                            size: 22,
                            color: context.colors.tagText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Padding(
                      padding: _labelPadding,
                      child: Text('صور العرض', style: secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: _padding,
                  itemCount: details.images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      details.images[index],
                      width: 116,
                      height: 150,
                      fit: BoxFit.cover,
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
