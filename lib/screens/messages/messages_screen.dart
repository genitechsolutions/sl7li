import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../notifications/notifications_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/craftsman_avatar.dart';
import '../../data/chat_data.dart';
import '../../data/dummy_data.dart';
import '../new_request/new_request_screen.dart';
import 'chat_screen.dart';
import 'widgets/message_status_icon.dart';

/// "محادثاتي" — قائمة المحادثات مع الحرفيين (تاب "الرسائل").
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(context),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 2,
          // TODO: navigate to settings tab
          onTap: (index) {
            if (index == 0) Navigator.of(context).popUntil((r) => r.isFirst);
            if (index == 1) Navigator.of(context).pop();
          },
          onAddTap: () => Navigator.push(context, NewRequestScreen.route()),
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
                    AppIconButton(
                      icon: 'assets/icons/ic_bell.svg',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
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
                        child: Text(
                          'البحث في المحادثات...',
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sampleConversations.length,
                  itemBuilder: (context, i) => _ConversationRow(
                    conversation: sampleConversations[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(conversation: sampleConversations[i]),
                      ),
                    ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.time,
                  style: small.copyWith(
                    color: unread ? colors.verified : colors.textHint,
                  ),
                ),
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: colors.verified,
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
