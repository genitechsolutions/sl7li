import 'dart:convert';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_craftsman_signup.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../craftsman_signup.dart';

abstract class CraftsmanSignupRepository {
  /// بينشئ الملف المهني؛ بيرمي [BackendException] برسالة عربية إذا رفضته الخلفية.
  Future<void> submit(CraftsmanSignupDraft draft);
}

class FakeCraftsmanSignupRepository implements CraftsmanSignupRepository {
  const FakeCraftsmanSignupRepository();

  @override
  Future<void> submit(CraftsmanSignupDraft draft) async {}
}

class RemoteCraftsmanSignupRepository implements CraftsmanSignupRepository {
  const RemoteCraftsmanSignupRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<void> submit(CraftsmanSignupDraft draft) async {
    final problem = craftsmanSignupProblem(draft);
    if (problem != null) throw BackendException(problem);

    final cur = asMap(
      (await _gateway.run(Gql.getCurrentUser))['getCurrentUserSecure'],
    );
    throwIfBackendError(cur);
    final user = asMap(cur['user']);
    final userId = str(user, 'user_id') ?? '';

    final data = await _gateway.run(
      GqlCraftsmanSignup.createProfessional,
      variables: {
        'input': jsonEncode(
          craftsmanSignupInput(
            draft,
            userId: userId,
            whatsappNumber: str(user, 'phone_number') ?? '',
          ),
        ),
      },
      mutation: true,
    );
    final error = str(asMap(data['createProfessionalSecure']), 'error');
    if (error != null) {
      throw BackendException(craftsmanSignupErrorMessage(error), code: error);
    }

    final rolesRaw = user['roles'];
    final roles = [
      if (rolesRaw is List) for (final r in rolesRaw) r.toString(),
    ];
    if (roles.contains('professional')) return;
    // متل الموقع: بعد الإنشاء بنضيف الدور؛ فشله ما بيلغي الملف المهني اللي انحفظ.
    try {
      await _gateway.run(
        Gql.updateUser,
        variables: {
          'input': {
            'user_id': userId,
            'roles': [...(roles.isEmpty ? ['customer'] : roles), 'professional'],
            'professional_since': DateTime.now().toUtc().toIso8601String(),
          },
        },
        mutation: true,
      );
    } on BackendException {
      return;
    }
  }
}

/// كود الخلفية لخدمة التطبيق (تصنيفات كتالوج الموقع).
const craftsmanServiceIds = {
  'الدهانات': 'painting_molding',
  'التكييف': 'air_conditioning',
  'الكهرباء': 'electrical_repair',
  'السباكة': 'plumbing_repair',
};

/// كود تخصص الكتالوج للتخصصات اللي اسمها مطابق (الباقي بيتجاهل).
const craftsmanSpecialtyIds = {
  'تصليح براد': 'refrigerator_repair',
  'تركيب وصيانة وحدات التكييف': 'install_repair_ac_units',
  'تبديل وصيانة الضواغط': 'repair_ac_compressors',
  'إعادة شحن غاز التبريد': 'recharge_refrigerant_gas',
  'نقل وحدة المكيف': 'relocate_ac_units',
  'دهان داخلي': 'interior_wall_painting',
  'دهان خارجي': 'exterior_wall_painting',
  'ورق جدران': 'wallpaper_installation_removal',
  'الأنظمة الأمنية و المنزل الذكي': 'smart_home',
  'تسليك مجاري': 'unclog_drains',
  'صيانة سخانات': 'water_heater_repair',
};

const _cityCodes = {
  'دمشق': 'damascus',
  'حلب': 'aleppo',
  'حمص': 'homs',
  'حماة': 'hama',
};

const _noTools = 'لا أملك أدوات';
const _noTransport = 'لا أملك وسيلة مواصلات';
const _flexibleHours = 'مرن - أي وقت من النهار';

const _transportLabels = {
  'سيارة خاصة': 'نعم، سيارة خاصة',
  'دراجة نارية': 'نعم، دراجة نارية',
  'مواصلات عامة': 'أستخدم المواصلات العامة',
  _noTransport: _noTransport,
};

String? _codeOf(List<(String, String)> options, String? label) {
  for (final o in options) {
    if (o.$1 == label) return o.$2;
  }
  return null;
}

/// أول مشكلة بالمسودة بتمنع الإرسال (null = جاهزة)، بنفس شروط الخلفية.
String? craftsmanSignupProblem(CraftsmanSignupDraft d) {
  if (d.services.isEmpty) return 'اختر خدمة واحدة على الأقل';
  if (!d.registrationValid) return 'اختر كيف عرفت عن صلّحلي';
  if (_codeOf(craftsmanBusinessTypes, d.businessType) == null) {
    return 'حدد إذا كنت فرداً أو شركة';
  }
  if (!d.ageValid) return 'الحد الأدنى للعمر $craftsmanMinAge سنة';
  if (d.projectScales == null) return 'اختر حجم المشاريع اللي اشتغلت عليها';
  if (!d.teamValid) return 'أدخل عدد أعضاء الفريق';
  return null;
}

/// مدخل createProfessionalSecure (متل الموقع) من مسودة التسجيل.
Map<String, dynamic> craftsmanSignupInput(
  CraftsmanSignupDraft d, {
  required String userId,
  required String whatsappNumber,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  final years = int.tryParse(RegExp(r'\d+').stringMatch(d.years) ?? '') ?? 0;
  final source = _codeOf(craftsmanRegistrationSources, d.registrationSource);
  final scales = [
    for (final o in craftsmanProjectScaleOptions)
      if (o.$1 == d.projectScales) ...o.$2,
  ];
  final hasTransport = d.transport != null && d.transport != _noTransport;

  return {
    'user_id': userId,
    'details': 'profile',
    'business_name': d.businessName.trim(),
    'whatsapp_number': whatsappNumber,
    'description_ar': d.bio.trim().isEmpty
        ? 'خبير في ${d.services.join('، ')}'
        : d.bio.trim(),
    'experience_years': years,
    'service_area_codes': [for (final x in d.districts) placeCode(x)],
    'serving_city_codes': [_cityCodes[d.city] ?? placeCode(d.city ?? '')],
    'tools_status': d.hasTools ? 'نعم، أملك جميع الأدوات' : _noTools,
    'has_tools': d.hasTools,
    if (d.transport != null) ...{
      'transportation_mode': _transportLabels[d.transport] ?? d.transport,
      'has_transport': hasTransport,
    },
    if (d.workTimes != null)
      'working_hours': jsonEncode({
        'type': d.workTimes,
        'flexible': d.workTimes == _flexibleHours,
      }),
    'professional_services': [
      for (final s in d.services)
        {
          'serviceId': craftsmanServiceIds[s] ?? s,
          'approvalStatus': 'APPROVED',
          'yearsExperience': years,
          'skillLevel': null,
          'canProvide': true,
          'requestedAt': now,
          'approvedAt': now,
          'approvedBy': 'system_registration',
          'pricingOverride': null,
          'approvedSpecialties': [
            for (final n in d.specialties[s] ?? const <String>{})
              if (craftsmanSpecialtyIds[n] != null) craftsmanSpecialtyIds[n]!,
          ],
        },
    ],
    'is_managed_by_salehli': false,
    'manager_number': null,
    'manager_user_id': null,
    'manager_name': null,
    'whatsapp_job_notifications_enabled': true,
    'registration_source': source,
    'registration_organization_name': source == 'organization'
        ? _clip(d.registrationOrganizationName)
        : null,
    'business_type': _codeOf(craftsmanBusinessTypes, d.businessType),
    'age': d.ageValue,
    'has_engineering_degree': d.hasEngineeringDegree,
    'has_professional_license': d.hasProfessionalLicense,
    'certificate_documents': <String>[],
    'project_scales': scales,
    'industrial_portfolio_images': <String>[],
    'has_team': d.hasTeam,
    'team_size': d.hasTeam ? d.teamSizeValue : null,
    'accepts_daily_work': false,
    'daily_rate': null,
    'accepts_hourly_work': false,
    'hourly_rate': null,
    'work_rate_currency': null,
    if (d.workshopAddress.trim().isNotEmpty)
      'workshop_address': d.workshopAddress.trim(),
    if (d.latitude != null && d.longitude != null) ...{
      'workshop_latitude': d.latitude,
      'workshop_longitude': d.longitude,
    },
  };
}

String _clip(String s) {
  final t = s.trim();
  return t.length > 100 ? t.substring(0, 100) : t;
}

/// رسالة عربية لأخطاء التحقق من الخلفية (غير المعروفة بترجع كما هي).
String craftsmanSignupErrorMessage(String error) {
  final e = error.toLowerCase();
  if (e.contains('already exists')) return 'عندك حساب مهني مسبقاً';
  if (e.contains('minimum age')) return 'الحد الأدنى للعمر $craftsmanMinAge سنة';
  if (e.contains('organization name')) return 'أدخل اسم المنظمة أو الجمعية';
  if (e.contains('registration source')) return 'اختر كيف عرفت عن صلّحلي';
  if (e.contains('business_type')) return 'حدد إذا كنت فرداً أو شركة';
  if (e.contains('missing required qualifications')) {
    return 'معلومات المؤهلات ناقصة، راجع الخطوات';
  }
  if (e.contains('service')) return 'اختر خدمة واحدة على الأقل';
  return error;
}
