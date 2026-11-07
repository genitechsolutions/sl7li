import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/push_token_repository.dart';

void main() {
  final now = DateTime.utc(2026, 11, 6);

  test('mergePushTokens: إضافة توكن جديد مع الحفاظ على أجهزة تانية', () {
    final other = jsonEncode({'token': 'web-1', 'platform': 'web', 'deviceId': 'w1'});
    final out = mergePushTokens([other], token: 'fcm-1', platform: 'android', now: now, appVersion: '1.0.0');
    expect(out.length, 2);
    final added = jsonDecode(out.last) as Map;
    expect(added['token'], 'fcm-1');
    expect(added['platform'], 'android');
    expect(added['appVersion'], '1.0.0');
    expect(added['deviceId'], pushDeviceId('android', 'fcm-1'));
  });

  test('mergePushTokens: بيحفظ endpointArn والصيغة نفس الموقع', () {
    final out = mergePushTokens(const [], token: 'fcm-9', platform: 'android', now: now, endpointArn: 'arn:aws:sns:x');
    final m = jsonDecode(out.single) as Map;
    expect(m['endpointArn'], 'arn:aws:sns:x');
    expect(m['lastUpdated'], isNotNull);
    expect(pushAnonId('fcm-9'), startsWith('anon-'));
  });

  test('mergePushTokens: نفس التوكن ما بيتكرر وبيتحدّث', () {
    final first = mergePushTokens(const [], token: 'fcm-1', platform: 'android', now: now);
    final again = mergePushTokens(first, token: 'fcm-1', platform: 'android', now: now);
    expect(again.length, 1);
  });

  test('removePushToken بيشيل التوكن المطلوب بس', () {
    final two = mergePushTokens(
      mergePushTokens(const [], token: 'a', platform: 'android', now: now),
      token: 'b',
      platform: 'android',
      now: now,
    );
    final out = removePushToken(two, 'a');
    expect(out.length, 1);
    expect((jsonDecode(out.single) as Map)['token'], 'b');
  });
}
