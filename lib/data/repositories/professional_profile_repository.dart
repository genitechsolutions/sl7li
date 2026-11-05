import 'dart:convert';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_professional_profile.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../../core/backend/media_upload.dart';
import 'craftsman_signup_repository.dart';

const professionalMaxPortfolio = 20;

/// خدمات الواجهة (عربي) ← أكواد الخدمات بالخلفية.
const professionalServiceCodes = craftsmanServiceIds;

/// الملف المهني الحقيقي (الحقول اللي بتعرضها/بتعدّلها الواجهة).
class ProfessionalProfile {
  const ProfessionalProfile({
    this.userId = '',
    this.businessName = '',
    this.imageUrl,
    this.portfolio = const [],
    this.description = '',
    this.experienceYears,
    this.hasTools,
    this.hasTransport,
    this.workingHoursType,
    this.cityCode,
    this.areaCodes = const [],
    this.workshopAddress = '',
    this.latitude,
    this.longitude,
    this.services = const [],
    this.rating,
    this.reviewCount = 0,
  });

  final String userId;
  final String businessName;

  /// رابط صورة الملف المهني كاملاً (null = ما في).
  final String? imageUrl;

  /// مفاتيح صور معرض الأعمال (S3) كما هي بالخلفية.
  final List<String> portfolio;
  final String description;
  final int? experienceYears;
  final bool? hasTools;
  final bool? hasTransport;
  final String? workingHoursType;
  final String? cityCode;
  final List<String> areaCodes;
  final String workshopAddress;
  final double? latitude;
  final double? longitude;

  /// عناصر professional_services الخام (بنحافظ على باقي حقولها عند الحفظ).
  final List<Map<String, dynamic>> services;
  final double? rating;
  final int reviewCount;

  List<String> get portfolioUrls => [for (final k in portfolio) resourceUrl(k)];

  /// خدمات الواجهة (عربي) اللي إلها كود معروف.
  List<String> get serviceNames => [
    for (final e in professionalServiceCodes.entries)
      if (services.any((s) => s['serviceId'] == e.value)) e.key,
  ];

  /// الخدمات تحت الاسم.
  String get headline => serviceNames.join(' · ');
}

ProfessionalProfile professionalFromJson(Map<String, dynamic> j) {
  final area = j['service_area_codes'];
  final images = j['portfolio_images'];
  final img = str(j, 'professional_profile_image_url');
  return ProfessionalProfile(
    userId: str(j, 'user_id') ?? '',
    businessName: str(j, 'business_name') ?? '',
    imageUrl: img == null ? null : resourceUrl(img),
    portfolio: images is List
        ? [
            for (final e in images)
              if (e is String && e.trim().isNotEmpty) e,
          ]
        : const [],
    description: str(j, 'description_ar') ?? '',
    experienceYears: intOf(j, 'experience_years'),
    hasTools: j['has_tools'] is bool ? j['has_tools'] as bool : null,
    hasTransport: j['has_transport'] is bool
        ? j['has_transport'] as bool
        : null,
    workingHoursType: _workingHoursType(j['working_hours']),
    cityCode: str(j, 'primary_city_code') ?? _firstOf(j['serving_city_codes']),
    areaCodes: area is List ? [for (final e in area) '$e'] : const [],
    workshopAddress: str(j, 'workshop_address') ?? '',
    latitude: (j['workshop_latitude'] as num?)?.toDouble(),
    longitude: (j['workshop_longitude'] as num?)?.toDouble(),
    services: asMapList(j['professional_services']),
    rating: (j['rating'] as num?)?.toDouble(),
    reviewCount: intOf(j, 'review_count') ?? 0,
  );
}

String? _firstOf(Object? v) => v is List && v.isNotEmpty ? '${v.first}' : null;

String? _workingHoursType(Object? v) {
  if (v is! String || v.isEmpty) return null;
  try {
    final m = jsonDecode(v);
    return m is Map ? m['type'] as String? : v;
  } on FormatException {
    return v;
  }
}

/// تعديلات النموذج (null = ما تغيّر).
class ProfessionalEdits {
  const ProfessionalEdits({
    this.businessName,
    this.description,
    this.experienceYears,
    this.hasTools,
    this.hasTransport,
    this.workingHoursType,
    this.cityCode,
    this.areaCodes,
    this.workshopAddress,
    this.latitude,
    this.longitude,
    this.serviceNames,
  });

  final String? businessName;
  final String? description;
  final int? experienceYears;
  final bool? hasTools;
  final bool? hasTransport;
  final String? workingHoursType;
  final String? cityCode;
  final List<String>? areaCodes;
  final String? workshopAddress;
  final double? latitude;
  final double? longitude;
  final List<String>? serviceNames;
}

/// بيدمج الخدمات المختارة مع الموجودة: بيحافظ على المختارة وعلى غير المعروفة، وبيضيف الجديدة PENDING، وبيشيل المحذوفة.
List<Map<String, dynamic>> mergeProfessionalServices(
  List<Map<String, dynamic>> existing,
  List<String> selectedNames,
  int? years,
) {
  final selected = {
    for (final n in selectedNames)
      if (professionalServiceCodes[n] != null) professionalServiceCodes[n]!,
  };
  final known = professionalServiceCodes.values.toSet();
  final out = <Map<String, dynamic>>[];
  final kept = <String>{};
  for (final s in existing) {
    final id = s['serviceId'];
    if (!known.contains(id) || selected.contains(id)) {
      out.add(s);
      if (id is String) kept.add(id);
    }
  }
  for (final id in selected.difference(kept)) {
    out.add({
      'serviceId': id,
      'approvalStatus': 'PENDING',
      'canProvide': true,
      'yearsExperience': years,
    });
  }
  return out;
}

/// حقول updateProfessionalSecure: بس اللي تغيّر عن [current].
Map<String, dynamic> professionalUpdateInput(
  ProfessionalProfile current,
  ProfessionalEdits e,
) {
  final m = <String, dynamic>{};
  if (e.businessName != null && e.businessName != current.businessName) {
    m['business_name'] = e.businessName;
  }
  if (e.description != null && e.description != current.description) {
    m['description_ar'] = e.description;
  }
  if (e.experienceYears != null &&
      e.experienceYears != current.experienceYears) {
    m['experience_years'] = e.experienceYears;
  }
  if (e.hasTools != null && e.hasTools != current.hasTools) {
    m['has_tools'] = e.hasTools;
  }
  if (e.hasTransport != null && e.hasTransport != current.hasTransport) {
    m['has_transport'] = e.hasTransport;
  }
  if (e.workingHoursType != null &&
      e.workingHoursType != current.workingHoursType) {
    m['working_hours'] = jsonEncode({
      'type': e.workingHoursType,
      'flexible': e.workingHoursType!.startsWith('مرن'),
    });
  }
  if (e.cityCode != null && e.cityCode != current.cityCode) {
    m['serving_city_codes'] = [e.cityCode];
    m['serving_cities_ar'] = [placeName(e.cityCode!)];
  }
  if (e.areaCodes != null && !_sameList(e.areaCodes!, current.areaCodes)) {
    m['service_area_codes'] = e.areaCodes;
  }
  if (e.workshopAddress != null &&
      e.workshopAddress != current.workshopAddress) {
    m['workshop_address'] = e.workshopAddress;
  }
  if (e.latitude != null &&
      e.longitude != null &&
      (e.latitude != current.latitude || e.longitude != current.longitude)) {
    m['workshop_latitude'] = e.latitude;
    m['workshop_longitude'] = e.longitude;
  }
  if (e.serviceNames != null &&
      !_sameList(_codesOf(e.serviceNames!), _codesOf(current.serviceNames))) {
    m['professional_services'] = mergeProfessionalServices(
      current.services,
      e.serviceNames!,
      e.experienceYears ?? current.experienceYears,
    );
  }
  return m;
}

List<String> _codesOf(List<String> names) => [
  for (final n in names)
    if (professionalServiceCodes[n] != null) professionalServiceCodes[n]!,
];

bool _sameList(List<String> a, List<String> b) {
  final x = [...a]..sort();
  final y = [...b]..sort();
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}

abstract class ProfessionalProfileRepository {
  Future<ProfessionalProfile> load();

  /// بيحفظ التعديلات (بدون تغييرات ما بيعمل شي).
  Future<void> save(ProfessionalProfile current, ProfessionalEdits edits);

  Future<void> saveAvatar(ProfessionalProfile current, String path);

  /// بيرفع الصور وبيضيفها لمعرض الأعمال (حتى [professionalMaxPortfolio]).
  Future<void> addPortfolio(ProfessionalProfile current, List<String> paths);

  Future<void> removePortfolio(ProfessionalProfile current, String key);
}

class FakeProfessionalProfileRepository
    implements ProfessionalProfileRepository {
  const FakeProfessionalProfileRepository();

  @override
  Future<ProfessionalProfile> load() async => const ProfessionalProfile(
    userId: 'fake',
    businessName: 'رضا الكويفاتي',
    experienceYears: 4,
    hasTools: true,
    hasTransport: true,
    workingHoursType: 'صباحاً',
    cityCode: 'damascus',
    areaCodes: ['damascus_center'],
    rating: 4.9,
    reviewCount: 128,
    services: [
      {'serviceId': 'ac_repair'},
      {'serviceId': 'electricity'},
      {'serviceId': 'plumbing_repair'},
    ],
  );

  @override
  Future<void> save(
    ProfessionalProfile current,
    ProfessionalEdits edits,
  ) async {}

  @override
  Future<void> saveAvatar(ProfessionalProfile current, String path) async {}

  @override
  Future<void> addPortfolio(
    ProfessionalProfile current,
    List<String> paths,
  ) async {}

  @override
  Future<void> removePortfolio(ProfessionalProfile current, String key) async {}
}

class RemoteProfessionalProfileRepository
    implements ProfessionalProfileRepository {
  const RemoteProfessionalProfileRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<ProfessionalProfile> load() async {
    final data = await _gateway.run(Gql.getCurrentProfessional);
    final res = asMap(data['getCurrentProfessionalSecure']);
    throwIfBackendError(res);
    final pro = asMap(res['professional']);
    if (pro.isEmpty) throw const BackendException('ما لقينا ملفك المهني');
    return professionalFromJson(pro);
  }

  Future<void> _update(
    ProfessionalProfile current,
    Map<String, dynamic> fields,
  ) async {
    if (fields.isEmpty) return;
    final data = await _gateway.run(
      GqlProfessionalProfile.update,
      variables: {
        'input': jsonEncode({
          'user_id': current.userId,
          'details': 'profile',
          ...fields,
        }),
      },
      mutation: true,
    );
    throwIfBackendError(asMap(data['updateProfessionalSecure']));
  }

  @override
  Future<void> save(ProfessionalProfile current, ProfessionalEdits edits) =>
      _update(current, professionalUpdateInput(current, edits));

  @override
  Future<void> saveAvatar(ProfessionalProfile current, String path) async {
    final key = await uploadMedia(_gateway, path, type: 'profile');
    await _update(current, {'professional_profile_image_url': key});
  }

  @override
  Future<void> addPortfolio(
    ProfessionalProfile current,
    List<String> paths,
  ) async {
    final room = professionalMaxPortfolio - current.portfolio.length;
    final keys = <String>[];
    for (final p in paths.take(room < 0 ? 0 : room)) {
      keys.add(await uploadMedia(_gateway, p, type: 'portfolio'));
    }
    if (keys.isEmpty) return;
    await _update(current, {
      'portfolio_images': [...current.portfolio, ...keys],
    });
  }

  @override
  Future<void> removePortfolio(ProfessionalProfile current, String key) =>
      _update(current, {
        'portfolio_images': [
          for (final k in current.portfolio)
            if (k != key) k,
        ],
      });
}
