import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khaled_flutter/core/backend/backend_exception.dart';
import 'package:khaled_flutter/core/backend/graphql_gateway.dart';
import 'package:khaled_flutter/cubits/craftsman_signup_cubit.dart';
import 'package:khaled_flutter/data/craftsman_signup.dart';
import 'package:khaled_flutter/data/repositories/craftsman_signup_repository.dart';

CraftsmanSignupDraft _draft() {
  final d = CraftsmanSignupDraft()
    ..businessName = ' مركز النور '
    ..city = 'دمشق'
    ..districts.addAll(['مركز المدينة', 'المزة'])
    ..services.addAll(['التكييف', 'الدهانات'])
    ..years = '5'
    ..transport = 'سيارة خاصة'
    ..workTimes = 'مرن - أي وقت من النهار'
    ..workshopAddress = 'شارع بغداد'
    ..bio = 'نبذة'
    ..registrationSource = 'من الإعلانات'
    ..businessType = 'فرد'
    ..age = '30'
    ..projectScales = 'أعمال منزلية ومحلات';
  d.specialties['التكييف'] = {'تصليح براد', 'تبديل وصيانة الضواغط', 'تنظيف وحدات التكييف'};
  d.specialties['الدهانات'] = {'دهان داخلي'};
  return d;
}

class _FakeGateway implements GraphQlGateway {
  _FakeGateway(this.createResponse, {this.roles = const ['customer']});

  final Map<String, dynamic> createResponse;
  final List<String> roles;
  final calls = <(String, Map<String, dynamic>)>[];

  @override
  Future<Map<String, dynamic>> run(
    String document, {
    Map<String, dynamic> variables = const {},
    bool mutation = false,
    bool guest = false,
  }) async {
    calls.add((document, variables));
    if (document.contains('GetCurrentUserSecure')) {
      return {
        'getCurrentUserSecure': {
          'user': jsonEncode({
            'user_id': 'u1',
            'phone_number': '+963111111111',
            'roles': roles,
          }),
          'error': null,
        },
      };
    }
    if (document.contains('CreateProfessionalSecure')) {
      return {'createProfessionalSecure': createResponse};
    }
    return {'updateUser': {'user_id': 'u1'}};
  }

  @override
  Stream<Map<String, dynamic>> subscribe(String document, {Map<String, dynamic> variables = const {}}) =>
      const Stream.empty();
}

void main() {
  group('craftsmanSignupInput', () {
    final input = craftsmanSignupInput(_draft(), userId: 'u1', whatsappNumber: '+963111111111');

    test('حقول الخلفية المطلوبة', () {
      expect(input['registration_source'], 'ads');
      expect(input['registration_organization_name'], isNull);
      expect(input['business_type'], 'individual');
      expect(input['age'], 30);
      expect(input['has_engineering_degree'], false);
      expect(input['has_professional_license'], false);
      expect(input['project_scales'], ['residential_small_business']);
      expect(input['has_team'], false);
      expect(input['team_size'], isNull);
    });

    test('الأساسيات والمدينة والأحياء', () {
      expect(input['user_id'], 'u1');
      expect(input['details'], 'profile');
      expect(input['business_name'], 'مركز النور');
      expect(input['whatsapp_number'], '+963111111111');
      expect(input['serving_city_codes'], ['damascus']);
      expect(input['service_area_codes'], ['damascus_center', 'المزة']);
      expect(input['experience_years'], 5);
      expect(input['description_ar'], 'نبذة');
      expect(input['workshop_address'], 'شارع بغداد');
      expect(input.containsKey('workshop_latitude'), isFalse);
    });

    test('الخدمات بأكواد الكتالوج والتخصصات المعروفة بس', () {
      final services = (input['professional_services'] as List).cast<Map<String, dynamic>>();
      expect(services.map((s) => s['serviceId']), ['air_conditioning', 'painting_molding']);
      expect(services[0]['approvedSpecialties'], ['refrigerator_repair', 'repair_ac_compressors']);
      expect(services[1]['approvedSpecialties'], ['interior_wall_painting']);
      expect(services[0]['approvalStatus'], 'APPROVED');
      expect(services[0]['yearsExperience'], 5);
    });

    test('الأدوات والمواصلات وساعات العمل متل الموقع', () {
      expect(input['tools_status'], 'نعم، أملك جميع الأدوات');
      expect(input['has_tools'], true);
      expect(input['transportation_mode'], 'نعم، سيارة خاصة');
      expect(input['has_transport'], true);
      expect(jsonDecode(input['working_hours'] as String), {
        'type': 'مرن - أي وقت من النهار',
        'flexible': true,
      });
    });

    test('منظمة + فريق + شركة + الاتنين حجم + بدون مواصلات + موقع', () {
      final d = _draft()
        ..registrationSource = craftsmanOrganizationSource
        ..registrationOrganizationName = '  جمعية الخير  '
        ..businessType = 'شركة'
        ..projectScales = 'كلاهما'
        ..hasTeam = true
        ..teamSize = '4'
        ..hasTools = false
        ..hasEngineeringDegree = true
        ..transport = 'لا أملك وسيلة مواصلات'
        ..latitude = 33.5
        ..longitude = 36.3;
      final i = craftsmanSignupInput(d, userId: 'u', whatsappNumber: '');
      expect(i['registration_source'], 'organization');
      expect(i['registration_organization_name'], 'جمعية الخير');
      expect(i['business_type'], 'company');
      expect(i['project_scales'], ['residential_small_business', 'large_industrial']);
      expect(i['has_team'], true);
      expect(i['team_size'], 4);
      expect(i['has_tools'], false);
      expect(i['tools_status'], 'لا أملك أدوات');
      expect(i['has_engineering_degree'], true);
      expect(i['has_transport'], false);
      expect(i['workshop_latitude'], 33.5);
      expect(i['workshop_longitude'], 36.3);
    });

    test('بدون نبذة بيطلع وصف افتراضي، وأوقات العمل اختيارية', () {
      final d = _draft()
        ..bio = ''
        ..workTimes = null;
      final i = craftsmanSignupInput(d, userId: 'u', whatsappNumber: '');
      expect(i['description_ar'], 'خبير في التكييف، الدهانات');
      expect(i.containsKey('working_hours'), isFalse);
    });

    test('قابل للترميز JSON (AWSJSON)', () {
      expect(() => jsonEncode(input), returnsNormally);
    });
  });

  group('تحقق المسودة', () {
    test('مسودة كاملة', () {
      expect(craftsmanSignupProblem(_draft()), isNull);
    });

    test('العمر تحت 20 أو مش رقم', () {
      expect((_draft()..age = '19').step1Valid, isFalse);
      expect((_draft()..age = 'abc').step1Valid, isFalse);
      expect((_draft()..age = '20').step1Valid, isTrue);
      expect(craftsmanSignupProblem(_draft()..age = '15'), contains('20'));
    });

    test('المنظمة بدها اسم', () {
      final d = _draft()..registrationSource = craftsmanOrganizationSource;
      expect(d.registrationValid, isFalse);
      expect(craftsmanSignupProblem(d), isNotNull);
      d.registrationOrganizationName = 'جمعية';
      expect(d.registrationValid, isTrue);
    });

    test('الفريق بدو عدد، والخطوة 3 بدها حجم المشاريع', () {
      final d = _draft()..hasTeam = true;
      expect(d.step3Valid, isFalse);
      d.teamSize = '0';
      expect(d.teamValid, isFalse);
      d.teamSize = '3';
      expect(d.step3Valid, isTrue);
      d.projectScales = null;
      expect(d.step3Valid, isFalse);
    });

    test('بدون خدمات أو نوع نشاط', () {
      expect(craftsmanSignupProblem(_draft()..services.clear()), isNotNull);
      expect(craftsmanSignupProblem(_draft()..businessType = null), isNotNull);
    });
  });

  group('رسائل أخطاء الخلفية', () {
    test('الردود الفعلية اللي جرّبناها على devqa', () {
      expect(
        craftsmanSignupErrorMessage('Professional profile already exists for this user'),
        'عندك حساب مهني مسبقاً',
      );
      expect(craftsmanSignupErrorMessage('Minimum age to join is 20.'), contains('20'));
      expect(
        craftsmanSignupErrorMessage('A valid registration source is required.'),
        'اختر كيف عرفت عن صلّحلي',
      );
      expect(
        craftsmanSignupErrorMessage('An organization name is required for the organization registration source.'),
        'أدخل اسم المنظمة أو الجمعية',
      );
      expect(craftsmanSignupErrorMessage('Invalid business_type.'), 'حدد إذا كنت فرداً أو شركة');
      expect(
        craftsmanSignupErrorMessage('Missing required qualifications: has_team'),
        'معلومات المؤهلات ناقصة، راجع الخطوات',
      );
      expect(
        craftsmanSignupErrorMessage('At least one service must be selected. Service selection is mandatory.'),
        'اختر خدمة واحدة على الأقل',
      );
      expect(craftsmanSignupErrorMessage('Something else'), 'Something else');
    });
  });

  group('RemoteCraftsmanSignupRepository', () {
    test('بيرسل المدخل كنص JSON ويضيف دور المهني بعد النجاح', () async {
      final gw = _FakeGateway({'professional': '{}', 'error': null});
      await RemoteCraftsmanSignupRepository(gw).submit(_draft());
      final create = gw.calls.firstWhere((c) => c.$1.contains('CreateProfessionalSecure'));
      final sent = jsonDecode(create.$2['input'] as String) as Map<String, dynamic>;
      expect(sent['user_id'], 'u1');
      expect(sent['whatsapp_number'], '+963111111111');
      final role = gw.calls.last;
      expect((role.$2['input'] as Map)['roles'], ['customer', 'professional']);
    });

    test('ما بيضيف الدور إذا موجود', () async {
      final gw = _FakeGateway({'professional': '{}', 'error': null}, roles: ['customer', 'professional']);
      await RemoteCraftsmanSignupRepository(gw).submit(_draft());
      expect(gw.calls.where((c) => c.$1.contains('UpdateUser')), isEmpty);
    });

    test('خطأ الخلفية بيتحول لرسالة عربية وما بيضيف دور', () async {
      final gw = _FakeGateway({
        'professional': null,
        'error': 'Professional profile already exists for this user',
      });
      await expectLater(
        RemoteCraftsmanSignupRepository(gw).submit(_draft()),
        throwsA(
          isA<BackendException>().having((e) => e.message, 'message', 'عندك حساب مهني مسبقاً'),
        ),
      );
      expect(gw.calls.where((c) => c.$1.contains('UpdateUser')), isEmpty);
    });

    test('مسودة ناقصة ما بتوصل للشبكة', () async {
      final gw = _FakeGateway({'professional': '{}', 'error': null});
      await expectLater(
        RemoteCraftsmanSignupRepository(gw).submit(_draft()..age = '10'),
        throwsA(isA<BackendException>()),
      );
      expect(gw.calls, isEmpty);
    });
  });

  group('CraftsmanSignupCubit', () {
    test('نجاح', () async {
      final cubit = CraftsmanSignupCubit(const FakeCraftsmanSignupRepository());
      await cubit.submit(_draft());
      expect(cubit.state.status, SignupStatus.success);
    });

    test('فشل بيحمل رسالة الخلفية', () async {
      final gw = _FakeGateway({'professional': null, 'error': 'Minimum age to join is 20.'});
      final cubit = CraftsmanSignupCubit(RemoteCraftsmanSignupRepository(gw));
      await cubit.submit(_draft());
      expect(cubit.state.status, SignupStatus.failure);
      expect(cubit.state.error, contains('20'));
    });
  });
}
