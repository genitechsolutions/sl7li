import 'dart:convert';

import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_public_profile.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../dummy_data.dart';
import '../service_names.dart';
import 'offers_repository.dart';

/// الصفحة العامة للمهني (عامة — بتشتغل للضيف كمان).
abstract class PublicProfileRepository {
  Future<CraftsmanProfile> get(String professionalId);
}

class FakePublicProfileRepository implements PublicProfileRepository {
  const FakePublicProfileRepository();

  @override
  Future<CraftsmanProfile> get(String professionalId) async => sampleCraftsmanProfile;
}

class RemotePublicProfileRepository implements PublicProfileRepository {
  const RemotePublicProfileRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<CraftsmanProfile> get(String professionalId) async {
    final data = await _gateway.run(
      GqlPublicProfile.getPage,
      variables: {'userId': professionalId},
      guest: true,
    );
    final res = asMap(data['getProfessionalPublicPageSecure']);
    throwIfBackendError(res);
    final professional = asMap(res['professional']);
    if (professional.isEmpty) throw const BackendException('هالمهني غير موجود');
    return craftsmanProfileFromJson(
      professional,
      reviews: asMapList(res['reviews']),
      offers: await _offers(professionalId),
    );
  }

  /// فشل العروض ما بيكسر الصفحة.
  Future<List<Map<String, dynamic>>> _offers(String professionalId) async {
    try {
      final data = await _gateway.run(
        GqlPublicProfile.listOffers,
        variables: {'professionalId': professionalId, 'limit': 20},
        guest: true,
      );
      return asMapList(asMap(data['listProfessionalPublicOffers'])['items']);
    } on BackendException {
      return const [];
    }
  }
}

const _defaultAvatar = 'assets/images/craftsman_1.jpg';
const _bioPreviewChars = 140;

/// JSON المهني + آراءه + عروضه ← نموذج الصفحة العامة.
CraftsmanProfile craftsmanProfileFromJson(
  Map<String, dynamic> p, {
  List<Map<String, dynamic>> reviews = const [],
  List<Map<String, dynamic>> offers = const [],
}) {
  final id = str(p, 'user_id');
  final services = _approvedServices(p['professional_services']);
  final specialties = <String>[];
  for (final s in services) {
    final name = serviceNameAr(str(s, 'serviceId') ?? '');
    if (name != null && !specialties.contains(name)) specialties.add(name);
  }
  final image = str(p, 'professional_profile_image_url');
  final rating = (p['rating'] as num?)?.toDouble();
  final reviewCount = intOf(p, 'review_count') ?? reviews.length;
  final status = (str(p, 'verification_status') ?? '').toLowerCase();
  final bio = str(p, 'description_ar') ?? '';
  final portfolio = _stringList(p['portfolio_images']);

  return CraftsmanProfile(
    craftsman: Craftsman(
      name: str(p, 'business_name') ?? 'مهني',
      location: _location(p),
      services: specialties,
      image: image == null ? null : resourceUrl(image),
      rating: rating == null || rating <= 0 ? null : rating,
      reviewsCount: reviewCount,
      isPro: boolOf(p, 'is_vip') || boolOf(p, 'isVip'),
      isVerified: status == 'verified' || status == 'approved',
      isRecommended: boolOf(p, 'is_featured'),
      professionalId: id,
    ),
    bio: bio,
    bioPreviewLength: bio.length < _bioPreviewChars ? bio.length : _bioPreviewChars,
    experience: _experience(p, services),
    tools: _yesNo(p['has_tools'], yes: 'نعم، أملك الأدوات'),
    transport: _yesNo(p['has_transport'], yes: 'نعم، عندي وسيلة نقل'),
    specialties: specialties,
    offers: offers.map(offerFromJson).toList(),
    works: portfolio.map(resourceUrl).toList(),
    reviews: reviews.map(reviewFromJson).toList(),
  );
}

/// JSON تقييم زبون (نموذج CustomerFeedback) ← تقييم الواجهة.
Review reviewFromJson(Map<String, dynamic> j) {
  final serviceId = str(j, 'service_id') ?? str(j, 'serviceId');
  return Review(
    name: str(j, 'customer_name') ?? str(j, 'customerName') ?? 'عميل',
    avatar: _defaultAvatar,
    rating: (intOf(j, 'overall_rating') ?? 0).clamp(0, 5),
    date: arabicDate(str(j, 'submitted_at') ?? str(j, 'createdAt')),
    tag: serviceId == null ? '' : (serviceNameAr(serviceId) ?? ''),
    comment: str(j, 'written_feedback') ?? '',
  );
}

List<Map<String, dynamic>> _approvedServices(Object? raw) => [
  for (final s in asMapList(raw))
    if (str(s, 'approvalStatus') == null || str(s, 'approvalStatus') == 'APPROVED') s,
];

/// قوائم الخلفية أحياناً نص JSON وأحياناً List.
List<String> _stringList(Object? v) {
  if (v is List) return [for (final e in v) '$e'];
  if (v is String && v.trim().startsWith('[')) {
    try {
      final d = jsonDecode(v);
      if (d is List) return [for (final e in d) '$e'];
    } on FormatException {
      return const [];
    }
  }
  return const [];
}

String _location(Map<String, dynamic> p) {
  final ar = _stringList(p['service_areas_ar']);
  if (ar.isNotEmpty) return ar.first;
  final city = str(p, 'primary_city_code');
  if (city != null) return placeName(city);
  final areas = _stringList(p['service_area_codes']);
  return areas.isEmpty ? '' : areas.map(placeName).join('، ');
}

String _experience(Map<String, dynamic> p, List<Map<String, dynamic>> services) {
  var years = intOf(p, 'experience_years') ?? 0;
  if (years == 0) {
    for (final s in services) {
      final y = intOf(s, 'yearsExperience') ?? 0;
      if (y > years) years = y;
    }
  }
  return switch (years) {
    0 => 'غير محدد',
    1 => 'سنة واحدة',
    2 => 'سنتان',
    <= 10 => '$years سنوات',
    _ => '$years سنة',
  };
}

String _yesNo(Object? v, {required String yes}) => switch (v) {
  true => yes,
  false => 'لا',
  _ => 'غير محدد',
};
