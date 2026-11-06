import 'dart:convert';

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

  @override
  Future<void> register(String token, {String platform = 'android', String? appVersion}) async {
    final merged = mergePushTokens(
      await _existing(),
      token: token,
      platform: platform,
      appVersion: appVersion,
      now: DateTime.now().toUtc(),
    );
    await _save(merged);
  }

  @override
  Future<void> unregister(String token) async => _save(removePushToken(await _existing(), token));
}

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
    'registeredAt': now.toIso8601String(),
  });
  return [for (final e in kept) jsonEncode(e)];
}

List<String> removePushToken(List<Object?> existing, String token) => [
  for (final e in existing.map(_asToken).whereType<Map<String, dynamic>>())
    if (e['token'] != token) jsonEncode(e),
];
