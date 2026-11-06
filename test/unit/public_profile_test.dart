import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/cubits/load_cubit.dart';
import 'package:khaled_flutter/cubits/public_profile_cubit.dart';
import 'package:khaled_flutter/data/repositories/public_profile_repository.dart';

const _pid = '61bb9520-a0f1-701c-7c97-1aa1c23122c1';

Map<String, dynamic> _professional() => {
  'user_id': _pid,
  'business_name': 'سارة للصيانة',
  'professional_profile_image_url': 'professional-profile-pictures/$_pid/p.jpg',
  'professional_services': [
    {'serviceId': 'plumbing', 'yearsExperience': 3},
    {'serviceId': 'plumbing_repair', 'approvalStatus': 'APPROVED', 'yearsExperience': 5},
    {'serviceId': 'electrical_repair', 'approvalStatus': 'PENDING'},
  ],
  'portfolio_images': ['portfolio/$_pid/a.jpg', 'portfolio/$_pid/b.jpg'],
  'service_area_codes': ['damascus_center'],
  'primary_city_code': 'damascus',
  'description_ar': 'نبذة قصيرة',
  'has_tools': true,
  'has_transport': false,
  'rating': 4.5,
  'review_count': 2,
  'isVip': true,
  'verification_status': 'verified',
};

void main() {
  test('craftsmanProfileFromJson بيحوّل حقول المهني', () {
    final p = craftsmanProfileFromJson(_professional());
    final c = p.craftsman;
    expect(c.professionalId, _pid);
    expect(c.name, 'سارة للصيانة');
    expect(c.location, 'دمشق');
    expect(c.rating, 4.5);
    expect(c.reviewsCount, 2);
    expect(c.isPro, isTrue);
    expect(c.isVerified, isTrue);
    expect(c.image, startsWith('https://'));
    expect(p.specialties, ['خدمات تمديدات صحية أخرى', 'تمديدات الصحية']);
    expect(p.works, hasLength(2));
    expect(p.works.first, startsWith('https://'));
    expect(p.experience, '5 سنوات');
    expect(p.tools, 'نعم، أملك الأدوات');
    expect(p.transport, 'لا');
    expect(p.bio, 'نبذة قصيرة');
    expect(p.bioPreviewLength, p.bio.length);
  });

  test('قيم ناقصة بتعطي افتراضات آمنة', () {
    final p = craftsmanProfileFromJson({'user_id': 'x'});
    expect(p.craftsman.rating, isNull);
    expect(p.experience, 'غير محدد');
    expect(p.tools, 'غير محدد');
    expect(p.works, isEmpty);
    expect(p.reviews, isEmpty);
  });

  test('reviewFromJson من نموذج CustomerFeedback', () {
    final r = reviewFromJson({
      'overall_rating': 4,
      'written_feedback': 'شغل ممتاز',
      'submitted_at': '2026-08-05T10:00:00Z',
      'customer_name': 'أحمد',
    });
    expect(r.rating, 4);
    expect(r.comment, 'شغل ممتاز');
    expect(r.name, 'أحمد');
    expect(r.date, contains('2026'));
    expect(reviewFromJson({}).name, 'عميل');
  });

  test('العروض بتحمل professionalId', () {
    final p = craftsmanProfileFromJson(
      _professional(),
      offers: [
        {'title': 'عرض', 'professionalId': _pid, 'discountPercentage': 20},
      ],
    );
    expect(p.offers.single.professionalId, _pid);
    expect(p.offers.single.discount, 'خصم 20%');
  });

  test('PublicProfileCubit بيحمّل من الريبو الوهمي', () async {
    final cubit = PublicProfileCubit(const FakePublicProfileRepository(), 'any');
    await cubit.load();
    expect(cubit.state.status, LoadStatus.success);
    expect(cubit.state.data!.craftsman.name, isNotEmpty);
  });
}
