import 'dart:convert';

import '../../core/backend/graphql_documents.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import '../../core/backend/media_upload.dart';
import 'offers_repository.dart';

/// عرض ترويجي للمهني مع حالته.
class MyOffer {
  const MyOffer({
    required this.id,
    required this.title,
    required this.image,
    required this.discount,
    required this.location,
    required this.active,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String image;
  final String discount;
  final String location;

  /// منشور وشغّال (مو قيد المراجعة/مرفوض/منتهي).
  final bool active;
  final String statusLabel;
}

/// حقول إنشاء عرض من الواجهة.
class NewOffer {
  const NewOffer({
    required this.title,
    required this.description,
    required this.serviceCategory,
    required this.percentage,
    required this.amount,
    required this.expiresAt,
    required this.photos,
    required this.cityCode,
    required this.neighborhoods,
  });

  final String title;
  final String description;
  final String serviceCategory;
  final bool percentage;
  final num amount;
  final DateTime expiresAt;
  final List<String> photos;
  final String cityCode;
  final List<String> neighborhoods;
}

abstract class MyOffersRepository {
  Future<List<MyOffer>> list();

  Future<void> create(NewOffer offer);
}

class FakeMyOffersRepository implements MyOffersRepository {
  const FakeMyOffersRepository();

  @override
  Future<List<MyOffer>> list() async => const [];

  @override
  Future<void> create(NewOffer offer) async {}
}

class RemoteMyOffersRepository implements MyOffersRepository {
  const RemoteMyOffersRepository(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<List<MyOffer>> list() async {
    final data = await _gateway.run(Gql.listMyOffers);
    final res = asMap(data['listMyOffers']);
    throwIfBackendError(res);
    return asMapList(res['offers']).map(myOfferFromJson).toList();
  }

  @override
  Future<void> create(NewOffer o) async {
    final keys = <String>[];
    for (final p in o.photos.where(isLocalPhoto)) {
      keys.add(await uploadMedia(_gateway, p, type: 'offer'));
    }
    final input = {
      'title': o.title,
      'description': o.description,
      'serviceCategory': o.serviceCategory,
      'offerType': o.percentage ? 'percentage_discount' : 'fixed_price',
      if (o.percentage) 'discountPercentage': o.amount else 'price': o.amount,
      'currency': 'SYP',
      'cityCode': o.cityCode,
      'neighborhoods': o.neighborhoods,
      'photos': keys,
      'expiresAt': o.expiresAt.toUtc().toIso8601String(),
    };
    final data = await _gateway.run(
      Gql.createOffer,
      variables: {'input': jsonEncode(input)},
      mutation: true,
    );
    throwIfBackendError(asMap(data['createOfferSecure']));
  }
}

MyOffer myOfferFromJson(Map<String, dynamic> j) {
  final offer = offerFromJson(j);
  final status = str(j, 'status') ?? 'pending';
  final listing = str(j, 'listing_status') ?? '';
  final active =
      status == 'approved' && (listing.isEmpty || listing == 'active');
  return MyOffer(
    id: str(j, 'id') ?? '',
    title: offer.title,
    image: offer.image,
    discount: offer.discount,
    location: offer.location,
    active: active,
    statusLabel: switch (status) {
      'approved' => active ? 'نشط' : 'منتهي',
      'rejected' => 'مرفوض',
      _ => 'قيد المراجعة',
    },
  );
}
