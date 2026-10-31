import 'dummy_data.dart';

/// معلومات "طلب خدمة" اللي بتتعبّى خطوة خطوة.
/// نسخة وحدة بتنعمل بالخطوة 1 وبتنمرّر لباقي الخطوات، وكل خطوة بتكتب فيها مباشرة،
/// فلما ترجع لخطوة بتلاقي اللي عبّيته.
class RequestDraft {
  // الخطوة 1
  String description = '';
  String? serviceType;
  String? subSpecialty;
  bool onBehalf = false;
  String customerName = '';
  String phone = '';
  String city = requestCities.first;
  String area = '';

  // الخطوة 2
  final photos = <String>[];
  bool allowWhatsapp = true;
  int urgency = 0;
  String preferredDate = requestPreferredDates.first;
  String preferredTime = requestPreferredTimes.first;

  // الخطوة 3
  bool located = false;

  static const urgencyLevels = ['عادي', 'عاجل', 'طارئ'];

  String get location {
    if (onBehalf) return area.trim().isEmpty ? city : '$city - ${area.trim()}';
    return located ? 'موقعك الحالي' : 'غير محدد';
  }

  /// أسطر ملخص الطلب بخطوة التأكيد: (العنوان، القيمة).
  List<(String, String)> get summary => [
    ('نوع الخدمة', serviceType ?? 'غير محدد'),
    if (subSpecialty != null) ('التخصص الفرعي', subSpecialty!),
    ('مدى الإلحاح', urgencyLevels[urgency]),
    ('الموعد المفضل', preferredDate),
    ('الوقت المفضل', preferredTime),
    ('الموقع', location),
    if (onBehalf && customerName.trim().isNotEmpty) ('بالنيابة عن', customerName.trim()),
    ('التواصل', allowWhatsapp ? 'عبر وتساب والتطبيق' : 'عبر التطبيق فقط'),
  ];
}
