import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/graphql_gateway.dart';
import 'package:khaled_flutter/data/repositories/professional_profile_repository.dart';

const _json = {
  'user_id': 'u1',
  'business_name': 'سارة للصيانة',
  'professional_profile_image_url': 'professional-profile-pictures/u1/p.jpg',
  'portfolio_images': ['portfolio/u1/a.jpg', ' ', 'portfolio/u1/b.jpg'],
  'primary_city_code': 'damascus',
  'service_area_codes': ['damascus_center'],
  'has_tools': true,
  'working_hours': '{"type":"صباحاً","flexible":false}',
  'professional_services': [
    {'serviceId': 'plumbing', 'yearsExperience': 3},
    {
      'serviceId': 'plumbing_repair',
      'approvalStatus': 'APPROVED',
      'yearsExperience': 3,
    },
  ],
};

class _RecordingGateway implements GraphQlGateway {
  Map<String, dynamic>? vars;

  @override
  Future<Map<String, dynamic>> run(
    String document, {
    Map<String, dynamic> variables = const {},
    bool mutation = false,
    bool guest = false,
  }) async {
    vars = variables;
    return {
      'updateProfessionalSecure': {'professional': '{}', 'error': null},
    };
  }

  @override
  Stream<Map<String, dynamic>> subscribe(
    String document, {
    Map<String, dynamic> variables = const {},
  }) => const Stream.empty();
}

void main() {
  group('professionalFromJson', () {
    final p = professionalFromJson(_json);

    test('بيقرأ الحقول الأساسية وبيتجاهل صور المعرض الفاضية', () {
      expect(p.userId, 'u1');
      expect(p.businessName, 'سارة للصيانة');
      expect(p.portfolio, ['portfolio/u1/a.jpg', 'portfolio/u1/b.jpg']);
      expect(p.imageUrl, endsWith('/professional-profile-pictures/u1/p.jpg'));
      expect(p.hasTools, true);
      expect(p.hasTransport, isNull);
      expect(p.workingHoursType, 'صباحاً');
      expect(p.cityCode, 'damascus');
    });

    test('الخدمات المعروفة بس بتظهر بالواجهة', () {
      expect(p.serviceNames, ['السباكة']);
    });
  });

  group('professionalUpdateInput', () {
    final p = professionalFromJson(_json);

    test('بدون تعديلات أو بقيم مطابقة ما بيرسل شي', () {
      expect(professionalUpdateInput(p, const ProfessionalEdits()), isEmpty);
      expect(
        professionalUpdateInput(
          p,
          ProfessionalEdits(
            businessName: p.businessName,
            hasTools: true,
            workingHoursType: 'صباحاً',
            areaCodes: const ['damascus_center'],
            serviceNames: const ['السباكة'],
          ),
        ),
        isEmpty,
      );
    });

    test('بيرسل بس الحقول المتغيّرة', () {
      final m = professionalUpdateInput(
        p,
        const ProfessionalEdits(
          businessName: 'اسم جديد',
          description: 'نبذة',
          experienceYears: 5,
          hasTransport: true,
          workingHoursType: 'مرن - أي وقت من النهار',
          workshopAddress: 'المزة',
          latitude: 33.5,
          longitude: 36.3,
        ),
      );
      expect(m['business_name'], 'اسم جديد');
      expect(m['description_ar'], 'نبذة');
      expect(m['experience_years'], 5);
      expect(m['has_transport'], true);
      expect(jsonDecode(m['working_hours'] as String), {
        'type': 'مرن - أي وقت من النهار',
        'flexible': true,
      });
      expect(m['workshop_latitude'], 33.5);
      expect(m.containsKey('has_tools'), isFalse);
    });

    test('المدينة والمناطق بالأكواد', () {
      final m = professionalUpdateInput(
        p,
        const ProfessionalEdits(
          cityCode: 'aleppo',
          areaCodes: ['damascus_center', 'x'],
        ),
      );
      expect(m['serving_city_codes'], ['aleppo']);
      expect(m['serving_cities_ar'], ['حلب']);
      expect(m['service_area_codes'], ['damascus_center', 'x']);
    });

    test('الخدمات: إضافة PENDING وحذف المعروفة مع الحفاظ على غير المعروفة', () {
      final add =
          professionalUpdateInput(
                p,
                const ProfessionalEdits(
                  serviceNames: ['السباكة', 'الكهرباء'],
                  experienceYears: 4,
                ),
              )['professional_services']
              as List;
      expect(add.length, 3);
      expect((add.last as Map)['serviceId'], 'electrical_repair');
      expect((add.last as Map)['approvalStatus'], 'PENDING');

      final remove =
          professionalUpdateInput(
                p,
                const ProfessionalEdits(serviceNames: ['الكهرباء']),
              )['professional_services']
              as List;
      expect(remove.map((e) => (e as Map)['serviceId']), [
        'plumbing',
        'electrical_repair',
      ]);
    });
  });

  test('RemoteProfessionalProfileRepository بيرسل input كنص JSON فيه user_id و details', () async {
    final gw = _RecordingGateway();
    final repo = RemoteProfessionalProfileRepository(gw);
    final p = professionalFromJson(_json);
    await repo.save(p, const ProfessionalEdits(description: 'x'));
    final input = jsonDecode(gw.vars!['input'] as String) as Map;
    expect(input, {
      'user_id': 'u1',
      'details': 'profile',
      'description_ar': 'x',
    });

    gw.vars = null;
    await repo.save(p, const ProfessionalEdits());
    expect(gw.vars, isNull);
  });
}
