import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// مشاركة نص من تطبيق صلّحلي؛ إذا فشلت المشاركة بالجهاز بينتسخ النص.
Future<void> shareText(BuildContext context, String text) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await SharePlus.instance.share(ShareParams(text: text));
  } on Object {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
    } on Object {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تعذّرت المشاركة')));
    }
  }
}
