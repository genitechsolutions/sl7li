/// مستندات GraphQL لتعديل الملف المهني.
class GqlProfessionalProfile {
  GqlProfessionalProfile._();

  static const update = r'''
mutation UpdateProfessionalSecure($input: AWSJSON!) {
  updateProfessionalSecure(input: $input) {
    professional
    error
  }
}''';
}
