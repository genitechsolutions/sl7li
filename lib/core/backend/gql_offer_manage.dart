/// مستندات إدارة عروض المهني (تعديل / إيقاف-تفعيل / حذف).
class GqlOfferManage {
  const GqlOfferManage._();

  static const update = r'''
mutation UpdateOfferSecure($input: AWSJSON!) {
  updateOfferSecure(input: $input) {
    offer
    error
  }
}''';

  static const toggle = r'''
mutation ToggleOfferStatusSecure($offerId: String!) {
  toggleOfferStatusSecure(offerId: $offerId) {
    offer
    error
  }
}''';

  static const delete = r'''
mutation DeleteOfferSecure($offerId: String!) {
  deleteOfferSecure(offerId: $offerId) {
    offer
    error
  }
}''';
}
