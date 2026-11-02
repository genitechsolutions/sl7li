import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/header_action_button.dart';
import '../../data/dummy_data.dart';
import '../../data/request_draft.dart';
import 'request_sent_screen.dart';
import 'widgets/selectable_craftsman_card.dart';

/// "استهداف المهنيين": اختيار حتى 5 مهنيين لإرسال الطلب إلهم بشكل خاص.
class CraftsmanTargetingScreen extends StatefulWidget {
  const CraftsmanTargetingScreen({
    super.key,
    required this.craftsmen,
    this.draft,
  });

  /// مسودة الطلب اللي رح تنبعت (null بالعرض فقط).
  final RequestDraft? draft;

  final List<Craftsman> craftsmen;

  @override
  State<CraftsmanTargetingScreen> createState() =>
      _CraftsmanTargetingScreenState();
}

class _CraftsmanTargetingScreenState extends State<CraftsmanTargetingScreen> {
  static const _maxSelected = 5;

  final _selected = <int>{};

  void _toggle(int index) {
    setState(() {
      if (!_selected.remove(index) && _selected.length < _maxSelected) {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'إرسال الطلب',
          onPressed: _selected.isEmpty
              ? null
              : () {
                  final draft = widget.draft;
                  draft == null
                      ? RequestSentScreen.open(context)
                      : RequestSentScreen.submit(context, draft);
                },
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 11, 20, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'استهداف المهنيين',
                      style: AppTextStyles.title22Bold,
                    ),
                  ),
                  HeaderActionButton(
                    label: 'إلغاء',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'اختر الحرفيين المناسبين',
                        style: AppTextStyles.body14Medium,
                      ),
                    ),
                    Text(
                      '(محدد $_maxSelected/${_selected.length})',
                      style: AppTextStyles.body14.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < widget.craftsmen.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableCraftsmanCard(
                    craftsman: widget.craftsmen[i],
                    selected: _selected.contains(i),
                    onTap: () => _toggle(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
