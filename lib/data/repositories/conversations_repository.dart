import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../chat_data.dart';
import '../dummy_data.dart';

/// قائمة المحادثات ("الرسائل").
abstract class ConversationsRepository {
  Future<List<Conversation>> list({required bool professionalMode});
}

class FakeConversationsRepository implements ConversationsRepository {
  const FakeConversationsRepository();

  @override
  Future<List<Conversation>> list({required bool professionalMode}) async =>
      professionalMode ? sampleCustomerConversations : sampleConversations;
}

class RemoteConversationsRepository implements ConversationsRepository {
  const RemoteConversationsRepository(this._gateway);

  final GraphQlGateway _gateway;

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
