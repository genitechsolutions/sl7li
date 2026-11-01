import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// خانات رمز التأكيد. حقل نص واحد مخفي بياخد الأرقام، والخانات بس بتعرضها.
/// الرمز بينكتب من اليسار لليمين (أول رقم بأول خانة يسار).
class OtpInput extends StatefulWidget {
  const OtpInput({super.key, required this.controller, this.length = 6});

  final TextEditingController controller;
  final int length;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _focus.requestFocus,
      child: Stack(
        children: [
          // الحقل الحقيقي، مخفي ورا الخانات (نص ومؤشر شفاف بدل Opacity(0): الويب ما بيعطي
          // تركيز لحقل شفافيته 0).
          Positioned.fill(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, value, _) => Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                spacing: 8,
                children: [
                  for (var i = 0; i < widget.length; i++)
                    Expanded(child: _OtpBox(digit: i < value.text.length ? value.text[i] : null)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit});

  final String? digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primaryContent),
      ),
      child: Text(
        digit ?? '0',
        style: AppTextStyles.title24Medium.copyWith(
          color: digit != null ? context.colors.textPrimary : context.colors.textHint,
        ),
      ),
    );
  }
}
