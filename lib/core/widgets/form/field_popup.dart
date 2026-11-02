import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// قائمة لاصقة بحقل (تحته، أو فوقه لما [above]) بعرض الحقل نفسه، فوق باقي الصفحة.
class FieldPopup extends StatefulWidget {
  const FieldPopup({
    super.key,
    required this.isOpen,
    required this.onDismiss,
    required this.panel,
    required this.child,
    this.above = false,
  });

  final bool isOpen;
  final VoidCallback onDismiss;
  final Widget panel;
  final Widget child;
  final bool above;

  @override
  State<FieldPopup> createState() => _FieldPopupState();
}

class _FieldPopupState extends State<FieldPopup> {
  // المسافة بين الحقل والقائمة (6 بعد حدود الحقل الكحلي).
  static const _gap = 8.0;

  final _link = LayerLink();
  final _portal = OverlayPortalController();

  // الـ portal دايماً ظاهر (show ممنوعة وقت الـ build)، والقائمة نفسها بتنرسم بس لما [isOpen].
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: this,
      onTapOutside: (_) => widget.onDismiss(),
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (_) {
          if (!widget.isOpen) return const SizedBox.shrink();
          final width = (context.findRenderObject() as RenderBox?)?.size.width ?? 0;
          return Align(
            alignment: Alignment.topLeft,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: widget.above ? Alignment.topCenter : Alignment.bottomCenter,
              followerAnchor: widget.above ? Alignment.bottomCenter : Alignment.topCenter,
              offset: Offset(0, widget.above ? -_gap : _gap),
              child: TapRegion(
                groupId: this,
                child: SizedBox(width: width, child: widget.panel),
              ),
            ),
          );
        },
        child: CompositedTransformTarget(link: _link, child: widget.child),
      ),
    );
  }
}

/// صندوق القائمة: خلفية فاتحة، ظل ناعم، واختيارياً خط كحلي تحت ([accentBottom]).
class FieldPopupPanel extends StatelessWidget {
  const FieldPopupPanel({super.key, required this.child, this.accentBottom = false});

  final Widget child;
  final bool accentBottom;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: context.colors.primary.withValues(alpha: 0.12), blurRadius: 24),
          ],
        ),
        child: accentBottom
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  ColoredBox(color: context.colors.primary, child: SizedBox(height: 4)),
                ],
              )
            : child,
      ),
    );
  }
}

/// سطر خيار بالقائمة؛ المختار خلفيته رمادية.
class FieldPopupItem extends StatelessWidget {
  const FieldPopupItem({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.height = 40,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: selected ? context.colors.fieldFill : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.body16),
      ),
    );
  }
}
