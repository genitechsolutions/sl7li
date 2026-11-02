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
}

class FakeConversationsRepository implements ConversationsRepository {
  const FakeConversationsRepository();

  @override
  Future<List<Conversation>> list({required bool professionalMode}) async =>
      professionalMode ? sampleCustomerConversations : sampleConversations;

  @override
  Future<List<ChatMessage>> messages(String conversationId) async => sampleChat;
}

class RemoteConversationsRepository implements ConversationsRepository {
  const RemoteConversationsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

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
    // الأقدم أولاً (ترتيب الدردشة).
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
  return (
    message: ChatMessage(
      text: str(j, 'content') ?? '',
      time: arabicTime(created),
      sent: myId != null && str(j, 'senderId') == myId,
      status: status,
      // الصور الحقيقية لسا مش مربوطة؛ الرسالة النصية بتنعرض عادي.
      content: hasImages && (str(j, 'content') ?? '').isEmpty
          ? ChatContent.image
          : ChatContent.text,
    ),
    sortKey: created,
  );
}
