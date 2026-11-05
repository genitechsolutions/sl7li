import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/backend/backend_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_segmented_control.dart';
import '../../core/widgets/form/app_toggle.dart';
import '../../cubits/feature_cubits.dart';
import '../../data/dummy_data.dart';
import '../../data/chat_data.dart';
import '../../data/my_request.dart';
import '../messages/chat_screen.dart';
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
  List<RequestOffer>? _proposals;
  RequestOffer? _selected;
  bool _offersFailed = false;

  bool get _real => widget.request.id != null;

  @override
  void initState() {
    super.initState();
    if (_real) _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final list = await context.read<MyRequestsCubit>().offers(
        widget.request.id!,
      );
      if (mounted) setState(() => _proposals = list);
    } on Object {
      if (mounted) setState(() => _offersFailed = true);
    }
  }

  Future<void> _update() async {
    if (await runUpdateStatusFlow(context, widget.request) && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _accept() async {
    final offer = _selected;
    final id = offer?.proposalId;
    if (offer == null || id == null) return;
    final ok = await _acceptOffer(context, id);
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _message() async {
    final offer = _selected;
    final jobId = widget.request.id;
    final proId = offer?.professionalId;
    if (jobId == null || proId == null) return;
    final conversation = await _openChat(context, jobId, proId);
    if (conversation == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );
  }

  List<RequestOffer> get _shownOffers => _real
      ? (_proposals ?? const [])
      : [sampleBestOffer, ...sampleOtherOffers];

  int get _offersCount =>
      _real ? (_proposals?.length ?? widget.request.offersCount ?? 0) : 3;

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
          selected: _real ? _selected : null,
          onAccept: _accept,
          onMessage: _message,
          onUpdate: _update,
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
                        options: ['التفاصيل', 'العروض ($_offersCount)'],
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
          child: OfferTile(
            offer: _real && _proposals?.isNotEmpty == true
                ? _proposals!.first
                : sampleOtherOffers[0],
            onOpen: () {},
          ),
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
      if (!_real || widget.request.images.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          child: Text('الصور المرفقة:', style: label),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              for (
                var i = 0;
                i < (_real ? widget.request.images.take(3).length : 3);
                i++
              ) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _real
                          ? Image.network(
                              widget.request.images[i],
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/request_photo_${i + 1}.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Text('وصف الطلب:', style: label),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Text(
          _real ? widget.request.description : 'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب',
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
                      text: _real
                          ? switch (widget.request.priority) {
                              RequestPriority.emergency => 'طارئ',
                              RequestPriority.urgent => 'عاجل',
                              RequestPriority.normal => 'عادي',
                            }
                          : 'عاجل',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ]),
            if (!_real)
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
        child: Text(
          _real ? (widget.request.location ?? '') : 'دمشق, مركز المدينة',
          style: AppTextStyles.body18,
        ),
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

  Widget _selectable(RequestOffer offer) {
    final selected = _real && identical(_selected, offer);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _real ? () => setState(() => _selected = selected ? null : offer) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.colors.successLight : Colors.transparent,
            width: 2,
          ),
        ),
        child: OfferTile(offer: offer, onOpen: () {}),
      ),
    );
  }

  List<Widget> _offers(BuildContext context) {
    final label = AppTextStyles.body16Medium.copyWith(
      color: context.colors.textSecondary,
    );
    final list = _shownOffers;
    if (_real && list.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
          child: Center(
            child: _proposals == null && !_offersFailed
                ? const CircularProgressIndicator()
                : Text(
                    _offersFailed ? 'تعذّر تحميل العروض' : 'ما وصلتك عروض لسا',
                    style: label,
                  ),
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
        child: Text('أفضل عرض:', style: label),
      ),
      // TODO: navigate to offer / craftsman profile
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _selectable(list.first),
      ),
      if (list.length > 1) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
          child: Text('باقي العروض:', style: label),
        ),
        for (final offer in list.skip(1))
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _selectable(offer),
          ),
      ],
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
    this.selected,
    this.onAccept,
    this.onMessage,
    this.onUpdate,
  });

  final MyRequest request;
  final bool offersTab;
  final RequestOffer? selected;
  final VoidCallback? onAccept;
  final VoidCallback? onMessage;
  final VoidCallback? onUpdate;
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
                        onTap: onUpdate,
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
                        onTap: onUpdate,
                      ),
                  ]
                : offersTab
                ? [
                    button(
                      'قبول العرض',
                      bg: selected == null
                          ? colors.successDisabled
                          : colors.success,
                      fg: colors.textOnPrimary,
                      onTap: selected == null ? null : onAccept,
                    ),
                    button(
                      'مراسلة المختص',
                      bg: colors.primary,
                      fg: colors.textOnPrimary,
                      onTap: selected == null ? null : onMessage,
                    ),
                  ]
                : [
                    button(
                      'تحديث حالة الطلب',
                      bg: colors.primary,
                      fg: colors.textOnPrimary,
                      onTap: onUpdate,
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

Future<bool> _acceptOffer(BuildContext context, String proposalId) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await context.read<MyRequestsCubit>().respondToOffer(proposalId, approve: true);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('تم الاتفاق مع المهني')));
    return true;
  } on Object catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e is BackendException ? e.message : 'تعذّر قبول العرض')));
    return false;
  }
}

Future<Conversation?> _openChat(BuildContext context, String jobId, String professionalId) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final c = await context.read<ConversationsCubit>().openWithProfessional(jobId, professionalId);
    if (c == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذّر فتح المحادثة')));
    }
    return c;
  } on Object {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('تعذّر فتح المحادثة')));
    return null;
  }
}
