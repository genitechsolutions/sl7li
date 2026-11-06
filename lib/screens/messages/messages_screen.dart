import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/arabic_search.dart';
import '../../core/widgets/notification_badge.dart';
import '../../core/theme/app_colors.dart';
import '../notifications/notifications_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/craftsman_avatar.dart';
import '../../data/chat_data.dart';
import '../../cubits/feature_cubits.dart';
import '../../cubits/load_view.dart';
import '../new_request/new_request_screen.dart';
import '../settings/settings_screen.dart';
import 'chat_screen.dart';
import 'widgets/message_status_icon.dart';

/// "محادثاتي" — قائمة المحادثات مع الحرفيين (تاب "الرسائل").
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.craftsmanMode = false});

  /// رسائل المهني: بدون الشريط السفلي، ومحادثات مع الزبائن.
  final bool craftsmanMode;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _search = TextEditingController();
  String _query = '';

  bool get craftsmanMode => widget.craftsmanMode;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: craftsmanMode
            ? null
            : AppBottomNavBar(
                currentIndex: 2,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                  if (index == 1) Navigator.of(context).pop();
                  if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }
                },
                onAddTap: () =>
                    Navigator.push(context, NewRequestScreen.route()),
              ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'محادثاتي',
                      style: AppTextStyles.title24Medium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    NotificationBadge(child: AppIconButton(
                      icon: 'assets/icons/ic_bell.svg',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.fieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_search_field.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          colors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (v) => setState(() => _query = v),
                          style: AppTextStyles.body16,
                          decoration: InputDecoration.collapsed(
                            hintText: 'البحث في المحادثات...',
                            hintStyle: AppTextStyles.body16.copyWith(color: colors.textHint),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() {
                            _search.clear();
                            _query = '';
                          }),
                          child: Icon(Icons.close, size: 20, color: colors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LoadView<ConversationsCubit, List<Conversation>>(
                  onInit: (c) => c.loadFor(professionalMode: craftsmanMode),
                  emptyText: 'لا توجد محادثات بعد',
                  isEmpty: (list) => list.isEmpty,
                  builder: (context, all) {
                    final list = all
                        .where((c) =>
                            arabicContains(c.name, _query) || arabicContains(c.lastMessage, _query))
                        .toList();
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'لا نتائج',
                          style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _ConversationRow(
                        conversation: list[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversation: list[i],
                              craftsmanMode: craftsmanMode,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.body12.copyWith(
      fontSize: 13,
      color: colors.textSecondary,
    );
    final unread = conversation.unread > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CraftsmanAvatar(
              image: 'assets/images/chat_avatar.png',
              isPro: conversation.isPro,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body16Medium,
                        ),
                      ),
                      if (conversation.verified) ...[
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/icons/ic_verified.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (conversation.sentStatus != null) ...[
                        MessageStatusIcon(status: conversation.sentStatus!),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.time,
                  style: small.copyWith(
                    color: unread ? colors.link : colors.textHint,
                  ),
                ),
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: colors.link,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Text(
                      '${conversation.unread}',
                      style: small.copyWith(color: colors.textOnPrimary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
