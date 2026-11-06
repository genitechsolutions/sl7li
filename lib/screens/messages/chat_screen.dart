import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/widgets/photo_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/feature_cubits.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/craftsman_avatar.dart';
import '../../data/chat_data.dart';
import '../../data/dummy_data.dart';
import '../my_requests/request_details_screen.dart';
import '../my_requests/dialogs/request_dialogs.dart';
import '../../core/backend/backend_exception.dart';
import '../../core/voice/voice_recorder.dart';
import '../reports/report_dialog.dart';
import 'widgets/message_status_icon.dart';
import '../../cubits/unread_count_cubit.dart';
import 'widgets/voice_bubble.dart';

/// دردشة مع حرفي: رسائل، بطاقة الطلب، صور، وشريط كتابة.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
    this.firstTime = false,
    this.craftsmanMode = false,
  });

  final Conversation conversation;

  /// المهني بيحكي مع زبون: بدون شارات Pro/توثيق، وقائمة الخيارات فيها "إبلاغ" بس.
  final bool craftsmanMode;

  /// أول مرة بتفتح المحادثة: بتبيّن بطاقة الحرفي و"رسائل غير مقروءة".
  final bool firstTime;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late List<ChatMessage> _messages = [...sampleChat];

  // بعد ما نبعد عن بطاقة الطلب (فوق) بنبيّن "العودة للعرض"، وبعد ما نبعد عن الآخر بنبيّن زر النزول.
  bool _showBackToRequest = false;
  bool _showToBottom = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    _loadMessages();
  }

  /// محادثة حقيقية (إلها id) ← رسائلها من الخلفية؛ غير هيك بنضل على العينة.
  Future<void> _loadMessages() async {
    final id = widget.conversation.id;
    if (id == null) return;
    try {
      final cubit = context.read<ConversationsCubit>();
      final loaded = await cubit.messages(id);
      if (!mounted) return;
      setState(() => _messages = [...loaded]);
      unawaited(cubit.markRead(id).catchError((Object _) {}));
      unawaited(context.read<UnreadCountCubit>().markConversation(id));
    } on Object {
      // نكمّل بالعينة.
    }
    if (mounted) _listen();
  }

  void _listen() {
    _live?.cancel();
    final cubit = context.read<ConversationsCubit>();
    _live = cubit
        .liveMessages(widget.conversation)
        .listen(
          _onLive,
          onError: (Object _) => _reconnect(),
          onDone: _reconnect,
        );
  }

  void _reconnect() {
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted) _listen();
    });
  }

  void _onLive(ChatMessage m) {
    if (m.id != null && _messages.any((x) => x.id == m.id)) return;
    final nearBottom =
        !_scroll.hasClients || _scroll.position.maxScrollExtent - _scroll.position.pixels < 200;
    setState(() => _messages.add(m));
    final convId = widget.conversation.id;
    if (!m.sent && convId != null) {
      unawaited(context.read<ConversationsCubit>().markRead(convId).catchError((Object _) {}));
    }
    if (nearBottom || m.sent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scrollTo(_scroll.position.maxScrollExtent);
      });
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final back = pos.pixels > 160;
    final bottom = pos.maxScrollExtent - pos.pixels > 160;
    if (back != _showBackToRequest || bottom != _showToBottom) {
      setState(() {
        _showBackToRequest = back;
        _showToBottom = bottom;
      });
    }
  }

  void _scrollTo(double offset) => _scroll.animateTo(
    offset,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _recTimer?.cancel();
    _live?.cancel();
    _voice.dispose();
    super.dispose();
  }

  final _voice = VoiceRecorder();
  StreamSubscription<ChatMessage>? _live;
  bool _recording = false;
  Timer? _recTimer;
  int _recSeconds = 0;

  bool get _canSend => _controller.text.trim().isNotEmpty;

  Future<void> _startRecording() async {
    final ok = await _voice.start();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('اسمح للتطبيق باستخدام المايكروفون')));
      return;
    }
    setState(() {
      _recording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _recSeconds++));
  }

  Future<void> _cancelRecording() async {
    _recTimer?.cancel();
    await _voice.cancel();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _sendRecording() async {
    _recTimer?.cancel();
    final rec = await _voice.stop();
    if (!mounted) return;
    setState(() => _recording = false);
    if (rec == null) return;
    final index = _messages.length;
    setState(() {
      _messages.add(
        ChatMessage(
          text: '',
          time: '2:10 م',
          sent: true,
          status: MessageStatus.sending,
          content: ChatContent.voice,
          voicePath: rec.path,
          voiceSeconds: rec.seconds,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scrollTo(_scroll.position.maxScrollExtent);
    });
    try {
      final sent = await context.read<ConversationsCubit>().sendVoice(
        widget.conversation,
        rec.path,
        rec.seconds,
      );
      if (mounted && index < _messages.length) setState(() => _messages[index] = sent);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _messages.removeAt(index));
      final text = e is BackendException ? e.message : 'تعذّر إرسال التسجيل';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _confirmDelete(ChatMessage m) async {
    final ok = await showAppModal<bool>(
      context,
      (c) => _DeleteMessageDialog(onClose: (v) => Navigator.of(c).pop(v)),
    );
    if (ok != true || !mounted) return;
    final index = _messages.indexOf(m);
    if (index < 0) return;
    setState(() => _messages.removeAt(index));
    final id = m.id;
    if (id == null || widget.conversation.id == null) return;
    try {
      await context.read<ConversationsCubit>().deleteMessage(id);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _messages.insert(index.clamp(0, _messages.length), m));
      _snack(e is BackendException ? e.message : 'تعذّر حذف الرسالة');
    }
  }

  Future<void> _sendImage() async {
    final picked = await pickPhotos(max: 1);
    if (picked.isEmpty || !mounted) return;
    final path = picked.first;
    if (widget.conversation.id != null) {
      try {
        await context.read<ConversationsCubit>().validateImage(widget.conversation);
      } on Object catch (e) {
        if (!mounted) return;
        _snack(e is BackendException ? e.message : 'تعذّر التحقق من الصورة');
        return;
      }
      if (!mounted) return;
    }
    final index = _messages.length;
    setState(() {
      _messages.add(
        ChatMessage(
          text: '',
          time: '2:10 م',
          sent: true,
          status: MessageStatus.sending,
          content: ChatContent.image,
          image: path,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scrollTo(_scroll.position.maxScrollExtent);
    });
    if (widget.conversation.id == null) return;
    try {
      final sent = await context.read<ConversationsCubit>().sendImage(widget.conversation, path);
      if (!mounted) return;
      final live = sent.id != null && _messages.any((x) => x.id == sent.id);
      setState(() {
        if (live) {
          _messages.removeAt(index);
        } else if (index < _messages.length) {
          _messages[index] = sent;
        }
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        if (index < _messages.length) _messages.removeAt(index);
      });
      final msg = e is BackendException ? e.message : 'تعذّر إرسال الصورة';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _send() async {
    if (!_canSend) return;
    final text = _controller.text.trim();
    _controller.clear();
    final index = _messages.length;
    setState(() {
      _messages.add(
        ChatMessage(text: text, time: '2:10 م', sent: true, status: MessageStatus.sending),
      );
    });
    if (widget.conversation.id == null) return;
    try {
      final sent = await context.read<ConversationsCubit>().sendText(widget.conversation, text);
      if (!mounted) return;
      final live = sent.id != null && _messages.any((x) => x.id == sent.id);
      setState(() {
        if (live) {
          _messages.removeAt(index);
        } else if (index < _messages.length) {
          _messages[index] = sent;
        }
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        if (index < _messages.length) _messages.removeAt(index);
      });
      _controller.text = text;
      final msg = e is BackendException ? e.message : 'تعذّر إرسال الرسالة';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          (Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: colors.surface,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _Header(
              conversation: widget.conversation,
              craftsmanMode: widget.craftsmanMode,
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: _ChatPattern()),
                  ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    children: [
                      if (widget.firstTime) ...[
                        _ProfileCard(conversation: widget.conversation),
                        const SizedBox(height: 16),
                        const _Pill('2 رسائل غير مقروءة'),
                        const SizedBox(height: 16),
                      ],
                      if (widget.conversation.id == null) ...[
                        const _RequestCardBubble(),
                        const SizedBox(height: 8),
                      ],
                      for (var i = 0; i < _messages.length; i++) ...[
                        if (i == 4 && widget.conversation.id == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: _Pill('اليوم')),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Bubble(
                            message: _messages[i],
                            onLongPress:
                                _messages[i].sent && _messages[i].status != MessageStatus.sending
                                ? () => _confirmDelete(_messages[i])
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_showBackToRequest)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _scrollTo(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accentButton,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'العودة للعرض',
                                  style: AppTextStyles.body12.copyWith(
                                    fontSize: 13,
                                    color: colors.textOnAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                RotatedBox(
                                  quarterTurns: 2,
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_chevron_down.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      colors.textOnAccent,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_showToBottom)
                    PositionedDirectional(
                      end: 20,
                      bottom: 16,
                      child: GestureDetector(
                        onTap: () =>
                            _scrollTo(_scroll.position.maxScrollExtent),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/ic_chevron_down.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              colors.primaryContent,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _Composer(
              controller: _controller,
              canSend: _canSend,
              onSend: _send,
              onAttach: _sendImage,
              recording: _recording,
              recSeconds: _recSeconds,
              onMic: _startRecording,
              onCancelRecording: _cancelRecording,
              onSendRecording: _sendRecording,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conversation, this.craftsmanMode = false});

  final Conversation conversation;
  final bool craftsmanMode;

  Set<String> get _participants => {
    ?conversation.participant1Id,
    ?conversation.participant2Id,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SvgPicture.asset(
                  'assets/icons/ic_arrow_back.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colors.primaryContent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CraftsmanAvatar(
                image: 'assets/images/chat_header_avatar.png',
                isPro: !craftsmanMode,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        conversation.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body16Medium,
                      ),
                    ),
                    if (!craftsmanMode) ...[
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/ic_verified.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: colors.background,
                surfaceTintColor: Colors.transparent,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(minWidth: 189, maxWidth: 189),
                offset: const Offset(0, 36),
                onSelected: (value) {
                  switch (value) {
                    case 'agree':
                      final jobId = conversation.jobId;
                      if (jobId == null) {
                        showAgreementDialog(context);
                      } else {
                        agreeWithOffer(
                          context,
                          jobId,
                          preferProfessionalIds: _participants,
                        );
                      }
                    case 'rate':
                      rateProfessional(
                        context,
                        jobId: conversation.jobId,
                        professionalIds: _participants,
                        name: conversation.name,
                      );
                    case 'report':
                      reportConversationOffer(
                        context,
                        jobId: conversation.jobId,
                        professionalIds: _participants,
                        name: conversation.name,
                      );
                  }
                },
                itemBuilder: (context) => [
                  if (!craftsmanMode)
                    _menuItem(
                      context,
                      'agree',
                      'الاتفاق مع المهني',
                      SvgPicture.asset(
                        'assets/icons/ic_menu_agree.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  if (!craftsmanMode)
                    _menuItem(
                      context,
                      'rate',
                      'تقييم المهني',
                      SvgPicture.asset(
                        'assets/icons/ic_menu_star.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  _menuItem(
                    context,
                    'report',
                    'إبلاغ',
                    SvgPicture.asset(
                      'assets/icons/ic_menu_report.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
                child: SvgPicture.asset(
                  'assets/icons/ic_more_vert_24.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colors.primaryContent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PopupMenuItem<String> _menuItem(
  BuildContext context,
  String value,
  String label,
  Widget icon,
) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.body16),
      ],
    ),
  );
}

/// نقشة صواعق خفيفة بخلفية الدردشة (Figma ما بيصدّرها كأصل، فبنرسمها من شكل الـ Bolt).
class _ChatPattern extends StatelessWidget {
  const _ChatPattern();

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textHint.withValues(alpha: 0.06);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          const cellW = 118.0;
          const cellH = 104.0;
          final cols = (box.maxWidth / cellW).ceil() + 1;
          final rows = (box.maxHeight / cellH).ceil() + 1;

          return ClipRect(
            child: Stack(
              children: [
                for (var r = 0; r < rows; r++)
                  for (var c = 0; c < cols; c++)
                    Positioned(
                      left: c * cellW + (r.isOdd ? cellW / 2 : 0) - 20,
                      top: r * cellH,
                      child: SvgPicture.asset(
                        'assets/icons/onboarding_bolt.svg',
                        width: 44,
                        height: 35,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Text(
          text,
          style: AppTextStyles.body12.copyWith(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CraftsmanAvatar(
            image: 'assets/images/chat_avatar.png',
            isPro: true,
            size: 74,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_open_external.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  colors.primaryContent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text('مركز النور للكهرباء', style: AppTextStyles.title18Medium),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/ic_verified.svg',
                width: 24,
                height: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_star.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(colors.star, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Text(
                '(128) 4.9',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body14.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colors.border,
              ),
              Text(
                'محترف موصى به',
                style: AppTextStyles.body14.copyWith(color: colors.verified),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '+963 939 316 463',
            textDirection: TextDirection.ltr,
            style: AppTextStyles.body16,
          ),
          const SizedBox(height: 12),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'قسم تأسيس واصلاح جميع الاعمال الكهربائية منزلي/مصانع . اصلاح منظومة ',
              style: AppTextStyles.body14.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'قراءة المزيد',
                  style: TextStyle(
                    color: colors.link,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.link,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// رسالة بطاقة الطلب (أول رسالة بالمحادثة) مع زر "عرض تفاصيل الطلب".
class _RequestCardBubble extends StatelessWidget {
  const _RequestCardBubble();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(12),
              topEnd: Radius.circular(12),
              bottomStart: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'طارئ',
                    style: AppTextStyles.body12.copyWith(
                      fontSize: 13,
                      color: colors.error,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: colors.chatBarrier,
                  ),
                  Flexible(
                    child: Text(
                      'طلب خدمة إصلاحات الكهربائية',
                      style: AppTextStyles.title18Medium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب',
                style: AppTextStyles.body16.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RequestDetailsScreen(request: sampleActiveRequests[0]),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    'عرض تفاصيل الطلب',
                    style: AppTextStyles.title18Medium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primaryContent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '2:10 م',
                style: AppTextStyles.body12.copyWith(
                  fontSize: 13,
                  color: colors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onLongPress});

  final ChatMessage message;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sent = message.sent;
    final bg = sent ? colors.chatSent : colors.background;
    final fg = sent ? colors.textOnPrimary : colors.textPrimary;
    final timeColor = sent ? colors.textOnPrimaryMuted : colors.textHint;
    const r = Radius.circular(12);

    return Align(
      alignment: sent
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadiusDirectional.only(
              topStart: r,
              topEnd: r,
              bottomStart: r,
              bottomEnd: sent ? Radius.zero : r,
            ),
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.content == ChatContent.image &&
                    message.image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 258,
                      height: 258,
                      child: photoImage(message.image!),
                    ),
                  ),
                  if (message.text.isNotEmpty) const SizedBox(height: 10),
                ],
                if (message.content == ChatContent.voice)
                  VoiceBubbleBody(message: message, color: fg)
                else if (message.content != ChatContent.image || message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: AppTextStyles.body18.copyWith(color: fg, height: 1.5),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.time,
                      style: AppTextStyles.body12.copyWith(
                        fontSize: 13,
                        color: timeColor,
                      ),
                    ),
                    if (sent) ...[
                      const SizedBox(width: 4),
                      MessageStatusIcon(status: message.status, onNavy: true),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _DeleteMessageDialog extends StatelessWidget {
  const _DeleteMessageDialog({required this.onClose});

  final ValueChanged<bool> onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppDialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('حذف الرسالة', style: AppTextStyles.title18Medium),
          const SizedBox(height: 8),
          Text(
            'هل تريد حذف هذه الرسالة؟ ما بتقدر ترجّعها.',
            style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          AppDialogButton(
            label: 'حذف الرسالة',
            background: colors.destructive,
            foreground: colors.textOnPrimary,
            onTap: () => onClose(true),
          ),
          const SizedBox(height: 8),
          AppDialogButton(
            label: 'إلغاء',
            background: colors.background,
            foreground: colors.primaryContent,
            border: colors.border,
            onTap: () => onClose(false),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.onAttach,
    required this.recording,
    required this.recSeconds,
    required this.onMic,
    required this.onCancelRecording,
    required this.onSendRecording,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool recording;
  final int recSeconds;
  final VoidCallback onMic;
  final VoidCallback onCancelRecording;
  final VoidCallback onSendRecording;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: recording ? onSendRecording : (canSend ? onSend : onMic),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: canSend || recording
                      ? SvgPicture.asset(
                          'assets/icons/ic_send_plane.svg',
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            colors.textOnPrimary,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(Icons.mic_none, size: 28, color: colors.textOnPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: recording ? 52 : null,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.fieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: recording
                      ? Row(
                          children: [
                            GestureDetector(
                              onTap: onCancelRecording,
                              child: Icon(Icons.delete_outline, color: colors.error, size: 26),
                            ),
                            const Spacer(),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(voiceDuration(recSeconds), style: AppTextStyles.body16),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                            ),
                          ],
                        )
                      : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          style: AppTextStyles.body16,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            hintStyle: AppTextStyles.body16.copyWith(
                              color: colors.textHint,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onAttach,
                        child: SvgPicture.asset(
                          'assets/icons/ic_attach.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            colors.primaryContent,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
