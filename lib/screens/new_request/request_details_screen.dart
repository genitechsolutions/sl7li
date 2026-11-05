import 'package:flutter/material.dart';
import '../../core/widgets/photo_source.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/form/app_select_field.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../../core/widgets/form/form_label.dart';
import '../../core/widgets/form/options_sheet.dart';
import '../../data/dummy_data.dart';
import '../../data/request_draft.dart';
import 'new_request_screen.dart';
import 'request_location_screen.dart';
import 'widgets/photo_picker.dart';
import 'widgets/request_step_header.dart';

/// طلب خدمة — الخطوة 2: تفاصيل الطلب.
class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.draft});

  final RequestDraft draft;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  static const _maxPhotos = 5;
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  RequestDraft get _draft => widget.draft;
  bool _showMore = false;

  Future<void> _addPhoto() async {
    final picked = await pickPhotos(max: _maxPhotos - _draft.photos.length);
    if (picked.isNotEmpty && mounted) setState(() => _draft.photos.addAll(picked));
  }

  @override
  Widget build(BuildContext context) {
    final secondary = AppTextStyles.body16.copyWith(color: context.colors.textSecondary);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'المتابعة',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RequestLocationScreen(draft: _draft)),
          ),
          secondaryLabel: 'رجوع للخطوة السابقة',
          onSecondaryPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            children: [
              RequestStepHeader(
                step: 2,
                totalSteps: 4,
                onCancel: () => NewRequestScreen.cancelFlow(context),
              ),
              const SizedBox(height: 22),
              const Center(child: Text('تفاصيل الطلب', style: AppTextStyles.title24Bold)),
              const SizedBox(height: 33),
              Row(
                children: [
                  const Expanded(child: FormLabel('إرفاق صور', note: '(اختياري)')),
                  Text(
                    '(${_draft.photos.length}/$_maxPhotos)',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.body12.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PhotoPicker(
                photos: _draft.photos,
                maxPhotos: _maxPhotos,
                onAdd: _addPhoto,
                onRemove: (i) => setState(() => _draft.photos.removeAt(i)),
              ),
              const SizedBox(height: 33),
              const Padding(
                padding: _labelPadding,
                child: Text('طريقة التواصل المفضلة', style: AppTextStyles.body16Medium),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _draft.allowWhatsapp
                          ? 'يسمح تواصل المهنيين عبر وتساب'
                          : 'تواصل المهنيين عبر التطبيق فقط',
                      style: secondary,
                    ),
                  ),
                  AppToggle(
                    value: _draft.allowWhatsapp,
                    onChanged: (v) => setState(() => _draft.allowWhatsapp = v),
                  ),
                ],
              ),
              const SizedBox(height: 52),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                  onTap: () => setState(() => _showMore = !_showMore),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'تفاصيل إضافية',
                              style: AppTextStyles.body16.copyWith(
                                color: context.colors.link,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.link,
                              ),
                            ),
                            TextSpan(
                              text: ' (اختياري)',
                              style: AppTextStyles.body12.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _showMore
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showMore) ..._moreDetails(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _moreDetails() {
    final sublabel = AppTextStyles.body14.copyWith(color: context.colors.textSecondary);

    return [
      const SizedBox(height: 36),
      const Padding(
        padding: _labelPadding,
        child: Text('مدى الإلحاح', style: AppTextStyles.body16Medium),
      ),
      const SizedBox(height: 8),
      AppSegmentedControl(
        options: RequestDraft.urgencyLevels,
        selected: _draft.urgency,
        onChanged: (i) => setState(() => _draft.urgency = i),
        height: 48,
        textStyle: AppTextStyles.body16,
      ),
      const SizedBox(height: 34),
      const Padding(
        padding: _labelPadding,
        child: Text('التاريخ والوقت المفضل لإنجاز المهمة', style: AppTextStyles.body16Medium),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: _labelPadding,
        child: Text('الموعد المفضل', style: sublabel),
      ),
      const SizedBox(height: 6),
      AppSelectField(
        hint: 'الموعد المفضل',
        value: _draft.preferredDate,
        onTap: () async {
          final value = await showOptionsSheet(
            context,
            title: 'الموعد المفضل',
            options: requestPreferredDates,
          );
          if (value != null) setState(() => _draft.preferredDate = value);
        },
      ),
      const SizedBox(height: 12),
      Padding(
        padding: _labelPadding,
        child: Text('الوقت المفضل', style: sublabel),
      ),
      const SizedBox(height: 6),
      AppSelectField(
        hint: 'الوقت المفضل',
        value: _draft.preferredTime,
        onTap: () async {
          final value = await showOptionsSheet(
            context,
            title: 'الوقت المفضل',
            options: requestPreferredTimes,
          );
          if (value != null) setState(() => _draft.preferredTime = value);
        },
      ),
    ];
  }
}
