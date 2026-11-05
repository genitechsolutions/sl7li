import '../../core/backend/graphql_documents.dart';
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
}

abstract class NotificationsRepository {
  Future<NotificationsData> load();

  Future<void> markAllRead();
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
  );
}
