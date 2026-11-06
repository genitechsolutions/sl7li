import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/gql_offer_manage.dart';
import 'package:khaled_flutter/data/repositories/my_offers_repository.dart';

void main() {
  test('مدخل التعديل: id + خصم نسبة بدون تاريخ انتهاء', () {
    final input = updateOfferInput(
      'o1',
      NewOffer(
        title: 'ت',
        description: 'و',
        serviceCategory: 'plumbing_repair',
        percentage: true,
        amount: 15,
        expiresAt: DateTime(2026),
        photos: const [],
        cityCode: 'damascus',
        neighborhoods: const ['damascus_center'],
      ),
      ['offers/a.jpg'],
    );
    expect(input['id'], 'o1');
    expect(input['discountPercentage'], 15);
    expect(input.containsKey('price'), false);
    expect(input.containsKey('expiresAt'), false);
    expect(input['photos'], ['offers/a.jpg']);
  });

  test('تحويل عرض معتمد موقوف وغير منتهي = موقوف', () {
    final o = myOfferFromJson({
      'id': 'o1',
      'title': 'ع',
      'status': 'approved',
      'listing_status': 'inactive',
      'expiresAt': '2999-01-01T00:00:00.000Z',
      'price': 1000,
      'serviceCategory': 'electrical_repair',
      'photos': ['offers/a.jpg'],
    });
    expect(o.statusLabel, 'موقوف');
    expect(o.approved, true);
    expect(o.active, false);
    expect(o.amount, 1000);
    expect(o.percentage, false);
    expect(o.photoKeys, ['offers/a.jpg']);
  });

  test('عرض نشط وعرض منتهي', () {
    final active = myOfferFromJson({
      'status': 'approved',
      'listing_status': 'active',
      'discountPercentage': 10,
    });
    expect(active.statusLabel, 'نشط');
    expect(active.percentage, true);
    final expired = myOfferFromJson({
      'status': 'approved',
      'listing_status': 'inactive',
      'expiresAt': '2020-01-01T00:00:00.000Z',
    });
    expect(expired.statusLabel, 'منتهي');
  });

  test('مستندات الإدارة', () {
    expect(GqlOfferManage.toggle, contains('toggleOfferStatusSecure'));
    expect(GqlOfferManage.delete, contains(r'$offerId'));
    expect(GqlOfferManage.update, contains('AWSJSON'));
  });
}
