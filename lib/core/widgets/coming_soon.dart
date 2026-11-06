import 'package:flutter/material.dart';

/// مفتاح عام مشان نعرض رسائل من أي مكان (حتى من TapGestureRecognizer بدون context).
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showNotice(String message) {
  final messenger = appMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showComingSoon() => showNotice('هالميزة قريباً');

void showCountryNotice() => showNotice('الخدمة متاحة حالياً داخل سوريا فقط');
