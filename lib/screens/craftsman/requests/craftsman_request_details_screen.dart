import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/backend/backend_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../cubits/feature_cubits.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../data/chat_data.dart';
import '../../../data/craftsman_data.dart';
import '../../../data/my_request.dart';
import '../../messages/chat_screen.dart';
import '../../../data/dummy_data.dart';
import '../../my_requests/widgets/request_stepper.dart';
import 'offer_dialogs.dart';
import 'task_dialogs.dart';

/// تفاصيل طلب (عند المهني): صور، وصف، موقع، "تجاهل الطلب"، وأزرار "تقديم عرض" و"مراسلة الزبون".
class CraftsmanRequestDetailsScreen extends StatefulWidget {
  const CraftsmanRequestDetailsScreen({
    super.key,
    required this.request,
    this.offerSent = false,
  });

  final CraftsmanRequest request;
  final bool offerSent;

  @override
  State<CraftsmanRequestDetailsScreen> createState() =>
      _CraftsmanRequestDetailsScreenState();
}

class _CraftsmanRequestDetailsScreenState
    extends State<CraftsmanRequestDetailsScreen> {
  late bool _offerSent = widget.offerSent;
  RequestOffer? _mine;

  @override
  void initState() {
    super.initState();
    final id = widget.request.id;
    if (id != null) {
      context
          .read<CraftsmanJobsCubit>()
          .myProposal(id)
          .then((o) {
            if (!mounted) return;
            setState(() {
              _mine = o;
              if (o != null) _offerSent = true;
            });
          })
          .catchError((Object _) {});
    }
  }

  Future<void> _sendOffer() async {
    final sent = await showSendOfferFlow(
      context,
      requestTitle: widget.request.title,
      jobId: widget.request.id,
    );
    if (sent == true) setState(() => _offerSent = true);
  }

  Future<void> _message() async {
    if (!_offerSent) {
      final go = await showOfferFirstDialog(context);
      if (go == true && mounted) _sendOffer();
      return;
    }
    if (!mounted) return;
    var conversation = sampleConversations[0];
    final jobId = widget.request.id;
    if (jobId != null) {
      Conversation? found;
      try {
        found = await context.read<ConversationsCubit>().openForJob(
          jobId,
          widget.request.customerId,
        );
      } on BackendException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
      if (!mounted) return;
      if (found == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('تعذّر فتح المحادثة')));
        return;
      }
      conversation = found;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(conversation: conversation, craftsmanMode: true),
      ),
    );
  }

  Future<void> _ignore() async {
    final ok = await showIgnoreRequestDialog(context, jobId: widget.request.id);
    if (ok == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = AppTextStyles.body16Medium.copyWith(
      color: colors.textSecondary,
    );
    final r = widget.request;
    final isTask =
        r.state == CraftsmanRequestState.task ||
        r.state == CraftsmanRequestState.done;

    Widget box(Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );

    Widget wide(
      String text,
      Color bg, {
      IconData? icon,
      Widget? iconW,
      VoidCallback? onTap,
      Color? fg,
    }) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconW != null || icon != null) ...[
              iconW ?? Icon(icon, color: fg ?? colors.textOnPrimary, size: 22),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: AppTextStyles.title18Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: fg ?? colors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 7,
                children: [
                  if (!_offerSent)
                    wide('تقديم عرض', colors.success, onTap: _sendOffer),
                  if (r.state == CraftsmanRequestState.task)
                    wide(
                      'تحديث حالة الطلب',
                      colors.primary,
                      onTap: () async {
                        final res = await showTaskStatusDialog(
                          context,
                          jobId: r.id,
                          proposalId: _mine?.proposalId,
                        );
                        if (res == 'cancel' && r.id != null && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  wide(
                    'مراسلة الزبون',
                    isTask ? colors.accentButton : colors.primary,
                    fg: isTask ? colors.textOnAccent : null,
                    onTap: _message,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
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
                              r.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title20.copyWith(
                                color: colors.textOnPrimary,
                              ),
                            ),
                            Text(
                              'تاريخ الإنشاء: ${r.date}',
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
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  if (isTask) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RequestStepper(
                        stage: r.stage ?? 0,
                        labels: const [
                          'عرض\nمرسل',
                          'تم الاتفاق',
                          'قيد\nالتنفيذ',
                          'مكتمل',
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 12,
                        top: 20,
                        bottom: 8,
                      ),
                      child: Text('العرض المقدم:', style: label),
                    ),
                    _MyOffer(offer: _mine),
                  ],
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      bottom: 8,
                    ),
                    child: Text('الصور المرفقة:', style: label),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      for (
                        var i = 1;
                        i <= (r.id != null ? r.images.take(3).length : 3);
                        i++
                      )
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: r.id != null
                                  ? Image.network(
                                      r.images[i - 1],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/request_photo_$i.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 28,
                      bottom: 4,
                    ),
                    child: Text('وصف الطلب:', style: label),
                  ),
                  Text(
                    r.id != null
                        ? r.description
                        : '${r.description}, ${r.description}',
                    style: AppTextStyles.body18.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  box(
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.body16.copyWith(
                          color: colors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'مدى الإلحاح: '),
                          TextSpan(
                            text: r.urgency,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (r.id == null)
                    box(
                      Column(
                        children: [
                          Text(
                            'التاريخ والوقت المفضل',
                            style: AppTextStyles.body16.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'خلال الأسبوع القادم  |  بعد الظهر',
                            style: AppTextStyles.body16,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // TODO: الواتساب بيشتغل بس بعد تقديم عرض.
                  wide(
                    'التواصل عبر واتساب',
                    colors.success,
                    iconW: SvgPicture.asset(
                      'assets/icons/ic_whatsapp.svg',
                      width: 20,
                      height: 20,
                    ),
                    onTap: _message,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 24,
                      bottom: 4,
                    ),
                    child: Text('الموقع:', style: label),
                  ),
                  Text(r.location, style: AppTextStyles.body18),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 145,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/map_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  wide(
                    'تجاهل الطلب',
                    colors.destructive,
                    iconW: SvgPicture.asset(
                      'assets/icons/ic_block.svg',
                      width: 20,
                      height: 20,
                    ),
                    onTap: _ignore,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyOffer extends StatelessWidget {
  const _MyOffer({this.offer});

  final RequestOffer? offer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.textSecondary,
    );
    final green = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.success,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('الكلفة الأولية التقديرية', style: AppTextStyles.body16),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: offer == null ? '100 ' : '${offer!.price} ',
                      style: AppTextStyles.title20.copyWith(
                        color: colors.success,
                      ),
                    ),
                    TextSpan(
                      text: offer == null ? 'ليرة جديدة' : offer!.priceUnit,
                      style: AppTextStyles.body16.copyWith(
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('أجور الكشف والمواصلات', style: small),
              const Spacer(),
              Text(offer?.inspectionFee ?? 'مجاني', style: green),
            ],
          ),
          Row(
            children: [
              Text('أجور المواد والأدوات', style: small),
              const Spacer(),
              Text(offer?.materialsFee ?? '20 ليرة جديدة', style: green),
            ],
          ),
        ],
      ),
    );
  }
}
