import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/craftsman_avatar.dart';
import '../../data/chat_data.dart';
import '../../data/dummy_data.dart';
import '../my_requests/request_details_screen.dart';
import '../my_requests/dialogs/request_dialogs.dart';
import 'widgets/message_status_icon.dart';

/// دردشة مع حرفي: رسائل، بطاقة الطلب، صور، وشريط كتابة.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
    this.firstTime = false,
  });

  final Conversation conversation;

  /// أول مرة بتفتح المحادثة: بتبيّن بطاقة الحرفي و"رسائل غير مقروءة".
  final bool firstTime;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _messages = [...sampleChat];

  // بعد ما نبعد عن بطاقة الطلب (فوق) بنبيّن "العودة للعرض"، وبعد ما نبعد عن الآخر بنبيّن زر النزول.
  bool _showBackToRequest = false;
  bool _showToBottom = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _scroll.addListener(_onScroll);
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
    super.dispose();
  }

  bool get _canSend => _controller.text.trim().isNotEmpty;

  // TODO: إرسال حقيقي؛ هلق بس بيضيف الرسالة محلياً.
  void _send() {
    if (!_canSend) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: _controller.text.trim(),
          time: '2:10 م',
          sent: true,
          status: MessageStatus.sending,
        ),
      );
      _controller.clear();
    });
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
            _Header(conversation: widget.conversation),
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
                      const _RequestCardBubble(),
                      const SizedBox(height: 8),
                      for (var i = 0; i < _messages.length; i++) ...[
                        if (i == 4)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: _Pill('اليوم')),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Bubble(message: _messages[i]),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conversation});

  final Conversation conversation;

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
              const CraftsmanAvatar(
                image: 'assets/images/chat_header_avatar.png',
                isPro: true,
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
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/icons/ic_verified.svg',
                      width: 20,
                      height: 20,
                    ),
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
                      showAgreementDialog(context);
                    case 'rate':
                      showRatingDialog(context);
                    // TODO: إبلاغ (ما في تصميم لنافذة الإبلاغ)
                  }
                },
                itemBuilder: (context) => [
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
            size: 100,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Text(
                'محترف موصى به',
                style: AppTextStyles.body14.copyWith(color: colors.verified),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colors.border,
              ),
              Text(
                '(128) 4.9',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body14.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/icons/ic_star.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(colors.star, BlendMode.srcIn),
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
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sent = message.sent;
    final bg = sent ? colors.chatSent : colors.background;
    final fg = sent ? colors.textOnPrimary : colors.textPrimary;
    final timeColor = sent ? colors.textOnPrimaryMuted : colors.textHint;
    const r = Radius.circular(12);

    return Align(
      // المرسلة على اليسار والمستلمة على اليمين (متل التصميم).
      alignment: sent
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
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
                    child: Image.asset(
                      message.image!,
                      fit: BoxFit.cover,
                      width: 258,
                      height: 258,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

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
                onTap: onSend,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: canSend ? colors.primary : colors.disabled,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/ic_send_plane.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      colors.textOnPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.fieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
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
                      // TODO: اختيار ملف/صورة حقيقي (image_picker)
                      SvgPicture.asset(
                        'assets/icons/ic_attach.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primaryContent,
                          BlendMode.srcIn,
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
