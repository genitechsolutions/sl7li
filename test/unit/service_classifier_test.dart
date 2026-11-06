import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/json_utils.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';
import 'package:khaled_flutter/data/repositories/service_classifier_repository.dart';
import 'package:khaled_flutter/data/request_draft.dart';

void main() {
  group('classificationFromJson', () {
    test('سباكة مع تخصص معروف', () {
      final r = classificationFromJson({
        'confidence': 0.9,
        'primaryService': 'plumbing_repair',
        'suggestedSpecialties': ['unclog_drains'],
      });
      expect(r?.serviceId, 'plumbing_repair');
      expect(r?.serviceLabel, 'السباكة');
      expect(r?.specialtyId, 'unclog_drains');
      expect(r?.specialtyLabel, 'تسليك مجاري');
    });

    test('تخصص مجهول بيتجاهل والخدمة بتضل', () {
      final r = classificationFromJson({
        'confidence': 0.8,
        'primaryService': 'carpentry',
        'suggestedSpecialties': ['door_handles_locks_repair'],
      });
      expect(r?.serviceLabel, 'النجارة');
      expect(r?.specialtyId, isNull);
    });

    test('غير مصنّف/ثقة قليلة/خدمة مجهولة = null', () {
      expect(classificationFromJson({'confidence': 0.1, 'primaryService': 'unspecified'}), isNull);
      expect(classificationFromJson({'confidence': 0.3, 'primaryService': 'carpentry'}), isNull);
      expect(classificationFromJson({'confidence': 0.9, 'primaryService': 'zzz'}), isNull);
      expect(classificationFromJson({}), isNull);
    });
  });

  test('createJobInput بيستعمل service_id المصنّف', () {
    final d = RequestDraft()
      ..description = 'تسريب'
      ..serviceId = 'plumbing_repair'
      ..specialtyId = 'unclog_drains';
    final j = createJobInput(d, jobId: 'a');
    expect(j['service_id'], 'plumbing_repair');
    expect(j['specialties_requested'], ['unclog_drains']);
    expect(createJobInput(RequestDraft(), jobId: 'a')['service_id'], 'general');
  });

  test('fake classifier دايماً null', () async {
    expect(await const FakeServiceClassifier().classify('x'), isNull);
  });

  test('placeName: أكواد المراكز', () {
    expect(placeName('aleppo_center'), 'مركز حلب');
    expect(placeName('latakia_center'), 'مركز اللاذقية');
    expect(placeName('daraa'), 'درعا');
    expect(placeName('damascus_center'), 'مركز المدينة');
    expect(placeName('idlib_center'), 'مركز إدلب');
    expect(placeName('xyz_center'), 'مركز المدينة');
    expect(placeName('some_new_area'), 'منطقة أخرى');
    expect(placeName('المزة'), 'المزة');
  });
}
