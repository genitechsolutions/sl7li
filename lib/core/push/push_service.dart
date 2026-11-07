import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/repositories/push_token_repository.dart';

/// الإشعارات الفورية (FCM). بدون `google-services.json` بتضل مطفية وما بتأثر على التطبيق.
class PushService {
  PushService(this._tokens);

  final PushTokenRepository _tokens;
  final _local = FlutterLocalNotificationsPlugin();
  String? _token;
  bool _ready = false;
  StreamSubscription<String>? _refresh;

  /// بيُستدعى لما المستخدم يفتح إشعار (مثلاً بنفتح شاشة الإشعارات).
  void Function()? onOpen;

  static const _channel = AndroidNotificationChannel(
    'salehli_default',
    'إشعارات صلّحلي',
    description: 'رسائل وعروض وتحديثات الطلبات',
    importance: Importance.high,
  );

  Future<bool> _init() async {
    if (_ready) return true;
    if (kIsWeb) return false;
    try {
      await Firebase.initializeApp();
    } on Object catch (e) {
      debugPrint('Push disabled (Firebase not configured): $e');
      return false;
    }
    await _local.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (_) => onOpen?.call(),
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => onOpen?.call());
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) onOpen?.call();
    _ready = true;
    return true;
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null) return;
    await _local.show(
      m.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name, importance: Importance.high, priority: Priority.high),
      ),
    );
  }

  /// بعد تسجيل الدخول: إذن + توكن + تسجيله بحساب المستخدم.
  Future<void> start() async {
    if (!await _init()) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _token = token;
      await _tokens.register(token);
      _refresh ??= FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        _token = t;
        try {
          await _tokens.register(t);
        } on Object {
          // المحاولة الجاية.
        }
      });
    } on Object catch (e) {
      debugPrint('Push start failed: $e');
    }
  }

  /// قبل تسجيل الخروج: بنشيل التوكن من الحساب (ما بيوصل إشعار لحساب مسجّل خروج).
  Future<void> stop() async {
    final t = _token;
    _token = null;
    if (t == null) return;
    try {
      await _tokens.unregister(t);
    } on Object {
      // نكمّل الخروج.
    }
  }
}
