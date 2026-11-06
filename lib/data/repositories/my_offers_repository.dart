import 'dart:convert';

import '../../core/backend/gql_offer_manage.dart';
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
    this.description = '',
    this.serviceCategory = '',
    this.percentage = false,
    this.amount = 0,
    this.cityCode = '',
    this.neighborhoods = const [],
    this.photoKeys = const [],
    this.approved = false,
  });

  final String id;
  final String title;
  final String image;
  final String discount;
  final String location;

  /// منشور وشغّال (مو قيد المراجعة/مرفوض/منتهي).
  final bool active;
  final String statusLabel;
  final String description;
  final String serviceCategory;
  final bool percentage;
  final num amount;
  final String cityCode;
  final List<String> neighborhoods;

  /// مفاتيح S3 للصور المحفوظة.
  final List<String> photoKeys;

  /// موافَق عليه من الإدارة (شرط الإيقاف/التفعيل).
  final bool approved;
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

  Future<void> update(String id, NewOffer offer);

  Future<void> toggle(String id);

  Future<void> delete(String id);
}

class FakeMyOffersRepository implements MyOffersRepository {
  const FakeMyOffersRepository();

  @override
  Future<List<MyOffer>> list() async => const [];

  @override
  Future<void> create(NewOffer offer) async {}

  @override
  Future<void> update(String id, NewOffer offer) async {}

  @override
  Future<void> toggle(String id) async {}

  @override
  Future<void> delete(String id) async {}
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

  @override
  Future<void> update(String id, NewOffer o) async {
    final keys = <String>[];
    for (final p in o.photos) {
      keys.add(
        isLocalPhoto(p) && !p.startsWith('http')
            ? await uploadMedia(_gateway, p, type: 'offer')
            : offerPhotoKey(p),
      );
    }
    final data = await _gateway.run(
      GqlOfferManage.update,
      variables: {'input': jsonEncode(updateOfferInput(id, o, keys))},
      mutation: true,
    );
    throwIfBackendError(asMap(data['updateOfferSecure']));
  }

  @override
  Future<void> toggle(String id) async {
    final data = await _gateway.run(
      GqlOfferManage.toggle,
      variables: {'offerId': id},
      mutation: true,
    );
    throwIfBackendError(asMap(data['toggleOfferStatusSecure']));
  }

  @override
  Future<void> delete(String id) async {
    final data = await _gateway.run(
      GqlOfferManage.delete,
      variables: {'offerId': id},
      mutation: true,
    );
    throwIfBackendError(asMap(data['deleteOfferSecure']));
  }
}

/// مدخل التعديل؛ تاريخ الانتهاء ممنوع تعديله بالخلفية فمو مرسل.
Map<String, dynamic> updateOfferInput(
  String id,
  NewOffer o,
  List<String> photoKeys,
) => {
  'id': id,
  'title': o.title,
  'description': o.description,
  'serviceCategory': o.serviceCategory,
  'offerType': o.percentage ? 'percentage_discount' : 'fixed_price',
  if (o.percentage) 'discountPercentage': o.amount else 'price': o.amount,
  'currency': 'SYP',
  'cityCode': o.cityCode,
  'neighborhoods': o.neighborhoods,
  'photos': photoKeys,
};

/// رابط صورة محمّلة ← مفتاح S3 (المفتاح نفسه إذا مو رابط).
String offerPhotoKey(String p) {
  final prefix = resourceUrl('');
  return p.startsWith(prefix) ? p.substring(prefix.length) : p;
}

MyOffer myOfferFromJson(Map<String, dynamic> j) {
  final offer = offerFromJson(j);
  final status = str(j, 'status') ?? 'pending';
  final listing = str(j, 'listing_status') ?? '';
  final active =
      status == 'approved' && (listing.isEmpty || listing == 'active');
  final expires = DateTime.tryParse(str(j, 'expiresAt') ?? '');
  final expired = expires != null && expires.isBefore(DateTime.now());
  final percent = num.tryParse('${j['discountPercentage'] ?? ''}');
  return MyOffer(
    id: str(j, 'id') ?? '',
    title: offer.title,
    image: offer.image,
    discount: offer.discount,
    location: offer.location,
    active: active,
    description: str(j, 'description') ?? '',
    serviceCategory: str(j, 'serviceCategory') ?? '',
    percentage: percent != null && percent > 0,
    amount: percent != null && percent > 0
        ? percent
        : num.tryParse('${j['price'] ?? ''}') ?? 0,
    cityCode: str(j, 'cityCode') ?? '',
    neighborhoods: strList(j, 'neighborhoods'),
    photoKeys: strList(j, 'photos'),
    approved: status == 'approved',
    statusLabel: switch (status) {
      'approved' => active ? 'نشط' : (expired ? 'منتهي' : 'موقوف'),
      'rejected' => 'مرفوض',
      _ => 'قيد المراجعة',
    },
  );
}
