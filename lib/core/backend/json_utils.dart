import 'dart:convert';

import 'app_config.dart';
import 'backend_exception.dart';

/// حقول AWSJSON بترجع كنص JSON؛ هالدوال بتفكّها بأمان.
Map<String, dynamic> asMap(Object? value) {
  if (value == null) return const {};
  if (value is Map) return Map<String, dynamic>.from(value);
  // الخلفية أحياناً بترجع JSON مرمّز مرتين (نص جوا نص): نفك لحد ما يطلع Map.
  Object? v = value;
  for (var i = 0; i < 3 && v is String && v.trim().isNotEmpty; i++) {
    try {
      v = jsonDecode(v);
    } on FormatException {
      return const {};
    }
  }
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

/// قائمة عناصر AWSJSON (كل عنصر نص JSON أو Map).
List<Map<String, dynamic>> asMapList(Object? value) {
  if (value == null) return const [];
  Object? v = value;
  if (v is String) {
    try {
      v = jsonDecode(v);
    } on FormatException {
      return const [];
    }
  }
  if (v is Map) {
    // أحياناً بترجع { items: [...] } أو { notifications: [...] }.
    for (final key in const ['items', 'notifications', 'offers', 'jobs']) {
      if (v[key] is List) return asMapList(v[key]);
    }
    return const [];
  }
  if (v is! List) return const [];
  return [
    for (final e in v)
      if (asMap(e).isNotEmpty) asMap(e),
  ];
}

String? str(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int? intOf(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v');
}

bool boolOf(Map<String, dynamic> m, String key) => m[key] == true;

List<String> strList(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is List) return [for (final e in v) '$e'];
  return const [];
}

const _months = [
  'كانون الثاني',
  'شباط',
  'آذار',
  'نيسان',
  'أيار',
  'حزيران',
  'تموز',
  'آب',
  'أيلول',
  'تشرين الأول',
  'تشرين الثاني',
  'كانون الأول',
];

/// "2026-08-05T10:00:00Z" ← "5 آب 2026".
String arabicDate(String? iso) {
  final d = DateTime.tryParse(iso ?? '')?.toLocal();
  if (d == null) return '';
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// وقت نسبي مختصر للإشعارات والمحادثات: "الآن" / "2:10 م" / "5 آب".
String arabicTime(String? iso, {DateTime? now}) {
  final d = DateTime.tryParse(iso ?? '')?.toLocal();
  if (d == null) return '';
  final n = now ?? DateTime.now();
  final diff = n.difference(d);
  if (diff.inMinutes < 1) return 'الآن';
  if (d.year == n.year && d.month == n.month && d.day == n.day) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final suffix = d.hour >= 12 ? 'م' : 'ص';
    return '$h12:${d.minute.toString().padLeft(2, '0')} $suffix';
  }
  return '${d.day} ${_months[d.month - 1]}';
}

/// مفتاح S3 أو مسار ← رابط كامل عبر مضيف الموارد؛ الروابط الكاملة بتضل متل ما هي.
String resourceUrl(String keyOrUrl) {
  if (keyOrUrl.startsWith('http')) return keyOrUrl;
  final key = keyOrUrl.startsWith('/') ? keyOrUrl.substring(1) : keyOrUrl;
  return 'https://${AppConfig.env.resourcesHost}/$key';
}

/// ردود الخلفية بتحمل `error` كنص؛ إذا موجود نرمي استثناء جاهز للعرض.
void throwIfBackendError(Map<String, dynamic> res) {
  final error = str(res, 'error');
  if (error != null) throw BackendException(error);
}
