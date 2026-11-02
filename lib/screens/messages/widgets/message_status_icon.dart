import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/chat_data.dart';

/// علامات حالة الرسالة (ساعة، صح، صحين رمادي، صحين أزرق).
class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({
    super.key,
    required this.status,
    this.onNavy = false,
    this.size = 16,
  });

  final MessageStatus status;
  final bool onNavy;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (asset, color) = switch (status) {
      MessageStatus.sending => (
        'assets/icons/ic_msg_sending.svg',
        onNavy ? colors.textOnPrimaryMuted : colors.textSecondary,
      ),
      MessageStatus.sent => (
        'assets/icons/ic_msg_sent.svg',
        onNavy ? colors.textOnPrimary : colors.textSecondary,
      ),
      MessageStatus.delivered => (
        'assets/icons/ic_msg_delivered.svg',
        onNavy ? colors.textOnPrimaryMuted : colors.textSecondary,
      ),
      MessageStatus.read => ('assets/icons/ic_msg_read.svg', colors.link),
    };

    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
