import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../data/repositories/my_offers_repository.dart';
import 'create_offer_screen.dart';

/// قائمة الثلاث نقاط بكرت العرض: إيقاف/تفعيل، تعديل، حذف.
Future<void> showOfferMenu(BuildContext anchor, MyOffer offer) async {
  final colors = anchor.colors;
  final box = anchor.findRenderObject() as RenderBox;
  final overlay = Overlay.of(anchor).context.findRenderObject() as RenderBox;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final position = RelativeRect.fromLTRB(
    topLeft.dx,
    topLeft.dy + box.size.height + 4,
    overlay.size.width - topLeft.dx - box.size.width,
    0,
  );
  PopupMenuItem<String> item(
    String value,
    IconData icon,
    String label, {
    Color? color,
  }) => PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20, color: color ?? colors.textPrimary),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.body16.copyWith(color: color)),
      ],
    ),
  );
  final choice = await showMenu<String>(
    context: anchor,
    position: position,
    color: colors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    items: [
      if (offer.approved)
        offer.active
            ? item('toggle', Icons.pause_circle_outline, 'إيقاف العرض')
            : item('toggle', Icons.play_circle_outline, 'تفعيل العرض'),
      item('edit', Icons.edit_outlined, 'تعديل العرض'),
      item('delete', Icons.delete_outline, 'حذف العرض', color: colors.error),
    ],
  );
  if (!anchor.mounted) return;
  switch (choice) {
    case 'toggle':
      await _run(anchor, () => anchor.read<MyOffersCubit>().toggle(offer.id));
    case 'edit':
      await Navigator.push(
        anchor,
        MaterialPageRoute(builder: (_) => CreateOfferScreen(editing: offer)),
      );
    case 'delete':
      final ok = await showDeleteOfferDialog(anchor);
      if (ok == true && anchor.mounted) {
        await _run(anchor, () => anchor.read<MyOffersCubit>().delete(offer.id));
      }
  }
}

Future<void> _run(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on BackendException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
  }
}

/// نافذة تأكيد حذف العرض (true = حذف).
Future<bool?> showDeleteOfferDialog(BuildContext context) {
  return showAppModal<bool>(context, (context) {
    final colors = context.colors;
    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('حذف العرض', style: AppTextStyles.title18Medium),
          const SizedBox(height: 8),
          Text(
            'هل أنت متأكد من حذف هذا العرض؟ لا يمكن التراجع عن هذا الإجراء.',
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppDialogButton(
              label: 'حذف العرض',
              background: colors.destructive,
              foreground: colors.textOnPrimary,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ),
          AppDialogButton(
            label: 'رجوع',
            background: colors.background,
            foreground: colors.primaryContent,
            border: colors.border,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  });
}
