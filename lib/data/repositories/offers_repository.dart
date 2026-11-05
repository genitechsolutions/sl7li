import '../../core/backend/backend_exception.dart';
import '../../core/backend/gql_offer_details.dart';
import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../dummy_data.dart';

/// العروض الخاصة (عامة — بتشتغل للضيف كمان).
abstract class OffersRepository {
  /// [featured] = عروض الرئيسية (أقل عدداً)؛ بدونها كل العروض.
  Future<List<Offer>> listPublicOffers({
    String? cityCode,
    String? serviceCategory,
    bool featured = false,
  });

  Future<OfferDetails> offerDetails(String offerId);

  /// تتبّع التفاعل: فشله ما لازم يأثر على الواجهة.
  Future<void> trackDetailView(String offerId);
  Future<void> trackWhatsAppClick(String offerId);
  Future<void> trackRelatedQuoteRequest(String offerId);
}

class FakeOffersRepository implements OffersRepository {
  const FakeOffersRepository();

  @override
  Future<List<Offer>> listPublicOffers({
    String? cityCode,
    String? serviceCategory,
    bool featured = false,
  }) async => featured ? specialOffers : allOffers;

  @override
  Future<OfferDetails> offerDetails(String offerId) async => sampleOfferDetails;

  @override
  Future<void> trackDetailView(String offerId) async {}

  @override
  Future<void> trackWhatsAppClick(String offerId) async {}

  @override
  Future<void> trackRelatedQuoteRequest(String offerId) async {}
}

class RemoteOffersRepository implements OffersRepository {
  const RemoteOffersRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<List<Offer>> listPublicOffers({
    String? cityCode,
    String? serviceCategory,
    bool featured = false,
  }) async {
    final Map<String, dynamic> data;
    try {
      data = await _gateway.run(
        Gql.listPublicOffers,
        variables: {
          'cityCode': cityCode,
          'serviceCategory': serviceCategory,
          'limit': featured ? 10 : 50,
        },
        guest: true,
      );
    } on BackendException catch (e) {
      if (e.code == 'NO_API_KEY') return const [];
      rethrow;
    }
    final res = asMap(data['listPublicOffers']);
    return asMapList(res['items']).map(offerFromJson).toList();
  }

  @override
  Future<OfferDetails> offerDetails(String offerId) async {
    final data = await _gateway.run(
      GqlOfferDetails.getOfferDetails,
      variables: {'offerId': offerId},
      guest: true,
    );
    final res = asMap(data['getOfferDetails']);
    throwIfBackendError(res);
    final offer = asMap(res['offer']);
    if (offer.isEmpty) throw const BackendException('العرض غير موجود');
    return offerDetailsFromJson(offer);
  }

  @override
  Future<void> trackDetailView(String offerId) =>
      _track(GqlOfferDetails.trackOfferDetailView, offerId);

  @override
  Future<void> trackWhatsAppClick(String offerId) =>
      _track(GqlOfferDetails.trackOfferWhatsAppClick, offerId);

  @override
  Future<void> trackRelatedQuoteRequest(String offerId) =>
      _track(GqlOfferDetails.trackOfferRelatedQuoteRequest, offerId);

  Future<void> _track(String document, String offerId) async {
    try {
      await _gateway.run(
        document,
        variables: {'offerId': offerId},
        mutation: true,
        guest: true,
      );
    } on BackendException {
      return;
    }
  }
}

String _priceLabel(Map<String, dynamic> j) {
  final price = j['price'];
  if (price == null) return '';
  final currency = str(j, 'currency') ?? 'SYP';
  return '${formatMoney(price)} ${currency == 'SYP' ? 'ل.س' : currency}';
}

/// JSON تفاصيل عرض ← شاشة التفاصيل.
OfferDetails offerDetailsFromJson(Map<String, dynamic> j) {
  final photos = strList(j, 'photos').map(resourceUrl).toList();
  final profileImage = str(j, 'professionalProfileImage');
  final percent = intOf(j, 'discountPercentage');
  final cityCode = str(j, 'cityCode');
  final expires = DateTime.tryParse(str(j, 'expiresAt') ?? '')?.toLocal();
  final category = str(j, 'serviceCategory');
  final rating = j['professionalRating'];
  return OfferDetails(
    id: str(j, 'id'),
    title: str(j, 'title') ?? '',
    discount: percent != null && percent > 0 ? 'خصم $percent%' : _priceLabel(j),
    validUntil: expires == null ? '' : '${expires.day}/${expires.month}/${expires.year}',
    city: cityCode == null ? 'جميع المدن' : placeName(cityCode),
    description: str(j, 'description') ?? '',
    images: photos.isNotEmpty ? photos : ['assets/images/offer_carpentry.jpg'],
    tags: [?category],
    craftsman: Craftsman(
      name: str(j, 'professionalName') ?? '',
      location: cityCode == null ? '' : placeName(cityCode),
      services: const [],
      image: profileImage == null ? null : resourceUrl(profileImage),
      rating: rating is num ? rating.toDouble() : null,
      reviewsCount: intOf(j, 'professionalReviewCount') ?? 0,
      isPro: boolOf(j, 'professionalIsVip'),
      professionalId: str(j, 'professionalId'),
    ),
  );
}

/// JSON عرض (حقول نموذج Offer بالخلفية) ← عرض الواجهة.
Offer offerFromJson(Map<String, dynamic> j) {
  final photos = strList(j, 'photos');
  final image = photos.isNotEmpty
      ? photos.first
      : str(j, 'professionalProfileImage');
  final percent = intOf(j, 'discountPercentage');
  final price = j['price'];
  final discount = percent != null && percent > 0
      ? '$percent%'
      : price != null
      ? '${formatMoney(price)} ${(str(j, 'currency') ?? 'SYP') == 'SYP' ? 'ل.س' : str(j, 'currency')}'
      : '';
  final neighborhoods = strList(j, 'neighborhoods');
  return Offer(
    id: str(j, 'id'),
    title: str(j, 'title') ?? '',
    location: placeName(
      neighborhoods.isNotEmpty ? neighborhoods.first : (str(j, 'cityCode') ?? ''),
    ),
    image: image == null ? 'assets/images/offer_carpentry.jpg' : resourceUrl(image),
    discount: discount,
    tags: [if (str(j, 'serviceCategory') != null) str(j, 'serviceCategory')!],
    professionalId: str(j, 'professionalId'),
  );
}
