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
    this.state = CraftsmanRequestState.open,
    this.note,
    this.rated = false,
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
  final CraftsmanRequestState state;

  /// ملاحظة الحالة ("قام الزبون بإنشاء الطلب عن طريق الخطأ"...).
  final String? note;

  /// مكتمل: هل الزبون قيّم الخدمة.
  final bool rated;
}

/// حالة الطلب عند المهني.
enum CraftsmanRequestState { open, task, done, cancelled, withdrawn }

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
    state: CraftsmanRequestState.task,
  ),
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    stage: 1,
    state: CraftsmanRequestState.task,
  ),
];

const sampleDoneTasks = [
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    stage: 4,
    state: CraftsmanRequestState.done,
  ),
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    stage: 4,
    state: CraftsmanRequestState.done,
    rated: true,
  ),
];

const sampleCancelledTasks = [
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    state: CraftsmanRequestState.cancelled,
    note: 'قام الزبون بإنشاء الطلب عن طريق الخطأ',
  ),
  CraftsmanRequest(
    date: '5 آب 2026',
    urgency: 'عاجل',
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _craftsmanDesc,
    location: 'دمشق, المزة',
    state: CraftsmanRequestState.withdrawn,
  ),
];
