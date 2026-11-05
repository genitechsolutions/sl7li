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
  double? latitude;
  double? longitude;

  // مؤهلات مطلوبة من الخلفية (بالخطوتين 1 و3)؛ الاختيارات نصوص عربية وبتتحوّل لأكواد بالمحوّل.
  String? registrationSource;
  String registrationOrganizationName = '';
  String? businessType;
  String age = '';
  bool hasEngineeringDegree = false;
  bool hasProfessionalLicense = false;
  String? projectScales;
  bool hasTeam = false;
  String teamSize = '';

  /// العمر كرقم (null = فاضي أو مش رقم).
  int? get ageValue => int.tryParse(age.trim());

  /// عدد أعضاء الفريق كرقم (null = فاضي أو مش رقم).
  int? get teamSizeValue => int.tryParse(teamSize.trim());

  bool get registrationValid =>
      registrationSource != null &&
      (registrationSource != craftsmanOrganizationSource ||
          registrationOrganizationName.trim().isNotEmpty);

  bool get ageValid => (ageValue ?? 0) >= craftsmanMinAge && ageValue! <= 100;

  bool get teamValid =>
      !hasTeam || ((teamSizeValue ?? 0) >= 1 && teamSizeValue! <= 1000);

  bool get step1Valid =>
      businessName.trim().isNotEmpty &&
      city != null &&
      districts.isNotEmpty &&
      businessType != null &&
      ageValid &&
      registrationValid;
  bool get step2Valid =>
      services.isNotEmpty &&
      services.every((s) => (specialties[s] ?? {}).isNotEmpty);
  bool get step3Valid =>
      years.trim().isNotEmpty &&
      transport != null &&
      projectScales != null &&
      teamValid;
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

/// الحد الأدنى للعمر (رسالة الخلفية: "Minimum age to join is 20").
const craftsmanMinAge = 20;

const craftsmanOrganizationSource = 'منظمة أو جمعية';

/// (النص، الكود بالخلفية).
const craftsmanRegistrationSources = [
  ('من الإعلانات', 'ads'),
  ('من صديق أو قريب', 'friend_family'),
  (craftsmanOrganizationSource, 'organization'),
  ('من مصدر آخر', 'other'),
];

const craftsmanBusinessTypes = [('فرد', 'individual'), ('شركة', 'company')];

/// حجم المشاريع: كود واحد أو أكتر (كلاهما = الاتنين).
const craftsmanProjectScaleOptions = [
  ('أعمال منزلية ومحلات', ['residential_small_business']),
  ('مشاريع كبيرة وصناعية', ['large_industrial']),
  ('كلاهما', ['residential_small_business', 'large_industrial']),
];

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
