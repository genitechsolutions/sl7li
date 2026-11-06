import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/backend_exception.dart';
import 'package:khaled_flutter/cubits/feature_cubits.dart';
import 'package:khaled_flutter/cubits/unread_count_cubit.dart';
import 'package:khaled_flutter/data/repositories/notifications_repository.dart';

void main() {
  test('unreadCountFromJson يقرأ العدد ويرمي عند الفشل', () {
    expect(unreadCountFromJson('{"success":true,"count":4}'), 4);
    expect(unreadCountFromJson('{"success":true}'), 0);
    expect(
      () => unreadCountFromJson('{"success":false,"error":"x"}'),
      throwsA(isA<BackendException>()),
    );
  });

  test('notificationFromJson بياخد المعرّف ومعرّف المحادثة', () {
    final n = notificationFromJson({
      'notification_id': 'n1',
      'type': 'new_message',
      'status': 'unread',
      'template_variables': {'conversationId': 'c9'},
    });
    expect(n.id, 'n1');
    expect(n.conversationId, 'c9');
    expect(n.unread, isTrue);
    expect(n.markedRead().unread, isFalse);
    expect(n.markedRead().id, 'n1');
  });

  test('NotificationsCubit.markRead تحديث متفائل', () async {
    final cubit = NotificationsCubit(const FakeNotificationsRepository());
    await cubit.load();
    final before = cubit.state.data!.unread;
    final item = cubit.state.data!.important.first;
    await cubit.markRead(item);
    expect(cubit.state.data!.unread, before - 1);
  });

  test('UnreadCountCubit يحمّل وينقص ولا ينزل عن صفر', () async {
    final cubit = UnreadCountCubit(const FakeNotificationsRepository());
    await cubit.load();
    final start = cubit.state.data!;
    cubit.decrement();
    expect(cubit.state.data, start - 1);
    cubit.set(0);
    cubit.decrement();
    expect(cubit.state.data, 0);
  });
}
