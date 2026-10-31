/// أولوية الطلب.
enum RequestPriority { urgent, emergency, normal }

/// طلب خدمة بقائمة "طلباتي". الحالة: 0 مفتوح، 1 تم الاتفاق، 2 قيد التنفيذ، 3 مكتمل.
class MyRequest {
  const MyRequest({
    required this.date,
    required this.priority,
    required this.title,
    required this.description,
    required this.stage,
    this.offersCount,
    this.craftsmanName,
    this.craftsmanRating,
    this.craftsmanReviews,
  });

  final String date;
  final RequestPriority priority;
  final String title;
  final String description;
  final int stage;

  /// عدد العروض الواردة (للطلبات المفتوحة بدون حرفي).
  final int? offersCount;
  final String? craftsmanName;
  final String? craftsmanRating;
  final int? craftsmanReviews;

  bool get hasCraftsman => craftsmanName != null;
}
