import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/data/my_request.dart';
import 'package:khaled_flutter/data/repositories/proposal_filter.dart';
import 'package:khaled_flutter/data/repositories/requests_repository.dart';

Map<String, dynamic> _p(String id, String pro, String status, [String at = '2026-01-01']) => {
  'proposal_id': id,
  'professional_id': pro,
  'status': status,
  'updatedAt': at,
};

void main() {
  group('liveProposals', () {
    test('بيستبعد المسحوب والمرفوض', () {
      final list = liveProposals([
        _p('1', 'a', 'submitted'),
        _p('2', 'b', 'withdrawn'),
        _p('3', 'c', 'rejected'),
        _p('4', 'd', 'approved'),
      ]);
      expect(list.map((p) => p['proposal_id']), ['1', '4']);
    });

    test('نسخة وحدة لكل مهني (الأحدث)', () {
      final list = liveProposals([
        _p('1', 'a', 'submitted', '2026-01-01'),
        _p('2', 'a', 'submitted', '2026-01-03'),
        _p('3', 'b', 'submitted'),
      ]);
      expect(list.map((p) => p['proposal_id']), ['2', '3']);
    });
  });

  group('effectiveSelection', () {
    test('عرض وحيد بيتختار تلقائياً', () {
      expect(effectiveSelection(['x'], null), 'x');
    });
    test('أكتر من عرض بدون اختيار = ولا واحد', () {
      expect(effectiveSelection(['x', 'y'], null), isNull);
    });
    test('الاختيار بيُحترم، والمعرّف الغريب بيتجاهل', () {
      expect(effectiveSelection(['x', 'y'], 'y'), 'y');
      expect(effectiveSelection(['x', 'y'], 'z'), isNull);
    });
  });

  group('عدّاد العروض بالطلب', () {
    test('بيعدّ العروض الفعّالة مش response_count', () {
      final r = myRequestFromJson({
        'job_id': 'j',
        'status': 'open',
        'response_count': 4,
        'proposals': [
          _p('1', 'a', 'submitted'),
          _p('2', 'b', 'withdrawn'),
          _p('3', 'c', 'submitted'),
        ],
      });
      expect(r.offersCount, 2);
    });

    test('بدون قائمة عروض بيرجع لـ response_count', () {
      expect(myRequestFromJson({'job_id': 'j', 'status': 'open', 'response_count': 3}).offersCount, 3);
    });

    test('واتساب والمدينة', () {
      final r = myRequestFromJson({
        'job_id': 'j',
        'share_whatsapp_with_professionals': false,
        'city_code': 'aleppo',
      });
      expect(r.shareWhatsapp, isFalse);
      expect(r.cityCode, 'aleppo');
    });
  });

  test('updateJobInput', () {
    final m = updateJobInput(
      'j1',
      description: '  وصف جديد للطلب  ',
      priority: RequestPriority.urgent,
      shareWhatsapp: false,
    );
    expect(m, {
      'job_id': 'j1',
      'description': 'وصف جديد للطلب',
      'urgency': 'urgent',
      'share_whatsapp_with_professionals': false,
    });
  });
}
