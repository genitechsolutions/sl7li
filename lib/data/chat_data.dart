/// حالة تسليم الرسالة المرسلة.
enum MessageStatus { sending, sent, delivered, read }

/// محادثة بقائمة "الرسائل".
class Conversation {
  const Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isPro = true,
    this.verified = false,
    this.unread = 0,
    this.sentStatus,
  });

  final String name;
  final String lastMessage;
  final String time;
  final bool isPro;
  final bool verified;

  /// عدد الرسائل غير المقروءة (0 = ما في).
  final int unread;

  /// حالة آخر رسالة مرسلة (null = آخر رسالة مستلمة).
  final MessageStatus? sentStatus;
}

/// نوع محتوى رسالة الدردشة.
enum ChatContent { text, requestCard, image }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.sent,
    this.status = MessageStatus.read,
    this.content = ChatContent.text,
    this.image,
  });

  final String text;
  final String time;

  /// true = رسالتي (كحلي)، false = مستلمة.
  final bool sent;
  final MessageStatus status;
  final ChatContent content;
  final String? image;
}
