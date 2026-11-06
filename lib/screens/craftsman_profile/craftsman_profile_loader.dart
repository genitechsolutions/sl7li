import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/share_app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/load_cubit.dart';
import '../../cubits/public_profile_cubit.dart';
import '../../data/dummy_data.dart';
import '../../data/repositories/public_profile_repository.dart';
import 'craftsman_profile_screen.dart';
import 'widgets/profile_top_bar.dart';

/// بيفتح صفحة المهني: بمعرّف حقيقي بيحمّلها من الخلفية، وبدونه (بيانات وهمية) بيعرض العيّنة.
void openCraftsmanProfile(
  BuildContext context, {
  String? professionalId,
  bool selfView = false,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => professionalId == null
          ? CraftsmanProfileScreen(profile: sampleCraftsmanProfile, selfView: selfView)
          : CraftsmanProfileLoader(professionalId: professionalId, selfView: selfView),
    ),
  );
}

class CraftsmanProfileLoader extends StatelessWidget {
  const CraftsmanProfileLoader({
    super.key,
    required this.professionalId,
    this.selfView = false,
  });

  final String professionalId;
  final bool selfView;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PublicProfileCubit(context.read<PublicProfileRepository>(), professionalId)..load(),
      child: BlocBuilder<PublicProfileCubit, LoadState<CraftsmanProfile>>(
        builder: (context, state) {
          final profile = state.data;
          if (profile != null) {
            return CraftsmanProfileScreen(profile: profile, selfView: selfView);
          }
          return _Placeholder(
            error: state.status == LoadStatus.failure ? (state.error ?? 'حدث خطأ') : null,
            onRetry: () => context.read<PublicProfileCubit>().load(force: true),
          );
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          ProfileTopBar(onShareTap: () => shareText(context, 'تعرّف على حرفيين موثوقين عبر تطبيق صلّحلي')),
          Expanded(
            child: Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: onRetry,
                            child: Text(
                              'إعادة المحاولة',
                              style: AppTextStyles.body16Medium.copyWith(
                                color: colors.link,
                                decoration: TextDecoration.underline,
                                decorationColor: colors.link,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
