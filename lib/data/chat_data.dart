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
    this.id,
    this.jobId,
    this.participant1Id,
    this.participant2Id,
  });

  final String? participant1Id;
  final String? participant2Id;

  /// معرّف المحادثة ومعرّف الطلب المرتبط بالخلفية.
  final String? id;
  final String? jobId;
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
enum ChatContent { text, requestCard, image, voice }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.sent,
    this.status = MessageStatus.read,
    this.content = ChatContent.text,
    this.image,
    this.voicePath,
    this.voiceKey,
    this.voiceSeconds = 0,
    this.id,
  });

  final String? id;

  /// تسجيل صوتي: مسار محلي (للمرسل) أو مفتاح S3 (للمستلم).
  final String? voicePath;
  final String? voiceKey;
  final int voiceSeconds;

  final String text;
  final String time;

  /// true = رسالتي (كحلي)، false = مستلمة.
  final bool sent;
  final MessageStatus status;
  final ChatContent content;
  final String? image;
}

/// نوع الإشعار (بيحدد الأيقونة واللون).
enum NotificationKind { offer, completion, withdrawn, message }

class NotificationItem {
  const NotificationItem({
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.actionLabel,
  });

  final NotificationKind kind;
  final String title;
  final String body;
  final String time;
  final bool unread;

  /// زر بآخر الكرت (مثلاً "الانتقال للخدمة").
  final String? actionLabel;
}
