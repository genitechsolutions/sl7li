/// مستندات الصفحة العامة للمهني (عامة؛ بتشتغل بتسجيل دخول أو API key).
class GqlPublicProfile {
  const GqlPublicProfile._();

  static const getPage = r'''
query GetProfessionalPublicPageSecure($userId: String!) {
  getProfessionalPublicPageSecure(userId: $userId) {
    professional
    reviews
    reviewsTruncated
    error
  }
}''';

  static const listOffers = r'''
query ListProfessionalPublicOffers($professionalId: String!, $limit: Int, $nextToken: String) {
  listProfessionalPublicOffers(professionalId: $professionalId, limit: $limit, nextToken: $nextToken) {
    items
    nextToken
    error
  }
}''';
}
