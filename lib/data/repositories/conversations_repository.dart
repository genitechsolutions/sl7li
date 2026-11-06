import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import '../../core/backend/app_config.dart';
import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_chat_extras.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../../core/backend/media_upload.dart';
import '../chat_data.dart';
import 'auth_repository.dart';
import '../dummy_data.dart';

/// قائمة المحادثات ("الرسائل").
abstract class ConversationsRepository {
  Future<List<Conversation>> list({required bool professionalMode});

  /// رسائل محادثة (الأقدم أولاً).
  Future<List<ChatMessage>> messages(String conversationId);

  /// بيرفع التسجيل وبيبعته كرسالة صوتية.
  Future<ChatMessage> sendVoice(Conversation conversation, String path, int seconds);

  /// رابط تشغيل تسجيل مستلم (null = غير متاح).
  Future<String?> voiceUrl(String key);

  Future<ChatMessage> sendText(Conversation conversation, String text);

  Future<ChatMessage> sendImage(Conversation conversation, String path);

  Future<void> markRead(String conversationId);

  /// بيتحقق قبل إرسال صورة (بيرمي BackendException إذا تجاوز الحد).
  Future<void> validateImage(Conversation conversation);

  /// حذف رسالة أنا كاتبها.
  Future<void> deleteMessage(String messageId);

  /// رقم واتساب المهني المعتمد للطلب (null = غير متاح).
  Future<String?> assignedWhatsApp(String jobId);

  /// بيفتح (أو بيعمل) محادثة الطلب بين الزبون والمهني الحالي.
  Future<void> ensureJobConversation(String jobId, String otherId, {bool asCustomer = false});

  /// رسائل جديدة مباشرة (من الطرف التاني ومن أجهزتي).
  Stream<ChatMessage> liveMessages(Conversation conversation);

  /// تحديثات مباشرة على رسائل موجودة (مقروءة/محذوفة).
  Stream<MessageEvent> liveUpdates(Conversation conversation);
}

class FakeConversationsRepository implements ConversationsRepository {
  const FakeConversationsRepository();

  @override
  Future<List<Conversation>> list({required bool professionalMode}) async =>
      professionalMode ? sampleCustomerConversations : sampleConversations;

  @override
  Future<List<ChatMessage>> messages(String conversationId) async => sampleChat;

  @override
  Future<ChatMessage> sendVoice(Conversation conversation, String path, int seconds) async =>
      ChatMessage(
        text: '',
        time: arabicTime(DateTime.now().toIso8601String()),
        sent: true,
        status: MessageStatus.sent,
        content: ChatContent.voice,
        voicePath: path,
        voiceSeconds: seconds,
      );

  @override
  Future<String?> voiceUrl(String key) async => null;

  @override
  Future<ChatMessage> sendImage(Conversation conversation, String path) async => ChatMessage(
    text: '',
    time: arabicTime(DateTime.now().toIso8601String()),
    sent: true,
    status: MessageStatus.sent,
    content: ChatContent.image,
    image: path,
  );

  @override
  Future<ChatMessage> sendText(Conversation conversation, String text) async => ChatMessage(
    text: text,
    time: arabicTime(DateTime.now().toIso8601String()),
    sent: true,
    status: MessageStatus.sent,
  );

  @override
  Future<void> markRead(String conversationId) async {}

  @override
  Future<void> validateImage(Conversation conversation) async {}

  @override
  Future<void> deleteMessage(String messageId) async {}

  @override
  Future<String?> assignedWhatsApp(String jobId) async => null;

  @override
  Future<void> ensureJobConversation(String jobId, String otherId, {bool asCustomer = false}) async {}

  @override
  Stream<ChatMessage> liveMessages(Conversation conversation) => const Stream.empty();

  @override
  Stream<MessageEvent> liveUpdates(Conversation conversation) => const Stream.empty();
}

class RemoteConversationsRepository implements ConversationsRepository {
  const RemoteConversationsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<ChatMessage> sendVoice(Conversation conversation, String path, int seconds) async {
    // نوع "image" لأن الخلفية ما بتقبل نوع صوت للدردشة؛ المسار بيكون قابل للقراءة من الطرفين.
    final key = await uploadMedia(
      _gateway,
      path,
      contentType: kIsWeb ? 'audio/webm' : 'audio/mp4',
      fileName: 'voice_${DateTime.now().millisecondsSinceEpoch}.${kIsWeb ? 'webm' : 'm4a'}',
    );
    final messageId = await _createMessage(
      conversation,
      'voice',
      jsonEncode({'voice': key, 'seconds': seconds}),
    );
    return ChatMessage(
      id: messageId,
      text: '',
      time: arabicTime(DateTime.now().toIso8601String()),
      sent: true,
      status: MessageStatus.sent,
      content: ChatContent.voice,
      voicePath: path,
      voiceKey: key,
      voiceSeconds: seconds,
    );
  }

  @override
  Future<ChatMessage> sendImage(Conversation conversation, String path) async {
    final key = await uploadMedia(_gateway, path);
    final id = await _createMessage(conversation, 'text', '', images: [key]);
    return ChatMessage(
      id: id,
      text: '',
      time: arabicTime(DateTime.now().toIso8601String()),
      sent: true,
      status: MessageStatus.sent,
      content: ChatContent.image,
      image: path,
    );
  }

  @override
  Future<ChatMessage> sendText(Conversation conversation, String text) async {
    final id = await _createMessage(conversation, 'text', text);
    return ChatMessage(
      id: id,
      text: text,
      time: arabicTime(DateTime.now().toIso8601String()),
      sent: true,
      status: MessageStatus.sent,
    );
  }

  Future<String?> _createMessage(
    Conversation c,
    String type,
    String content, {
    List<String> images = const [],
  }) async {
    final me = _auth.currentUserId;
    final id = c.id;
    final p1 = c.participant1Id;
    final p2 = c.participant2Id;
    if (me == null || id == null || p1 == null || p2 == null) {
      throw BackendException.unauthenticated;
    }
    final res = await _gateway.run(
      Gql.createMessage,
      variables: {
        'input': {
          'conversationId': id,
          'senderId': me,
          'participant1Id': p1,
          'participant2Id': p2,
          'type': type,
          'content': content,
          if (images.isNotEmpty) 'imageAttachments': images,
        },
      },
      mutation: true,
    );
    final created = asMap(res['createMessage']);
    if (created.isEmpty) throw const BackendException('تعذّر إرسال الرسالة');
    return str(created, 'id');
  }

  @override
  Future<void> ensureJobConversation(String jobId, String otherId, {bool asCustomer = false}) async {
    final me = _auth.currentUserId;
    if (me == null) throw BackendException.unauthenticated;
    await _gateway.run(
      Gql.findOrCreateJobConversation,
      variables: {'a': asCustomer ? me : otherId, 'b': asCustomer ? otherId : me, 'j': jobId},
      mutation: true,
    );
  }

  @override
  Future<void> validateImage(Conversation conversation) async {
    final id = conversation.id;
    if (id == null) return;
    final data = await _gateway.run(
      GqlChatExtras.validateImageCount,
      variables: {'conversationId': id, 'newImageCount': 1},
    );
    final msg = imageCountError(asMap(data['validateConversationImageCount']));
    if (msg != null) throw BackendException(msg);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _gateway.run(
      GqlChatExtras.deleteMessage,
      variables: {
        'input': {'id': messageId},
      },
      mutation: true,
    );
  }

  @override
  Future<String?> assignedWhatsApp(String jobId) async {
    final data = await _gateway.run(GqlChatExtras.assignedWhatsApp, variables: {'jobId': jobId});
    final res = asMap(data['getJobAssignedProfessionalWhatsAppSecure']);
    if (str(res, 'error') != null) return null;
    return str(res, 'whatsappNumber');
  }

  @override
  Future<void> markRead(String conversationId) async {
    await _gateway.run(
      Gql.markMessagesRead,
      variables: {'conversationId': conversationId},
      mutation: true,
    );
  }

  @override
  Stream<ChatMessage> liveMessages(Conversation conversation) {
    final id = conversation.id;
    final p1 = conversation.participant1Id;
    final p2 = conversation.participant2Id;
    if (id == null || p1 == null || p2 == null) return const Stream.empty();
    final me = _auth.currentUserId;
    // قاعدة owner: بنمرّر بس الحقل اللي قيمته أنا.
    return _gateway
        .subscribe(
          Gql.onCreateMessage,
          variables: {
            'filter': {
              'conversationId': {'eq': id},
            },
            if (me == p1) 'participant1Id': p1,
            if (me == p2) 'participant2Id': p2,
          },
        )
        .map((data) => asMap(data['onCreateMessage']))
        .where((j) => j.isNotEmpty)
        .map((j) => chatMessageFromJson(j, me).message);
  }

  @override
  Stream<MessageEvent> liveUpdates(Conversation conversation) {
    final id = conversation.id;
    final p1 = conversation.participant1Id;
    final p2 = conversation.participant2Id;
    if (id == null || p1 == null || p2 == null) return const Stream.empty();
    final me = _auth.currentUserId;
    final vars = {
      'filter': {
        'conversationId': {'eq': id},
      },
      if (me == p1) 'participant1Id': p1,
      if (me == p2) 'participant2Id': p2,
    };
    late final StreamController<MessageEvent> out;
    final subs = <StreamSubscription<MessageEvent>>[];
    out = StreamController<MessageEvent>(
      onListen: () {
        subs.add(
          _gateway
              .subscribe(Gql.onUpdateMessage, variables: vars)
              .map((d) => asMap(d['onUpdateMessage']))
              .where((j) => str(j, 'id') != null)
              .map((j) => MessageEvent(id: str(j, 'id')!, status: messageStatusFrom(str(j, 'status'))))
              .listen(out.add, onError: out.addError),
        );
        subs.add(
          _gateway
              .subscribe(Gql.onDeleteMessage, variables: vars)
              .map((d) => asMap(d['onDeleteMessage']))
              .where((j) => str(j, 'id') != null)
              .map((j) => MessageEvent(id: str(j, 'id')!, deleted: true))
              .listen(out.add, onError: out.addError),
        );
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return out.stream;
  }

  @override
  Future<String?> voiceUrl(String key) async {
    if (AppConfig.env.storageBucket == null) return null;
    try {
      final res = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(key),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(expiresIn: Duration(minutes: 30)),
        ),
      ).result;
      return res.url.toString();
    } on StorageException {
      return null;
    }
  }

  @override
  Future<List<ChatMessage>> messages(String conversationId) async {
    final data = await _gateway.run(
      Gql.getConversationMessages,
      variables: {'conversationId': conversationId, 'limit': 100},
    );
    final res = asMap(data['getSecureConversationMessages']);
    throwIfBackendError(res);
    final me = _auth.currentUserId;
    final list = asMapList(res['messages'])
        .map((j) => chatMessageFromJson(j, me))
        .toList();
    list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return list.map((m) => m.message).toList();
  }

  @override
  Future<List<Conversation>> list({required bool professionalMode}) async {
    final data = await _gateway.run(
      Gql.getSecureUserConversations,
      variables: {'isProfessionalMode': professionalMode},
    );
    final res = asMap(data['getSecureUserConversations']);
    throwIfBackendError(res);
    return asMapList(res['conversations']).map(conversationFromJson).toList();
  }
}

/// رسالة خطأ لرد validateConversationImageCount (null = مسموح).
String? imageCountError(Map<String, dynamic> res) {
  final error = str(res, 'error');
  if (error != null) {
    return error.contains('Invalid image count')
        ? 'يمكنك إرفاق من 1 إلى 5 صور فقط في كل رسالة'
        : error;
  }
  if (res.isNotEmpty && res['canAttach'] == false) {
    return 'وصلت للحد الأقصى من الصور في هذه المحادثة (${intOf(res, 'maxAllowed') ?? 30})';
  }
  return null;
}

/// حقول Conversation + اسم الطرف الآخر (الخلفية بتضيفه بالرد؛ أسماء بديلة للاحتياط).
Conversation conversationFromJson(Map<String, dynamic> j) {
  final name =
      str(j, 'displayName') ??
      str(j, 'otherParticipantName') ??
      str(j, 'participantName') ??
      str(j, 'otherUserName') ??
      str(j, 'name') ??
      'محادثة';
  return Conversation(
    id: str(j, 'id'),
    jobId: str(j, 'jobId'),
    participant1Id: str(j, 'participant1Id'),
    participant2Id: str(j, 'participant2Id'),
    name: name,
    lastMessage: str(j, 'lastMessage') ?? '',
    time: arabicTime(str(j, 'lastMessageAt') ?? str(j, 'updatedAt')),
    isPro: boolOf(j, 'otherIsProfessional') || str(j, 'type') == 'professional',
    verified: boolOf(j, 'otherVerified'),
    unread: intOf(j, 'unreadCount') ?? 0,
  );
}

/// رسالة دردشة من الخلفية + مفتاح ترتيب زمني.
({ChatMessage message, String sortKey}) chatMessageFromJson(
  Map<String, dynamic> j,
  String? myId,
) {
  final images = strList(j, 'imageAttachments');
  final hasImages = images.isNotEmpty;
  final status = messageStatusFrom(str(j, 'status')) ?? MessageStatus.sent;
  final created = str(j, 'createdAt') ?? '';
  final isVoice = str(j, 'type') == 'voice';
  final voice = isVoice ? asMap(j['content']) : const <String, dynamic>{};
  return (
    message: ChatMessage(
      id: str(j, 'id'),
      text: isVoice ? '' : (str(j, 'content') ?? ''),
      voiceKey: isVoice ? str(voice, 'voice') : null,
      image: hasImages ? resourceUrl(images.first) : null,
      voiceSeconds: intOf(voice, 'seconds') ?? 0,
      time: arabicTime(created),
      sent: myId != null && str(j, 'senderId') == myId,
      status: status,
      content: isVoice
          ? ChatContent.voice
          : hasImages
          ? ChatContent.image
          : ChatContent.text,
    ),
    sortKey: created,
  );
}

/// حالة الرسالة بالخلفية ← حالة الواجهة (null إذا القيمة مش معروفة).
MessageStatus? messageStatusFrom(String? v) => switch (v) {
  'read' => MessageStatus.read,
  'delivered' => MessageStatus.delivered,
  'sending' => MessageStatus.sending,
  'sent' => MessageStatus.sent,
  _ => null,
};
