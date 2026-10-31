import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/app_chip.dart';
import '../../data/dummy_data.dart';
import '../new_request/new_request_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, required this.details});

  final ServiceDetails details;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'أوصف مشكلتك واطلب عرض سعر',
          onPressed: () => Navigator.push(context, NewRequestScreen.route()),
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconButton(
                      icon: 'assets/icons/ic_arrow_back.svg',
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    AppIconButton(
                      icon: 'assets/icons/ic_share.svg',
                      onTap: () {}, // TODO: share
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    details.image,
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                // النصوص بالتصميم داخلة 12 عن حواف الصورة والتخصصات.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details.title, style: AppTextStyles.title20Medium),
                      const SizedBox(height: 13),
                      Text(
                        details.description,
                        style: AppTextStyles.body18.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 34),
                      const Text('التخصصات المتاحة', style: AppTextStyles.title18Medium),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final s in details.specialties) AppChip(label: s)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
