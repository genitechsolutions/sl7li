/// مستندات GraphQL لتصنيف الطلب تلقائياً.
class GqlServiceClassifier {
  const GqlServiceClassifier._();

  static const analyze = r'''
query AnalyzeServiceRequest($userInput: String!, $countryCode: String) {
  analyzeServiceRequest(userInput: $userInput, countryCode: $countryCode) {
    confidence
    primaryService
    category
    reasoning
    alternativeServices
    suggestedSpecialties
  }
}''';
}
