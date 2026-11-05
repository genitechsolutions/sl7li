/// مستندات GraphQL لتسجيل المهني.
class GqlCraftsmanSignup {
  const GqlCraftsmanSignup._();

  static const createProfessional = r'''
mutation CreateProfessionalSecure($input: AWSJSON!) {
  createProfessionalSecure(input: $input) {
    professional
    error
  }
}''';
}
