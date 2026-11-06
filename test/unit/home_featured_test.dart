import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/repositories/offers_repository.dart';
import 'package:khaled_flutter/data/service_names.dart';

Map<String, dynamic> _offer(String id, String pro, String cat) => {
  'id': id,
  'title': 't',
  'professionalId': pro,
  'professionalName': 'سارة',
  'serviceCategory': cat,
  'cityCode': 'aleppo',
  'neighborhoods': ['aleppo_center'],
  'discountPercentage': 20,
};

void main() {
  test('حرفيو الرئيسية: بدون تكرار وخدماتهم مجمّعة بالعربي', () {
    final offers = [
      offerFromJson(_offer('1', 'p1', 'electrical_repair')),
      offerFromJson(_offer('2', 'p1', 'painting_molding')),
      offerFromJson(_offer('3', 'p2', 'carpentry')),
    ];
    final list = featuredCraftsmenFromOffers(offers);
    expect(list.map((c) => c.professionalId), ['p1', 'p2']);
    expect(list.first.services.length, 2);
    expect(offers.first.location, 'مركز حلب');
    expect(offers.first.discount, 'خصم 20%');
    expect(offers.first.tags, ['الإصلاحات الكهربائية']);
  });

  test('قائمة الخدمات: بدون تكرار وكود مجهول ما بيظهر خام', () {
    final all = allServices();
    expect(all.map((s) => s.name).toSet().length, all.length);
    expect(all.any((s) => s.id == 'unspecified'), isFalse);
    expect(serviceLabelAr('zzz_unknown'), 'خدمات أخرى');
  });
}
