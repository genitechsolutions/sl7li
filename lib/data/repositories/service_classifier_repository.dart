import '../../core/backend/gql_service_classifier.dart';
import '../../core/backend/graphql_gateway.dart';
import '../../core/backend/json_utils.dart';
import 'craftsman_signup_repository.dart';

/// نتيجة التصنيف التلقائي: كود الخدمة/التخصص للخلفية + اسمهم بالعربي للعرض.
class ServiceClassification {
  const ServiceClassification({
    required this.serviceId,
    required this.serviceLabel,
    this.specialtyId,
    this.specialtyLabel,
  });

  final String serviceId;
  final String serviceLabel;
  final String? specialtyId;
  final String? specialtyLabel;
}

abstract class ServiceClassifier {
  /// null إذا الوصف ما انفهم أو الخدمة اسمها مجهول؛ بيرمي لو فشل الاتصال.
  Future<ServiceClassification?> classify(String description);
}

/// وضع fake: دايماً بيفشل (متل التصميم).
class FakeServiceClassifier implements ServiceClassifier {
  const FakeServiceClassifier();

  @override
  Future<ServiceClassification?> classify(String description) async => null;
}

class RemoteServiceClassifier implements ServiceClassifier {
  const RemoteServiceClassifier(this._gateway);

  final GraphQlGateway _gateway;

  @override
  Future<ServiceClassification?> classify(String description) async {
    final data = await _gateway.run(
      GqlServiceClassifier.analyze,
      variables: {'userInput': description, 'countryCode': 'syria'},
      guest: true,
    );
    return classificationFromJson(asMap(data['analyzeServiceRequest']));
  }
}

const _extraServiceLabels = {'carpentry': 'النجارة', 'construction': 'البناء'};

final _serviceLabels = {
  for (final e in craftsmanServiceIds.entries) e.value: e.key,
  ..._extraServiceLabels,
};

final _specialtyLabels = {for (final e in craftsmanSpecialtyIds.entries) e.value: e.key};

/// ناتج analyzeServiceRequest ← نتيجة للواجهة، أو null إذا غير مصنّف/اسمه العربي مجهول.
ServiceClassification? classificationFromJson(Map<String, dynamic> j) {
  final id = '${j['primaryService'] ?? ''}';
  final confidence = (j['confidence'] as num?)?.toDouble() ?? 0;
  final label = _serviceLabels[id];
  if (id.isEmpty || id == 'unspecified' || confidence < 0.5 || label == null) return null;
  final specialties = (j['suggestedSpecialties'] as List?)?.map((e) => '$e') ?? const <String>[];
  final specialtyId = specialties.where(_specialtyLabels.containsKey).firstOrNull;
  return ServiceClassification(
    serviceId: id,
    serviceLabel: label,
    specialtyId: specialtyId,
    specialtyLabel: specialtyId == null ? null : _specialtyLabels[specialtyId],
  );
}

/// كود الخدمة للخلفية من اسمها العربي (لو اختارها المستخدم يدوي).
String? serviceIdForLabel(String? label) => craftsmanServiceIds[label];
