import '../../core/backend/graphql_documents.dart';
import '../../core/backend/gql_notification_extras.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../chat_data.dart';
import '../dummy_data.dart';
import 'auth_repository.dart';
import '../../core/backend/backend_exception.dart';

/// الإشعارات مقسّمة متل الشاشة: مهمة / اليوم / الأسبوع الماضي.
class NotificationsData {
  const NotificationsData({
    this.important = const [],
    this.today = const [],
    this.lastWeek = const [],
  });

  final List<NotificationItem> important;
  final List<NotificationItem> today;
  final List<NotificationItem> lastWeek;

  int get unread => [...important, ...today, ...lastWeek].where((n) => n.unread).length;

  NotificationsData withRead(NotificationItem item) {
    List<NotificationItem> swap(List<NotificationItem> l) => [
      for (final n in l)
        if (identical(n, item) || (item.id != null && n.id == item.id)) n.markedRead() else n,
    ];
    return NotificationsData(
      important: swap(important),
      today: swap(today),
      lastWeek: swap(lastWeek),
    );
  }
}

abstract class NotificationsRepository {
  Future<NotificationsData> load();

  Future<void> markAllRead();

  Future<void> markRead(String notificationId);

  Future<void> markConversationRead(String conversationId);

  Future<int> unreadCount();
}

class FakeNotificationsRepository implements NotificationsRepository {
  const FakeNotificationsRepository();

  @override
  Future<NotificationsData> load() async => const NotificationsData(
    important: sampleImportantNotifications,
    today: sampleTodayNotifications,
    lastWeek: sampleLastWeekNotifications,
  );

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markRead(String notificationId) async {}

  @override
  Future<void> markConversationRead(String conversationId) async {}

  @override
  Future<int> unreadCount() async => const NotificationsData(
    important: sampleImportantNotifications,
    today: sampleTodayNotifications,
    lastWeek: sampleLastWeekNotifications,
  ).unread;
}

class RemoteNotificationsRepository implements NotificationsRepository {
  const RemoteNotificationsRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  @override
  Future<NotificationsData> load() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw BackendException.unauthenticated;
    final data = await _gateway.run(
      Gql.getUserNotifications,
      variables: {'userId': userId, 'limit': 60},
    );
    final all = asMapList(data['getUserNotifications']);
    return groupNotifications(all);
  }

  @override
  Future<void> markAllRead() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw BackendException.unauthenticated;
    await _gateway.run(
      Gql.markAllNotificationsAsRead,
      variables: {'userId': userId},
      mutation: true,
    );
  }

  @override
  Future<void> markRead(String notificationId) async {
    final userId = _requireUser();
    final res = await _gateway.run(
      GqlNotificationExtras.markNotificationAsRead,
      variables: {'notificationId': notificationId, 'userId': userId},
      mutation: true,
    );
    _check(res['markNotificationAsRead']);
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final userId = _requireUser();
    final res = await _gateway.run(
      GqlNotificationExtras.markNotificationsByConversation,
      variables: {'conversationId': conversationId, 'userId': userId},
      mutation: true,
    );
    _check(res['markNotificationsByConversation']);
  }

  @override
  Future<int> unreadCount() async {
    final userId = _requireUser();
    final res = await _gateway.run(
      GqlNotificationExtras.getUnreadNotificationCount,
      variables: {'userId': userId},
    );
    return unreadCountFromJson(res['getUnreadNotificationCount']);
  }

  String _requireUser() {
    final userId = _auth.currentUserId;
    if (userId == null) throw BackendException.unauthenticated;
    return userId;
  }

  void _check(Object? raw) {
    final m = asMap(raw);
    if (m['success'] == false) {
      throw BackendException(str(m, 'error') ?? 'تعذّر تحديث الإشعار');
    }
  }
}

/// ردّ العدّاد: `{success, count}` كنص JSON.
int unreadCountFromJson(Object? raw) {
  final m = asMap(raw);
  if (m['success'] == false) throw BackendException(str(m, 'error') ?? 'تعذّر جلب العدد');
  return intOf(m, 'count') ?? 0;
}

NotificationsData groupNotifications(
  List<Map<String, dynamic>> all, {
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final important = <NotificationItem>[];
  final today = <NotificationItem>[];
  final lastWeek = <NotificationItem>[];
  for (final j in all) {
    final item = notificationFromJson(j, now: n);
    final created = DateTime.tryParse(str(j, 'createdAt') ?? '')?.toLocal();
    if (boolOf(j, 'action_required') && item.unread) {
      important.add(item);
    } else if (created != null &&
        created.year == n.year &&
        created.month == n.month &&
        created.day == n.day) {
      today.add(item);
    } else {
      lastWeek.add(item);
    }
  }
  return NotificationsData(important: important, today: today, lastWeek: lastWeek);
}

NotificationItem notificationFromJson(Map<String, dynamic> j, {DateTime? now}) {
  final key = '${str(j, 'type') ?? ''} ${str(j, 'category') ?? ''}'.toLowerCase();
  final kind = key.contains('message')
      ? NotificationKind.message
      : key.contains('complet')
      ? NotificationKind.completion
      : key.contains('withdraw') || key.contains('cancel')
      ? NotificationKind.withdrawn
      : NotificationKind.offer;
  final status = str(j, 'status');
  return NotificationItem(
    kind: kind,
    title: str(j, 'title') ?? '',
    body: str(j, 'body') ?? '',
    time: arabicTime(str(j, 'createdAt'), now: now),
    unread: status != 'read' && str(j, 'read_at') == null,
    actionLabel: boolOf(j, 'action_required') ? str(j, 'action_text') : null,
    entityType: str(j, 'entity_type'),
    entityId: str(j, 'entity_id'),
    id: str(j, 'notification_id'),
    conversationId: notificationConversationId(j),
  );
}

/// معرّف المحادثة من `template_variables` (نفس منطق الموقع).
String? notificationConversationId(Map<String, dynamic> j) {
  final tv = asMap(j['template_variables']);
  for (final k in const ['conversation_id', 'conversationId', 'conversationID']) {
    final v = str(tv, k);
    if (v != null) return v;
  }
  return null;
}
