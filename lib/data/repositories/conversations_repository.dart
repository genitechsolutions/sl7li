import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import '../../core/backend/app_config.dart';
import '../../core/backend/backend_exception.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
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
}

class RemoteConversationsRepository implements ConversationsRepository {
  const RemoteConversationsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<ChatMessage> sendVoice(Conversation conversation, String path, int seconds) async {
    final me = _auth.currentUserId;
    final id = conversation.id;
    final p1 = conversation.participant1Id;
    final p2 = conversation.participant2Id;
    if (me == null || id == null || p1 == null || p2 == null) {
      throw BackendException.unauthenticated;
    }
    final upload = await _gateway.run(
      Gql.generateUploadUrl,
      // نوع "image" لأن الخلفية ما بتقبل نوع صوت للدردشة؛ المسار بيكون قابل للقراءة من الطرفين.
      variables: {
        'fileType': 'image',
        'fileName': 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        'contentType': 'audio/mp4',
      },
      mutation: true,
    );
    final up = asMap(upload['generateUploadUrlSecure']);
    throwIfBackendError(up);
    final key = str(up, 'uploadUrl') == null ? null : str(up, 's3Key');
    if (key == null) throw const BackendException('تعذّر رفع التسجيل');
    await _putFile(str(up, 'uploadUrl')!, path);
    final res = await _gateway.run(
      Gql.createMessage,
      variables: {
        'input': {
          'conversationId': id,
          'senderId': me,
          'participant1Id': p1,
          'participant2Id': p2,
          'type': 'voice',
          'content': jsonEncode({'voice': key, 'seconds': seconds}),
        },
      },
      mutation: true,
    );
    if (asMap(res['createMessage']).isEmpty) throw const BackendException('تعذّر إرسال التسجيل');
    return ChatMessage(
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

  Future<void> _putFile(String url, String path) async {
    final bytes = await File(path).readAsBytes();
    final client = HttpClient();
    try {
      final req = await client.putUrl(Uri.parse(url));
      req.headers.contentType = ContentType('audio', 'mp4');
      req.add(bytes);
      final res = await req.close();
      await res.drain<void>();
      if (res.statusCode >= 300) throw const BackendException('تعذّر رفع التسجيل');
    } on SocketException {
      throw const BackendException('تعذّر الاتصال بالإنترنت');
    } finally {
      client.close();
    }
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
  final hasImages =
      asMapList(j['imageAttachments']).isNotEmpty ||
      (j['imageAttachments'] is List &&
          (j['imageAttachments'] as List).isNotEmpty);
  final status = switch (str(j, 'status')) {
    'read' => MessageStatus.read,
    'delivered' => MessageStatus.delivered,
    'sending' => MessageStatus.sending,
    _ => MessageStatus.sent,
  };
  final created = str(j, 'createdAt') ?? '';
  final isVoice = str(j, 'type') == 'voice';
  final voice = isVoice ? asMap(j['content']) : const <String, dynamic>{};
  return (
    message: ChatMessage(
      text: isVoice ? '' : (str(j, 'content') ?? ''),
      voiceKey: isVoice ? str(voice, 'voice') : null,
      voiceSeconds: intOf(voice, 'seconds') ?? 0,
      time: arabicTime(created),
      sent: myId != null && str(j, 'senderId') == myId,
      status: status,
      content: isVoice
          ? ChatContent.voice
          : hasImages && (str(j, 'content') ?? '').isEmpty
          ? ChatContent.image
          : ChatContent.text,
    ),
    sortKey: created,
  );
}
