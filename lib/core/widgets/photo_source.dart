import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// بيعرض صورة: أصل محلي (`assets/`) أو ملف مختار من المعرض.
Widget photoImage(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('assets/')) return Image.asset(path, fit: fit);
  if (kIsWeb) return Image.network(path, fit: fit);
  return Image.file(File(path), fit: fit);
}

/// اختيار صور من المعرض (بيرجع المسارات).
Future<List<String>> pickPhotos({required int max}) async {
  if (max <= 0) return const [];
  final files = await ImagePicker().pickMultiImage(
    limit: max > 1 ? max : null,
    imageQuality: 85,
    maxWidth: 1600,
  );
  return files.take(max).map((f) => f.path).toList();
}
