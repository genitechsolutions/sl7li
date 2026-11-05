import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/dashed_border_box.dart';
import '../../../core/widgets/photo_source.dart';

/// رفع الصور: صندوق كبير لما ما في صور، وبعدها شبكة صور مع مربع إضافة.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photos,
    required this.maxPhotos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final int maxPhotos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return GestureDetector(
        onTap: onAdd,
        child: DashedBorderBox(
          height: 146,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_upload_outlined, size: 40, color: context.colors.textSecondary),
                const SizedBox(height: 12),
                const Text('إضغط لإضافة صور', style: AppTextStyles.body14Medium),
                const SizedBox(height: 4),
                Text(
                  'يمكنك رفع حتى $maxPhotos صور',
                  style: AppTextStyles.body12.copyWith(color: context.colors.textHint),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 13,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < photos.length; i++)
          Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: photoImage(photos[i]),
              ),
              PositionedDirectional(
                top: 8,
                start: 7,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: context.colors.error, shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 13, color: context.colors.textOnPrimary),
                  ),
                ),
              ),
            ],
          ),
        if (photos.length < maxPhotos)
          GestureDetector(
            onTap: onAdd,
            child: DashedBorderBox(
              child: Center(
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 40,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
