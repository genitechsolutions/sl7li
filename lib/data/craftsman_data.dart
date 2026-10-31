/// طلب وارد للمهني (متاح لتقديم عرض)، أو مهمة حالية.
class CraftsmanRequest {
  const CraftsmanRequest({
    required this.date,
    required this.urgency,
    required this.title,
    required this.description,
    required this.location,
    this.contacts,
    this.stage,
    this.photos = 3,
  });

  final String date;

  /// "عاجل" / "طارئ" / "عادي".
  final String urgency;
  final String title;
  final String description;
  final String location;

  /// "تواصل 5 مهنيين مع الزبون".
  final int? contacts;

  /// مرحلة المهمة (0 عرض مرسل، 1 تم الاتفاق، 2 قيد التنفيذ، 3 مكتمل)؛ null = طلب متاح.
  final int? stage;
  final int photos;
}

const _craftsmanDesc =
    'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب';

const sampleAvailableRequests = [
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    contacts: 5,
  ),
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    contacts: 5,
  ),
];

const sampleCraftsmanTasks = [
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    contacts: 5,
    stage: 0,
  ),
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    stage: 1,
  ),
];
