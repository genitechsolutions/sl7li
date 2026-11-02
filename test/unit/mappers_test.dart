import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/json_utils.dart';
import 'package:khaled_flutter/data/chat_data.dart';
import 'package:khaled_flutter/data/craftsman_data.dart';
import 'package:khaled_flutter/data/my_request.dart';
import 'package:khaled_flutter/data/repositories/conversations_repository.dart';
import 'package:khaled_flutter/data/repositories/notifications_repository.dart';
import 'package:khaled_flutter/data/repositories/offers_repository.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';

void main() {
  liveShapeTests();
  group('json utils', () {
    test('asMapList يفك قائمة AWSJSON (نصوص JSON)', () {
      final list = asMapList(['{"a":1}', '{"b":2}']);
      expect(list, [
        {'a': 1},
        {'b': 2},
      ]);
    });

    test('asMapList يفك نص JSON فيه مفتاح items/notifications', () {
      expect(asMapList('{"notifications":[{"x":1}]}'), [
        {'x': 1},
      ]);
      expect(asMapList('{"items":[{"y":2}]}'), [
        {'y': 2},
      ]);
    });

    test('asMapList بيتجاهل الفاسد', () {
      expect(asMapList('not json'), isEmpty);
      expect(asMapList(null), isEmpty);
      expect(asMap('oops'), isEmpty);
    });

    test('arabicDate بالشهور الشامية', () {
      expect(arabicDate('2026-08-05T10:00:00'), '5 آب 2026');
      expect(arabicDate('2026-01-31T10:00:00'), '31 كانون الثاني 2026');
      expect(arabicDate(null), '');
    });

    test('arabicTime: الآن / اليوم 12 ساعة / تاريخ', () {
      final now = DateTime(2026, 8, 5, 15, 0);
      expect(
        arabicTime(
          DateTime(2026, 8, 5, 14, 59, 40).toIso8601String(),
          now: now,
        ),
        'الآن',
      );
      expect(
        arabicTime(DateTime(2026, 8, 5, 14, 10).toIso8601String(), now: now),
        '2:10 م',
      );
      expect(
        arabicTime(DateTime(2026, 8, 5, 0, 5).toIso8601String(), now: now),
        '12:05 ص',
      );
      expect(
        arabicTime(DateTime(2026, 8, 1, 9).toIso8601String(), now: now),
        '1 آب',
      );
    });

    test('resourceUrl بيضيف مضيف الموارد للمفاتيح فقط', () {
      expect(resourceUrl('services/a.webp'), endsWith('/services/a.webp'));
      expect(resourceUrl('/services/a.webp'), startsWith('https://'));
      expect(resourceUrl('https://x.com/a.png'), 'https://x.com/a.png');
    });
  });

  group('offers', () {
    test('عرض بنسبة خصم', () {
      final o = offerFromJson({
        'title': 'خصم نجارة',
        'discountPercentage': 25,
        'photos': ['offers/a.jpg'],
        'neighborhoods': ['المزة'],
        'serviceCategory': 'carpentry',
      });
      expect(o.discount, '25%');
      expect(o.location, 'المزة');
      expect(o.image, startsWith('https://'));
      expect(o.tags, ['carpentry']);
    });

    test('عرض بسعر وبدون صور بياخد الصورة الافتراضية', () {
      final o = offerFromJson({
        'title': 't',
        'price': 1000.0,
        'currency': 'ل.س',
        'cityCode': 'damascus',
      });
      expect(o.discount, '1000 ل.س');
      expect(o.image, 'assets/images/offer_carpentry.jpg');
      expect(o.location, 'damascus');
    });
  });

  group('طلبات الزبون', () {
    Map<String, dynamic> job(
      String status, {
      String urgency = 'normal',
      Map<String, dynamic>? extra,
    }) => {
      'job_id': 'j1',
      'title': 'تصليح',
      'description': 'وصف',
      'status': status,
      'urgency': urgency,
      'createdAt': '2026-08-05T10:00:00',
      ...?extra,
    };

    test('مفتوح: المرحلة 0 وعدد العروض', () {
      final r = myRequestFromJson(job('open', extra: {'response_count': 7}));
      expect(r.id, 'j1');
      expect(r.stage, 0);
      expect(r.status, RequestStatus.active);
      expect(r.offersCount, 7);
      expect(r.date, '5 آب 2026');
    });

    test('الأولوية من الإلحاح', () {
      expect(
        myRequestFromJson(job('open', urgency: 'emergency')).priority,
        RequestPriority.emergency,
      );
      expect(
        myRequestFromJson(job('open', urgency: 'urgent')).priority,
        RequestPriority.urgent,
      );
      expect(
        myRequestFromJson(job('open', urgency: 'flexible')).priority,
        RequestPriority.normal,
      );
    });

    test('مراحل الحالة', () {
      expect(
        myRequestFromJson(
          job(
            'professional_selected',
            extra: {'accepted_pro_name': 'أبو أحمد'},
          ),
        ).stage,
        1,
      );
      final inProgress = myRequestFromJson(
        job('in_progress', extra: {'accepted_pro_name': 'أبو أحمد'}),
      );
      expect(inProgress.stage, 2);
      expect(inProgress.hasCraftsman, isTrue);
      expect(inProgress.offersCount, isNull);
    });

    test('مكتمل وملغى ومنتهي', () {
      final done = myRequestFromJson(job('completed'));
      expect(done.status, RequestStatus.done);
      expect(done.stage, 4);
      final cancelled = myRequestFromJson(job('cancelled'));
      expect(cancelled.status, RequestStatus.canceled);
      expect(cancelled.cancelNote, 'تم إلغاء الطلب');
      expect(
        myRequestFromJson(job('expired')).cancelNote,
        'لقد انتهت مدة طلبك',
      );
    });
  });

  group('طلبات المهني', () {
    test('طلب متاح', () {
      final r = craftsmanRequestFromJson({
        'job_id': 'j2',
        'title': 't',
        'description': 'd',
        'urgency': 'urgent',
        'city_code': 'دمشق',
        'neighborhood_code': 'المزة',
        'images': ['a', 'b'],
        'interactions_count': 5,
        'createdAt': '2026-08-05T10:00:00',
      }, open: true);
      expect(r.state, CraftsmanRequestState.open);
      expect(r.urgency, 'عاجل');
      expect(r.location, 'دمشق, المزة');
      expect(r.photos, 2);
      expect(r.contacts, 5);
      expect(r.stage, isNull);
    });

    test('مهمة بحسب statusByProfessional', () {
      CraftsmanRequest of(String s) => craftsmanRequestFromJson({
        'job_id': 'x',
        'title': 't',
        'description': 'd',
        'statusByProfessional': s,
      });
      expect(of('in_progress').state, CraftsmanRequestState.task);
      expect(of('in_progress').stage, 2);
      expect(of('completed').state, CraftsmanRequestState.done);
      expect(of('cancelled').state, CraftsmanRequestState.cancelled);
      expect(of('professional_selected').stage, 1);
    });
  });

  group('محادثات وإشعارات', () {
    test('محادثة', () {
      final c = conversationFromJson({
        'id': 'c1',
        'jobId': 'j1',
        'otherParticipantName': 'مركز قزاز',
        'lastMessage': 'مرحبا',
        'unreadCount': 3,
        'lastMessageAt': '2026-08-05T10:00:00',
      });
      expect(c.id, 'c1');
      expect(c.name, 'مركز قزاز');
      expect(c.unread, 3);
      expect(conversationFromJson({'id': 'c2'}).name, 'محادثة');
    });

    test('نوع الإشعار من النوع/التصنيف', () {
      NotificationKind k(String type) =>
          notificationFromJson({'type': type, 'title': 't', 'body': 'b'}).kind;
      expect(k('new_message'), NotificationKind.message);
      expect(k('job_completed'), NotificationKind.completion);
      expect(k('proposal_withdrawn'), NotificationKind.withdrawn);
      expect(k('new_proposal'), NotificationKind.offer);
    });

    test('تجميع الإشعارات: مهم / اليوم / قبل', () {
      final now = DateTime(2026, 8, 5, 15);
      final data = groupNotifications([
        {
          'type': 'job_completed',
          'title': 'a',
          'body': 'b',
          'action_required': true,
          'status': 'unread',
          'createdAt': now.toIso8601String(),
        },
        {
          'type': 'new_message',
          'title': 'c',
          'body': 'd',
          'status': 'read',
          'createdAt': DateTime(2026, 8, 5, 9).toIso8601String(),
        },
        {
          'type': 'new_proposal',
          'title': 'e',
          'body': 'f',
          'status': 'unread',
          'createdAt': DateTime(2026, 7, 30).toIso8601String(),
        },
      ], now: now);
      expect(data.important, hasLength(1));
      expect(data.today, hasLength(1));
      expect(data.lastWeek, hasLength(1));
      expect(data.unread, 2);
    });
  });
}

void liveShapeTests() {
  group('شكل الردود الحقيقية (devqa)', () {
    test('asMap بيفك JSON مرمّز مرتين', () {
      const doubled =
          r'"{\"id\":\"c1\",\"displayName\":\"صيانة الشامي\",\"lastMessage\":\"أهلاً\"}"';
      final conv = conversationFromJson(asMapList([doubled]).single);
      expect(conv.id, 'c1');
      expect(conv.name, 'صيانة الشامي');
      expect(conv.lastMessage, 'أهلاً');
    });
  });
}
