import '../../core/backend/backend_exception.dart';
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
}

class FakeOffersRepository implements OffersRepository {
  const FakeOffersRepository();

  @override
  Future<List<Offer>> listPublicOffers({
    String? cityCode,
    String? serviceCategory,
    bool featured = false,
  }) async => featured ? specialOffers : allOffers;
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
