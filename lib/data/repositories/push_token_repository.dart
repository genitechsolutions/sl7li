import 'dart:convert';

import '../../core/backend/app_config.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import 'auth_repository.dart';

/// تسجيل توكن الإشعارات (FCM) بحساب المستخدم، بنفس صيغة الموقع: `push_device_tokens` بـ User.
abstract class PushTokenRepository {
  Future<void> register(String token, {String platform = 'android', String? appVersion});

  Future<void> unregister(String token);
}

class FakePushTokenRepository implements PushTokenRepository {
  const FakePushTokenRepository();

  @override
  Future<void> register(String token, {String platform = 'android', String? appVersion}) async {}

  @override
  Future<void> unregister(String token) async {}
}

class RemotePushTokenRepository implements PushTokenRepository {
  const RemotePushTokenRepository(this._gateway, this._auth);

  final GraphQlGateway _gateway;
  final AuthRepository _auth;

  Future<List<Object?>> _existing() async {
    final data = await _gateway.run(Gql.getCurrentUser);
    final res = asMap(data['getCurrentUserSecure']);
    throwIfBackendError(res);
    final user = asMap(res['user']);
    final v = user['push_device_tokens'];
    return v is List ? List<Object?>.from(v) : const [];
  }

  Future<void> _save(List<String> tokens) async {
    final id = _auth.currentUserId;
    if (id == null) return;
    await _gateway.run(
      Gql.updateUser,
      variables: {
        'input': {'user_id': id, 'push_device_tokens': tokens},
      },
      mutation: true,
    );
  }

  /// نفس مسار الموقع: توكن مجهول (API key) ← الخلفية بتعمل SNS endpoint وبتكتب `endpoint_arn` ← بنربطه بحساب المستخدم.
  Future<String?> _endpointArn(String token, String platform, String deviceId, String? appVersion) async {
    if (AppConfig.apiKey.isEmpty) return null;
    final anon = pushAnonId(token);
    final input = {
      'anon_id': anon,
      'token': token,
      'platform': platform,
      'device_id': deviceId,
      'app_version': appVersion,
      'endpoint_arn': null,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      'expires_at_epoch': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400 * 180,
    };
    try {
      await _gateway.run(Gql.createAnonymousDeviceToken, variables: {'input': input}, mutation: true, apiKeyOnly: true);
    } on Object {
      await _gateway.run(Gql.updateAnonymousDeviceToken, variables: {'input': input}, mutation: true, apiKeyOnly: true);
    }
    for (var i = 0; i < 8; i++) {
      final data = await _gateway.run(Gql.getAnonymousDeviceToken, variables: {'anon_id': anon});
      final r = asMap(data['getAnonymousDeviceToken']);
      final arn = str(r, 'endpoint_arn');
      if (arn != null && str(r, 'token') == token) return arn;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  @override
  Future<void> register(String token, {String platform = 'android', String? appVersion}) async {
    final deviceId = pushDeviceId(platform, token);
    String? arn;
    try {
      arn = await _endpointArn(token, platform, deviceId, appVersion);
    } on Object {
      arn = null;
    }
    final merged = mergePushTokens(
      await _existing(),
      token: token,
      platform: platform,
      appVersion: appVersion,
      endpointArn: arn,
      now: DateTime.now().toUtc(),
    );
    await _save(merged);
    if (arn != null) {
      try {
        await _gateway.run(
          Gql.deleteAnonymousDeviceToken,
          variables: {
            'input': {'anon_id': pushAnonId(token)},
          },
          mutation: true,
        );
      } on Object {
        // التوكن المجهول بينتهي لحاله.
      }
    }
  }

  @override
  Future<void> unregister(String token) async => _save(removePushToken(await _existing(), token));
}

/// معرّف التوكن المجهول (ثابت لنفس التوكن، فنقدر نحدّثه بدل ما نكرّره).
String pushAnonId(String token) => 'anon-${token.hashCode.toUnsigned(32).toRadixString(16)}';

/// معرّف الجهاز من التوكن (ثابت لنفس الجهاز بدون تخزين محلي).
String pushDeviceId(String platform, String token) =>
    '$platform-${token.hashCode.toUnsigned(32).toRadixString(16)}';

Map<String, dynamic>? _asToken(Object? e) {
  if (e is Map) return Map<String, dynamic>.from(e);
  if (e is String) {
    try {
      final d = jsonDecode(e);
      if (d is Map) return Map<String, dynamic>.from(d);
    } on FormatException {
      return null;
    }
  }
  return null;
}

/// بيضيف التوكن أو بيحدّثه (نفس الجهاز/التوكن) وبيحافظ على باقي أجهزة المستخدم.
List<String> mergePushTokens(
  List<Object?> existing, {
  required String token,
  required String platform,
  required DateTime now,
  String? appVersion,
  String? endpointArn,
}) {
  final deviceId = pushDeviceId(platform, token);
  final kept = [
    for (final e in existing.map(_asToken).whereType<Map<String, dynamic>>())
      if (e['token'] != token && e['deviceId'] != deviceId) e,
  ];
  kept.add({
    'token': token,
    'platform': platform,
    'deviceId': deviceId,
    'appVersion': ?appVersion,
    'lastUpdated': now.toIso8601String(),
    'endpointArn': endpointArn,
  });
  return [for (final e in kept) jsonEncode(e)];
}

List<String> removePushToken(List<Object?> existing, String token) => [
  for (final e in existing.map(_asToken).whereType<Map<String, dynamic>>())
    if (e['token'] != token) jsonEncode(e),
];
