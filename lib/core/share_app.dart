import 'package:share_plus/share_plus.dart';

/// مشاركة نص من تطبيق صلّحلي (ما في رابط عام لصفحات التطبيق لسا).
Future<void> shareText(String text) => SharePlus.instance.share(ShareParams(text: text));
