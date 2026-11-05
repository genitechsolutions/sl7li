import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/profile_repository.dart';

void main() {
  test('تحويل notification_preferences من نص JSON', () {
    final p = userProfileFromJson({
      'user_id': 'u1',
      'name': 'أحمد',
      'notification_preferences': '{"sms":true,"whatsapp":false,"push":true,"x":1}',
    });
    expect(p.notificationPrefs.whatsapp, false);
    expect(p.notificationPrefs.push, true);
    expect(p.notificationPrefs.extra, {'x': 1});
  });

  test('تفضيلات ناقصة أو غير موجودة = الكل شغّال', () {
    expect(userProfileFromJson({'user_id': 'u'}).notificationPrefs.sms, true);
    expect(NotificationPrefs.fromJson('مو json').push, true);
  });

  test('مدخل حفظ التفضيلات نص JSON ويحفظ المفاتيح الإضافية', () {
    final prefs = NotificationPrefs.fromJson({'sms': true, 'whatsapp': true, 'push': true, 'x': 1}).copyWith(push: false);
    final input = notificationPrefsInput('u1', prefs);
    expect(input['user_id'], 'u1');
    expect(jsonDecode(input['notification_preferences'] as String), {'sms': true, 'whatsapp': true, 'push': false, 'x': 1});
  });

  test('مدخل بيانات الحساب بأكواد المدينة والحي', () {
    expect(profileDetailsInput('u1', name: 'أحمد', city: 'دمشق', neighborhood: 'مركز المدينة'), {
      'user_id': 'u1',
      'name': 'أحمد',
      'city_code': 'damascus',
      'neighborhood_code': 'damascus_center',
    });
    expect(profileDetailsInput('u1', name: 'أحمد', neighborhood: ''), {'user_id': 'u1', 'name': 'أحمد'});
  });
}
