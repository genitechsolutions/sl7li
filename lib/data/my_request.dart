/// حالة الطلب بالقائمة: نشط، مكتمل، ملغى/منتهي.
enum RequestStatus { active, done, canceled }

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
    this.status = RequestStatus.active,
    this.rated = false,
    this.cancelNote,
    this.offersCount,
    this.craftsmanName,
    this.craftsmanRating,
    this.craftsmanReviews,
    this.id,
    this.images = const [],
    this.location,
  });

  /// صور الطلب (روابط) وموقعه؛ فاضيين بالبيانات الوهمية.
  final List<String> images;
  final String? location;

  /// معرّف الطلب بالخلفية (job_id)؛ null بالبيانات الوهمية.
  final String? id;
  final String date;
  final RequestPriority priority;
  final String title;
  final String description;
  final int stage;
  final RequestStatus status;

  /// المكتمل: هل الزبون قيّم الخدمة.
  final bool rated;

  /// الملغى: سبب الإلغاء ("تم إلغاء الطلب"، "لقد انتهت مدة طلبك").
  final String? cancelNote;

  /// عدد العروض الواردة (للطلبات المفتوحة بدون حرفي).
  final int? offersCount;
  final String? craftsmanName;
  final String? craftsmanRating;
  final int? craftsmanReviews;

  bool get hasCraftsman => craftsmanName != null;
}

/// عرض سعر وارد من حرفي على طلب.
class RequestOffer {
  const RequestOffer({
    required this.craftsmanName,
    required this.rating,
    required this.reviews,
    required this.priceLabel,
    required this.price,
    required this.priceUnit,
    required this.inspectionFee,
    required this.materialsFee,
    this.proposalId,
    this.professionalId,
  });

  /// معرّفات الباك (بالبيانات الحقيقية فقط).
  final String? proposalId;
  final String? professionalId;

  final String craftsmanName;
  final String rating;
  final int reviews;

  /// عنوان السعر (الكلفة الأولية التقديرية...).
  final String priceLabel;
  final String price;
  final String priceUnit;
  final String inspectionFee;
  final String materialsFee;
}
