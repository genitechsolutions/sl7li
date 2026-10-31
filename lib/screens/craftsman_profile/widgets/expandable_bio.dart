import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// نبذة الحرفي: بتظهر أول [previewLength] حرف مع رابط "قراءة المزيد".
class ExpandableBio extends StatefulWidget {
  const ExpandableBio({super.key, required this.text, required this.previewLength});

  final String text;
  final int previewLength;

  @override
  State<ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<ExpandableBio> {
  bool _expanded = false;
  late final _readMore = TapGestureRecognizer()..onTap = () => setState(() => _expanded = true);

  @override
  void dispose() {
    _readMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canExpand = !_expanded && widget.text.length > widget.previewLength;
    final style = AppTextStyles.body16.copyWith(color: context.colors.textSecondary, height: 1.5);

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: canExpand ? widget.text.substring(0, widget.previewLength) : widget.text),
          if (canExpand)
            TextSpan(
              text: ' قراءة المزيد',
              recognizer: _readMore,
              style: TextStyle(
                color: context.colors.link,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.link,
              ),
            ),
        ],
      ),
    );
  }
}
