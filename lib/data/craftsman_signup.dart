/// بيانات تسجيل المهني (متل [RequestDraft]: كائن عادي بيتمرّر بين الخطوات، مش state management).
class CraftsmanSignupDraft {
  // الخطوة 1
  String businessName = '';
  String? city;
  final List<String> districts = [];

  // الخطوة 2
  final List<String> services = [];

  /// التخصصات المختارة لكل خدمة.
  final Map<String, Set<String>> specialties = {};

  // الخطوة 3
  String years = '';
  String? transport;
  String? workTimes;
  bool hasTools = true;

  // الخطوة 4
  String workshopAddress = '';
  String bio = '';
  bool locationSet = false;

  bool get step1Valid =>
      businessName.trim().isNotEmpty && city != null && districts.isNotEmpty;
  bool get step2Valid =>
      services.isNotEmpty &&
      services.every((s) => (specialties[s] ?? {}).isNotEmpty);
  bool get step3Valid => years.trim().isNotEmpty && transport != null;
  bool get step4Valid =>
      workshopAddress.trim().isNotEmpty && bio.trim().isNotEmpty;
}

/// الخدمات (بأيقوناتها) اللي ممكن المهني يقدمها — أقصى شي 3.
const craftsmanServiceOptions = [
  ('الدهانات', 'assets/images/ic_paint.png'),
  ('التكييف', 'assets/images/ic_ac.png'),
  ('الكهرباء', 'assets/images/ic_electricity.png'),
  ('السباكة', 'assets/images/ic_plumbing.png'),
];

const craftsmanMaxServices = 3;

/// تخصصات كل خدمة (وهمية).
const craftsmanSpecialtiesByService = {
  'الدهانات': ['دهان داخلي', 'دهان خارجي', 'ورق جدران', 'معجون وتجليخ'],
  'التكييف': [
    'تصليح براد',
    'تبديل وصيانة الضواغط',
    'إعادة شحن غاز التبريد',
    'نقل وحدة المكيف',
    'تركيب وصيانة وحدات التكييف',
    'تنظيف وحدات التكييف',
  ],
  'الكهرباء': [
    'إصلاحات كهربائية',
    'الأنظمة الأمنية و المنزل الذكي',
    'الطاقة الشمسية',
    'تمديدات وإنارة',
  ],
  'السباكة': ['كشف تسربات', 'تركيب أدوات صحية', 'تسليك مجاري', 'صيانة سخانات'],
};

const craftsmanTransportOptions = [
  'سيارة خاصة',
  'دراجة نارية',
  'مواصلات عامة',
  'لا أملك وسيلة مواصلات',
];

const craftsmanWorkTimeOptions = [
  'صباحاً',
  'بعد الظهر',
  'مساءً',
  'مرن - أي وقت من النهار',
];
