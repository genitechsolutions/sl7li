import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../../data/dummy_data.dart';
import '../../data/my_request.dart';
import 'dialogs/request_dialogs.dart';
import 'widgets/offer_tile.dart';
import 'widgets/request_stepper.dart';

/// تفاصيل الطلب: تاب "التفاصيل" (مراحل، صور، وصف، موقع) وتاب "العروض" (عروض الأسعار الواردة).
class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({
    super.key,
    required this.request,
    this.initialTab = 0,
    this.completionPending = false,
  });

  final MyRequest request;
  final int initialTab;

  /// المهني أبلغ عن إنجاز الطلب وبانتظار تأكيد الزبون (من الإشعارات).
  final bool completionPending;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late int _tab = widget.initialTab;
  bool _whatsapp = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: _BottomBar(
          request: widget.request,
          completionPending: widget.completionPending,
          offersTab: _tab == 1,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(request: widget.request),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (!widget.request.hasCraftsman)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: AppSegmentedControl(
                        options: ['التفاصيل', 'العروض (3)'],
                        selected: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                        height: 48,
                        textStyle: AppTextStyles.body16,
                      ),
                    ),
                  if (_tab == 0) ..._details(context) else ..._offers(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _details(BuildContext context) {
    final colors = context.colors;
    final label = AppTextStyles.body16Medium.copyWith(
      color: colors.textSecondary,
    );

    Widget infoBox(List<Widget> children) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );

    return [
      Padding(
        padding: EdgeInsets.fromLTRB(
          40,
          widget.request.hasCraftsman ? 28 : 20,
          40,
          0,
        ),
        child: RequestStepper(stage: widget.request.stage),
      ),
      if (widget.request.hasCraftsman) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
          child: Text('العرض المعتمد:', style: label),
        ),
        // TODO: navigate to offer / craftsman profile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OfferTile(offer: sampleOtherOffers[0], onOpen: () {}),
        ),
        if (widget.completionPending)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: colors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تأكيد إنجاز الطلب',
                        style: AppTextStyles.body16.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أبلغ المهني Mevora عن إنجاز هذا الطلب, يرجى تأكيد الإنجاز أو الاعتراض في حال عدم إنجاز العمل مع المهني',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.warning,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        child: Text('الصور المرفقة:', style: label),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          children: [
            for (var i = 1; i <= 3; i++) ...[
              if (i > 1) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/request_photo_$i.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Text('وصف الطلب:', style: label),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Text(
          'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب',
          style: AppTextStyles.body18.copyWith(height: 1.5),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          spacing: 4,
          children: [
            infoBox([
              Text.rich(
                TextSpan(
                  style: AppTextStyles.body16.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'مدى الإلحاح: '),
                    TextSpan(
                      text: 'عاجل',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ]),
            infoBox([
              Text(
                'التاريخ والوقت المفضل',
                style: AppTextStyles.body16.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.body16,
                  children: [
                    const TextSpan(text: 'خلال الأسبوع القادم  '),
                    TextSpan(
                      text: '|',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const TextSpan(text: '  بعد الظهر'),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(
          children: [
            Text('يسمح تواصل المهنيين عبر وتساب', style: AppTextStyles.body18),
            const Spacer(),
            AppToggle(
              value: _whatsapp,
              onChanged: (v) => setState(() => _whatsapp = v),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
        child: Text('الموقع:', style: label),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Text('دمشق, مركز المدينة', style: AppTextStyles.body18),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 175,
            width: double.infinity,
            child: Image.asset(
              'assets/images/map_placeholder.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _offers(BuildContext context) {
    final label = AppTextStyles.body16Medium.copyWith(
      color: context.colors.textSecondary,
    );

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
        child: Text('أفضل عرض:', style: label),
      ),
      // TODO: navigate to offer / craftsman profile
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: OfferTile(offer: sampleBestOffer, onOpen: () {}),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
        child: Text('باقي العروض:', style: label),
      ),
      for (final offer in sampleOtherOffers)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: OfferTile(offer: offer, onOpen: () {}),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.request});

  final MyRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.primary,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            children: [
              AppIconButton(
                icon: 'assets/icons/ic_arrow_back.svg',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title20.copyWith(
                        color: colors.textOnPrimary,
                      ),
                    ),
                    Text(
                      'تاريخ الإنشاء: ${request.date}',
                      style: AppTextStyles.body16.copyWith(
                        color: colors.textOnPrimaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.request,
    required this.offersTab,
    required this.completionPending,
  });

  final MyRequest request;
  final bool offersTab;
  final bool completionPending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget button(
      String label, {
      required Color bg,
      required Color fg,
      Color? border,
      VoidCallback? onTap,
    }) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Text(
          label,
          style: AppTextStyles.title18Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );

    final noActions =
        request.hasCraftsman &&
        (request.status == RequestStatus.canceled ||
            (request.status == RequestStatus.done && request.rated));
    if (noActions) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          // TODO: navigate to edit request / update status / accept offer / chat
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 7,
            children: request.hasCraftsman
                ? [
                    if (completionPending) ...[
                      button(
                        'تحديث حالة الطلب',
                        bg: colors.primary,
                        fg: colors.textOnPrimary,
                        onTap: () => runUpdateStatusFlow(context),
                      ),
                      // TODO: الاعتراض على الإنجاز (ما في نافذة بالتصميم)
                      button(
                        'الاعتراض على إنجاز الطلب',
                        bg: colors.destructive,
                        fg: colors.textOnPrimary,
                      ),
                    ] else if (request.status == RequestStatus.done &&
                        !request.rated)
                      button(
                        'تقييم الخدمة',
                        bg: colors.accentButton,
                        fg: colors.textOnAccent,
                        onTap: () => showRatingDialog(context),
                      )
                    else if (request.status == RequestStatus.active)
                      button(
                        'تحديث حالة الطلب',
                        bg: colors.primary,
                        fg: colors.textOnPrimary,
                        onTap: () => runUpdateStatusFlow(context),
                      ),
                  ]
                : offersTab
                ? [
                    button(
                      'قبول العرض',
                      bg: colors.successDisabled,
                      fg: colors.textOnPrimary,
                    ),
                    button(
                      'مراسلة المختص',
                      bg: colors.primary,
                      fg: colors.textOnPrimary,
                    ),
                  ]
                : [
                    button(
                      'تحديث حالة الطلب',
                      bg: colors.primary,
                      fg: colors.textOnPrimary,
                      onTap: () => runUpdateStatusFlow(context),
                    ),
                    button(
                      'تعديل الطلب',
                      bg: colors.background,
                      fg: colors.primaryContent,
                      border: colors.border,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
