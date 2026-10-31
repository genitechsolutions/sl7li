import 'package:flutter/foundation.dart';

/// حالة توثيق حساب المهني.
enum VerificationStatus { none, pending, rejected, verified }

/// حالة التوثيق الحالية (ValueNotifier عادي مش state management). الافتراضي: غير موثّق.
final ValueNotifier<VerificationStatus> verificationNotifier = ValueNotifier(
  VerificationStatus.none,
);
