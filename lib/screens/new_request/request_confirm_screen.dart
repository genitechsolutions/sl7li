import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_action_bar.dart';
import '../../data/dummy_data.dart';
import '../../data/request_draft.dart';
import 'craftsman_targeting_screen.dart';
import 'new_request_screen.dart';
import 'request_sent_screen.dart';
import 'widgets/request_step_header.dart';

/// طلب خدمة — الخطوة 4: تأكيد إرسال الطلب.
class RequestConfirmScreen extends StatefulWidget {
  const RequestConfirmScreen({super.key, required this.draft});

  final RequestDraft draft;

  @override
  State<RequestConfirmScreen> createState() => _RequestConfirmScreenState();
}

class _RequestConfirmScreenState extends State<RequestConfirmScreen> {
  // العناوين الفرعية بالتصميم داخلة 12.
  static const _labelPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  final _termsTap = TapGestureRecognizer()..onTap = () {}; // TODO: open terms
  final _privacyTap = TapGestureRecognizer()
    ..onTap = () {}; // TODO: open privacy policy

  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    final ok = await RequestSentScreen.submit(context, widget.draft);
    if (!ok && mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final summary = draft.summary;
    final linkStyle = AppTextStyles.body12.copyWith(
      color: context.colors.link,
      decoration: TextDecoration.underline,
      decorationColor: context.colors.link,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: AppBottomActionBar(
          label: 'إرسال الطلب',
          onPressed: _sending ? null : _send,
          secondaryLabel: 'رجوع للخطوة السابقة',
          onSecondaryPressed: () => Navigator.pop(context),
          note: Text.rich(
            TextSpan(
              style: AppTextStyles.body12.copyWith(
                color: context.colors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'بإرسال الطلب أنت توافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: linkStyle,
                  recognizer: _termsTap,
                ),
                const TextSpan(text: ' و '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: linkStyle,
                  recognizer: _privacyTap,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
            children: [
              RequestStepHeader(
                step: 4,
                totalSteps: 4,
                onCancel: () => NewRequestScreen.cancelFlow(context),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'تأكيد إرسال الطلب',
                  style: AppTextStyles.title24Bold,
                ),
              ),
              const SizedBox(height: 24),
              for (final (label, value) in summary)
                _SummaryRow(label: label, value: value, showDivider: true),
              _SummaryRow(
                label: 'استهداف المحترفين',
                value: 'اختيار المهنيين',
                showDivider: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CraftsmanTargetingScreen(
                      craftsmen: targetableCraftsmen,
                      draft: draft,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 23),
              const Padding(
                padding: _labelPadding,
                child: Text('الوصف', style: AppTextStyles.body16Medium),
              ),
              const SizedBox(height: 10),
              Text(
                draft.description,
                style: AppTextStyles.body16.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (draft.photos.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Padding(
                  padding: _labelPadding,
                  child: Text(
                    'الصور المرفوعة',
                    style: AppTextStyles.body16Medium,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final photo in draft.photos)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(photo, fit: BoxFit.cover),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.showDivider,
    this.onTap,
  });

  final String label;
  final String value;
  final bool showDivider;

  /// لما يكون موجود، السطر بيصير زر (القيمة زرقا مع سهم).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 41,
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: context.colors.border))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body16.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          if (onTap == null)
            Text(value, style: AppTextStyles.body16Medium)
          else ...[
            Text(
              value,
              style: AppTextStyles.body16Medium.copyWith(
                color: context.colors.link,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 22,
              color: context.colors.link,
            ),
          ],
        ],
      ),
    );

    return onTap == null
        ? row
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: row,
          );
  }
}
