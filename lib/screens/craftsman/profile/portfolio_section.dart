import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/backend/json_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/dashed_border_box.dart';
import '../../../core/widgets/photo_source.dart';
import '../../../cubits/professional_profile_cubit.dart';
import '../../../data/repositories/professional_profile_repository.dart';

/// معرض أعمال المهني: عدّاد، صور حقيقية (حذف بضغطة مطوّلة)، وصندوق إضافة صور.
class CraftsmanPortfolioSection extends StatefulWidget {
  const CraftsmanPortfolioSection({super.key});

  @override
  State<CraftsmanPortfolioSection> createState() => _PortfolioState();
}

class _PortfolioState extends State<CraftsmanPortfolioSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() task) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await task();
    } on BackendException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add(int current) async {
    final picked = await pickPhotos(max: professionalMaxPortfolio - current);
    if (picked.isEmpty || !mounted) return;
    await _run(
      () => context.read<ProfessionalProfileCubit>().addPortfolio(picked),
    );
  }

  Future<void> _remove(String key) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الصورة من المعرض؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(
      () => context.read<ProfessionalProfileCubit>().removePortfolio(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final keys = context.select(
      (ProfessionalProfileCubit c) =>
          c.state.data?.portfolio ?? const <String>[],
    );
    final loaded = context.select(
      (ProfessionalProfileCubit c) => c.state.hasData,
    );
    final full = keys.length >= professionalMaxPortfolio;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
          child: Row(
            children: [
              Text('معرض الأعمال', style: AppTextStyles.title18Medium),
              const Spacer(),
              Text(
                '(${keys.length}/$professionalMaxPortfolio)',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body12.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (keys.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final k in keys)
                  GestureDetector(
                    onLongPress: _busy ? null : () => _remove(k),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(resourceUrl(k)),
                    ),
                  ),
              ],
            ),
          ),
        if (!full)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _busy || !loaded ? null : () => _add(keys.length),
              child: DashedBorderBox(
                height: keys.isEmpty ? 146 : 88,
                child: Center(
                  child: _busy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.file_upload_outlined,
                              size: keys.isEmpty ? 40 : 28,
                              color: colors.textSecondary,
                            ),
                            SizedBox(height: keys.isEmpty ? 12 : 8),
                            Text(
                              'إضغط لإضافة صور',
                              style: AppTextStyles.body14Medium,
                            ),
                            if (keys.isEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'لا توجد صور في معرض أعمالك بعد',
                                style: AppTextStyles.body12.copyWith(
                                  color: colors.textHint,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
