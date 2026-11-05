/// مستندات GraphQL لتفاصيل العرض وتتبّع التفاعل.
class GqlOfferDetails {
  const GqlOfferDetails._();

  static const getOfferDetails = r'''
query GetOfferDetails($offerId: String!) {
  getOfferDetails(offerId: $offerId) {
    offer
    error
  }
}''';

  static const trackOfferDetailView = r'''
mutation TrackOfferDetailView($offerId: String!) {
  trackOfferDetailView(offerId: $offerId) {
    success
    error
  }
}''';

  static const trackOfferWhatsAppClick = r'''
mutation TrackOfferWhatsAppClick($offerId: String!) {
  trackOfferWhatsAppClick(offerId: $offerId) {
    success
    error
  }
}''';

  static const trackOfferRelatedQuoteRequest = r'''
mutation TrackOfferRelatedQuoteRequest($offerId: String!) {
  trackOfferRelatedQuoteRequest(offerId: $offerId) {
    success
    error
  }
}''';
}
